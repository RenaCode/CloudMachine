import Foundation

/// Logs `message` only the FIRST time a given state is met (`active ==
/// true`) - later watchdog cycles in the same state stay quiet, so that a longer
/// failure does not flood the shared log with hundreds of identical lines.
/// When `active` goes back to `false`, the marker is cleared and the next
/// occurrence logs again.
///
/// Born from a real case: `BackupWatchdogService`/`VerifyWatchdogService` were
/// silent for >2 days, because their "mount not ready yet" guards simply
/// `return`ed without a trace in the log - the diagnosis took much longer than
/// it would have if that state boundary had been visible.
public enum EdgeTriggeredLog {
  public static func log(marker: URL, active: Bool, _ message: @autoclosure () -> String) {
    if active {
      guard !FileManager.default.fileExists(atPath: marker.path) else { return }
      CMLogger.log(message())
      FileManager.default.createFile(atPath: marker.path, contents: nil)
    } else {
      try? FileManager.default.removeItem(at: marker)
    }
  }
}
