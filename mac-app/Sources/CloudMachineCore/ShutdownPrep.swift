import Foundation

/// Preparing the Mac for a restart: pause the backup, detach the image, wait
/// until everything has reached Drive - the `prepare-shutdown` command and the
/// "Prepare for restart" button in the menu bar.
///
/// The preparation also leaves a marker, because the `gdrive-attach` agent
/// runs every 900 s and attaches whatever image it finds detached. Without the
/// marker it undid the preparation by itself: Time Machine got its destination
/// back, wrote into the buffer again, and the restart a few minutes later left
/// those writes local only - the very backlog that the preparation is there
/// to prevent (`UploadDrain`, 01.10.2026).
///
/// The marker holds the boot time and the time of the preparation. It blocks
/// the agent only in the same boot session (after the restart the agents bring
/// the image up as usual) and only for `window`: a preparation without a
/// restart must not leave Time Machine without a destination for good. An
/// explicit attach from the window clears it.
public enum ShutdownPrep {

  /// 30 min: enough to close programs and restart, short enough that a
  /// forgotten preparation costs at most two missed hourly backups.
  public static let window: TimeInterval = 1800

  public static var markerURL: URL {
    CMPaths.appSupportDir.appendingPathComponent("shutdown-prepared")
  }

  public struct Marker: Equatable {
    public var bootTime: TimeInterval
    public var preparedAt: TimeInterval

    public var text: String { "\(Int(bootTime)) \(Int(preparedAt))" }

    public init(bootTime: TimeInterval, preparedAt: TimeInterval) {
      self.bootTime = bootTime
      self.preparedAt = preparedAt
    }

    public init?(text: String) {
      let parts = text.split(whereSeparator: \.isWhitespace).compactMap { TimeInterval($0) }
      guard parts.count == 2 else { return nil }
      self.init(bootTime: parts[0], preparedAt: parts[1])
    }
  }

  /// Whether the marker still holds the agent back. The boot time is compared
  /// with a second of slack: `kern.boottime` is read with microseconds and
  /// stored in whole seconds.
  public static func isActive(_ marker: Marker?, bootTime: TimeInterval?, now: TimeInterval) -> Bool
  {
    guard let marker, let bootTime else { return false }
    guard abs(marker.bootTime - bootTime) <= 1 else { return false }
    let age = now - marker.preparedAt
    return age >= 0 && age < window
  }

  /// The marker as it stands on disk, `nil` when there is none (or it is unreadable).
  public static func readMarker() -> Marker? {
    guard let text = try? String(contentsOf: markerURL, encoding: .utf8) else { return nil }
    return Marker(text: text)
  }

  public static func holdsAttach(now: Date = Date()) -> Bool {
    isActive(readMarker(), bootTime: bootTime(), now: now.timeIntervalSince1970)
  }

  public static func clear() {
    try? FileManager.default.removeItem(at: markerURL)
  }

  /// When the Mac was started (`kern.boottime`), seconds since 1970.
  public static func bootTime() -> TimeInterval? {
    var tv = timeval()
    var size = MemoryLayout<timeval>.stride
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    guard sysctl(&mib, 2, &tv, &size, nil, 0) == 0, tv.tv_sec > 0 else { return nil }
    return TimeInterval(tv.tv_sec) + TimeInterval(tv.tv_usec) / 1_000_000
  }

  /// The whole preparation. `progress` gets the steps as they start (the CLI
  /// prints them; the app shows its own busy label).
  public static func perform(progress: (String) -> Void = { _ in }) async -> CMActionResult {
    // The order is not arbitrary. First Time Machine stops adding new writes,
    // only then do we detach the image - otherwise the detach would fight with
    // the running backup.
    if await TimeMachineStatus.isRunning() {
      progress(L10n.tr("Pausing the backup..."))
      _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 120)
      try? await Task.sleep(nanoseconds: 3_000_000_000)
    }

    progress(L10n.tr("Detaching the image and waiting for the upload..."))
    let detached = await BackupImageService.detach()
    guard detached.succeeded else {
      return CMActionResult(
        succeeded: false,
        message: detached.message + "\n\n"
          + L10n.tr("Do NOT restart yet - the buffer holds data that has not reached Drive."))
    }

    // Written only after a successful detach: a marker after a failure would
    // keep the agent from repairing a half-detached state.
    var written = false
    if let boot = bootTime() {
      let marker = Marker(bootTime: boot, preparedAt: Date().timeIntervalSince1970)
      try? FileManager.default.createDirectory(
        at: markerURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      written = (try? marker.text.write(to: markerURL, atomically: true, encoding: .utf8)) != nil
    }
    let minutes = "\(Int(window / 60))"
    return CMActionResult(
      succeeded: true,
      message: detached.message + "\n\n"
        + (written
          ? L10n.tr(
            "Safe to restart. The image stays detached for %@ min; after startup the agents will bring up the buffer and attach the image themselves.",
            minutes)
          : L10n.tr(
            "Safe to restart now - but the image could not be held detached, so the agent may attach it again within 15 min. Restart soon. After startup the agents will bring up the buffer and attach the image themselves."
          )))
  }
}
