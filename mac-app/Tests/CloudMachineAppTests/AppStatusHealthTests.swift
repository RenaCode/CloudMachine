import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Tests of the one sentence the user actually reads: the green badge
/// and the headline in the menu bar.
///
/// They exist because mutation testing exposed a gap: `healthy` and `headline` had NO
/// test at all, so the fix adding `erroredFiles` and `outOfSpace` to them
/// passed, but its inverse would have passed just as well. Broken
/// and working looked identical in the test suite too.
///
/// Headlines that come from `UploadState` or `BackupHealth.formatAge` (CloudMachineCore)
/// are compared with the core's own text: their wording is that module's business,
/// what matters here is that `headline` routes to them.
@MainActor
final class AppStatusHealthTests: XCTestCase {

  /// A state in which everything really works - the reference point.
  private func healthy() -> AppStatus {
    let status = AppStatus()
    status.dependencyState = .ready
    status.remoteConfigured = true
    status.timeMachineState = .registered(mountPoint: "/Volumes/CloudMachine")
    var buffer = BufferStatus()
    buffer.mounted = true
    buffer.imageAttached = true
    // Must be explicit: `BufferStatus` starts from "queue not read", so that
    // a fresh, unchecked state does not pass for an empty queue.
    buffer.queueKnown = true
    buffer.freeDiskGB = 400
    status.buffer = buffer
    // CHANGE 23.09.2026: "everything attached" stopped being enough for the green
    // badge. The reference point now also has to contain the fact that a backup
    // WAS ACTUALLY made - because that is exactly what was missing in the failure for which
    // `BackupHealth` was created in the first place. Previously this helper described the state of the
    // devices and said nothing about whether the backup succeeded; the test "a healthy state
    // is healthy" therefore also passed for a Mac that had not made a backup for
    // two days.
    status.backupCycle = BackupCycleStatus(
      known: true, lastSuccess: Date().addingTimeInterval(-1800), problems: [],
      checkedAt: Date())
    return status
  }

  /// REGRESSION 23.09.2026: `rclone rc` did not answer within the time limit,
  /// the caller substituted zeros and the menu bar showed "Ready" with 386 bands
  /// waiting in the queue.
  func testUnreadQueueTakesAwayGreenBadge() {
    let status = healthy()
    status.buffer.queueKnown = false
    XCTAssertFalse(status.healthy, "Unknown = not green.")
    XCTAssertNotEqual(status.headline, "Ready")
    XCTAssertEqual(status.buffer.uploadState, .queueUnknown)
  }

  func testHealthyStateIsHealthy() {
    let status = healthy()
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.headline, "Ready")
  }

  /// THIS is the failure. Bands that rclone did not upload exist only
  /// on this Mac - so the backup is not a copy. The interface then showed
  /// a green badge and "Ready".
  func testUnsentFilesTakeAwayGreenBadge() {
    let status = healthy()
    status.buffer.erroredFiles = 7
    XCTAssertFalse(status.healthy, "Unsent bands MUST NOT pass for a healthy state.")
    XCTAssertEqual(status.buffer.uploadState, .failedFiles(7))
    XCTAssertEqual(status.headline, UploadState.failedFiles(7).headline)
  }

  /// rclone reports that it has nowhere left to put data. A stronger signal than
  /// any threshold of ours, because it comes from the one who really knows.
  func testFullBufferTakesAwayGreenBadge() {
    let status = healthy()
    status.buffer.outOfSpace = true
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.buffer.uploadState, .bufferFull)
    XCTAssertEqual(status.headline, UploadState.bufferFull.headline)
  }

  func testMissingMountTakesAwayGreenBadge() {
    let status = healthy()
    status.buffer.mounted = false
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Buffer is not working")
  }

  func testDetachedImageTakesAwayGreenBadge() {
    let status = healthy()
    status.buffer.imageAttached = false
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Backup image not attached")
  }

  func testChangedTimeMachineDestinationTakesAwayGreenBadge() {
    let status = healthy()
    status.timeMachineState = .notRegistered
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Time Machine does not point to CloudMachine")
  }

  /// The daily limit does NOT require action, but the bands then sit only on this Mac -
  /// so the green badge is not deserved.
  func testExhaustedDriveLimitTakesAwayGreenBadge() {
    let status = healthy()
    status.buffer.dailyQuotaExhausted = true
    XCTAssertFalse(status.healthy)
    XCTAssertFalse(status.buffer.uploadState.needsAttention)
  }

  /// No space on the Drive is something DIFFERENT from the daily limit: it will not pass on its own.
  func testNoSpaceOnDriveRequiresAction() {
    let status = healthy()
    status.buffer.driveFull = true
    XCTAssertFalse(status.healthy)
    XCTAssertTrue(status.buffer.uploadState.needsAttention)
  }

  func testUnconnectedDriveTakesAwayGreenBadge() {
    let status = healthy()
    status.remoteConfigured = false
    XCTAssertFalse(status.healthy)
  }

  /// An upload in progress is NOT a failure - as long as the queue shrinks, everything goes
  /// as designed. Without this test a "fix" consisting of raising an alarm
  /// on every non-empty queue would have gone unnoticed.
  func testUploadInProgressIsNotAFailure() {
    let status = healthy()
    status.buffer.uploadsQueued = 12
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.buffer.uploadState, .flowing(queued: 12))
    XCTAssertEqual(status.headline, UploadState.flowing(queued: 12).headline)
  }

  // MARK: - Age of the last SUCCESSFUL backup

  /// THE failure. The mount is up, the image attached, the queue empty, the Time
  /// Machine destination set - and the last COMPLETED backup is two days old. The panel
  /// showed "Healthy / Ready" then, because it never asked about this even once:
  /// `grep -rn "BackupHealth" Sources/CloudMachineApp/` gave no hits.
  func testOldBackupTakesAwayGreenBadge() {
    let status = healthy()
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-48 * 3600)
    XCTAssertFalse(
      status.healthy,
      "All the devices can be fine while there has been no backup for two days.")
    XCTAssertEqual(
      status.headline, "No completed backup for \(BackupHealth.formatAge(48 * 3600))")
  }

  /// The threshold boundary. Just below it is still fine, just above it no longer -
  /// without this test a "fix" setting the threshold to 100 years would pass silently.
  func testBackupAgeThresholdWorksBothWays() {
    let justBefore = healthy()
    justBefore.backupCycle.lastSuccess = Date().addingTimeInterval(
      -(BackupHealth.maxAgeHours * 3600 - 60))
    XCTAssertTrue(justBefore.healthy)

    let justAfter = healthy()
    justAfter.backupCycle.lastSuccess = Date().addingTimeInterval(
      -(BackupHealth.maxAgeHours * 3600 + 60))
    XCTAssertFalse(justAfter.healthy)
  }

  /// An unread backup counter is NOT the same as a backup made a moment ago.
  /// The default `BackupCycleStatus` has `known == false` precisely so that
  /// the panel does not show green before anyone has asked anything.
  func testUnreadBackupCounterTakesAwayGreenBadge() {
    let status = healthy()
    status.backupCycle = BackupCycleStatus()
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Unknown when the last backup was made")
  }

  /// The preferences were read and there is NOT A SINGLE successful backup in them - which is
  /// something other than "could not read" and must sound different.
  func testNoBackupAtAllTakesAwayGreenBadge() {
    let status = healthy()
    status.backupCycle = BackupCycleStatus(known: true, lastSuccess: nil, checkedAt: Date())
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "There is no completed backup at all")
  }
}
