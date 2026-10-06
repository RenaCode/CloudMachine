import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Supervision of the supervisor itself: whether "the watchdog ran and had
/// nothing to report" can be told apart from "there is no watchdog".
///
/// `backup-health` runs with `StartInterval 1800` and WITHOUT `KeepAlive`, and
/// the only symptom of an unloaded or hung agent is silence - while silence is
/// the NORMAL state here (README: "Empty logs after a fresh install are
/// normal - the agents only write when something happens"). Until 25.09.2026
/// the watchdog left no trace behind, so these two states looked identical.
@MainActor
final class WatchdogHeartbeatTests: XCTestCase {

  private var directory: URL!
  private var marker: URL!

  override func setUpWithError() throws {
    directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-heartbeat-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    // EVERY test substitutes the file - none has the right to touch the real
    // marker in `~/Library/Application Support/CloudMachine/`, because then a
    // `swift test` run would report a watchdog that did not run.
    marker = directory.appendingPathComponent("backup-health-last-run")
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: directory)
  }

  // MARK: - The marker itself

  /// THAT defect: before the fix there was NOTHING to read.
  func testRunLeavesATraceThatCanBeRead() throws {
    let now = Date(timeIntervalSince1970: 1_790_000_000)
    XCTAssertTrue(WatchdogHeartbeat.record(now: now, file: marker))
    let read = try XCTUnwrap(
      WatchdogHeartbeat.lastRun(file: marker),
      "the marker must be readable back - otherwise it says nothing")
    XCTAssertEqual(
      read.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1)
  }

  /// The file must be readable by a person during diagnosis, not just by us.
  func testMarkerIsReadableText() throws {
    WatchdogHeartbeat.record(now: Date(timeIntervalSince1970: 1_790_000_000), file: marker)
    let content = try String(contentsOf: marker, encoding: .utf8)
    XCTAssertTrue(content.hasPrefix("2026-"), "got: \(content)")
  }

  /// A missing marker is NOT "the watchdog has not run for zero seconds" and
  /// not a read failure - it is a third, separate state. It happens on a fresh
  /// installation.
  func testMissingMarkerIsASeparateState() {
    XCTAssertNil(WatchdogHeartbeat.lastRun(file: marker))
    XCTAssertEqual(WatchdogHeartbeat.current(file: marker), .never)
  }

  // MARK: - Age assessment

  func testFreshRunIsFresh() {
    let now = Date()
    let assessment = WatchdogHeartbeat.freshness(
      lastRun: now.addingTimeInterval(-600), now: now)
    guard case .fresh = assessment else { return XCTFail("got: \(assessment)") }
  }

  /// Two missed runs in a row (StartInterval 1800) are no longer chance.
  func testSilenceLongerThanTheLimitIsNotFreshness() {
    let now = Date()
    let assessment = WatchdogHeartbeat.freshness(
      lastRun: now.addingTimeInterval(-3 * 3600), now: now)
    guard case .stale(_, let age) = assessment else { return XCTFail("got: \(assessment)") }
    XCTAssertEqual(age, 3 * 3600, accuracy: 1)
  }

  /// A marker from the future (a clock that was changed, a file moved from
  /// another machine) is NOT freshness: we do not know when the watchdog ran.
  /// We err on the side of a warning, not on the side of calm.
  func testMarkerFromTheFutureDoesNotPassAsFresh() {
    let now = Date()
    let assessment = WatchdogHeartbeat.freshness(
      lastRun: now.addingTimeInterval(3600), now: now)
    guard case .stale = assessment else { return XCTFail("got: \(assessment)") }
  }

  // MARK: - The line a person READS (drive-status and the panel)

  func testLineForAFreshRunGivesDateAndAge() {
    let now = Date()
    let line = StatusLines.watchdogRun(
      WatchdogHeartbeat.freshness(lastRun: now.addingTimeInterval(-720), now: now))
    XCTAssertTrue(line.contains("12 min ago"), "got: \(line)")
    XCTAssertFalse(line.contains("MAY NOT BE RUNNING"), "got: \(line)")
  }

  /// The core of item 13: the line must SAY that the watchdog may have stopped
  /// running. A date alone without that sentence disturbs nothing - a person's
  /// eyes slide over it just as over a date from two minutes ago.
  func testLineForASilentWatchdogWarns() {
    let now = Date()
    let line = StatusLines.watchdogRun(
      WatchdogHeartbeat.freshness(lastRun: now.addingTimeInterval(-3 * 24 * 3600), now: now))
    XCTAssertTrue(line.contains("THE WATCHDOG MAY NOT BE RUNNING"), "got: \(line)")
    XCTAssertTrue(line.contains("3 days ago"), "got: \(line)")
  }

  func testLineWithoutMarkerSaysSoPlainly() {
    let line = StatusLines.watchdogRun(.never)
    XCTAssertTrue(line.contains("NEVER"), "got: \(line)")
    XCTAssertFalse(line.contains("Optional"), "got: \(line)")
  }

  // MARK: - Panel

  /// Something unchecked has no right to shine green - just like `queueKnown`
  /// and `BackupCycleStatus.known`.
  func testPanelDoesNotTreatAnUncheckedWatchdogAsRunning() {
    let status = AppStatus()
    XCTAssertNil(status.watchdog)
    XCTAssertFalse(status.watchdogRunning)

    status.watchdog = WatchdogHeartbeat.freshness(
      lastRun: Date().addingTimeInterval(-3 * 3600))
    XCTAssertFalse(status.watchdogRunning, "a watchdog silent for 3 h is not a running watchdog")

    status.watchdog = WatchdogHeartbeat.freshness(lastRun: Date().addingTimeInterval(-300))
    XCTAssertTrue(status.watchdogRunning)
  }
}
