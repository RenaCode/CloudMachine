import Foundation

/// When the buffer is ready enough to attach the image on it.
///
/// Split out of `attach-image` so that it can be tested without mounting
/// anything - just like `CooldownGate` and `TimeMachineStatus`.
public enum BufferReadiness {
  /// How long to wait for a ready buffer before we treat it as a failure.
  ///
  /// Two minutes were enough as long as the buffer started empty. After an
  /// unclean shutdown it is different: on 13 Sep 2026 rclone read 225 dirty
  /// items (9.4 GB) after start-up, the mount came up at 07:56:30, and the wait
  /// gave up at 07:56:20 - ten seconds too early. Time Machine was left without
  /// a destination until the next launchd tick, i.e. for 15 minutes, and nobody
  /// found out except through an exit code that nobody reads.
  ///
  /// Waiting is free - `attach` on an already attached image only says
  /// "Already attached" - while a missed window costs a quarter of an hour
  /// without a backup.
  public static let defaultTimeout: TimeInterval = 900

  /// How often to poll.
  public static let defaultPoll: TimeInterval = 2

  /// The mount alone is not enough.
  ///
  /// rclone exposes the mount BEFORE it reads the dirty cache, so for a while
  /// the directory is empty. The attach would then fail with "No image" - that
  /// is, on the same race, just one step later.
  public static func isReady(mounted: Bool, imageVisible: Bool) -> Bool {
    mounted && imageVisible
  }

  /// Waits for the buffer to become ready. Returns `true` if it did.
  ///
  /// The clock and sleep are injected so that a test does not have to really wait.
  public static func wait(
    timeout: TimeInterval = defaultTimeout,
    poll: TimeInterval = defaultPoll,
    now: () -> Date = Date.init,
    sleep: (TimeInterval) async -> Void,
    probe: () -> Bool
  ) async -> Bool {
    let deadline = now().addingTimeInterval(timeout)
    while true {
      if probe() { return true }
      if now() >= deadline { return false }
      await sleep(poll)
    }
  }
}
