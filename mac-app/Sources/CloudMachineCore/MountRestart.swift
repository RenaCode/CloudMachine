import Foundation

/// Restarts the Google Drive mount without restarting the Mac - the way out of
/// a mount that predates the private socket (`DriveBufferService
/// .legacyPortOpen`). An upgrade deliberately leaves the mount running, and
/// "prepare-shutdown, then restart the Mac" is a price few pay soon.
///
/// It is the shutdown path, in the same order, with a start at the end:
///
/// 1. Refuse while Time Machine is backing up, or when that is not known, or
///    when the mount is not up.
/// 2. Detach the image and wait until everything has reached Drive - the same
///    `detach` as `prepare-shutdown`, whose verdict counts abandoned bands
///    too. If the image was not attached, drain the queue all the same. Any
///    doubt stops here, with the mount untouched.
/// 3. `launchctl kill SIGTERM` the mount. rclone unmounts and exits, and
///    launchd's `KeepAlive` starts `mount-drive` again - the new one, on the
///    socket. Not `bootout`: that unloads the job, and a failed `bootstrap`
///    after it would leave no mount and no agent to bring one back. Not
///    `kickstart -k`, which does not promise SIGTERM. If launchd cannot spawn
///    the new binary (`AgentRepair`), the job is reloaded once it has exited.
/// 4. Wait for the new mount on the private socket, then attach the image.
///
/// The whole run holds the image lock, so the attach agent cannot attach the
/// image between steps 2 and 3, under a mount about to be stopped.
public enum MountRestart {

  /// Why the restart must not start now; `nil` = it may.
  public static func refusal(backupRunning: Bool?, mounted: Bool?) -> String? {
    switch backupRunning {
    case .some(true):
      return L10n.tr(
        "Time Machine is backing up right now - the mount was NOT restarted. Try again when the backup has finished."
      )
    case .none:
      return L10n.tr(
        "Could not tell whether Time Machine is backing up (tmutil did not answer) - the mount was NOT restarted."
      )
    case .some(false):
      break
    }
    guard mounted == true else {
      return L10n.tr(
        "The Google Drive mount is not running (or its state is unknown) - there is nothing to restart. The agents start it by themselves."
      )
    }
    return nil
  }

  /// The steps, replaceable so the order and every early exit can be tested
  /// without launchd, hdiutil or rclone.
  struct Steps {
    var backupRunning: () async -> Bool?
    var mounted: () -> Bool?
    /// Detaches the image (or drains the queue when it is not attached) and
    /// says whether everything reached Drive.
    var detachAndDrain: () async -> CMActionResult
    /// Stops the running mount. `false` = it could not be stopped.
    var stopMount: () async -> Bool
    /// Waits for the new mount on the private socket.
    var waitForNewMount: () async -> Bool
    var attach: () async -> CMActionResult
  }

  static func run(_ steps: Steps) async -> CMActionResult {
    if let reason = refusal(backupRunning: await steps.backupRunning(), mounted: steps.mounted()) {
      return CMActionResult(succeeded: false, message: reason)
    }

    let drained = await steps.detachAndDrain()
    guard drained.succeeded else {
      // The mount was not touched. Put the image back where it was, so the
      // refusal does not leave Time Machine without a destination.
      let reattached = await steps.attach()
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The mount was NOT restarted: %@\nImage: %@", drained.message, reattached.message))
    }

    guard await steps.stopMount() else {
      let reattached = await steps.attach()
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not stop the mount (launchctl refused) - nothing was restarted. Image: %@",
          reattached.message))
    }

    guard await steps.waitForNewMount() else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The mount was stopped, but did not come back on the private socket in time. The agents keep trying (backup-health reloads one launchd cannot start). Check: cloudmachine-agent drive-status; if it stays down, restart the Mac."
        ))
    }

    let attached = await steps.attach()
    guard attached.succeeded else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The mount runs on the private socket now, but the image did not attach: %@ The attach agent retries every 15 minutes.",
          attached.message))
    }
    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "The mount was restarted and now listens only on the private socket. The image is attached again."
      ))
  }

  // MARK: - Live

  static let mountAgent = "gdrive-buffer"
  /// How long the new mount may take to come up. After a restart with an
  /// empty queue it is seconds; `KeepAlive` waits `ThrottleInterval` (30 s)
  /// before a respawn, and a respawn launchd refuses costs one more cycle.
  static let newMountTimeout: TimeInterval = 300

  public static func perform() async -> CMActionResult {
    // A restart of the mount ends with the image attached - a preparation for
    // a Mac restart (`ShutdownPrep`) no longer applies.
    ShutdownPrep.clear()
    return await withCMLock(BackupImageService.lockName) { await run(live) }
      ?? CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Another operation on the image is in progress - the mount was NOT restarted. Try again in a moment."
        ),
        didNotRun: true)
  }

  static var live: Steps {
    Steps(
      backupRunning: { await TimeMachineStatus.runningState() },
      mounted: { DriveBufferService.mountedState() },
      detachAndDrain: {
        switch BackupImageService.attachedState() {
        case .some(true):
          return await BackupImageService.detachLocked()
        case .some(false):
          CMLogger.log(
            BackupImageService.expiryLogLine(await DriveBufferService.expireQueuedUploads()))
          return BackupImageService.detachVerdict(
            settled: await DriveBufferService.statsWhenIdle(timeout: 600))
        case .none:
          return CMActionResult(
            succeeded: false,
            message: L10n.tr(
              "Could not read the mount table - it is UNKNOWN whether the image is attached."))
        }
      },
      stopMount: {
        CMLogger.log("Restarting the Drive mount: SIGTERM to \(mountAgent)")
        let result = try? await ProcessRunner.run(
          "/bin/launchctl",
          ["kill", "SIGTERM", "gui/\(getuid())/\(AgentRepair.prefix)\(mountAgent)"], timeout: 30)
        return result?.succeeded == true
      },
      waitForNewMount: { await waitForNewMount() },
      attach: {
        let ready = await BufferReadiness.wait(
          sleep: { try? await Task.sleep(nanoseconds: UInt64($0 * 1_000_000_000)) },
          probe: {
            BufferReadiness.isReady(
              mounted: DriveBufferService.isMounted, imageVisible: BackupImageService.exists)
          })
        guard ready else {
          return CMActionResult(
            succeeded: false,
            message: L10n.tr(
              "The buffer did not come up within %@ min - not attaching the image.",
              "\(Int(BufferReadiness.defaultTimeout / 60))"))
        }
        return await BackupImageService.attachLocked()
      })
  }

  /// Polls for the new mount: mounted, and answering on the private socket.
  /// Once the old rclone has gone, a job launchd cannot spawn (a replaced
  /// app bundle - see `AgentRepair`) is reloaded; the mount is down by then,
  /// so the reload costs nothing.
  static func waitForNewMount() async -> Bool {
    let deadline = Date().addingTimeInterval(newMountTimeout)
    var repaired = false
    while Date() < deadline {
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      if DriveBufferService.mountedState() == true,
        DriveBufferService.socketAnswers(DriveBufferService.rcSocket.path)
      {
        CMLogger.log("Drive mount is back, on the private socket")
        return true
      }
      if !repaired, let output = await AgentRepair.printOutput(label: mountAgent),
        AgentRepair.cannotStart(printOutput: output)
      {
        repaired = true
        CMLogger.log("\(mountAgent) cannot start after the restart - reloading it")
        await AgentRepair.reload(mountAgent)
      }
    }
    return false
  }
}
