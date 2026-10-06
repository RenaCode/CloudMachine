import XCTest

@testable import CloudMachineCore

/// Mutual exclusion lock. The tests run on a REAL directory - a file system
/// fake would check nothing here, because the whole mechanism is the atomicity
/// of `mkdir` and whether the written PID can be read back. The directory is
/// private and temporary, so that the test does not touch the production locks
/// in `~/Library/Logs/CloudMachine`.
final class CMLockTests: XCTestCase {

  private var dir: URL!

  override func setUpWithError() throws {
    dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("CMLockTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: dir)
  }

  private var lockPath: URL { dir.appendingPathComponent("image.lock.d") }

  func testSecondInstanceDoesNotGetAHeldLock() {
    let first = CMLock(directory: lockPath)
    XCTAssertTrue(first.acquire())
    defer { first.release() }

    let second = CMLock(directory: lockPath)
    XCTAssertFalse(
      second.acquire(),
      "the lock is held by a live process (this test) - a second instance has no right to get it")
  }

  func testAfterReleaseTheLockCanBeTakenAgain() {
    let first = CMLock(directory: lockPath)
    XCTAssertTrue(first.acquire())
    first.release()
    XCTAssertFalse(
      FileManager.default.fileExists(atPath: lockPath.path),
      "release must remove the lock directory, not just forget about it")

    let second = CMLock(directory: lockPath)
    XCTAssertTrue(second.acquire())
    second.release()
  }

  /// Exactly the state left by a process killed between `createDirectory` and
  /// writing the PID: the lock directory exists, the `pid` file does not. A
  /// competitor has the right to take it over - because nobody alive claims it.
  func testDirectoryWithoutPidIsOrphanedAndCanBeTakenOver() throws {
    try FileManager.default.createDirectory(at: lockPath, withIntermediateDirectories: false)

    let lock = CMLock(directory: lockPath)
    XCTAssertTrue(lock.acquire())
    defer { lock.release() }

    let pid = try String(
      contentsOf: lockPath.appendingPathComponent("pid"), encoding: .utf8)
    XCTAssertEqual(
      pid.split(separator: "\n").first.map(String.init), "\(getpid())",
      "after the takeover the file must hold OUR PID - otherwise the next competitor will consider the lock free"
    )
  }

  /// A lock left by a dead process must not stay forever - a watchdog
  /// interrupted by SIGKILL does not get to call `release()`.
  func testLockOfDeadPidIsTakenOver() throws {
    try FileManager.default.createDirectory(at: lockPath, withIntermediateDirectories: false)
    // A PID that certainly does not exist: `kill(pid, 0)` refuses with ESRCH.
    try "999999\n".write(
      to: lockPath.appendingPathComponent("pid"), atomically: true, encoding: .utf8)

    let lock = CMLock(directory: lockPath)
    XCTAssertTrue(lock.acquire())
    lock.release()
  }
}
