import XCTest

@testable import CloudMachineCore

/// The `drive-status` lines. This is the text a person READS when asking "is
/// the backup working" - and until now it broke exactly where missing data was
/// turned into some value.
final class StatusLinesTests: XCTestCase {

  // MARK: - Mount

  func testMountedAndNotMounted() {
    XCTAssertEqual(StatusLines.mounted(true), "OK")
    XCTAssertEqual(StatusLines.mounted(false), "MISSING")
  }

  /// "MISSING" means "I checked and it is not there". When reading the mount
  /// table failed, nobody has the right to draw that conclusion - and the
  /// decision to attach the image rests on this answer.
  func testUnreadTableIsNotAMissingMount() {
    let line = StatusLines.mounted(nil)
    XCTAssertNotEqual(line, "MISSING")
    XCTAssertNotEqual(line, "OK")
    XCTAssertTrue(line.contains("UNKNOWN"), "got: \(line)")
  }

  // MARK: - Free space

  func testMeasuredFreeSpaceIsANumber() {
    XCTAssertEqual(StatusLines.freeDisk(427), "427 GB")
  }

  /// Regression from 23 September 2026: after `BufferGuardService.freeGB()`
  /// was changed to `Int?` the line printed `Free on disk: Optional(427) GB`.
  /// The compiler reported it as a warning, not an error, so neither the build
  /// nor the tests stopped it.
  func testMissingMeasurementDoesNotPrintOptional() {
    let line = StatusLines.freeDisk(nil)
    XCTAssertFalse(line.contains("Optional"), "got: \(line)")
    XCTAssertFalse(line.contains("nil"), "got: \(line)")
  }

  /// Zero is a CONCRETE number at which the guard pauses Time Machine -
  /// substituting it for a missing measurement was the original bug, which
  /// the other agent fixed by changing the type. The line must not bring it
  /// back through the back door.
  func testMissingMeasurementIsNotZero() {
    XCTAssertNotEqual(StatusLines.freeDisk(nil), StatusLines.freeDisk(0))
    XCTAssertEqual(StatusLines.freeDisk(0), "0 GB")
  }

  func testMissingMeasurementIsNAMED() {
    let line = StatusLines.freeDisk(nil)
    XCTAssertTrue(line.contains("NOT MEASURED"), "got: \(line)")
    XCTAssertTrue(
      line.contains("buffer guard"),
      "the line must say WHAT follows from it - that the disk is not protected. Got: \(line)")
  }

  // MARK: - Undelivered alarm

  func testNoUndeliveredAlarmPrintsNothing() {
    XCTAssertEqual(StatusLines.undeliveredAlert(nil), [])
  }

  /// The point of the fix in `HealthAlert`: a failed notification must be
  /// VISIBLE. As long as `drive-status` was silent about it, the alarm existed
  /// only in the state file.
  func testUndeliveredAlarmIsVisible() {
    let when = Date(timeIntervalSince1970: 1_790_000_000)
    let lines = StatusLines.undeliveredAlert(
      (
        at: when, summary: "No backup made for 30 h",
        reason: "osascript code 1: permission denied"
      ))

    let text = lines.joined(separator: "\n")
    XCTAssertTrue(text.contains("UNDELIVERED ALARM"), text)
    XCTAssertTrue(text.contains("No backup made for 30 h"), "the alarm content must be visible")
    XCTAssertTrue(
      text.contains("permission denied"), "the reason for non-delivery must be visible")
    XCTAssertTrue(
      text.contains(BackupHealth.stamp(when)),
      "without a date it is unknown whether the alarm is fresh or from a week ago")
  }

  // MARK: - Cache vs backlog: TWO different quantities

  /// A single line "Buffer: 103 GB of 100G" answered a question it could not
  /// answer: whether the upload keeps up. The cache sits at the limit
  /// constantly, and only the second line tells about the backlog - that is
  /// why there are two.
  func testCacheAndBacklogAreSeparateLines() {
    XCTAssertEqual(StatusLines.cacheSize(103, limitGB: 100), "103 GB of 100G")
    XCTAssertEqual(StatusLines.backlog(14, items: 462), "~14 GB (462 items)")
  }

  /// "~" is not decoration: the backlog gigabytes are ESTIMATED from the item
  /// count, and the item count is a measurement. A line giving the estimate as
  /// a measurement hides how solid the basis for the decision to pause the
  /// backup is.
  func testBacklogIsMarkedAsEstimateAndGivesTheMeasurement() {
    let line = StatusLines.backlog(14, items: 462)
    XCTAssertTrue(line.hasPrefix("~"), "got: \(line)")
    XCTAssertTrue(line.contains("462"), "got: \(line)")
  }

  /// rclone not answering must not look like zero or like "Optional(0)".
  func testNoRcloneAnswerIsNamedInBothLines() {
    let cache = StatusLines.cacheSize(nil, limitGB: 100)
    XCTAssertTrue(cache.contains("NOT MEASURED"), "got: \(cache)")
    XCTAssertFalse(cache.contains("0 GB"), "got: \(cache)")

    let backlog = StatusLines.backlog(nil, items: nil)
    XCTAssertTrue(backlog.contains("UNKNOWN"), "got: \(backlog)")
    XCTAssertFalse(backlog.contains("Optional"), "got: \(backlog)")
    XCTAssertFalse(backlog.contains("~0"), "got: \(backlog)")
  }
}
