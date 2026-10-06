import XCTest

@testable import CloudMachineCore

/// Operations on the backup image: mutual exclusion and the verdicts that used
/// to lie - "everything uploaded" with abandoned bands and "image
/// INCONSISTENT" after the device was pulled out from under `fsck`.
final class BackupImageServiceTests: XCTestCase {

  // MARK: - Mutual exclusion

  /// The lock named `BackupImageService.lockName` lives in the real log
  /// directory, because `attach`/`detach`/`verify`/`create` use that same lock.
  /// We hold it for a fraction of a second and only to check that the
  /// operations RESPECT it - none of them gets as far as `hdiutil` then.
  private func withHeldImageLock(_ body: () async -> Void) async throws {
    let lock = CMLock(name: BackupImageService.lockName)
    try XCTSkipUnless(
      lock.acquire(),
      "the '\(BackupImageService.lockName)' lock is held by something else on this machine")
    defer { lock.release() }
    await body()
  }

  /// The heart of the fix: until 23 September 2026 `withCMLock` was not called
  /// from a single place in the repo, so each of these four operations ran with
  /// the lock held just as without it. The test checks not only
  /// `succeeded == false` (that already came out before, because the buffer is
  /// not mounted), but also the content and - more importantly - `disposition`:
  /// the operation has to recognise the lock is taken, not bounce off something
  /// else along the way.
  func testImageOperationsDoNotGetInEachOthersWay() async throws {
    try await withHeldImageLock {
      for (name, result) in [
        ("create", await BackupImageService.create(sizeGB: 100)),
        ("attach", await BackupImageService.attach()),
        ("detach", await BackupImageService.detach()),
        ("verify", await BackupImageService.verify()),
      ] {
        XCTAssertFalse(result.succeeded, "\(name) must not report success with the image busy")
        XCTAssertTrue(
          result.message.contains("another image operation"),
          "\(name) has to say that it did NOTHING - got: \(result.message)")
        XCTAssertEqual(
          result.disposition, .skipped,
          "\(name): busy has to be recognisable by the result TYPE, not by the message text")
      }
    }
  }

  /// `attach-image` runs under launchd every 900 s and its exit code lands in
  /// `launchd-gdrive-attach.err.log`. A busy image must not be recorded there
  /// as a failure - but a real failure MUST be, otherwise we would hide a real
  /// error behind exit code 0.
  func testBusyIsNotAFailureButAFailureIsStillAFailure() {
    XCTAssertEqual(
      CMActionResult(succeeded: true, message: "Attached").disposition, .ok)
    XCTAssertEqual(
      CMActionResult(succeeded: false, message: "busy", didNotRun: true).disposition,
      .skipped)
    XCTAssertEqual(
      CMActionResult(succeeded: false, message: "Could not attach the image").disposition,
      .failed,
      "no `didNotRun` has to mean a real failure - the default value must not silence errors")
  }

  // MARK: - Detach verdict

  private func stats(queued: Int = 0, inProgress: Int = 0, errored: Int = 0)
    -> DriveBufferService.QueueStats
  {
    DriveBufferService.QueueStats(
      uploadsInProgress: inProgress, uploadsQueued: queued, files: 10,
      erroredFiles: errored, bytesUsed: 1024, outOfSpace: false)
  }

  func testEmptyQueueWithoutErrorsMeansEverythingUploaded() {
    let result = BackupImageService.detachVerdict(settled: stats())
    XCTAssertTrue(result.succeeded)
    XCTAssertTrue(result.message.contains("everything uploaded"))
  }

  /// Bands abandoned by rclone drop out of the queue just like uploaded ones,
  /// so an empty queue alone reported "Detached, everything uploaded to Google
  /// Drive" with data existing ONLY on this Mac.
  func testAbandonedBandsAreNotUploaded() {
    let result = BackupImageService.detachVerdict(settled: stats(errored: 7))
    XCTAssertFalse(result.succeeded)
    XCTAssertFalse(result.message.contains("everything uploaded"))
    XCTAssertTrue(result.message.contains("7"))
  }

