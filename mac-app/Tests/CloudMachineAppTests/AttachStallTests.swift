import XCTest

@testable import CloudMachineCore

/// When a series of refused attaches ends in a restart of the mount - and
/// when it must not.
final class AttachStallTests: XCTestCase {

  private let boot: TimeInterval = 1_792_999_292
  private let start: TimeInterval = 1_793_000_000
  /// The attach agent's tick.
  private let tick: TimeInterval = 15 * 60

  private let refused = CMActionResult(
    succeeded: false,
    message:
      "Could not attach the image: hdiutil: attach failed - Resource temporarily unavailable",
    attachTemporarilyUnavailable: true)
  private let attached = CMActionResult(succeeded: true, message: "Attached")

  private final class Restarts: @unchecked Sendable {
    var count = 0
  }

  /// Runs the attach outcomes one tick apart, carrying the record along.
  private func ticks(
    _ outcomes: [CMActionResult], from record: AttachStall.Record? = nil,
    restartResult: CMActionResult = CMActionResult(succeeded: true, message: "restarted")
  ) async -> (record: AttachStall.Record?, restarts: Int) {
    let restarts = Restarts()
    var record = record
    for (i, outcome) in outcomes.enumerated() {
      record = await AttachStall.handle(
        outcome, record: record, bootTime: boot, now: start + Double(i) * tick,
        restart: {
          restarts.count += 1
          return restartResult
        }
      ).record
    }
    return (record, restarts.count)
  }

  func testRecognizesTheHdiutilRefusal() {
    XCTAssertTrue(
      BackupImageService.isTemporarilyUnavailable(
        stderr:
          "hdiutil: WARNING: 'hdiutil attach -nobrowse -mountpoint ...' is deprecated.\nhdiutil: attach failed - Resource temporarily unavailable\n"
      ))
    XCTAssertFalse(
      BackupImageService.isTemporarilyUnavailable(
        stderr: "hdiutil: attach failed - RPC version wrong"))
  }

  /// KNOWN BAD SAMPLE, 25-26 Oct 2026: every attach refused for 26 h, and
  /// nothing but a restart of the Mac helped. Three ticks (30 min) are enough.
  func testASeriesOfRefusalsRestartsTheMount() async {
    let result = await ticks([refused, refused])
    XCTAssertEqual(result.restarts, 0)
    let third = await ticks([refused, refused, refused])
    XCTAssertEqual(third.restarts, 1)
  }

  /// Refusals just after a start-up are normal (26.10 08:27) - three of them
  /// in quick succession are not yet a series.
  func testThreeQuickRefusalsAreNotASeries() async {
    let quick = AttachStall.addingFailure(
      to: AttachStall.addingFailure(
        to: AttachStall.addingFailure(to: nil, bootTime: boot, now: start), bootTime: boot,
        now: start + 60), bootTime: boot, now: start + 120)
    XCTAssertEqual(quick.failures, 3)
    XCTAssertFalse(AttachStall.shouldRestart(quick, bootTime: boot, now: start + 120))
  }

  /// A success between the refusals ends the series.
  func testASuccessEndsTheSeries() async {
    let result = await ticks([refused, refused, attached, refused, refused])
    XCTAssertEqual(result.restarts, 0)
  }

  /// Other failures (the buffer not ready, an orphaned mount point) are not
  /// what a fresh rclone fixes.
  func testOtherFailuresEndTheSeries() async {
    let other = CMActionResult(succeeded: false, message: "Drive is not mounted.")
    let result = await ticks([refused, refused, other, refused, refused])
    XCTAssertEqual(result.restarts, 0)
  }

  /// "Busy with another operation" says nothing about the mount: it neither
  /// ends the series nor adds to it.
  func testBusyNeitherEndsNorExtendsTheSeries() async {
    let busy = CMActionResult(succeeded: false, message: "busy", didNotRun: true)
    let result = await ticks([refused, busy, refused, busy, refused])
    XCTAssertEqual(result.restarts, 1)
    XCTAssertEqual(result.record?.failures, 0)
  }

  /// If a fresh rclone did not help, another one within the cooldown will
  /// not either - and every restart cuts the upload short.
  func testAtMostOneRestartPerCooldown() async {
    let hours = Int(AttachStall.cooldown / tick)
    let result = await ticks(Array(repeating: refused, count: hours - 1))
    XCTAssertEqual(result.restarts, 1)
    let longer = await ticks(Array(repeating: refused, count: hours + 3))
    XCTAssertEqual(longer.restarts, 2)
  }

  /// The cooldown holds across a short success, or restarts would follow
  /// every flap.
  func testCooldownSurvivesASuccess() async {
    let result = await ticks([refused, refused, refused, attached, refused, refused, refused])
    XCTAssertEqual(result.restarts, 1)
  }

  /// A refusal of the restart (Time Machine backing up, tmutil silent)
  /// touched nothing - the next refused attach asks again, no cooldown.
  func testRefusedRestartDoesNotStartTheCooldown() async {
    let refusedRestart = CMActionResult(succeeded: false, message: "backing up", didNotRun: true)
    let result = await ticks(
      [refused, refused, refused, refused], restartResult: refusedRestart)
    XCTAssertEqual(result.restarts, 2)
    XCTAssertEqual(result.record?.restartedAt, 0)
  }

  /// A restart that ran and failed (the queue did not drain) still starts the
  /// cooldown: running the same drain every tick would not change its answer.
  func testFailedRestartStartsTheCooldown() async {
    let failed = CMActionResult(succeeded: false, message: "not drained")
    let result = await ticks(
      [refused, refused, refused, refused, refused, refused, refused],
      restartResult: failed)
    XCTAssertEqual(result.restarts, 1)
  }

  /// A record from before a restart of the Mac describes a mount that is gone.
  func testARecordFromAnotherBootIsIgnored() async {
    let old = AttachStall.Record(
      bootTime: boot - 86_400, firstFailureAt: start - 7200, failures: 9, restartedAt: start - 600)
    let result = await ticks([refused], from: old)
    XCTAssertEqual(result.restarts, 0)
    XCTAssertEqual(result.record?.failures, 1)
    XCTAssertEqual(result.record?.restartedAt, 0)
  }

  func testRecordTextRoundTrips() {
    let record = AttachStall.Record(
      bootTime: boot, firstFailureAt: start, failures: 4, restartedAt: start + 900)
    XCTAssertEqual(AttachStall.Record(text: record.text), record)
    XCTAssertNil(AttachStall.Record(text: "garbage"))
    XCTAssertNil(AttachStall.Record(text: "1 2 3"))
  }
}
