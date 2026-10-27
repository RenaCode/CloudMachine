import Foundation

/// Status lines shared by `vm-status` and the app. Pure functions, because
/// the status line is what a person READS when asking "is the backup working"
/// - and it has broken before by turning "I do not know" into some value.
/// Each function below has an explicit branch for missing data.
public enum StatusLines {

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
