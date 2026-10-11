import XCTest

@testable import CloudMachineCore

/// The rclone log of a running mount grew without limit (257 MB on
/// 10.10.2026), because it was only rotated when the mount started. Trimming
/// it while rclone writes must not blind the stall detection, which reads the
/// last 30 minutes of the same file.
///
/// Own temporary files only - the production log is neither read nor written.
final class RcloneLogRotationTests: XCTestCase {

  private var directory: URL!
  private var log: URL { directory.appendingPathComponent("rclone.log") }
  private var previous: URL { directory.appendingPathComponent("rclone.log.1") }

  override func setUpWithError() throws {
    try super.setUpWithError()
    directory = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cm-rclone-rotation-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: directory)
    try super.tearDownWithError()
  }

  private func stamp(_ minutesAgo: Double) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    return formatter.string(from: Date().addingTimeInterval(-minutesAgo * 60))
  }

  /// A jam as the detection sees it: hundreds of limit errors, no uploads.
  private func jam(minutesAgo: Double, errors: Int = 400) -> String {
    (0..<errors).map { index in
      "\(stamp(minutesAgo)) ERROR : band-\(index): Received upload limit error: googleapi: Error 403: userRateLimitExceeded\n"
    }.joined()
  }

  /// REGRESSION: a trim in the middle of a jam. The jam is in `.1`, the live
  /// file has only the few lines written since. Reading the live file alone
  /// (the code until 11.10.2026) answers "no jam" for the next half hour.
  func testJamBeforeTheTrimIsStillSeen() throws {
    try jam(minutesAgo: 10).write(to: previous, atomically: true, encoding: .utf8)
    try "\(stamp(1)) INFO  : vfs cache: cleaned: objects 18853\n"
      .write(to: log, atomically: true, encoding: .utf8)

    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: log), true)
  }

  /// The same through the real trim, with rclone appending after it.
  func testTrimKeepsTheTailInOrderAndDetectionWorksAcrossIt() throws {
    let old = (0..<2000).map { "\(stamp(120)) INFO  : band-\($0): Copied (new)\n" }.joined()
    try (old + jam(minutesAgo: 5)).write(to: log, atomically: true, encoding: .utf8)
    let size = try XCTUnwrap(
      try FileManager.default.attributesOfItem(atPath: log.path)[.size] as? UInt64)

    XCTAssertTrue(DriveBufferService.trimLogIfLarge(log, limit: size / 2, keep: size / 3))

    // The live file is empty and stays the same file (rclone keeps writing
    // to its open descriptor).
    XCTAssertEqual(try Data(contentsOf: log).count, 0)
    let kept = try String(contentsOf: previous, encoding: .utf8)
    // Whole lines only: the first one starts with a timestamp.
    XCTAssertNotNil(kept.range(of: #"^\d{4}/\d{2}/\d{2} "#, options: .regularExpression))
    XCTAssertTrue(kept.hasSuffix("userRateLimitExceeded\n"))

    // rclone appends to the truncated file - O_APPEND writes at the new end.
    let handle = try FileHandle(forWritingTo: log)
    try handle.seekToEnd()
    try handle.write(contentsOf: Data("\(stamp(0)) INFO  : still running\n".utf8))
    try handle.close()

    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: log), true)
  }

  func testSmallLogIsLeftAlone() throws {
    try "\(stamp(1)) INFO  : band-1: Copied (new)\n".write(
      to: log, atomically: true, encoding: .utf8)
    XCTAssertFalse(DriveBufferService.trimLogIfLarge(log, limit: 1024 * 1024, keep: 1024))
    XCTAssertFalse(FileManager.default.fileExists(atPath: previous.path))
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: log), false)
  }

  /// `.1` is an addition: without it the live file alone still answers, and
  /// an unreadable live file is still "I do not know".
  func testMissingPreviousLogChangesNothing() throws {
    try jam(minutesAgo: 3).write(to: log, atomically: true, encoding: .utf8)
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: log), true)
    try FileManager.default.removeItem(at: log)
    try jam(minutesAgo: 3).write(to: previous, atomically: true, encoding: .utf8)
    XCTAssertNil(DriveBufferService.uploadStalledState(logFile: log))
  }
}
