import XCTest

@testable import CloudMachineCore

/// Tests of waiting for the upload before `hdiutil attach`.
///
/// They replay the start-up of 01.10.2026: a backlog of ~600 bands draining
/// over ~6 min. The old wait (a fixed 120 s) gave up halfway and hdiutil
/// started in the middle of the full upload.
final class UploadDrainTests: XCTestCase {

  private final class FakeClock {
    private(set) var now = Date(timeIntervalSince1970: 1_757_700_000)
    func sleep(_ seconds: TimeInterval) { now.addTimeInterval(seconds) }
  }

  /// KNOWN BAD SAMPLE: 600 items drain at ~2 per second, i.e. ~5 min.
  /// A fixed 120 s would have let hdiutil go with ~360 items in the queue.
  func testWaitsForABacklogThatTakesLongerThanTwoMinutes() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: { max(0, 600 - Int(clock.now.timeIntervalSince(start) * 2)) })
    XCTAssertEqual(outcome, .idle)
    XCTAssertGreaterThanOrEqual(clock.now.timeIntervalSince(start), 300)
  }

  /// Daily limit exhausted: the queue stands still. We then do not wait the full
  /// 20 min, only `stallTimeout`.
  func testGivesUpWhenTheQueueStandsStill() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {}, unsent: { 42 })
    XCTAssertEqual(outcome, .stalled(unsent: 42))
    let elapsed = clock.now.timeIntervalSince(start)
    XCTAssertGreaterThanOrEqual(elapsed, UploadDrain.defaultStallTimeout)
    XCTAssertLessThan(elapsed, UploadDrain.defaultStallTimeout + UploadDrain.defaultPoll * 2)
  }

  /// Upward swings (TM adding writes) are not progress - only a new minimum counts.
  func testSwingsWithoutANewMinimumAreNotProgress() async {
    let clock = FakeClock()
    var flip = false
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: {
        flip.toggle()
        return flip ? 50 : 60
      })
    XCTAssertEqual(outcome, .stalled(unsent: 50))
  }

  /// Hard ceiling: the queue drains, but more slowly than needed.
  func testHardCeilingOnSlowProgress() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: { 100_000 - Int(clock.now.timeIntervalSince(start)) })
    guard case .timedOut = outcome else { return XCTFail("\(outcome)") }
    XCTAssertLessThan(
      clock.now.timeIntervalSince(start), UploadDrain.defaultMaxTotal + UploadDrain.defaultPoll * 2)
  }

  /// rclone is silent - that is neither progress nor an empty queue.
  func testNoAnswerIsNotAnEmptyQueue() async {
    let clock = FakeClock()
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {}, unsent: { nil })
    XCTAssertEqual(outcome, .noAnswer)
  }

  /// Items read from the dirty cache AFTER the first deadline move get the
  /// full 10 min - the move has to be repeated.
  func testRepeatsMovingTheDeadlines() async {
    let clock = FakeClock()
    var expiries = 0
    _ = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: { expiries += 1 }, unsent: { 7 })
    XCTAssertGreaterThanOrEqual(expiries, 2)
  }
}
