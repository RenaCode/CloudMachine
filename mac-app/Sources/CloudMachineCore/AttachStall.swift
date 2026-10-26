import Foundation

/// The way out of an attach that `hdiutil` keeps turning away with "Resource
/// temporarily unavailable" - by restarting the Drive mount, which until now
/// only a restart of the Mac did.
///
/// 24-26 Oct 2026: the mount wedged during a backup, and from then on every
/// attach of the `gdrive-attach` agent (every 15-20 min, 5 `hdiutil` attempts
/// each) failed with EAGAIN for 26 h. rclone was idle (queue 0, nothing in
/// use) and answered about its queue, so neither "rclone busy" nor "rclone
/// does not answer" describes it - the only signal was the series of EAGAINs.
/// After the restart of the Mac a fresh rclone let the image attach within
/// minutes. 37 h without a backup.
///
/// The restart itself is `MountRestart` - the same path as the button in the
/// window, with all its refusals: not while Time Machine is backing up, not
/// before the queue has drained. This type only decides WHEN:
/// - a series: `minFailures` EAGAINs in a row, spanning at least
///   `minDuration`, in the same boot session - one or two refusals just after
///   a start-up are normal (26.10 08:27, a minute after rclone came up);
/// - at most one restart per `cooldown`: if a fresh rclone does not help, a
///   second one will not either, and restarting it hourly would only cut
///   the upload short.
public enum AttachStall {

  public static let minFailures = 3
  public static let minDuration: TimeInterval = 30 * 60
  public static let cooldown: TimeInterval = 6 * 3600

  public static var recordURL: URL {
    CMPaths.appSupportDir.appendingPathComponent("attach-stall")
  }

  /// The series so far. `restartedAt == 0` = no restart in this boot session.
  public struct Record: Equatable {
    public var bootTime: TimeInterval
    public var firstFailureAt: TimeInterval
    public var failures: Int
    public var restartedAt: TimeInterval

    public var text: String {
      "\(Int(bootTime)) \(Int(firstFailureAt)) \(failures) \(Int(restartedAt))"
    }

    public init(
      bootTime: TimeInterval, firstFailureAt: TimeInterval, failures: Int,
      restartedAt: TimeInterval
    ) {
      self.bootTime = bootTime
      self.firstFailureAt = firstFailureAt
      self.failures = failures
      self.restartedAt = restartedAt
    }

    public init?(text: String) {
      let parts = text.split(whereSeparator: \.isWhitespace).compactMap { TimeInterval($0) }
      guard parts.count == 4 else { return nil }
      self.init(
        bootTime: parts[0], firstFailureAt: parts[1], failures: Int(parts[2]),
        restartedAt: parts[3])
    }
  }

  /// A record from another boot session describes a mount that no longer
  /// exists - it starts from scratch, like `ShutdownPrep.isActive`.
  static func current(_ record: Record?, bootTime: TimeInterval) -> Record? {
    guard let record, abs(record.bootTime - bootTime) <= 1 else { return nil }
    return record
  }

  /// One more EAGAIN in the series.
  static func addingFailure(to record: Record?, bootTime: TimeInterval, now: TimeInterval)
    -> Record
  {
    guard var series = current(record, bootTime: bootTime) else {
      return Record(bootTime: bootTime, firstFailureAt: now, failures: 1, restartedAt: 0)
    }
    if series.failures == 0 { series.firstFailureAt = now }
    series.failures += 1
    return series
  }

  /// Any other outcome of the attach ends the series; the time of the last
  /// restart stays, so the cooldown holds across a short success.
  static func endingSeries(_ record: Record?, bootTime: TimeInterval, now: TimeInterval)
    -> Record?
  {
    guard let series = current(record, bootTime: bootTime), series.restartedAt > 0 else {
      return nil
    }
    return Record(
      bootTime: bootTime, firstFailureAt: now, failures: 0, restartedAt: series.restartedAt)
  }

  static func shouldRestart(_ record: Record?, bootTime: TimeInterval, now: TimeInterval) -> Bool {
    guard let series = current(record, bootTime: bootTime) else { return false }
    guard series.failures >= minFailures, now - series.firstFailureAt >= minDuration else {
      return false
    }
    return series.restartedAt == 0 || now - series.restartedAt >= cooldown
  }

  /// After a restart that ran (whatever its outcome) a new series starts, and
  /// the cooldown with it. A refusal (`didNotRun`) touched nothing and counts
  /// for nothing - the next failure asks again.
  static func afterRestart(_ record: Record, restart: CMActionResult, now: TimeInterval) -> Record {
    guard !restart.didNotRun else { return record }
    return Record(bootTime: record.bootTime, firstFailureAt: now, failures: 0, restartedAt: now)
  }

  /// What the attach agent does with the outcome of `BackupImageService.attach`.
  /// The time and the restart are replaceable so the decision can be tested
  /// without launchd.
  static func handle(
    _ attach: CMActionResult, record: Record?, bootTime: TimeInterval, now: TimeInterval,
    restart: () async -> CMActionResult
  ) async -> (record: Record?, restart: CMActionResult?) {
    // "Busy with another operation" says nothing about the mount - the
    // series neither grows nor ends.
    if attach.didNotRun { return (record, nil) }
    guard attach.attachTemporarilyUnavailable else {
      return (endingSeries(record, bootTime: bootTime, now: now), nil)
    }
    let series = addingFailure(to: record, bootTime: bootTime, now: now)
    guard shouldRestart(series, bootTime: bootTime, now: now) else { return (series, nil) }
    let restarted = await restart()
    return (afterRestart(series, restart: restarted, now: now), restarted)
  }

  // MARK: - Live

  /// Called by `attach-image` after every attach. Returns the restart's
  /// result when one was attempted.
  public static func afterAttach(_ attach: CMActionResult) async -> CMActionResult? {
    // No boot time - no way to tell this session's series from an old one.
    // Doing nothing is the old behaviour, not a new risk.
    guard let boot = ShutdownPrep.bootTime() else { return nil }
    let stored = (try? String(contentsOf: recordURL, encoding: .utf8)).flatMap(Record.init(text:))
    let outcome = await handle(
      attach, record: stored, bootTime: boot, now: Date().timeIntervalSince1970,
      restart: {
        CMLogger.log(
          "Attach refused with EAGAIN \(minFailures)+ times over \(Int(minDuration / 60))+ min - restarting the Drive mount"
        )
        let result = await MountRestart.perform()
        CMLogger.log("Mount restart after the stalled attach: \(result.message)")
        return result
      })
    if let record = outcome.record {
      try? record.text.write(to: recordURL, atomically: true, encoding: .utf8)
    } else {
      try? FileManager.default.removeItem(at: recordURL)
    }
    return outcome.restart
  }
}
