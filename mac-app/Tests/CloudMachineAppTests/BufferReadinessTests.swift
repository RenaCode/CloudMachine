import XCTest

@testable import CloudMachineCore

/// Tests of waiting for a ready buffer.
///
/// Each one replays a specific race that has already happened live - we do
/// not check that the function "works", but that it behaves differently from
/// the version that left Time Machine without a destination on 13 Sep 2026.
final class BufferReadinessTests: XCTestCase {

  /// A clock that moves only when the code would really sleep. Thanks to that
  /// the test measures WAITING, not the speed of the machine.
  private final class FakeClock {
    private(set) var now = Date(timeIntervalSince1970: 1_757_700_000)
    func sleep(_ seconds: TimeInterval) { now.addTimeInterval(seconds) }
  }

  // MARK: - Readiness condition

  /// This is the second race: the mount is already up, but rclone has not yet
  /// read the dirty cache, so the directory is empty. The old version treated
  /// that as ready and the attach failed with "No image".
  func testMountWithoutImageIsNotReady() {
    XCTAssertFalse(BufferReadiness.isReady(mounted: true, imageVisible: false))
  }

  func testImageWithoutMountIsNotReady() {
    XCTAssertFalse(BufferReadiness.isReady(mounted: false, imageVisible: true))
  }

  func testBothMeanReady() {
    XCTAssertTrue(BufferReadiness.isReady(mounted: true, imageVisible: true))
  }

  // MARK: - Waiting

  /// KNOWN BAD SAMPLE: the buffer comes up after 150 s. The old 120 s limit
  /// gave up ten seconds too early, and that is exactly what happened on
  /// 13 Sep 2026.
  func testWaitsForABufferThatComesUpAfter150s() async {
    let clock = FakeClock()
    let readyAt = clock.now.addingTimeInterval(150)

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { clock.now >= readyAt })

    XCTAssertTrue(ready, "The buffer came up after 150 s - the wait has to catch it")
  }

  /// Proof that the previous test does not pass because the function always
  /// returns `true`: a buffer that NEVER comes up must be reported as a failure.
  func testGivesUpWhenTheBufferNeverComesUp() async {
    let clock = FakeClock()

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { false })

    XCTAssertFalse(ready, "The buffer never came up - this has to be a failure, not silence")
  }

  /// The wait has to end roughly at the declared limit, not drag on forever:
  /// launchd waits for this process.
  func testStopsWaitingAtTheDeclaredLimit() async {
    let clock = FakeClock()
    let start = clock.now

    _ = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { false })

    let elapsed = clock.now.timeIntervalSince(start)
    XCTAssertGreaterThanOrEqual(elapsed, BufferReadiness.defaultTimeout)
    XCTAssertLessThan(elapsed, BufferReadiness.defaultTimeout + BufferReadiness.defaultPoll * 2)
  }

  /// A ready buffer must not cost a single sleep - `attach-image` also runs by
  /// hand and on every launchd tick.
  func testReadyBufferDoesNotWaitAtAll() async {
    let clock = FakeClock()
    let start = clock.now

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { true })

    XCTAssertTrue(ready)
    XCTAssertEqual(clock.now, start, "A ready buffer has to return immediately")
  }

  /// The limit has to be greater than the observed 150 s, otherwise the fix is
  /// only apparent. Written down explicitly, so that nobody cuts it back to two
  /// minutes.
  func testLimitIsGreaterThanTheObservedRace() {
    XCTAssertGreaterThan(BufferReadiness.defaultTimeout, 150)
  }
}
