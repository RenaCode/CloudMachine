import Foundation

/// Waiting for rclone to upload the backlog BEFORE `hdiutil attach` starts.
///
/// Until 01.10.2026 `attach()` waited a fixed 120 s for an empty queue. That is
/// enough for an ordinary attach, but not after a Mac restart without
/// `prepare-shutdown`: with `--vfs-write-back 600s` about 10 min of writes are
/// left in the buffer (01.10 - ~19 GB, ~600 bands). Measured that day: rclone
/// read the dirty cache 15:32-15:36, uploaded 15:37-15:42 (~120 bands/min), and
/// the 120 s ran out halfway through. The first `hdiutil attach` started at
/// 15:39 in the middle of the full upload, opened the lock file and HUNG for
/// 5 min, then failed with "image not recognized"; the second attempt failed
/// after 90 s, the third - by then in quiet - succeeded in 15 s. Time Machine
/// sat without a destination for 17 min, and the monitor was shouting FAILURE.
///
/// A longer fixed limit is not the answer: with Google's daily limit exhausted
/// the queue will not drain at all, and every attach would pay the whole limit.
/// So we wait as long as the upload IS MAKING PROGRESS, and give up when for
/// `stallTimeout` the number of unsent items has not dropped below its minimum
/// so far. `maxTotal` is a hard ceiling - launchd waits for this process, and
/// an image that is not attached means Time Machine has no destination.
public enum UploadDrain {

  public static let defaultStallTimeout: TimeInterval = 120
  /// 20 min: the backlog of 01.10 (~19 GB) drained in ~6 min, so this is three
  /// times that. More makes no sense anyway - a queue that grows faster than it
  /// drains is no longer a start-up but a jam, and the watchdog will report it.
  public static let defaultMaxTotal: TimeInterval = 1200
  public static let defaultPoll: TimeInterval = 5
  /// How often we repeat moving the upload deadlines forward. After start-up
  /// rclone reads the dirty cache band by band (01.10: four minutes) and each
  /// one gets a deadline `writeBackSeconds` ahead - a single move at the start
  /// would not cover the ones read later.
  public static let defaultExpiryInterval: TimeInterval = 60

  public enum Outcome: Equatable {
    /// Queue empty - safe to mount.
    case idle
    /// No progress for `stallTimeout`.
    case stalled(unsent: Int)
    /// There was progress, but it did not finish before `maxTotal`.
    case timedOut(unsent: Int)
    /// rclone did not answer for the whole `stallTimeout`.
    case noAnswer
  }

  /// `unsent` returns the number of unsent items, or `nil` when rclone did not
  /// answer. No answer is not progress: it counts towards `stallTimeout` just
  /// like a queue that is standing still.
  public static func wait(
    stallTimeout: TimeInterval = defaultStallTimeout,
    maxTotal: TimeInterval = defaultMaxTotal,
    poll: TimeInterval = defaultPoll,
    expiryInterval: TimeInterval = defaultExpiryInterval,
    now: () -> Date = Date.init,
    sleep: (TimeInterval) async -> Void,
    expire: () async -> Void,
    unsent: () async -> Int?
  ) async -> Outcome {
    let start = now()
    var lastProgress = start
    var lastExpiry: Date?
    var best: Int?
    var last: Int?

    while true {
      if lastExpiry.map({ now().timeIntervalSince($0) >= expiryInterval }) ?? true {
        await expire()
        lastExpiry = now()
      }
      let reading = await unsent()
      if let reading {
        if reading == 0 { return .idle }
        last = reading
        if best.map({ reading < $0 }) ?? true {
          best = reading
          lastProgress = now()
        }
      }
      let t = now()
      if t.timeIntervalSince(lastProgress) >= stallTimeout {
        return last.map { .stalled(unsent: $0) } ?? .noAnswer
      }
      if t.timeIntervalSince(start) >= maxTotal {
        return last.map { .timedOut(unsent: $0) } ?? .noAnswer
      }
      await sleep(poll)
    }
  }
}
