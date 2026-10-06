import XCTest

@testable import CloudMachineCore

/// Two questions the watchdog asks the rclone LOG: has Google Drive run out of
/// space, and is the upload stalled. Until 25.09.2026 both had only two
/// answers, while the file has three states.
///
/// `recentLog` returns `nil` when the file cannot be opened, and both
/// functions turned that into `false` - i.e. into "no problem". The effects
/// were two and different: the watchdog did not pause the backup when Drive
/// was out of space, and `reportStall(false)` DELETED the jam marker and wrote
/// "Upload to Google Drive has resumed". The rclone log has `-rw-r-----`
/// permissions, and at start-up it is moved to `.1`, so an unreadable log is
/// an expected state.
///
/// The tests write to their own temporary file. They do not touch the
/// production `~/.cloudmachine/rclone.log`, neither for reading nor for
/// writing - that is why both functions take a path.
final class RcloneLogReadabilityTests: XCTestCase {

  private var directory: URL!

  override func setUpWithError() throws {
    try super.setUpWithError()
    directory = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cm-rclone-log-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    // Permissions have to come back, otherwise the directory cannot be removed.
    if let files = try? FileManager.default.contentsOfDirectory(atPath: directory.path) {
      for file in files {
        try? FileManager.default.setAttributes(
          [.posixPermissions: 0o600], ofItemAtPath: directory.appendingPathComponent(file).path)
      }
    }
    try? FileManager.default.removeItem(at: directory)
    try super.tearDownWithError()
  }

  private func stamp(_ minutesAgo: Double = 0) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    return formatter.string(from: Date().addingTimeInterval(-minutesAgo * 60))
  }

  private func write(_ text: String, permissions: Int? = nil) throws -> URL {
    let file = directory.appendingPathComponent("rclone.log")
    try text.write(to: file, atomically: true, encoding: .utf8)
    if let permissions {
      try FileManager.default.setAttributes(
        [.posixPermissions: permissions], ofItemAtPath: file.path)
    }
    return file
  }

  // MARK: - No space on Google Drive

  func testFreshLimitEntryIsAnExplicitYES() throws {
    let file = try write(
      """
      \(stamp(5)) INFO  : band-1: Copied (replaced existing)
      \(stamp(2)) ERROR : band-2: Failed to copy: googleapi: Error 403: storageQuotaExceeded
      """)
    XCTAssertEqual(DriveBufferService.hitStorageQuotaState(logFile: file), true)
  }

  func testLogWithoutATraceOfTheLimitIsAnExplicitNO() throws {
    let file = try write("\(stamp(2)) INFO  : band-1: Copied (new)")
    XCTAssertEqual(DriveBufferService.hitStorageQuotaState(logFile: file), false)
  }

  /// THE failure. The file is there, but we have no permission for it - and
  /// that does NOT mean there is space on Drive.
  func testUnreadableLogIsIDoNotKnowNotNoProblem() throws {
    let file = try write(
      "\(stamp(2)) ERROR : band-2: googleapi: Error 403: storageQuotaExceeded", permissions: 0o000)
    XCTAssertNil(
      DriveBufferService.hitStorageQuotaState(logFile: file),
      "An unopenable file turned into `false` pretends to be the answer 'no problem'.")
    XCTAssertNil(
      DriveBufferService.uploadStalledState(logFile: file),
      "The same question about the jam - the same file and the same lack of an answer.")
  }

  /// The log moved to `.1` at rclone start-up, or not yet created after a
  /// fresh install. No file is no data, not no problem.
  func testMissingLogFileIsAlsoIDoNotKnow() {
    let file = directory.appendingPathComponent("no-such-file.log")
    XCTAssertNil(DriveBufferService.hitStorageQuotaState(logFile: file))
    XCTAssertNil(DriveBufferService.uploadStalledState(logFile: file))
  }

  // MARK: - Upload jam

  func testJamRecognisedFromTheRatioOfSuccessesToErrors() throws {
    // The `minErrors` threshold is 300 and `maxSuccessRatio` 0.1 - a jam is
    // hundreds of errors with almost zero traffic.
    var lines: [String] = []
    for _ in 0..<400 { lines.append("\(stamp(3)) ERROR : band: Received upload limit error") }
    lines.append("\(stamp(3)) INFO  : band: Copied (replaced existing)")
    let file = try write(lines.joined(separator: "\n"))
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: file), true)
  }

  func testOrdinaryRateThrottlingIsNotAJam() throws {
    // As many successes as errors - measured 1:1 on the throttling of 12.09.2026.
    var lines: [String] = []
    for _ in 0..<400 {
      lines.append("\(stamp(3)) ERROR : band: Received upload limit error")
      lines.append("\(stamp(3)) INFO  : band: Copied (replaced existing)")
    }
    let file = try write(lines.joined(separator: "\n"))
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: file), false)
  }
}
