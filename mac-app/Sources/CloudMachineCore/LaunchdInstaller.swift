import Foundation

/// Generates `.plist` files with the path to the compiled `cloudmachine-agent`
/// binary substituted in and installs them as LaunchAgents (the logged-in
/// user's session) - generically installs EVERY `*.plist.template` template
/// found in `launchd/` (currently `verify-watchdog` and `archive-watchdog`).
/// The removed earlier network NFS mount architecture additionally had
/// templates for mount/backup/quota here, which went away with it.
public enum LaunchdInstaller {
  public static var launchAgentsDir: URL {
    FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents")
  }

  /// Process name of the interface - the binary in `Contents/MacOS`, not the bundle.
  static let appProcessName = "CloudMachine.app/Contents/MacOS/CloudMachine"

  /// Closes the running interface so that launchd can start a NEW one.
  ///
  /// Politely first (`osascript quit`), so the app has time to clean up; only
  /// then forcefully. The interface does not make backups - the agents do - so
  /// killing it interrupts nothing.
  static func terminateRunningApp() async {
    let running = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", appProcessName])
    guard running?.succeeded == true,
      !(running?.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    else { return }

    CMLogger.log(
      "Agent installation: closing the running interface so it comes up on the new binary")
    _ = try? await ProcessRunner.run(
      "/usr/bin/osascript", ["-e", "quit app \"CloudMachine\""], timeout: 30)

    // Give it a moment to close cleanly, then check and finish it off.
    for _ in 0..<10 {
      try? await Task.sleep(nanoseconds: 500_000_000)
      let still = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", appProcessName])
      let alive =
        still?.succeeded == true
        && !(still?.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
      if !alive { return }
    }
    CMLogger.log(
      "Agent installation: the interface did not close by itself - terminating it forcefully")
    _ = try? await ProcessRunner.run("/usr/bin/pkill", ["-f", appProcessName], timeout: 30)
  }

  public static func install() async -> CMActionResult {
    // So that the commands from the documentation work from the terminal
    // instead of ending in "command not found" - the binary sits inside the
    // app bundle.
    CMTooling.linkCommandIntoPath()

    // Installation reloads the agents, including the one holding the mount.
    // Doing that with the image attached pulls the floor out from under it
    // mid-way - and detaching is a write that still has to reach the Drive. I
    // made this mistake three times in a row, so we no longer rely on
    // remembering it.
    if BackupImageService.isAttached {
      // A dead image (see `ImageProbe`) cannot be detached politely -
      // `hdiutil detach` without `-force` refuses, and the installation would
      // get stuck on exactly the state it is meant to fix.
      // ONLY `.dead`, not `!isUsable`. `.unknown` is not "usable" either, but
      // it means "I do not know" - and `detach -force` on a device that may be
      // alive abandons writes waiting to be uploaded to the Drive. Since
      // 26.09.2026 `.unknown` is REACHABLE here (the readability probe has a
      // time limit and, once it is exceeded, returns exactly this state), so
      // the difference is no longer theoretical. Without `-force`,
      // `hdiutil detach` simply refuses, the installation aborts with a
      // message and nobody loses data.
      var force = false
      if case .dead = await BackupImageService.attachment() { force = true }
      CMLogger.log(
        "Agent installation: detaching the image first\(force ? " (dead - forcefully)" : "") and waiting for the upload"
      )
      let detached = await BackupImageService.detach(force: force)
      CMLogger.log("Agent installation: \(detached.message)")
      if !detached.succeeded {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "The image was not detached before reloading the agents - aborting, so as not to lose data waiting in the buffer.\n%@",
            detached.message))
      }
    }

    guard let templatesDir = CMPaths.launchdTemplatesDir else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not find the launchd/ directory with templates."))
    }
    guard let resolvedAgentBin = CMPaths.agentBinaryPath else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Could not find the compiled cloudmachine-agent binary."))
    }
    // We ABORT, not warn. Previously a failure to stash the binary ended with
    // a "WARNING" entry in the log and the installation being completed -
    // launchd got a path into `.build/`, which the next `swift build` or `git
    // clean` deletes from under the running agents. An agent that disappears
    // is a backup that stops being made, and the only trace is a log line
    // nobody looks at. An installation without a stable binary is worse than
    // no installation, because it looks successful.
    let agentBin: URL
    do {
      agentBin = try stableAgentBinaryPath(resolvedFrom: resolvedAgentBin)
    } catch let error as NoStableBinary {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.",
          error.attemptedPath, error.fallbackPath))
    } catch {
      return CMActionResult(
        succeeded: false, message: L10n.tr("ABORTED: %@", error.localizedDescription))
    }

    try? FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)

    // Migration: an older version installed a separate agent
    // "com.renacode.cloudmachine.mount", long since replaced by
    // mount-watchdog - remove it if it is still loaded on someone's Mac.
    let oldMountPlist = launchAgentsDir.appendingPathComponent(
      "com.renacode.cloudmachine.mount.plist")
    if FileManager.default.fileExists(atPath: oldMountPlist.path) {
      CMLogger.log(
        "Removing the obsolete agent com.renacode.cloudmachine.mount (replaced by mount-watchdog)."
      )
      _ = try? await ProcessRunner.run("/bin/launchctl", ["unload", oldMountPlist.path])
      try? FileManager.default.removeItem(at: oldMountPlist)
    }

    // The interface has to be KILLED before launchd starts it again.
    //
    // The agent starts it via `open -a`, and `open -a` on a RUNNING application
    // only activates it - it does not replace it. The running process holds
    // the old, unlinked executable (the inode from before the bundle was
    // replaced) and keeps running on it until logout or a Mac restart.
    //
    // Observed 13 Sep 2026: after TWO deployments the menu bar still showed
    // "disk not attached", because the interface was from 12 Sep - process
    // inode 1129507643 versus 1129717794 on disk. The CLI version was already
    // new, so the CLI and the GUI said different things about the same
    // machine.
    await terminateRunningApp()

    guard
      let templates = try? FileManager.default.contentsOfDirectory(
        at: templatesDir, includingPropertiesForKeys: nil)
    else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Could not list the templates in %@.", templatesDir.path))
    }

    return installVerdict(
      await installAgents(
        templates: templates, into: launchAgentsDir, agentBin: agentBin, logDir: CMPaths.logDir))
  }

  /// What went in and what did NOT - with a reason, one per agent.
  ///
  /// Until 25.09.2026 we collected only `installedLabels`, and failures left no
  /// trace in the result: an unreadable template went through `continue`, a
  /// failed write through `try?`, and a failed `launchctl load` simply did not
  /// add the label.
  struct InstallOutcome: Equatable {
    struct Failure: Equatable {
      var label: String
      var reason: String
    }

    var installed: [String] = []
    var failed: [Failure] = []
  }

  /// Generates `.plist` files from the templates and reloads the agents,
  /// COLLECTING failures.
  ///
  /// Reading the template, writing and reloading are replaceable, because
  /// otherwise a KNOWN BAD sample cannot be injected - an unreadable template,
  /// a write without permission, `launchctl` refusing to load - and the defect
  /// was precisely in the handling of these three cases. The test substitutes
  /// them instead of writing to the real `~/Library/LaunchAgents` and reloading
  /// this machine's agents, i.e. instead of taking the working backup apart to
  /// check an error message.
  static func installAgents(
    templates: [URL],
    into destinationDir: URL,
    agentBin: URL,
    logDir: URL,
    read: @Sendable (URL) throws -> String = { try String(contentsOf: $0, encoding: .utf8) },
    write: @Sendable (String, URL) throws -> Void = {
      try $0.write(to: $1, atomically: true, encoding: .utf8)
    },
    reload: @Sendable (URL) async -> Bool = { await launchctlReload($0) },
    log: @Sendable (String) -> Void = { CMLogger.log($0) }
  ) async -> InstallOutcome {
    var outcome = InstallOutcome()
    for template in templates.filter({ $0.pathExtension == "template" }) {
      let destURL = destinationDir.appendingPathComponent(
        template.deletingPathExtension().lastPathComponent)
      let label = destURL.deletingPathExtension().lastPathComponent

      let templateText: String
      do {
        templateText = try read(template)
      } catch {
        // Previously: `guard ... else { continue }`. A template that could not
        // be read dropped out of the installation WITHOUT A TRACE - neither in
        // the log nor in the result - and `buffer-guard` is the only protection
        // of the disk on this machine.
        let reason = L10n.tr("could not read the template %@", template.lastPathComponent)
        outcome.failed.append(.init(label: label, reason: reason))
        log("NOT installed \(label): \(reason)")
        continue
      }

      var content = templateText.replacingOccurrences(of: "__CM_AGENT_BIN__", with: agentBin.path)
      content = content.replacingOccurrences(of: "__CM_LOG_DIR__", with: logDir.path)
      do {
        try write(content, destURL)
      } catch {
        // `continue` is ESSENTIAL here, not cosmetic. Previously the write went
        // through `try?` and after a failed write `launchctl load` ran on the
        // OLD .plist file, which still lies in ~/Library/LaunchAgents.
        // `launchctl` exited with code 0, the agent landed on the result list
        // and the installation reported success - with launchd running the
        // previous version, possibly pointing at a binary that no longer
        // exists. Success is then worse than failure, because nobody looks.
        let reason = L10n.tr(
          "could not write %@ (lack of space or permissions)", destURL.path)
        outcome.failed.append(.init(label: label, reason: reason))
        log("NOT installed \(label): \(reason) - NOT reloading, so as not to count the old one")
        continue
      }
      log("Generated \(destURL.path)")

      if await reload(destURL) {
        outcome.installed.append(label)
        log("Loaded \(label) via launchctl")
      } else {
        let reason = L10n.tr("launchctl load refused to load %@", destURL.lastPathComponent)
        outcome.failed.append(.init(label: label, reason: reason))
        log("NOT loaded \(label): \(reason)")
      }
    }
    return outcome
  }

  /// Verdict of the whole installation - pure, so it can be tested.
  ///
  /// ONE successful agent was enough for `succeeded: true` and for the message
  /// "Installed agents: ...", which listed only the successful ones. The
  /// observed result: `buffer-guard` did not load, the installer reported
  /// success, the only protection of the disk was not working and nobody knew
  /// - and nobody who does not know the list by heart sees a name missing from
  /// it.
  ///
  /// The same reason as with `stableAgentBinaryPath`: an incomplete
  /// installation is worse than none, because it looks successful.
  static func installVerdict(_ outcome: InstallOutcome) -> CMActionResult {
    guard outcome.failed.isEmpty else {
      let list = outcome.failed.map { "  - \($0.label): \($0.reason)" }.joined(separator: "\n")
      let wentIn =
        outcome.installed.isEmpty
        ? L10n.tr("NOT A SINGLE agent was loaded.")
        : L10n.tr("Only these went in: %@.", outcome.installed.joined(separator: ", "))
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (buffer-guard watches the disk, backup-health reports failures). Fix the cause and repeat the installation.",
          "\(outcome.failed.count)", "\(outcome.failed.count + outcome.installed.count)", list,
          wentIn))
    }
    guard !outcome.installed.isEmpty else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not load any launchd agent."))
    }
    return CMActionResult(
      succeeded: true,
      message: L10n.tr("Installed agents: %@", outcome.installed.joined(separator: ", ")))
  }

  /// Reloading one agent: `unload` (it may not be loaded - that is why we
  /// ignore the result), then `load -w`. `true` only when `load` SUCCEEDED.
  private static func launchctlReload(_ plist: URL) async -> Bool {
    _ = try? await ProcessRunner.run("/bin/launchctl", ["unload", plist.path])
    let loaded = try? await ProcessRunner.run("/bin/launchctl", ["load", "-w", plist.path])
    return loaded?.succeeded == true
  }

  /// Thrown when the binary cannot be put in a stable location. The caller
  /// must then ABORT the installation, not complete it with a worse variant.
  struct NoStableBinary: Error {
    var attemptedPath: String
    var fallbackPath: String
  }

  /// If `resolved` points inside the `.build/` of a development checkout
  /// (case 3 in `CMPaths.agentBinaryPath` - GUI/CLI started via `swift run` in
  /// the repo tree), the live launchd automation would point DIRECTLY at a
  /// file that every subsequent `swift build`/`git clean` in the repo can
  /// replace or delete (observed for real: that was exactly the path the
  /// production watchdogs of this installation ran from). So we copy the
  /// binary ONCE, on every installation, to a stable location outside the
  /// repo tree - launchd points at THAT copy. A binary packaged in the .app
  /// (case 1/2) is already stable in itself and needs no copying.
  ///
  /// Throws `NoStableBinary` when that fails - see `install()`.
  private static func stableAgentBinaryPath(resolvedFrom resolved: URL) throws -> URL {
    guard resolved.path.contains("/.build/") else { return resolved }
    let stableDir = CMPaths.appSupportDir.appendingPathComponent("bin")
    try? FileManager.default.createDirectory(at: stableDir, withIntermediateDirectories: true)
    let stableBin = stableDir.appendingPathComponent("cloudmachine-agent")

    // We copy ALONGSIDE, and replace the old copy only after a successful
    // write. The previous version deleted the old file BEFORE copying, so a
    // failed copy left the installation without a stable binary at all.
    // l10n-polish-ok: staging file name on disk; "nowy" means "new".
    let staging = stableDir.appendingPathComponent("cloudmachine-agent.nowy")
    try? FileManager.default.removeItem(at: staging)
    guard (try? FileManager.default.copyItem(at: resolved, to: staging)) != nil else {
      throw NoStableBinary(attemptedPath: stableBin.path, fallbackPath: resolved.path)
    }
    try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: staging.path)
    guard
      (try? FileManager.default.replaceItemAt(stableBin, withItemAt: staging)) != nil
        || (try? FileManager.default.moveItem(at: staging, to: stableBin)) != nil
    else {
      try? FileManager.default.removeItem(at: staging)
      throw NoStableBinary(attemptedPath: stableBin.path, fallbackPath: resolved.path)
    }
    return stableBin
  }

  public static func isInstalled(label: String) async -> Bool {
    guard let result = try? await ProcessRunner.run("/bin/launchctl", ["list"]) else {
      return false
    }
    return result.stdout.contains(label)
  }
}
