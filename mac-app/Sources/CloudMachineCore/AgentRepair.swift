import Foundation

/// Keeps the launchd agents startable after the app bundle is replaced.
///
/// Replacing `/Applications/CloudMachine.app` - by `brew upgrade`, or by hand -
/// leaves the loaded jobs pointing at the old code signature of that path.
/// From then on launchd refuses to start them: `job state = spawn failed`,
/// `last exit reason = OS_REASON_CODESIGNING`, and nothing in any log. Seen on
/// 6 Oct 2026 after the 1.3.0 -> 1.3.1 upgrade: the backup watchdog stopped
/// running, which looks exactly like a quiet, healthy day. Only `bootout` +
/// `bootstrap` clears it.
///
/// Three moments:
/// - after a version change, the agents that are safe to restart are reloaded
///   at once, so they run the new code;
/// - at any time, an agent that launchd failed to spawn is reloaded;
/// - always, the agents of the retired disk-image layout are removed
///   (`removeRetiredAgents`).
public enum AgentRepair {
  static let prefix = "com.renacode.cloudmachine."

  /// One-shot checks: reloading them only runs a check early.
  public static let safeToReload = ["backup-health", "vm-guard"]
  /// Every agent launchd should be able to start. `vm-start` is not reloaded
  /// after an upgrade: a reload starts the machine, and someone may have
  /// stopped it on purpose (`prepare-shutdown`). It is reloaded only when
  /// launchd cannot start it at all.
  public static let all = safeToReload + ["vm-start"]

  /// Agents of the disk-image layout (an rclone mount on the Mac, the image
  /// attached in /Volumes/CloudMachine, the buffer guard) and the even older
  /// `mount` agent. Their commands no longer exist in this binary, so a
  /// loaded one only fails, over and over.
  public static let retired = ["gdrive-buffer", "gdrive-attach", "buffer-guard", "mount"]

  // MARK: - Reading launchd

  /// Whether `launchctl print` output describes a job launchd cannot start.
  public static func cannotStart(printOutput: String) -> Bool {
    let lines = printOutput.split(separator: "\n").map {
      $0.trimmingCharacters(in: .whitespaces)
    }
    if lines.contains("job state = spawn failed") { return true }
    let running = lines.contains("state = running")
    return !running && lines.contains("last exit reason = OS_REASON_CODESIGNING")
  }

