import XCTest

@testable import CloudMachineCore

/// The machine's buffer guard (`vm-guard`, port of the shell `tm-guard.sh`).
///
/// The rules the shell version had, each pinned: pause over a threshold only
/// a RUNNING backup, resume only what the guard itself paused, and do nothing
/// at all when the machine or tmutil does not answer. Walked through
/// `step()` too, because the marker is what ties two runs together - the same
/// reason `BufferGuardDecisionTests` walks whole sequences.
final class VMGuardDecisionTests: XCTestCase {
  private let thresholds = VMGuard.Thresholds()
  private let gib: Int64 = 1 << 30

  private func reading(usedGiB: Int64, freeGiB: Int64 = 150, queued: Int = 3) -> VMLayout.Reading {
    VMLayout.Reading(
      buffer: .init(bytesUsed: usedGiB * gib, uploadsQueued: queued, uploadsInProgress: 1),
      freeBytes: freeGiB * gib)
  }

  // MARK: - The decision

  func testDefaultsAreTheOnesTheFirstBackupRanWith() {
    XCTAssertEqual(thresholds, .init(highGiB: 110, lowGiB: 40, minFreeGiB: 40))
  }

  func testNoAnswerFromTheMachineDoesNothing() {
    for paused in [false, true] {
      for running in [Bool?.none, true, false] {
        XCTAssertEqual(
          VMGuard.decide(
            reading: nil, backupRunning: running, pausedByGuard: paused, thresholds: thresholds),
          .nothing, "no reading must never pause or resume (running=\(String(describing: running)))"
        )
      }
    }
  }

  func testFullBufferPausesARunningBackup() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 111), backupRunning: true, pausedByGuard: false,
        thresholds: thresholds), .pause)
  }

  func testExactlyAtTheHighThresholdIsNotOver() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 110), backupRunning: true, pausedByGuard: false,
        thresholds: thresholds), .nothing)
  }

  func testLowFreeSpacePausesEvenWithASmallBuffer() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 5, freeGiB: 39), backupRunning: true, pausedByGuard: false,
        thresholds: thresholds), .pause)
  }

  func testOverThresholdWithoutARunningBackupDoesNothing() {
    for running in [Bool?.none, false] {
      XCTAssertEqual(
        VMGuard.decide(
          reading: reading(usedGiB: 115), backupRunning: running, pausedByGuard: false,
          thresholds: thresholds), .nothing,
        "tmutil not answering is not 'running' (running=\(String(describing: running)))")
    }
  }

  func testResumesOnlyWhatItPaused() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 39), backupRunning: false, pausedByGuard: true,
        thresholds: thresholds), .resume)
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 0), backupRunning: false, pausedByGuard: false,
        thresholds: thresholds), .nothing,
      "a backup the person stopped is not the guard's to start")
  }

  func testBetweenThresholdsKeepsThePause() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 40), backupRunning: false, pausedByGuard: true,
        thresholds: thresholds), .nothing, "hysteresis: resume only BELOW the low threshold")
  }

  func testDoesNotResumeIntoADiskWithoutRoom() {
    XCTAssertEqual(
      VMGuard.decide(
        reading: reading(usedGiB: 10, freeGiB: 30), backupRunning: false, pausedByGuard: true,
        thresholds: thresholds), .nothing)
  }

  // MARK: - Whole steps

  private final class Fake: @unchecked Sendable {
    private let lock = NSLock()
    private var _reading: VMLayout.Reading?
    private var _running: Bool? = true
    private var _marker = false
    private var _tmutilSucceeds = true
    private var _calls: [String] = []
    private var _log: [String] = []

    private func locked<T>(_ body: () -> T) -> T {
      lock.lock()
      defer { lock.unlock() }
      return body()
    }
    var reading: VMLayout.Reading? {
      get { locked { _reading } }
      set { locked { _reading = newValue } }
    }
    var running: Bool? {
      get { locked { _running } }
      set { locked { _running = newValue } }
    }
    var marker: Bool {
      get { locked { _marker } }
      set { locked { _marker = newValue } }
    }
    var tmutilSucceeds: Bool {
      get { locked { _tmutilSucceeds } }
      set { locked { _tmutilSucceeds = newValue } }
    }
    var calls: [String] { locked { _calls } }
    var log: [String] { locked { _log } }
    func call(_ command: String) -> Bool {
      locked {
        _calls.append(command)
        return _tmutilSucceeds
      }
    }
    func record(_ line: String) { locked { _log.append(line) } }

    var probes: VMGuard.Probes {
      VMGuard.Probes(
        reading: { self.reading }, backupRunning: { self.running },
        markerExists: { self.marker }, setMarker: { self.marker = $0 },
        tmutil: { self.call($0) }, log: { self.record($0) }, minute: { 17 })
    }
  }

  func testPauseThenResumeAcrossRuns() async {
    let fake = Fake()
    let guardian = VMGuard(thresholds: thresholds, probes: fake.probes)

    fake.reading = reading(usedGiB: 120)
    let first = await guardian.step()
    XCTAssertEqual(first, .pause)
    XCTAssertEqual(fake.calls, ["stopbackup"])
    XCTAssertTrue(fake.marker, "the marker is what lets the guard resume later")

    fake.running = false
    fake.reading = reading(usedGiB: 60)
    let second = await guardian.step()
    XCTAssertEqual(second, .nothing)

    fake.reading = reading(usedGiB: 20)
    let third = await guardian.step()
    XCTAssertEqual(third, .resume)
    XCTAssertEqual(fake.calls, ["stopbackup", "startbackup"])
    XCTAssertFalse(fake.marker)
  }

  func testFailedStopDoesNotClaimThePause() async {
    let fake = Fake()
    fake.tmutilSucceeds = false
    fake.reading = reading(usedGiB: 120)
    await VMGuard(thresholds: thresholds, probes: fake.probes).step()
    XCTAssertFalse(
      fake.marker,
      "with no marker after a failed stop the guard will not later start a backup it never paused")
  }

  /// The shell version removed the marker BEFORE `startbackup`; one failure
  /// left the backup paused with nobody to resume it.
  func testFailedResumeKeepsTheMarkerForTheNextRun() async {
    let fake = Fake()
    fake.marker = true
    fake.running = false
    fake.tmutilSucceeds = false
    fake.reading = reading(usedGiB: 10)
    let guardian = VMGuard(thresholds: thresholds, probes: fake.probes)
    await guardian.step()
    XCTAssertTrue(fake.marker)

    fake.tmutilSucceeds = true
    let retry = await guardian.step()
    XCTAssertEqual(retry, .resume)
    XCTAssertFalse(fake.marker)
  }

  func testNoAnswerLeavesTheMarkerAndCallsNothing() async {
    let fake = Fake()
    fake.marker = true
    fake.reading = nil
    await VMGuard(thresholds: thresholds, probes: fake.probes).step()
    XCTAssertTrue(fake.calls.isEmpty)
    XCTAssertTrue(fake.marker)
    XCTAssertTrue(fake.log.contains { $0.contains("NO ANSWER") }, "\(fake.log)")
  }
}
