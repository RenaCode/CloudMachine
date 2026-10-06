import Foundation

/// Building the `drive-status` lines. Pure functions, because the status line
/// is what a person READS when asking "is the backup working" - and until now
/// it could not be tested, because it was produced in a `print` inside a CLI
/// command.
///
/// These lines have already broken twice in the same way: by turning "I do
/// not know" into some value. Once by substituting zeros for rclone not
/// answering (hence `UploadState.queueUnknown`), once via `Optional(427)`
/// after `BufferGuardService.freeGB()` rightly stopped pretending that a
/// missing measurement is zero. That is why each of the functions below has an
/// explicit branch for missing data.
public enum StatusLines {

  /// The "Drive mount" line.
  ///
  /// The third state is separate for the same reason as with the queue:
  /// `MISSING` means "I checked and it is not there", and that is a conclusion
  /// nobody has the right to draw when reading the mount table failed.
  public static func mounted(_ state: Bool?) -> String {
    switch state {
    case .some(true): return "OK"
    case .some(false): return L10n.tr("MISSING")
    case .none: return L10n.tr("UNKNOWN - could not read the mount table")
    }
  }

  /// The "Free on disk" line.
  ///
  /// `nil` MUST be named. Not `Optional(427)` (because that looks like a
  /// program defect, not like information) and not a substituted zero
  /// (because zero is a CONCRETE number at which the buffer guard pauses Time
  /// Machine - exactly the bug the other agent fixed by changing the type to
  /// `Int?`). A missing measurement means the guard no longer protects the
  /// disk from filling up, so the line has to say that plainly.
  public static func freeDisk(_ gb: Int?) -> String {
    guard let gb else {
      return L10n.tr(
        "NOT MEASURED - the buffer guard will not pause Time Machine before the disk fills up")
    }
    return "\(gb) GB"
  }

  /// The "Cache on disk" line.
  ///
  /// Separate from the backlog line, and that is the most important thing
  /// here: throughout September 2026 a single line "Buffer: 103 GB of 100G" was
  /// supposed to answer two questions - how much space the cache takes and
  /// how much is left to upload. It did not answer the second one, because
  /// with `--vfs-cache-max-age 9999h` the cache sits at the limit constantly
  /// (281 measurements, minimum 99 GB). The buffer guard made its decision to
  /// pause Time Machine on this number - hence this change.
  public static func cacheSize(_ gb: Int?, limitGB: Int) -> String {
    guard let gb else {
      return L10n.tr(
        "NOT MEASURED - rclone did not respond, and walking the buffer directory failed")
    }
    return L10n.tr("%@ GB of %@G", "\(gb)", "\(limitGB)")
  }

  /// The "To upload" line - the UNSENT BACKLOG, i.e. the quantity on which the
  /// buffer guard decides to pause and resume.
  ///
  /// The item count is a MEASUREMENT, the gigabytes are an ESTIMATE from that
  /// count (see `BufferGuardService.backlogGB`) - that is why they carry a "~"
  /// and why we show both. A line that gives only the estimate as a number
  /// hides how solid the basis for the decision to pause the backup is.
  public static func backlog(_ gb: Int?, items: Int?) -> String {
    guard let gb, let items else {
      return L10n.tr(
        "UNKNOWN - the rclone control interface did not respond (the buffer guard will neither pause nor resume Time Machine on this basis)"
      )
    }
    return L10n.tr("~%@ GB (%@ items)", "\(gb)", "\(items)")
  }

  /// Lines about a notification that could NOT be delivered.
  ///
  /// `HealthAlert.notify` has recently started returning `Bool`, and
  /// `HealthAlert.report` does not close the matter with a marker until the
  /// notification has been delivered - thanks to that the alarm no longer
  /// vanishes silently for 12 hours. But that alone is not enough: as long as
  /// nobody PRINTS it, a person learns about an undelivered alarm only if they
  /// look into the state file themselves. A refused notification permission
  /// is typical for a launchd process, so this is not a theoretical case.
  ///
  /// Empty array = nothing to report.
  public static func undeliveredAlert(_ failure: (at: Date, summary: String, reason: String)?)
    -> [String]
  {
    guard let failure else { return [] }
    return [
      L10n.tr("UNDELIVERED ALARM: %@", failure.summary),
      "        "
        + L10n.tr("from %@, reason: %@", BackupHealth.stamp(failure.at), failure.reason),
      "        "
        + L10n.tr("The system notification was not delivered - you will see this alarm ONLY here."),
    ]
  }

  /// The "Backup watchdog" line, i.e. when `backup-health` last ran.
  ///
  /// A third line from the same family as the two above: it shows a fact that
  /// is otherwise invisible. The watchdog runs with `StartInterval 1800` and
  /// without `KeepAlive`, so when unloaded or hung it gives NO symptom other
  /// than silence - and silence is the normal state here (README: "Empty logs
  /// after a fresh install are normal"). Without this line "no alarm" meant
  /// both "the backup works" and "nobody checked", i.e. it meant nothing.
  ///
  /// Named separately and added at the end of `StatusLines` instead of being
  /// woven into the existing functions - `drive-status` is being rebuilt in
  /// parallel on the `naprawy/dozorca-bufora` branch (l10n-polish-ok: a git branch name).
  public static func watchdogRun(_ freshness: WatchdogHeartbeat.Freshness) -> String {
    switch freshness {
    case .fresh(let lastRun, let age):
      return L10n.tr(
        "%@ (%@ ago)", BackupHealth.stamp(lastRun), BackupHealth.formatAge(age))
    case .stale(let lastRun, let age):
      // A marker from the future (a clock that was changed, a file moved from
      // another machine) is also a lack of knowledge, not an age - "-60 min
      // ago" is not a sentence that says anything.
      guard age >= 0 else {
        return L10n.tr("%@ - marker from the FUTURE", BackupHealth.stamp(lastRun))
      }
      return L10n.tr(
        "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING", BackupHealth.stamp(lastRun),
        BackupHealth.formatAge(age))
    case .never:
      return L10n.tr("NEVER - the watchdog has not recorded a single run")
    }
  }
}