  static func printOutput(label: String) async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/bin/launchctl", ["print", "gui/\(getuid())/\(prefix)\(label)"], timeout: 15),
      result.succeeded
    else { return nil }
    return result.stdout
  }

  /// Agents that are loaded but cannot start. Not loaded = not listed:
  /// installing agents is a setup step, not a repair.
  public static func brokenAgents() async -> [String] {
    var broken: [String] = []
    for name in all {
      if let output = await printOutput(label: name), cannotStart(printOutput: output) {
        broken.append(name)
      }
    }
    return broken
  }

  // MARK: - Reloading

  static func plist(_ name: String) -> URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/LaunchAgents/\(prefix)\(name).plist")
  }

  /// `bootout` + `bootstrap`. `bootout` finishes asynchronously and a
  /// `bootstrap` right after it fails with error 5, so it is retried.
  @discardableResult
  static func reload(_ name: String) async -> Bool {
    let plist = plist(name)
    guard FileManager.default.fileExists(atPath: plist.path) else { return false }
    let domain = "gui/\(getuid())"
    _ = try? await ProcessRunner.run(
      "/bin/launchctl", ["bootout", "\(domain)/\(prefix)\(name)"], timeout: 30)
    for _ in 0..<10 {
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      if let result = try? await ProcessRunner.run(
        "/bin/launchctl", ["bootstrap", domain, plist.path], timeout: 30),
        result.succeeded
      {
        CMLogger.log("Reloaded launchd agent \(name)")
        return true
      }
    }
    CMLogger.log("Could not reload launchd agent \(name) - bootstrap kept failing")
    return false
  }

  /// Reloads every agent launchd cannot start. Returns the ones reloaded.
  @discardableResult
  public static func repairBroken() async -> [String] {
    var repaired: [String] = []
    for name in await brokenAgents() {
      CMLogger.log("launchd agent \(name) cannot start (spawn failed) - reloading")
      if await reload(name) { repaired.append(name) }
    }
    return repaired
  }

  // MARK: - The retired layout

  /// What removing the retired agents touches - replaceable, so the tests
  /// run the whole migration without launchd and without the real
  /// ~/Library/LaunchAgents.
  struct RetiredProbes: Sendable {
    var plistExists: @Sendable (String) -> Bool
    var isLoaded: @Sendable (String) async -> Bool
    var bootout: @Sendable (String) async -> Void
    var removePlist: @Sendable (String) -> Bool
    var leftovers: @Sendable () -> [String]
    var log: @Sendable (String) -> Void

    static let live = RetiredProbes(
      plistExists: { FileManager.default.fileExists(atPath: plist($0).path) },
      isLoaded: { await printOutput(label: $0) != nil },
      bootout: { name in
        _ = try? await ProcessRunner.run(
          "/bin/launchctl", ["bootout", "gui/\(getuid())/\(prefix)\(name)"], timeout: 30)
      },
      removePlist: { name in
        let url = plist(name)
        guard FileManager.default.fileExists(atPath: url.path) else { return true }
        return (try? FileManager.default.removeItem(at: url)) != nil
      },
      leftovers: { retiredLeftovers() },
      log: { CMLogger.log($0) })
  }

  /// Unloads and deletes the retired agents. Idempotent: an agent that is
  /// neither loaded nor on disk is skipped silently, so this runs on every
  /// launch and costs a few `launchctl print` calls. Nothing else is deleted -
  /// what the old layout left behind is only listed in the log, once, when
  /// an agent was actually removed.
  @discardableResult
  static func removeRetiredAgents(_ probes: RetiredProbes) async -> [String] {
    var removed: [String] = []
    for name in retired {
      let onDisk = probes.plistExists(name)
      let loaded = await probes.isLoaded(name)
      guard onDisk || loaded else { continue }
      if loaded { await probes.bootout(name) }
      if onDisk && !probes.removePlist(name) {
        probes.log("Retired launchd agent \(name): unloaded, but its plist could not be deleted")
        continue
      }
      probes.log("Removed the retired launchd agent \(name) (disk-image layout)")
      removed.append(name)
    }
    if !removed.isEmpty {
      for line in probes.leftovers() {
        probes.log("Left from the disk-image layout, remove by hand when no longer needed: \(line)")
      }
    }
    return removed
  }

  @discardableResult
  public static func removeRetiredAgents() async -> [String] {
    await removeRetiredAgents(.live)
  }

  /// What the disk-image layout may have left on this Mac. Listed, never
  /// deleted: the cache can hold bands that never reached Drive, and the old
  /// image on Drive is a backup someone may still want to restore from.
  static func retiredLeftovers(
    home: URL = FileManager.default.homeDirectoryForCurrentUser,
    mounted: [String] = mountedPaths(),
    exists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
  ) -> [String] {
    var lines: [String] = []
    for path in ["/Volumes/CloudMachine", home.appendingPathComponent(".cloudmachine/drive").path]
    where mounted.contains(path) {
      lines.append(
        "\(path) is still mounted - detach it (hdiutil detach / umount) before deleting anything")
    }
    for name in ["cache", "drive", "fuse", "run", "rclone.log", "rclone.log.1"] {
      let path = home.appendingPathComponent(".cloudmachine/\(name)").path
      if exists(path) { lines.append(path) }
    }
    let known = CMPaths.appSupportDir.appendingPathComponent("known-image").path
    if exists(known) { lines.append(known) }
    if exists("/usr/local/lib/libfuse-t.dylib") {
      lines.append("/usr/local/lib/libfuse-t.dylib (FUSE-T, only if nothing else uses it)")
    }
    lines.append(
      "\(DriveFolder.remoteName):\(DriveFolder.remoteRoot)/\(DriveFolder.name) on Google Drive (the old disk image; the machine uses \(VMLayout.remote))"
    )
    return lines
  }

  /// Mount points from the kernel's table, without waiting on any of them
  /// (`MNT_NOWAIT`): a dead FUSE mount must not hang this check.
  static func mountedPaths() -> [String] {
    let count = getfsstat(nil, 0, MNT_NOWAIT)
    guard count > 0 else { return [] }
    var buffer = [Darwin.statfs](repeating: Darwin.statfs(), count: Int(count))
    let size = Int32(MemoryLayout<Darwin.statfs>.stride * Int(count))
    let filled = getfsstat(&buffer, size, MNT_NOWAIT)
    guard filled > 0 else { return [] }
    return buffer.prefix(Int(filled)).map { entry in
      var mountPoint = entry.f_mntonname
      return withUnsafePointer(to: &mountPoint) {
        $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { String(cString: $0) }
      }
    }
  }

  // MARK: - After an upgrade

  static var stampFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("agents-version")
  }

  /// Decides whether the safe agents need a reload: the running app is a
  /// different build than the one that last checked. A missing stamp counts
  /// as different - the first launch of a version with this code is exactly
  /// the launch after an upgrade from one without it.
  public static func versionChanged(current: String, stamp: String?) -> Bool {
    current != stamp?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Called when the app starts: remove the retired layout's agents, after an
  /// upgrade reload the agents that are safe to restart, then repair any that
  /// cannot start. The reload is skipped for a build run outside a bundle
  /// (`swift run`), which has no version to compare.
  public static func afterLaunch() async {
    await removeRetiredAgents()
    guard let version = AppVersionReader.current() else { return }
    let current = version.summary
    let stamp = try? String(contentsOf: stampFile, encoding: .utf8)
    if versionChanged(current: current, stamp: stamp) {
      CMLogger.log("App version is now \(current) - reloading the launchd agents")
      for name in safeToReload where FileManager.default.fileExists(atPath: plist(name).path) {
        await reload(name)
      }
      try? current.write(to: stampFile, atomically: true, encoding: .utf8)
    }
    await repairBroken()
  }
}