  /// No reading is not success - see `UploadState.queueUnknown`.
  func testNoQueueReadingIsNotSuccess() {
    let result = BackupImageService.detachVerdict(settled: nil)
    XCTAssertFalse(result.succeeded)
  }

  // MARK: - Mount table

  /// Until now this list came from parsing `/sbin/mount` output (`" on "` …
  /// `" ("`) inside `unmountBrowsedSnapshots()`, so there was nothing to
  /// substitute a sample for. A backup snapshot mounts under
  /// `/Volumes/.timemachine/<host>/<date>.backup/<volume>` and keeps the image's
  /// device busy, which makes `hdiutil detach` refuse.
  func testPicksOnlyBrowsedBackupSnapshots() {
    let points = [
      "/",
      "/Volumes/CloudMachine",
      "/Users/mbeczynski/.cloudmachine/drive",
      "/Volumes/.timemachine/mac-studio/2026-09-23-101500.backup/CloudMachine",
      "/Volumes/.timemachine/mac-studio/2026-09-22-231500.backup/CloudMachine",
      // Trap: a similar name, but NOT under the snapshot directory.
      "/Volumes/timemachine-copy",
    ]
    XCTAssertEqual(
      BackupImageService.browsedSnapshotMounts(points),
      [
        "/Volumes/.timemachine/mac-studio/2026-09-23-101500.backup/CloudMachine",
        "/Volumes/.timemachine/mac-studio/2026-09-22-231500.backup/CloudMachine",
      ])
  }

  func testNoSnapshotsGivesEmptyList() {
    XCTAssertEqual(BackupImageService.browsedSnapshotMounts(["/", "/Volumes/CloudMachine"]), [])
  }

  /// The mount table read from the kernel, not from `/sbin/mount`. We check it
  /// live, because the whole fix is that this read does NOT start a process
  /// and does NOT touch the file system - which a fake would not show.
  func testMountTableIsReadableAndContainsRoot() throws {
    let points = try XCTUnwrap(
      DriveBufferService.mountPoints(), "getmntinfo did not return the mount table")
    XCTAssertTrue(points.contains("/"), "every system has the root mounted - got: \(points)")
  }

  // MARK: - Attachment state

  /// `.unknown` is NOT `.detached`. `.detached` is a claim ("I checked, it is
  /// not there"), while with an unread mount table there was nothing to check.
  /// The distinction matters, because on `.detached` `attach` runs
  /// `purgeStaleDevices()`, i.e. `detach -force` on a device that may be alive
  /// at that moment.
  func testUnknownStateIsNeitherAttachedNorDetached() {
    let unknown = BackupImageService.Attachment.unknown
    XCTAssertNotEqual(unknown, .detached)
    XCTAssertNotEqual(unknown, .attached)
    XCTAssertFalse(
      unknown.isUsable,
      "you must not rely on an unknown - Time Machine has no guaranteed destination here")
  }

  /// Every state has to give a different sentence. A shared description for
  /// `.detached` and `.unknown` would bring back the merging this fix removes -
  /// just in the layer a person reads.
  func testEveryAttachmentStateHasItsOwnDescription() {
    let descriptions = [
      BackupImageService.describe(.attached),
      BackupImageService.describe(.detached),
      BackupImageService.describe(.dead(errno: ENXIO)),
      BackupImageService.describe(.unknown),
      // The same state, a DIFFERENT cause: the readability probe did not
      // answer in time. The decision is the same (hold off), but the sentence
      // for a person must differ - see `attachmentReading()`.
      BackupImageService.describe(.unknown, probeTimedOut: true),
    ]
    XCTAssertEqual(
      Set(descriptions).count, descriptions.count, "descriptions repeat: \(descriptions)")
    XCTAssertTrue(BackupImageService.describe(.unknown).contains("UNKNOWN"))
    XCTAssertTrue(
      BackupImageService.describe(.unknown, probeTimedOut: true).contains("probe"),
      "the description has to say that the probe did not answer, not the mount table")
  }

  // MARK: - Parent device

