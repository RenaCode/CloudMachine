import XCTest

@testable import CloudMachineCore

/// The upload state shown to the user.
///
/// The heart of these tests is one distinction: **the daily limit passes by
/// itself, lack of space does not**. Both look the same in every counter and
/// mean something entirely different to the person looking at the screen.
final class UploadStateTests: XCTestCase {

  private func state(
    mounted: Bool = true, queueKnown: Bool = true, queued: Int = 0, inProgress: Int = 0,
    failedFiles: Int = 0, bufferOutOfSpace: Bool = false, driveFull: Bool = false,
    dailyQuotaExhausted: Bool = false
  ) -> UploadState {
    UploadState.from(
      mounted: mounted, queueKnown: queueKnown, queued: queued, inProgress: inProgress,
      failedFiles: failedFiles, bufferOutOfSpace: bufferOutOfSpace, driveFull: driveFull,
      dailyQuotaExhausted: dailyQuotaExhausted)
  }

  /// THIS is the difference. Daily limit: do nothing, but do not pretend all is
  /// well. No space: do something.
  func testDailyLimitNeedsNoActionButIsNotNominal() {
    let s = state(queued: 800, dailyQuotaExhausted: true)
    XCTAssertEqual(s, .dailyQuotaExhausted)
    XCTAssertFalse(
      s.needsAttention, "the daily limit passes by itself - nothing to ask the user for")
    XCTAssertFalse(s.isNominal, "but the bands sit only locally, so this is not a nominal state")
  }

  func testNoSpaceNeedsAction() {
    let s = state(queued: 800, driveFull: true)
    XCTAssertEqual(s, .driveFull)
    XCTAssertTrue(s.needsAttention)
    XCTAssertFalse(s.isNominal)
  }

  /// "rclone gave up" means the backup is incomplete NOW. The limit only means
  /// it will wait. That is why errors come before the limit.
  func testAbandonedFilesComeBeforeTheDailyLimit() {
    let s = state(queued: 800, failedFiles: 3, dailyQuotaExhausted: true)
    XCTAssertEqual(s, .failedFiles(3))
    XCTAssertTrue(s.needsAttention)
  }

  /// No mount overrides everything - without it the other counters describe
  /// nothing meaningful.
  func testNoMountOverridesEverything() {
    let s = state(mounted: false, queued: 800, failedFiles: 3, driveFull: true)
    XCTAssertEqual(s, .mountDown)
  }

  func testOngoingUploadIsNominal() {
    let s = state(queued: 120, inProgress: 8)
    XCTAssertEqual(s, .flowing(queued: 128))
    XCTAssertTrue(s.isNominal)
    XCTAssertTrue(s.isMovingData)
    XCTAssertFalse(s.needsAttention)
  }

  func testEmptyQueueMeansEverythingUploaded() {
    let s = state()
    XCTAssertEqual(s, .upToDate)
    XCTAssertTrue(s.isNominal)
    XCTAssertFalse(s.isMovingData)
  }

  /// REGRESSION 23.09.2026. `rclone rc vfs/stats` exceeded the time limit, so
  /// `queueStats()` returned `nil`, and the caller substituted zeros - and with
  /// 386 bands in the queue `drive-status` and the card in the interface
  /// announced "Everything uploaded to Google Drive". No answer has to look
  /// like no answer.
  func testNoQueueReadingDoesNotPretendToBeAnEmptyQueue() {
    let s = state(queueKnown: false)
    XCTAssertEqual(s, .queueUnknown)
    XCTAssertNotEqual(s, .upToDate)
    XCTAssertFalse(s.isNominal, "an unknown state has no right to glow green")
    XCTAssertFalse(s.isMovingData)
    XCTAssertFalse(
      s.needsAttention, "persistence of the problem is backup-health's job, not the card colour's")
    XCTAssertFalse(
      s.headline.contains("Everything uploaded"), "that very sentence was the lie")
  }

  /// Hard facts that do not come from the queue come before not knowing about
  /// it: no mount and no space on Drive are known without `vfs/stats`.
  func testFactsFromOutsideTheQueueComeBeforeNotKnowing() {
    XCTAssertEqual(state(mounted: false, queueKnown: false), .mountDown)
    XCTAssertEqual(state(queueKnown: false, driveFull: true), .driveFull)
  }

  /// The daily limit, on the other hand, is lost on purpose: when it is unknown
  /// whether rclone abandoned something, "wait, it will pass" is not an honest
  /// answer.
  func testDailyLimitDoesNotHideNotKnowingAboutTheQueue() {
    XCTAssertEqual(state(queueKnown: false, dailyQuotaExhausted: true), .queueUnknown)
  }

  func testEveryStateHasALabelForAPerson() {
    let all: [UploadState] = [
      .mountDown, .driveFull, .failedFiles(2), .bufferFull, .dailyQuotaExhausted,
      .flowing(queued: 5), .upToDate, .queueUnknown,
    ]
    for s in all {
      XCTAssertFalse(s.badge.isEmpty, "no label for \(s)")
    }
    XCTAssertNotEqual(
      UploadState.queueUnknown.badge, UploadState.upToDate.badge,
      "not knowing and all-good must not look the same")
    XCTAssertNotEqual(
      UploadState.queueUnknown.badge, UploadState.dailyQuotaExhausted.badge,
      "not knowing is not 'will pass by itself'")
  }

  /// Every state has to be able to explain itself. Empty text on the card is
  /// exactly the kind of silent failure this project has already had once.
  func testEveryStateHasTextForAPerson() {
    let all: [UploadState] = [
      .mountDown, .driveFull, .failedFiles(2), .bufferFull, .dailyQuotaExhausted,
      .flowing(queued: 5), .upToDate, .queueUnknown,
    ]
    for s in all {
      XCTAssertFalse(s.headline.isEmpty, "no headline for \(s)")
      XCTAssertGreaterThan(s.explanation.count, 20, "explanation too short for \(s)")
    }
  }

  /// With the limit exhausted the user has to see that they DO NOT have to do
  /// anything - otherwise they will look for a failure where there is none.
  func testLimitExplanationReassuresInsteadOfAlarming() {
    let text = UploadState.dailyQuotaExhausted.explanation
    XCTAssertTrue(text.contains("750 GB"), "has to say which limit it is about")
    XCTAssertTrue(text.contains("by itself"), "has to say that it passes by itself")
    XCTAssertTrue(text.contains("There is nothing to do"), "has to release from action outright")
  }
}
