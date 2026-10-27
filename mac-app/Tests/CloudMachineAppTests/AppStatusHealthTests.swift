import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Tests of the one sentence the user actually reads: the green badge
/// and the headline in the menu bar.
///
/// They exist because mutation testing exposed a gap: `healthy` and `headline` had NO
/// test at all, so a fix adding a condition to them passed, but its inverse
/// would have passed just as well.
///
/// Headlines that come from `UploadState` or `BackupHealth.formatAge` (CloudMachineCore)
/// are compared with the core's own text: their wording is that module's business,
/// what matters here is that `headline` routes to them.
@MainActor
final class AppStatusHealthTests: XCTestCase {

  private func healthyStatus() -> AppStatus { AppStatus.healthyForTests() }

  private func withReading(
    _ status: AppStatus, _ change: (inout VMLayout.BufferStats) -> Void
  ) {
    var machine = status.machine
    var buffer = machine.reading!.buffer
    change(&buffer)
    machine.reading!.buffer = buffer
    status.machine = machine
  }

  func testHealthyStateIsHealthy() {
    let status = healthyStatus()
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.headline, "Ready")
    XCTAssertEqual(status.overallTone, .success)
  }

  /// REGRESSION 23.09.2026: rclone did not answer, the caller substituted
  /// zeros and the menu bar showed "Ready" with bands waiting in the queue.
  func testUnreadQueueTakesAwayGreenBadge() {
    let status = healthyStatus()
    withReading(status) { $0.unsentBytes = nil }
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.machine.uploadState, .queueUnknown)
    XCTAssertEqual(status.headline, UploadState.queueUnknown.headline)
  }

  /// An open remote control makes any web page able to delete the backup.
  func testOpenRemoteControlTakesAwayGreenAndSaysSo() {
    let status = healthyStatus()
    status.remoteControlOpen = true
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "rclone's remote control is open on this Mac")
    XCTAssertEqual(status.overallTone, .danger)
  }

  /// REGRESSION 09.10.2026: the button followed `healthy`, so an OLD backup -
  /// the very thing it fixes - greyed it out.
  func testStaleBackupStillAllowsBackingUp() {
    let status = healthyStatus()
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-3 * 24 * 3600)
    XCTAssertFalse(status.healthy)
    XCTAssertTrue(status.canStartBackup)
  }

  func testUnreadQueueStillAllowsBackingUp() {
    let status = healthyStatus()
    withReading(status) { $0.unsentBytes = nil }
    XCTAssertTrue(status.canStartBackup)
  }

  func testNowhereToBackUpToBlocksTheButton() {
    var status = healthyStatus()
    status.machine.state = .notRunning("Stopped")
    XCTAssertFalse(status.canStartBackup)
    XCTAssertTrue(status.canStartMachine)

    status = healthyStatus()
    status.timeMachineState = .notRegistered
    XCTAssertFalse(status.canStartBackup)

    status = healthyStatus()
    status.machine.services["smbd"] = "failed"
    XCTAssertFalse(status.canStartBackup)

    status = healthyStatus()
    status.isBusy = true
    XCTAssertFalse(status.canStartBackup)
  }

  /// An empty queue with abandoned bands is not "Everything uploaded" - the
  /// data exists only in the machine.
  func testAbandonedBandsAreNotEverythingUploaded() {
    let status = healthyStatus()
    withReading(status) { $0.erroredFiles = 3 }
    XCTAssertNotEqual(status.machine.queueSummary, "Everything uploaded")
    XCTAssertTrue(status.machine.queueSummary.contains("3"))
  }

  func testQueueRowStates() {
    let status = healthyStatus()
    XCTAssertEqual(status.machine.queueSummary, "Everything uploaded")
    withReading(status) {
      $0.unsentBytes = 5 * VMGuard.gib
      $0.uploadsQueued = 160
      $0.uploadsInProgress = 8
    }
    XCTAssertEqual(status.machine.queueSummary, "5 GiB in 160 bands, 8 uploading")
    withReading(status) { $0.unsentBytes = nil }
    XCTAssertEqual(status.machine.queueSummary, "not read")
    status.machine = MachineStatus()
    XCTAssertEqual(status.machine.queueSummary, "not read", "a fresh state is not a measurement")
  }

  /// Bands rclone did not upload exist only in the machine - the backup is
  /// not a copy.
  func testUnsentFilesTakeAwayGreenBadge() {
    let status = healthyStatus()
    withReading(status) { $0.erroredFiles = 2 }
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.machine.uploadState, .failedFiles(2))
  }

  func testFullBufferTakesAwayGreenBadge() {
    let status = healthyStatus()
    withReading(status) { $0.outOfSpace = true }
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.machine.uploadState, .bufferFull)
  }

  /// rclone in the machine down: nothing reaches the Drive.
  func testStoppedUploadTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.machine.services["rclone-tm"] = "activating"
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.machine.uploadState, .mountDown)
    XCTAssertEqual(status.headline, "A service in the CloudMachine machine is not running")
  }

  func testMachineStatesHaveTheirOwnHeadlines() {
    let status = healthyStatus()
    status.machine = MachineStatus()
    status.machine.state = .notCreated
    XCTAssertEqual(status.headline, "The CloudMachine machine is not set up yet")
    status.machine.state = .notRunning("Stopped")
    XCTAssertEqual(status.headline, "The CloudMachine machine is stopped")
    status.machine.state = .noAnswer
    XCTAssertEqual(status.headline, "The CloudMachine machine does not answer")
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.overallTone, .danger)
  }

  /// `tm-bands-bind` is skipped before `vm-prepare-bundle`; that is not a failure.
  func testSkippedBandBindIsNotAFailure() {
    let status = healthyStatus()
    status.machine.services["tm-bands-bind"] = "inactive"
    XCTAssertTrue(status.healthy)
    status.machine.services["tm-bands-bind"] = "failed"
    XCTAssertFalse(status.healthy)
  }

  func testChangedTimeMachineDestinationTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.timeMachineState = .notRegistered
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Time Machine does not point to CloudMachine")
  }

  func testUnconnectedDriveTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.remoteConfigured = false
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Google Drive not connected")
  }

  /// An upload in progress is NOT a failure - as long as the queue shrinks,
  /// everything goes as designed.
  func testUploadInProgressIsNotAFailure() {
    let status = healthyStatus()
    withReading(status) {
      $0.unsentBytes = 2 * VMGuard.gib
      $0.uploadsQueued = 60
      $0.uploadsInProgress = 4
    }
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.machine.uploadState, .flowing(queued: 64))
    XCTAssertEqual(status.headline, UploadState.flowing(queued: 64).headline)
  }

  /// THE failure: the machine runs, Time Machine points at it, the queue is
  /// empty - and the last COMPLETED backup is two days old.
  func testOldBackupTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-2 * 24 * 3600)
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(
      status.headline,
      "No completed backup for \(BackupHealth.formatAge(status.backupCycle.age()!))")
  }

  /// The threshold boundary works both ways.
  func testBackupAgeThresholdWorksBothWays() {
    let status = healthyStatus()
    let limit = BackupHealth.maxAgeHours * 3600
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-(limit - 60))
    XCTAssertTrue(status.healthy)
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-(limit + 60))
    XCTAssertFalse(status.healthy)
  }

  /// An unread backup counter is NOT the same as a backup made a moment ago.
  func testUnreadBackupCounterTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.backupCycle = BackupCycleStatus()
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Unknown when the last backup was made")
  }

  func testNoBackupAtAllTakesAwayGreenBadge() {
    let status = healthyStatus()
    status.backupCycle.lastSuccess = nil
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "There is no completed backup at all")
  }

  /// Time Machine has made its first image and the bands are still 875 MB on
  /// the machine's disk - `vm-prepare-bundle` is due, and only then.
  func testBundleIsDueOnlyForANewUnpreparedImage() {
    var machine = MachineStatus.healthyForTests
    XCTAssertFalse(machine.bundleNeedsPreparing)
    machine.bundlePrepared = false
    machine.imageCount = 0
    XCTAssertFalse(machine.bundleNeedsPreparing, "no image yet - Time Machine has to create it")
    machine.imageCount = 1
    XCTAssertTrue(machine.bundleNeedsPreparing)
    machine.bundlePrepared = nil
    XCTAssertFalse(machine.bundleNeedsPreparing, "unread is not 'not prepared'")
  }

  func testMachineStateFromLima() {
    XCTAssertEqual(MachineState.from(instanceStatus: .none), .noAnswer)
    XCTAssertEqual(MachineState.from(instanceStatus: .some(nil)), .notCreated)
    XCTAssertEqual(MachineState.from(instanceStatus: .some("Running")), .running)
    XCTAssertEqual(MachineState.from(instanceStatus: .some("Stopped")), .notRunning("Stopped"))
  }
}
