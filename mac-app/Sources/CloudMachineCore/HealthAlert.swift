import Foundation

/// Reports a broken backup cycle where the user will see it WITHOUT opening
/// anything.
///
/// Reason for existence: all the "monitoring" this project had so far relied
/// on someone opening the app and looking at the icon. A failure that does not
/// get in the way of daily work - and every backup failure is like that -
/// gives no reason to look there. Backups may not be made for weeks and
/// nothing will give it away.
///
/// The channel is a macOS system notification: it needs no mail server and no
/// secret whose absence would be yet another silent failure.
public enum HealthAlert {

  /// File with the state of the last report. Kept APART from the buffer and
  /// the image, in a directory that lives independently of them - the
  /// watchdog must not share the fate of what it supervises.
  public static var stateFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("health-alert.json")
  }

  struct AlertState: Codable {
    /// The text last SHOWN - kept for a person (`drive-status`, diagnosis from
    /// the file), not for comparison. It is in the UI language of the run that
    /// wrote it.
    var lastSummary: String
    var lastAlertAt: Date
    /// Identity of the problems, i.e. how we recognize that it is THE SAME
    /// failure - see `identity(of:)`. Optional, so that a file written before
    /// 23.09.2026 can still be read; with `nil` we compare by text as before
    /// (at most one extra notification, once).
    ///
    /// Built from `Problem.code`, which does not depend on the UI language.
    /// Files written before the switch to codes hold a fingerprint of the
    /// Polish summary instead; it does not match any code, so the first run
    /// after the update notifies once more - the same one-off cost as above.
    var lastIdentity: String?
    /// Whether the notification was ACTUALLY delivered. `nil` = a file in the
    /// old format, i.e. from before anyone checked this - treated as delivered,
    /// because otherwise retries would pour in after the update.
    var delivered: Bool?
    /// Why it was not delivered - to be shown to a person. Written as the
    /// language-independent `osascriptFailureReason` and translated only when
    /// displayed (see `lastDeliveryFailure`); older files may hold Polish text,
    /// which is then shown as it is.
    var deliveryError: String?
  }

  /// After this many hours we remind about THE SAME problem once more.
  ///
  /// Without a reminder the alarm lights up once and goes out forever - while
  /// a backup failure lasts until someone fixes it. Without a gap it turns
  /// into noise every 15 minutes and stops meaning anything.
  static let reminderHours = 12.0

  /// Reports the problems if they are NEW or if the reminder time has passed.
  /// Returns `true` when something was actually reported AND DELIVERED.
  ///
  /// `stateFile`, `deliver` and `log` are replaceable so that the WHOLE path
  /// can be tested - including a refused delivery - without writing to the
  /// user's real directory, without showing anyone notifications and without
  /// adding made-up failures to the production log.
  ///
  /// `log` is injectable for exactly the same reason as
  /// `BufferGuardService.Probes.log`. Until it was, every `swift test` run
  /// appended its invented "BACKUP FAILURE" (then still in Polish) to the
  /// real `cloudmachine.log` - measured 25.09.2026: 117 lines containing a
  /// word that existed only in `HealthAlertTests.raport(_:)` (now
  /// `report(_:)`), all from one day. This log is the ONLY trace of backup
  /// failures and it stopped allowing events that happened to be told apart
  /// from ones someone merely tested - and after a failure it is read
  /// precisely to establish what happened.
  ///
  /// Rejected: globally redirecting `CMLogger` to a temporary file in the
  /// test's `setUp`. That is shared process state, so with tests running in
  /// parallel it would also silence the ones that are supposed to write, and
  /// switched on by mistake in production code it would silence production -
  /// i.e. it would trade noise in the log for silence in the log, which is a
  /// change for the worse. The default value of this parameter goes to the
  /// real log and no production code passes it.
  @discardableResult
  public static func report(
    _ report: BackupHealth.Report,
    now: Date = Date(),
    stateFile: URL = HealthAlert.stateFile,
    deliver: @Sendable (String, String) async -> Bool = {
      await notify(title: $0, message: $1)
    },
    log: @Sendable (String) -> Void = { CMLogger.log($0) }
  ) async -> Bool {
    guard let first = report.problems.first else {
      // Recovery deletes the state, so that the next failure is reported
      // right away instead of waiting for the reminder window.
      try? FileManager.default.removeItem(at: stateFile)
      return false
    }

    let summary = report.problems.map(\.summary).joined(separator: " | ")
    let identity = self.identity(of: report.problems)
    if !shouldAlert(identity: identity, now: now, stateFile: stateFile) { return false }

    let body = report.problems.map { "\($0.summary): \($0.detail)" }.joined(separator: "\n")
    log("BACKUP FAILURE: \(body)")
    let delivered = await deliver(L10n.tr("CloudMachine: backup is not working"), first.summary)

    // We ALWAYS write the state, but with the information whether the
    // notification was delivered.
    //
    // Previously it was written unconditionally as a success, so a failed
    // notification (permission refused for the launchd process, no Aqua
    // session, osascript time limit exceeded) closed the quiet window for 12
    // hours. The alarm vanished silently - i.e. the supervision died together
    // with the supervised, which the header of this file warns against.
    if !delivered {
      log(
        "FAILED to show the backup failure notification. The content went to the log above; will retry at the next check."
      )
    }
    let state = AlertState(
      lastSummary: summary, lastAlertAt: now, lastIdentity: identity,
      delivered: delivered,
      deliveryError: delivered ? nil : osascriptFailureReason)
    if let data = try? JSONEncoder().encode(state) {
      try? data.write(to: stateFile, options: .atomic)
    }
    return delivered
  }

  static func shouldAlert(identity: String, now: Date, stateFile: URL = HealthAlert.stateFile)
    -> Bool
  {
    guard let state = loadState(stateFile) else { return true }
    // A failed delivery does NOT close the quiet window - otherwise the first
    // failed attempt would silence the alarm for 12 hours.
    if state.delivered == false { return true }
    if (state.lastIdentity ?? state.lastSummary) != identity { return true }
    return now.timeIntervalSince(state.lastAlertAt) > reminderHours * 3600
  }

  /// Identity of a set of problems: their codes with NUMBERS cut out.
  ///
  /// Comparing the finished text for the user does not work, because that
  /// text contains variables: "No successful backup for 3 h" turns into "...
  /// for 4 h" an hour later. The condition "different text = new problem" was
  /// therefore met on EVERY watchdog run and the notification came back every
  /// hour instead of once every twelve - and an alarm without a gap turns into
  /// noise and stops meaning anything (see `reminderHours`). The same failure
  /// must have the same identity regardless of how long it lasts.
  ///
  /// It also must not depend on the UI language: the summary is translated,
  /// so the same failure seen by a Polish-language run and an English-language
  /// run would look like two different ones. That is why we take
  /// `Problem.code`, not `summary`.
  ///
  /// A run of digits is replaced by a single `#`, so that "for 9 h" and "for
  /// 12 h" give the same fingerprint (this matters for problems whose code
  /// defaults to their summary). A NEW problem added to the list changes the
  /// fingerprint and alarms right away - and that is how it should be.
  static func identity(of problems: [BackupHealth.Problem]) -> String {
    problems.map { fingerprint($0.code) }.joined(separator: " | ")
  }

  static func fingerprint(_ text: String) -> String {
    var out = ""
    var inNumber = false
    for character in text {
      if character.isNumber {
        if !inNumber {
          out.append("#")
          inNumber = true
        }
      } else {
        out.append(character)
        inNumber = false
      }
    }
    return out
  }

  static func loadState(_ file: URL = HealthAlert.stateFile) -> AlertState? {
    guard let data = try? Data(contentsOf: file) else { return nil }
    return try? JSONDecoder().decode(AlertState.self, from: data)
  }

  /// Reason written to `deliveryError` when `osascript` did not show the
  /// notification. Persisted in English and translated only for display, so
  /// the file does not depend on the language of the run that wrote it.
  static let osascriptFailureReason =
    "osascript did not show the notification (permissions or no graphical session)"

  /// The last report that could NOT be delivered - to be shown in
  /// `drive-status`. `nil` when the last report was delivered or when there
  /// was none. A silent alarm has to be visible somewhere a person looks on
  /// their own, because by definition it will not reach them via a
  /// notification.
  public static func lastDeliveryFailure(stateFile: URL = HealthAlert.stateFile) -> (
    at: Date, summary: String, reason: String
  )? {
    guard let state = loadState(stateFile), state.delivered == false else { return nil }
    let reason: String
    switch state.deliveryError {
    case .none: reason = L10n.tr("unknown reason")
    case .some(osascriptFailureReason):
      reason = L10n.tr(
        "osascript did not show the notification (permissions or no graphical session)")
    case .some(let other): reason = other
    }
    return (state.lastAlertAt, state.lastSummary, reason)
  }

  /// System notification via `osascript`. The text itself is inserted as an
  /// AppleScript literal with escaped quotes - otherwise a message containing
  /// `"` (and rclone messages do contain them) would break the script and the
  /// alarm would vanish silently, i.e. exactly like the failure it is meant to
  /// report.
  ///
  /// Returns `true` only when `osascript` ACTUALLY finished successfully. The
  /// result used to be thrown away with `_ = try?`, so a refused notification
  /// permission (typical for a launchd process), no Aqua session or an
  /// exceeded time limit looked exactly the same as a notification that was
  /// shown.
  @discardableResult
  public static func notify(title: String, message: String) async -> Bool {
    let script =
      "display notification \(appleScriptLiteral(message)) with title \(appleScriptLiteral(title))"
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/osascript", ["-e", script], timeout: 30)
    else {
      CMLogger.log(
        "osascript did not respond within the time limit - the notification was not sent.")
      return false
    }
    if !result.succeeded {
      let text = (result.stderr + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
      CMLogger.log(
        "osascript returned code \(result.exitCode): "
          + (text.isEmpty ? "(no message)" : text))
    }
    return result.succeeded
  }

  static func appleScriptLiteral(_ text: String) -> String {
    let escaped =
      text
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
      .replacingOccurrences(of: "\n", with: " ")
    return "\"\(escaped)\""
  }
}
