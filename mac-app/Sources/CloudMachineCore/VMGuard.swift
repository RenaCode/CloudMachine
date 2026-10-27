import Foundation

/// Guard of the machine's upload buffer: Time Machine writes to Samba faster
/// than rclone uploads to Google Drive (750 GB a day at most), and the buffer
/// is the machine's 200 GB disk. One `step()` per launchd run (every 60 s).
///
/// Pause when the buffer holds more than `highGiB` or the disk has less than
/// `minFreeGiB` free. Resume below `lowGiB` - and ONLY if this guard paused
/// the backup (the marker file); a backup the person stopped stays stopped.
/// No answer from the machine or from tmutil means: do nothing.
public struct VMGuard: Sendable {
  public struct Thresholds: Equatable, Sendable {
    public var highGiB: Int
    public var lowGiB: Int
    public var minFreeGiB: Int

    /// The values the first full backup ran with (27.10.2026): the buffer is
    /// capped at 120 GB (`--vfs-cache-max-size`), so 110 leaves room for what
    /// is already in flight.
    public init(highGiB: Int = 110, lowGiB: Int = 40, minFreeGiB: Int = 40) {
      self.highGiB = highGiB
      self.lowGiB = lowGiB
      self.minFreeGiB = minFreeGiB
    }
  }

  public enum Action: Equatable, Sendable {
    case pause
    case resume
    case nothing
  }

  /// The decision. Pure, so every rule has a test.
  ///
  /// - `reading == nil`: the machine did not answer. Nothing - pausing on a
  ///   guess stops backups for no reason, resuming on one floods a full disk.
  /// - over a threshold: pause, but only a backup that is RUNNING (`true`);
  ///   `nil` from tmutil is not "running".
  /// - under `lowGiB` with the marker: resume. Without the marker the guard
  ///   did not pause it, so it is not the guard's to resume.
  public static func decide(
    reading: VMLayout.Reading?, backupRunning: Bool?, pausedByGuard: Bool,
    thresholds: Thresholds
  ) -> Action {
    guard let reading else { return .nothing }
    let usedGiB = reading.buffer.bytesUsed / gib
    let freeGiB = reading.freeBytes / gib
    if usedGiB > Int64(thresholds.highGiB) || freeGiB < Int64(thresholds.minFreeGiB) {
      return backupRunning == true ? .pause : .nothing
    }
    if pausedByGuard && usedGiB < Int64(thresholds.lowGiB) {
      return .resume
    }
    return .nothing
  }

  static let gib: Int64 = 1 << 30

  /// What the guard reads and does - replaceable, so the tests walk the whole
  /// step (marker included) without a machine or tmutil.
  public struct Probes: Sendable {
    public var reading: @Sendable () async -> VMLayout.Reading?
    public var backupRunning: @Sendable () async -> Bool?
    public var markerExists: @Sendable () -> Bool
    public var setMarker: @Sendable (Bool) -> Void
    public var tmutil: @Sendable (String) async -> Bool
    public var log: @Sendable (String) -> Void
    public var minute: @Sendable () -> Int

    public static let live = Probes(
      reading: { await VMLayout.currentReading() },
      backupRunning: { await TimeMachineStatus.runningState() },
      markerExists: { FileManager.default.fileExists(atPath: VMLayout.guardMarker.path) },
      setMarker: { on in
        if on {
          try? FileManager.default.createDirectory(
            at: VMLayout.hostDir, withIntermediateDirectories: true)
          FileManager.default.createFile(atPath: VMLayout.guardMarker.path, contents: Data())
        } else {
          try? FileManager.default.removeItem(at: VMLayout.guardMarker)
        }
      },
      tmutil: { await BufferGuardService.tmutil($0) },
      log: { CMLogger.log($0) },
      minute: { Calendar.current.component(.minute, from: Date()) })
  }

  public var thresholds: Thresholds
  var probes: Probes

  public init(thresholds: Thresholds = Thresholds()) {
    self.init(thresholds: thresholds, probes: .live)
  }

  init(thresholds: Thresholds, probes: Probes) {
    self.thresholds = thresholds
    self.probes = probes
  }

  /// One check. Returns what it decided (for the tests and the CLI).
  @discardableResult
  public func step() async -> Action {
    let reading = await probes.reading()
    guard let reading else {
      probes.log("VM guard: NO ANSWER from the machine (rclone rc) - neither pausing nor resuming")
      return .nothing
    }
    let running = await probes.backupRunning()
    let paused = probes.markerExists()
    let action = Self.decide(
      reading: reading, backupRunning: running, pausedByGuard: paused, thresholds: thresholds)
    let used = reading.buffer.bytesUsed / Self.gib
    let free = reading.freeBytes / Self.gib
    let queued = reading.buffer.uploadsQueued
    switch action {
    case .pause:
      if await probes.tmutil("stopbackup") {
        probes.setMarker(true)
        probes.log("VM guard: PAUSE - buffer \(used) GiB, queue \(queued), free \(free) GiB")
      } else {
        probes.log("VM guard: tmutil stopbackup FAILED - buffer \(used) GiB, free \(free) GiB")
      }
    case .resume:
      // The marker goes only after a successful start. The shell version
      // removed it first, so one failed `startbackup` left the backup paused
      // for good with nobody left to resume it.
      if await probes.tmutil("startbackup") {
        probes.setMarker(false)
        probes.log("VM guard: RESUME - buffer \(used) GiB, free \(free) GiB")
      } else {
        probes.log("VM guard: tmutil startbackup FAILED - will try again on the next run")
      }
    case .nothing:
      break
    }
    if probes.minute() == 0 {
      let state = running.map { $0 ? "1" : "0" } ?? "unknown"
      probes.log(
        "VM guard ok: buffer \(used) GiB, queue \(queued), free \(free) GiB, TM running=\(state)")
    }
    return action
  }
}
