import XCTest

@testable import CloudMachineCore

/// Tests of the ALARM itself, not of the watchdog.
///
/// Until 23.09.2026 `HealthAlert` did not have a single test, even though it is
/// what decides whether anyone learns about a backup failure. Both defects
/// fixed here are of the same kind: the alarm considered itself reported,
/// although nobody saw it.
///
/// Every test SUBSTITUTES the log (`log:`) - see `report(_:now:deliver:)`.
/// There is exactly one exception, and it is deliberate:
/// `testRealRunStillWritesToTheLog`, which has to use the real one to prove
/// that the substitution did not silence production.
final class HealthAlertTests: XCTestCase {

  private var directory: URL!
  private var stateFile: URL!
  private var log: CapturedLog!

  override func setUpWithError() throws {
    directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-health-alert-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    stateFile = directory.appendingPathComponent("health-alert.json")
    log = CapturedLog()
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: directory)
    L10n.language = .en
  }

  private func healthReport(_ summaries: [String], lastSuccess: Date? = nil)
    -> BackupHealth.Report
  {
    BackupHealth.Report(
      problems: summaries.map { BackupHealth.Problem(summary: $0, detail: "details") },
      lastSuccess: lastSuccess, lastAttempt: nil)
  }

  /// `HealthAlert.report` with a substituted state file AND a substituted log.
  /// We call this instead of `HealthAlert.report` directly, so that no test can
  /// be added that, by forgetting one argument, starts cluttering the
  /// production `cloudmachine.log` again.
  @discardableResult
  private func report(
    _ report: BackupHealth.Report, now: Date = Date(),
    deliver: @escaping @Sendable (String, String) async -> Bool
  ) async -> Bool {
    await HealthAlert.report(
      report, now: now, stateFile: stateFile, deliver: deliver, log: log.write)
  }

  // MARK: - Finding 3: tests do not write to the production log

  /// THAT defect. `report()` logged via a hard-wired `CMLogger.log(...)`, so
  /// the state file and the delivery could be substituted, but not the log.
  /// Measured 25.09.2026: `~/Library/Logs/CloudMachine/cloudmachine.log`
  /// contained 117 lines with the word "szczegoly" (Polish for "details"),
  /// which came only from this class's report helper - all from one day, i.e.
  /// from `swift test` runs. The production log is the only trace of backup
  /// failures and it stopped allowing real events to be told apart from test
  /// ones.
  func testReportWithSubstitutedLogDoesNotTouchTheProductionOne() async {
    let marker = "CM-TEST-\(UUID().uuidString)"
    XCTAssertEqual(
      linesInProductionLog(containing: marker), 0,
      "the marker is a fresh UUID - it cannot be there before the test")

    let delivered = await report(
      healthReport(["No successful backup for 5 h \(marker)"]), deliver: { _, _ in false })
    XCTAssertFalse(delivered)

    // The content MUST be produced - just not in the production file. If it
    // disappeared, the "fix" would consist of silencing the alarm, not of
    // redirecting it.
    XCTAssertTrue(
      log.lines.contains { $0.contains(marker) },
      "the substituted log must receive the report content: \(log.lines)")
    XCTAssertTrue(
      log.lines.contains { $0.contains("FAILED to show the backup failure notification") },
      "a failed delivery must also be recorded - where the test can see it")

    XCTAssertEqual(
      linesInProductionLog(containing: marker), 0,
      "the test must not append a single line to \(CMPaths.combinedLogFile.path)")
  }

  /// The other side of the same fix - and the only test in this class that
  /// DELIBERATELY writes to the production log (one line, marked as a canary).
  ///
  /// Without this test the fix could have silenced REAL alarms and nobody
  /// would have noticed: a backup failure does not get in the way of daily
  /// work, and the log is the only trace from which it can be reconstructed
  /// later. Silence in the log would look exactly the same as a working
  /// backup.
  func testRealRunStillWritesToTheLog() async throws {
    let marker = "TEST-CANARY-\(UUID().uuidString)"
    let canary = BackupHealth.Report(
      problems: [
        BackupHealth.Problem(
          summary: "this was not a failure, it is a test canary \(marker)",
          detail:
            "the line was appended by HealthAlertTests to prove that a report without a substituted log still reaches cloudmachine.log"
        )
      ], lastSuccess: nil, lastAttempt: nil)

    XCTAssertEqual(linesInProductionLog(containing: marker), 0)

    // `log:` is NOT substituted - that is the core of the test. `deliver:` is,
    // and only because otherwise a notification about a failure that does not
    // exist would pop up on the user's screen; we return `true` so that a
    // second line (about a failed delivery) does not reach the log.
    await HealthAlert.report(
      canary, stateFile: stateFile, deliver: { _, _ in true })

    XCTAssertEqual(
      linesInProductionLog(containing: marker), 1,
      """
      A real report MUST reach \(CMPaths.combinedLogFile.path). \
      If this is 0, the fix silenced the alarm instead of redirecting it.
      """)
  }

  /// How many lines of the tail of the production log contain `marker`.
  ///
  /// We read the TAIL, not the whole file: `CMLogger.rotateIfLarge` trims it
  /// only at 200 MB, so pulling the whole thing into memory in a test invites a
  /// test that over time starts taking seconds. The marker is a fresh UUID, so
  /// we are interested only in lines appended during this run - those are
  /// always at the end.
  private func linesInProductionLog(containing marker: String) -> Int {
    let file = CMPaths.combinedLogFile
    guard let handle = try? FileHandle(forReadingFrom: file) else { return 0 }
    defer { try? handle.close() }
    let size = (try? handle.seekToEnd()) ?? 0
    let tail: UInt64 = 256 * 1024
    try? handle.seek(toOffset: size > tail ? size - tail : 0)
    guard let data = try? handle.readToEnd(), let text = String(data: data, encoding: .utf8)
    else { return 0 }
    return text.split(separator: "\n").filter { $0.contains(marker) }.count
  }

  // MARK: - Item 6: a failed notification is not a report

  /// THAT failure. `osascript` fails (permission refused for the launchd
  /// process, no Aqua session, time limit), and `report()` still wrote
  /// `lastSummary` and `lastAlertAt` and returned `true`. From that moment
  /// `shouldAlert` blocked further attempts for 12 hours - the alarm vanished
  /// silently, i.e. the supervision died together with the supervised.
  func testFailedNotificationDoesNotSilenceTheAlarm() async {
    let problems = healthReport(["No successful backup for 5 h"])

    let first = await report(problems, deliver: { _, _ in false })
    XCTAssertFalse(first, "A report nobody saw is not a report.")

    // Five minutes later, the same problem: it MUST try again, not wait 12
    // hours.
    let retried = AttemptCounter()
    let second = await report(
      problems, now: Date().addingTimeInterval(300),
      deliver: { _, _ in
        retried.increment()
        return true
      })
    XCTAssertEqual(retried.count, 1, "After a failed attempt the alarm must come back.")
    XCTAssertTrue(second)
  }

  /// A failed delivery must be VISIBLE - an alarm that did not arrive will by
  /// definition not be noticed, so it must be possible to see it where a
  /// person looks on their own (`drive-status`).
  func testFailedDeliveryCanBeRead() async {
    let when = Date(timeIntervalSince1970: 1_758_000_000)
    await report(
      healthReport(["The backup image is not attached"]), now: when, deliver: { _, _ in false })

    let failure = HealthAlert.lastDeliveryFailure(stateFile: stateFile)
    XCTAssertNotNil(failure)
    XCTAssertEqual(failure?.at, when)
    XCTAssertEqual(failure?.summary, "The backup image is not attached")

    // After a successful delivery the trace disappears - otherwise it would
    // hang there forever.
    await report(
      healthReport(["The backup image is not attached"]), now: when.addingTimeInterval(3600),
      deliver: { _, _ in true })
    XCTAssertNil(HealthAlert.lastDeliveryFailure(stateFile: stateFile))
  }

  // MARK: - Item 8: the gap between reminders

  /// THAT defect. The problem text contains the age of the failure ("No
  /// successful backup for 3 h"), so during an ongoing failure it changed
  /// EVERY HOUR. The condition "different text = new problem" was then met on
  /// every run and the notification came back every hour instead of once
  /// every twelve - and an alarm without a gap turns into noise and stops
  /// meaning anything.
  func testGrowingFailureAgeIsNotANewProblem() async {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    let delivered = await report(
      healthReport(["No successful backup for 3 h"]), now: start, deliver: { _, _ in true })
    XCTAssertTrue(delivered)

    // An hour later the same failure describes itself with a different text.
    let counter = AttemptCounter()
    let again = await report(
      healthReport(["No successful backup for 4 h"]), now: start.addingTimeInterval(3600),
      deliver: { _, _ in
        counter.increment()
        return true
      })
    XCTAssertEqual(counter.count, 0, "It is the same failure, just older - we do not alarm anew.")
    XCTAssertFalse(again)
  }

  /// After the reminder period the same failure must speak up again -
  /// otherwise the alarm lights up once and goes out forever.
  func testAfterTheReminderPeriodTheSameFailureComesBack() {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    save(
      identity: HealthAlert.identity(of: healthReport(["No successful backup for 3 h"]).problems),
      at: start)

    let fingerprint = HealthAlert.identity(
      of: healthReport(["No successful backup for 15 h"]).problems)
    XCTAssertFalse(
      HealthAlert.shouldAlert(
        identity: fingerprint, now: start.addingTimeInterval(11 * 3600), stateFile: stateFile),
      "Before 12 h have passed we stay silent.")
    XCTAssertTrue(
      HealthAlert.shouldAlert(
        identity: fingerprint, now: start.addingTimeInterval(13 * 3600), stateFile: stateFile),
      "After 12 h we remind - the failure lasts until someone fixes it.")
  }

  /// A NEW problem added to the list must alarm right away, without waiting
  /// for the reminder window. Without this test a "fix" silencing everything
  /// for 12 hours would go unnoticed.
  func testNewProblemAlarmsRightAway() {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    save(
      identity: HealthAlert.identity(of: healthReport(["No successful backup for 3 h"]).problems),
      at: start)

    let twoProblems = HealthAlert.identity(
      of: healthReport(["No successful backup for 4 h", "The backup image is not attached"])
        .problems)
    XCTAssertTrue(
      HealthAlert.shouldAlert(
        identity: twoProblems, now: start.addingTimeInterval(600), stateFile: stateFile))
  }

  /// The fingerprint itself: numbers disappear, content stays.
  func testFingerprintCutsNumbersButNotContent() {
    XCTAssertEqual(
      HealthAlert.fingerprint("No successful backup for 3 h"),
      HealthAlert.fingerprint("No successful backup for 27 h"))
    XCTAssertNotEqual(
      HealthAlert.fingerprint("No successful backup for 3 h"),
      HealthAlert.fingerprint("The backup image is not attached"))
    // Two DIFFERENT problems differ only by the number in parentheses - it is
    // still the same kind of failure and there is no reason to alarm anew at
    // every GB.
    XCTAssertEqual(
      HealthAlert.fingerprint("Google Drive is running out of space (28 GB)"),
      HealthAlert.fingerprint("Google Drive is running out of space (12 GB)"))
  }

  /// Recovery deletes the state, so that the next failure is reported right
  /// away.
  func testRecoveryDeletesTheState() async {
    await report(healthReport(["No successful backup for 3 h"]), deliver: { _, _ in true })
    XCTAssertTrue(FileManager.default.fileExists(atPath: stateFile.path))

    await report(healthReport([]), deliver: { _, _ in true })
    XCTAssertFalse(FileManager.default.fileExists(atPath: stateFile.path))
  }

  // MARK: - The UI language does not change identity or persisted state

  /// The same failure seen by a Polish-language run and by an English-language
  /// run must have the same identity. Otherwise switching the system language
  /// - or the GUI and a launchd agent running with different languages -
  /// would look like a new problem and break the 12-hour quiet window.
  func testIdentityDoesNotDependOnTheUILanguage() {
    let now = Date(timeIntervalSince1970: 1_758_000_000)
    func evaluated() -> BackupHealth.Report {
      BackupHealth.evaluate(
        lastSuccess: now.addingTimeInterval(-5 * 3600), lastAttempt: nil, result: 0, now: now,
        mounted: true, attached: false, destinationRegistered: nil, erroredFiles: 3,
        outOfSpace: false, queueReadable: true)
    }

    L10n.language = .pl
    let polish = evaluated()
    L10n.language = .en
    let english = evaluated()

    XCTAssertNotEqual(
      polish.problems.map(\.summary), english.problems.map(\.summary),
      "the summaries are translated - otherwise this test checks nothing")
    XCTAssertEqual(
      HealthAlert.identity(of: polish.problems), HealthAlert.identity(of: english.problems))
  }

  /// The delivery-failure reason is written in a language-independent form
  /// and translated only when shown.
  func testDeliveryFailureReasonIsPersistedLanguageIndependently() async throws {
    L10n.language = .pl
    await report(healthReport(["No successful backup for 5 h"]), deliver: { _, _ in false })
    L10n.language = .en

    let state = try XCTUnwrap(HealthAlert.loadState(stateFile))
    XCTAssertEqual(state.deliveryError, HealthAlert.osascriptFailureReason)
    XCTAssertEqual(
      HealthAlert.lastDeliveryFailure(stateFile: stateFile)?.reason,
      "osascript did not show the notification (permissions or no graphical session)")
  }

  // MARK: - Helpers

  private func save(identity: String, at date: Date) {
    let state = HealthAlert.AlertState(
      lastSummary: "irrelevant", lastAlertAt: date, lastIdentity: identity, delivered: true,
      deliveryError: nil)
    let data = try! JSONEncoder().encode(state)
    try! data.write(to: stateFile)
  }

  /// A log collected in memory. A class, because the `log` closure is
  /// `@Sendable`.
  private final class CapturedLog: @unchecked Sendable {
    private let lock = NSLock()
    private var collected: [String] = []

    /// The method reference is passed directly as the `log:` argument.
    func write(_ line: String) {
      lock.lock()
      collected.append(line)
      lock.unlock()
    }

    var lines: [String] {
      lock.lock()
      defer { lock.unlock() }
      return collected
    }
  }

  /// Counter of delivery attempts. A class, because the `deliver` closure is
  /// `@Sendable`.
  private final class AttemptCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    func increment() {
      lock.lock()
      value += 1
      lock.unlock()
    }
    var count: Int {
      lock.lock()
      defer { lock.unlock() }
      return value
    }
  }
}
