import XCTest

@testable import CloudMachineCore

/// Status lines shared by `vm-status` and the app. This is the text a person
/// READS when asking "is the backup working".
final class StatusLinesTests: XCTestCase {

  // MARK: - Undelivered alarm

  func testNoUndeliveredAlarmPrintsNothing() {
    XCTAssertEqual(StatusLines.undeliveredAlert(nil), [])
  }

  /// The point of the fix in `HealthAlert`: a failed notification must be
  /// VISIBLE. As long as the status was silent about it, the alarm existed
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
}
