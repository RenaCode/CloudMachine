import Foundation

/// `prepare-shutdown`: stops the machine cleanly before the Mac restarts.
///
/// What it protects: a band Samba is halfway through writing, and rclone's
/// list of what is still to upload. Both survive a clean guest shutdown -
/// systemd stops smbd, punchfs and rclone in order, and rclone keeps unsent
/// bands in its cache on the machine's disk and uploads them after the next
/// start. A machine killed together with the Mac gets no such order.
///
/// So: stop the backup, give the upload a while to drain (a shorter backlog
/// after the restart, nothing more - the cache is what keeps the data), then
/// `limactl stop`. A backlog left after the wait is reported, not a reason to
/// refuse: refusing would leave the person to restart anyway, uncleanly.
///
/// The machine then stays stopped until the next login (`vm-start` runs at
/// load) or until someone starts it (the app's Start button, `vm-setup`).
public enum VMShutdown {
  /// How long to wait for the upload before stopping the machine.
  public static let drainTimeout: TimeInterval = 30 * 60
  static let pollInterval: TimeInterval = 15

  public static func perform(
    drainTimeout: TimeInterval = drainTimeout,
    progress: @Sendable (String) -> Void = { _ in }
  ) async -> CMActionResult {
    let status: String?
    do {
      status = try await VMLayout.instanceStatus()
    } catch {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Could not ask Lima about the machine: %@", error.localizedDescription))
    }
    guard status == "Running" else {
      return CMActionResult(
        succeeded: true,
        message: L10n.tr(
          "The machine %@ is not running - nothing to prepare.", VMLayout.instanceName))
    }

    // 1. No new writes. A backup that does not stop is a reason to stop here:
    //    stopping the machine under it is what this command exists to avoid.
    if await TimeMachineStatus.runningState() != false {
      progress(L10n.tr("Stopping the Time Machine backup..."))
      _ = await TimeMachineStatus.control("stopbackup")
      var stopped = false
      for _ in 0..<24 {
        if await TimeMachineStatus.runningState() == false {
          stopped = true
          break
        }
        try? await Task.sleep(nanoseconds: 5_000_000_000)
      }
      guard stopped else {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment."
          ))
      }
    }

    // 2. Let the upload drain for a while.
    progress(
      L10n.tr(
        "Waiting for the upload to Google Drive (at most %@ min)...", "\(Int(drainTimeout / 60))"))
    let deadline = Date().addingTimeInterval(drainTimeout)
    var unsent: Int64?
    while true {
      unsent = await VMLayout.currentReading()?.buffer.unsentBytes
      if unsent == 0 || Date() >= deadline { break }
      if let unsent {
        progress(L10n.tr("Still to upload: %@ GiB", "\(unsent / VMGuard.gib)"))
      }
      try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
    }

    // 3. A clean guest shutdown.
    progress(L10n.tr("Stopping the machine %@...", VMLayout.instanceName))
    let stopped = try? await VMLayout.limactl(["stop", VMLayout.instanceName], timeout: 300)
    guard stopped?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("limactl stop failed: %@", VMLayout.errorTail(stopped)))
    }
    CMLogger.log(
      "prepare-shutdown: machine \(VMLayout.instanceName) stopped, unsent \(unsent.map { "\($0 / VMGuard.gib) GiB" } ?? "unknown")"
    )
    return CMActionResult(succeeded: true, message: outcomeMessage(unsentBytes: unsent))
  }

  /// What the person reads after the machine stopped. Pure, so every branch
  /// is tested: a backlog that is unknown must not read as "all uploaded".
  static func outcomeMessage(unsentBytes: Int64?) -> String {
    switch unsentBytes {
    case .some(0):
      return L10n.tr(
        "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login."
      )
    case .some(let bytes):
      return L10n.tr(
        "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.",
        "\(max(1, bytes / VMGuard.gib))")
    case .none:
      return L10n.tr(
        "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted."
      )
    }
  }
}