  /// `fsck_apfs` gets the partition, `hdiutil info` lists the parent device -
  /// without this conversion the "did the device survive" check would always
  /// answer "no".
  func testParentDeviceFromPartition() {
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk7s1"), "/dev/disk7")
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk12s3"), "/dev/disk12")
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk7"), "/dev/disk7")
    XCTAssertEqual(BackupImageService.parentDevice(of: "something-else"), "something-else")
  }

  // MARK: - Image on the remote

  private let listing = """
    other-data/
    mac-studio.sparsebundle/
    """

  func testRemoteListingWithImage() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(succeeded: true, stdout: listing, stderr: ""),
      .present)
  }

  func testEmptyRemoteListingMeansNoImage() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(succeeded: true, stdout: "", stderr: ""),
      .absent)
  }

  /// First run: the remote directory does not exist yet. That is an ANSWER
  /// ("there is nothing there"), not the lack of one - otherwise the guard would
  /// block `create` in exactly the one case `create` exists for.
  func testMissingRemoteDirectoryMeansNoImage() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(
        succeeded: false, stdout: "",
        stderr: "2026/09/23 10:00:00 ERROR : : error listing: directory not found"),
      .absent)
  }

  /// A broken link is NOT proof that the image is absent. Creating the image is
  /// irreversible, so lack of certainty has to abort it.
  func testNoLinkIsNotProofOfAbsence() {
    let result = BackupImageService.classifyRemoteListing(
      succeeded: false, stdout: "",
      stderr: "Failed to lsf with 2 errors: couldn't connect to Google Drive")
    guard case .unknown = result else {
      return XCTFail("no answer has to be .unknown, got \(result)")
    }
  }

  // MARK: - Finding 5: what the detach says about the queue

  /// THE defect. `expireQueuedUploads()` counted only SUCCESSES, so a queue
  /// full of items none of which could be sped up came out of it as `0` -
  /// exactly like an empty queue. The measured state of this machine at the
  /// time of the audit: 462 items, and the log would claim "queue empty".
  ///
  /// A person reads these lines at the moment of deciding whether the buffer
  /// may be deleted - "queue empty" reads there as "nothing is waiting to be
  /// uploaded".
  func testFullQueueWithoutASingleSuccessIsNotAnEmptyQueue() {
    let line = BackupImageService.expiryLogLine(
      DriveBufferService.ExpiryOutcome(queued: 462, moved: 0))
    XCTAssertFalse(
      line.contains("queue empty"),
      "462 queued items are not an empty queue - got: \(line)")
    XCTAssertTrue(line.contains("462"), "the number of waiting items must be visible: \(line)")
    XCTAssertTrue(
      line.contains("NOT ONE could be"),
      "the log has to say that the deadlines were NOT moved: \(line)")
  }

  /// An empty queue still has to describe itself as empty - otherwise a
  /// "fix" consisting of deleting this case would go unnoticed.
  func testEmptyQueueStillSaysItIsEmpty() {
    XCTAssertTrue(
      BackupImageService.expiryLogLine(
        DriveBufferService.ExpiryOutcome(queued: 0, moved: 0)
      ).contains("queue empty"))
  }

  /// A partial failure is not a success either: items without a moved deadline
  /// will wait the whole `writeBackSeconds` and the drain will take longer than
  /// the line "forced upload of N items" would suggest.
  func testPartialMoveSaysHowManyAreLeft() {
    let line = BackupImageService.expiryLogLine(
      DriveBufferService.ExpiryOutcome(queued: 100, moved: 60))
    XCTAssertTrue(line.contains("60 of 100"), line)
    XCTAssertTrue(line.contains("40"), "the missing 40 items must be visible: \(line)")
  }

  func testAllMovedGivesThePlainMessage() {
    let line = BackupImageService.expiryLogLine(
      DriveBufferService.ExpiryOutcome(queued: 12, moved: 12))
    XCTAssertEqual(line, "Detach: forced upload of 12 queued items")
  }

  /// No answer from rclone is a third, separate case - it must not be merged
  /// with either the empty queue or the failure to move.
  func testNoAnswerIsStillASeparateCase() {
    let line = BackupImageService.expiryLogLine(nil)
    XCTAssertTrue(line.contains("did not answer"), line)
    XCTAssertFalse(line.contains("queue empty"), line)
  }
}
