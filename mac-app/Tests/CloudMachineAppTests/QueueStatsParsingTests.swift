import XCTest

@testable import CloudMachineCore

/// Parsing responses of rclone's remote control interface. Each case here is a
/// different way in which "I do not know" turned into "zero" - and "zero" read
/// on screen as "Everything uploaded to Google Drive".
final class QueueStatsParsingTests: XCTestCase {

  // MARK: - vfs/stats

  private let fullResponse = """
    {
      "diskCache": {
        "bytesUsed": 12345678,
        "erroredFiles": 3,
        "files": 40,
        "outOfSpace": false,
        "uploadsInProgress": 2,
        "uploadsQueued": 386
      },
      "metadataCache": { "dirs": 1, "files": 40 }
    }
    """

  func testFullResponseGivesCounters() throws {
    let stats = try XCTUnwrap(DriveBufferService.parseQueueStats(fullResponse))
    XCTAssertEqual(stats.uploadsInProgress, 2)
    XCTAssertEqual(stats.uploadsQueued, 386)
    XCTAssertEqual(stats.files, 40)
    XCTAssertEqual(stats.erroredFiles, 3)
    XCTAssertEqual(stats.bytesUsed, 12_345_678)
    XCTAssertFalse(stats.outOfSpace)
  }

  /// The heart of the fix. A response without the `diskCache` section fell
  /// through to `?? json`, where none of the counters are, and a missing key
  /// gave 0 - the result was a full set of zeros, i.e. `queueKnown == true` and
  /// "Everything uploaded".
  func testResponseWithoutDiskCacheMeansNotKnowing() {
    let withoutSection = """
      { "metadataCache": { "dirs": 1, "files": 40 } }
      """
    XCTAssertNil(DriveBufferService.parseQueueStats(withoutSection))
  }

  /// The same bug one level down: the section is there, but the counter is not.
  func testMissingCounterMeansNotKnowing() {
    let withoutErrors = """
      {
        "diskCache": {
          "bytesUsed": 1, "files": 40,
          "uploadsInProgress": 0, "uploadsQueued": 0
        }
      }
      """
    XCTAssertNil(
      DriveBufferService.parseQueueStats(withoutErrors),
      "missing erroredFiles does not mean 'zero errors'")
  }

  func testEmptyResponseMeansNotKnowing() {
    XCTAssertNil(DriveBufferService.parseQueueStats(""))
    XCTAssertNil(DriveBufferService.parseQueueStats("connection refused"))
  }

  /// `outOfSpace` is the only field whose absence may be made up with a default
  /// value - it is a flag, not a counter.
  func testMissingOutOfSpaceFlagDoesNotBreakTheReading() throws {
    let withoutFlag = """
      {
        "diskCache": {
          "bytesUsed": 1, "erroredFiles": 0, "files": 2,
          "uploadsInProgress": 0, "uploadsQueued": 0
        }
      }
      """
    let stats = try XCTUnwrap(DriveBufferService.parseQueueStats(withoutFlag))
    XCTAssertFalse(stats.outOfSpace)
  }

  // MARK: - Quiet versus idle

  func testEmptyQueueWithAbandonedBandsIsNotQuiet() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 0, uploadsQueued: 0, files: 40,
      erroredFiles: 5, bytesUsed: 1024, outOfSpace: false)
    XCTAssertTrue(stats.isIdle, "rclone really is doing nothing - hdiutil can work")
    XCTAssertFalse(
      stats.isQuiet,
      "but 5 bands did not reach Drive, so 'everything uploaded' would be a lie")
  }

  func testEmptyQueueWithoutErrorsIsQuiet() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 0, uploadsQueued: 0, files: 40,
      erroredFiles: 0, bytesUsed: 1024, outOfSpace: false)
    XCTAssertTrue(stats.isIdle)
    XCTAssertTrue(stats.isQuiet)
  }

  func testOngoingUploadIsNeitherQuietNorIdle() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 1, uploadsQueued: 12, files: 40,
      erroredFiles: 0, bytesUsed: 1024, outOfSpace: false)
    XCTAssertFalse(stats.isIdle)
    XCTAssertFalse(stats.isQuiet)
  }

  // MARK: - vfs/queue

  func testQueueSkipsItemsAlreadyUploading() throws {
    let response = """
      {
        "queue": [
          { "id": 1, "name": "bands/0001", "uploading": false, "expiry": 480.2 },
          { "id": 2, "name": "bands/0002", "uploading": true, "expiry": -1 },
          { "id": 3, "name": "bands/0003", "uploading": false, "expiry": 512.9 }
        ]
      }
      """
    let ids = try XCTUnwrap(DriveBufferService.parseQueueIDs(response))
    XCTAssertEqual(ids, [1, 3], "rclone will not speed up an item already uploading anyway")
  }

  /// An empty queue and no answer are TWO DIFFERENT THINGS - both used to come
  /// out of `expireQueuedUploads()` as `0`, so the log was silent exactly when
  /// the deadlines were NOT moved and the drain could take 10 minutes.
  func testEmptyQueueIsNotTheSameAsNoAnswer() {
    XCTAssertEqual(DriveBufferService.parseQueueIDs(#"{ "queue": [] }"#), [])
    XCTAssertNil(DriveBufferService.parseQueueIDs(""))
    XCTAssertNil(DriveBufferService.parseQueueIDs("{}"))
  }
}
