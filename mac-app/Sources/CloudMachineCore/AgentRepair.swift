import Foundation

/// Keeps the launchd agents startable after the app bundle is replaced.
///
/// Replacing `/Applications/CloudMachine.app` - by `brew upgrade`, or by hand -
/// leaves the loaded jobs pointing at the old code signature of that path.
/// From then on launchd refuses to start them: `job state = spawn failed`,
/// `last exit reason = OS_REASON_CODESIGNING`, and nothing in any log. Seen on
/// 6 Oct 2026 after the 1.3.0 -> 1.3.1 upgrade: the backup watchdog and the
/// image attach stopped running, which looks exactly like a quiet, healthy day.
/// Only `bootout` + `bootstrap` clears it.
///
/// Two moments:
/// - after a version change, the agents that are safe to restart are reloaded
///   at once, so they run the new code;
/// - at any time, an agent that launchd failed to spawn is reloaded. This is
///   what covers `gdrive-buffer`: restarting it while it runs would drop the
///   Google Drive mount, so it is left alone until it has actually died - and
///   then reloading costs nothing, because the mount is already gone.
public enum AgentRepair {
  static let prefix = "com.renacode.cloudmachine."

  /// Restarting these does not touch the mount (measured 26 Sep 2026; the
  /// mount lives in the rclone process of `gdrive-buffer`).
  public static let safeToReload = ["backup-health", "gdrive-attach", "buffer-guard"]
  /// Every agent that runs our binary.
  public static let all = ["gdrive-buffer"] + safeToReload

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

  /// Called when the app starts: after an upgrade, reload the agents that are
  /// safe to restart, then repair any that cannot start. Does nothing for a
  /// build run outside a bundle (`swift run`), which has no version to compare.
  public static func afterLaunch() async {
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
