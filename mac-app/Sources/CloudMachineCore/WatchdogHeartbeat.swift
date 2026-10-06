import Foundation

/// A "the watchdog REALLY ran" marker, i.e. supervision of the supervisor
/// itself.
///
/// `backup-health` runs with `StartInterval 1800` and WITHOUT `KeepAlive`. If
/// the agent gets unloaded (`launchctl bootout`, a failed install, a renamed
/// binary) or hangs in uninterruptible I/O on the Google Drive mount, the only
/// symptom is SILENCE - and silence is the default, expected state here. The
/// README says it plainly: "Empty logs after a fresh install are normal - the
/// agents only write when something happens". So a watchdog that works and has
/// nothing to report looks exactly like a watchdog that is not there.
///
/// That is why every run leaves a FILE with a date behind. No alert stops
/// meaning "all good" and starts meaning "the watchdog ran at 14:32 and had
/// nothing to report" - or "the watchdog has not run for three days", which is
/// completely different information.
///
/// The marker is NOT an alert channel. An external channel (mail, push) is the
/// owner's architectural decision, not a fix - here we only record a fact that
/// `drive-status` and the panel SHOW when a person looks for themselves.
///
/// The file lives in `appSupportDir`, next to the alert state
/// (`health-alert.json`), not in the buffer or in the image - the watchdog must
/// not share the fate of what it supervises.
public enum WatchdogHeartbeat {

  /// Marker of the `backup-health` watchdog.
  ///
  /// Plain text, not JSON: it is a file a person `cat`s during diagnosis, and
  /// it has to be readable without tools.
  public static var backupHealthFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("backup-health-last-run")
  }

  /// After this many hours of silence we consider the watchdog NOT RUNNING.
  ///
  /// The watchdog's `StartInterval` is 1800 s, so an hour is two missed runs in
  /// a row - too many to be chance, while leaving headroom for a run that takes
  /// long (every tmutil call has a time limit and the watchdog can use it up).
  public static let maxSilenceHours = 1.0

  /// What we know about the watchdog's last run.
  ///
  /// Three states, not two, for the same reason as `DestinationReading` and
  /// `queueKnown`: "the watchdog has not recorded a single run" is different
  /// information from "the last run was long ago". The former happens on a
  /// fresh install and after the update that added this marker.
  public enum Freshness: Equatable {
    case fresh(lastRun: Date, age: TimeInterval)
    case stale(lastRun: Date, age: TimeInterval)
    /// There is no marker at all.
    case never
  }

  /// Records the fact "the watchdog ran now".
  ///
  /// Called BEFORE the watchdog prints anything and before it decides on the
  /// exit code: a run that found a failure is just as much a run as one that
  /// found nothing. If the marker were written only on the healthy path, a
  /// broken backup would look like an inactive watchdog and vice versa.
  ///
  /// Returns `false` when the write did NOT succeed - the marker will then be
  /// old, i.e. it errs on the safe side ("the watchdog may not be running").
  @discardableResult
  public static func record(now: Date = Date(), file: URL = WatchdogHeartbeat.backupHealthFile)
    -> Bool
  {
    let formatter = ISO8601DateFormatter()
    let text = formatter.string(from: now) + "\n"
    guard let data = text.data(using: .utf8) else { return false }
    return (try? data.write(to: file, options: .atomic)) != nil
  }

  /// Date of the last run, or `nil` when there is no marker (or it is
  /// unreadable - both mean "I do not know when the watchdog ran" here).
  public static func lastRun(file: URL = WatchdogHeartbeat.backupHealthFile) -> Date? {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return nil }
    return ISO8601DateFormatter().date(from: text.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  /// Pure assessment of the marker's age - separate from reading the file, so
  /// it can be tested without touching the disk.
  public static func freshness(
    lastRun: Date?, now: Date = Date(),
    maxSilenceHours: Double = WatchdogHeartbeat.maxSilenceHours
  ) -> Freshness {
    guard let lastRun else { return .never }
    let age = now.timeIntervalSince(lastRun)
    // A negative age (a marker from the future - a clock that was changed, a
    // copy from another machine) is NOT freshness: we do not know when the
    // watchdog ran.
    guard age >= 0, age <= maxSilenceHours * 3600 else {
      return .stale(lastRun: lastRun, age: age)
    }
    return .fresh(lastRun: lastRun, age: age)
  }

  public static func current(
    now: Date = Date(), file: URL = WatchdogHeartbeat.backupHealthFile,
    maxSilenceHours: Double = WatchdogHeartbeat.maxSilenceHours
  ) -> Freshness {
    freshness(lastRun: lastRun(file: file), now: now, maxSilenceHours: maxSilenceHours)
  }
}
