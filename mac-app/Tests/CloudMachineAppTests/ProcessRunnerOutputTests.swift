import XCTest

@testable import CloudMachineCore

/// REGRESSION 09.10.2026: `ProcessRunner` sometimes returned an EMPTY stdout
/// with exit code 0 - measured 2 in 5000 and 1 in 2000 calls of `/bin/cat`.
/// `terminationHandler` removed the readability handlers before the last data
/// in the pipe had been read, and an append still on its way to the serial
/// queue could land after the result had been built. Callers took "" for an
/// answer: `destinationinfo` -> "destination not registered", `listremotes`
/// -> "no remote", which is the way to overwriting a working token.
final class ProcessRunnerOutputTests: XCTestCase {
  private var fixture: URL!
  private var expected = ""

  override func setUpWithError() throws {
    // A few kB, several lines - the size of a `tmutil destinationinfo` or
    // `rclone listremotes` answer that the callers parse.
    expected = (0..<120).map { "line \($0) of the expected output\n" }.joined()
    fixture = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-process-runner-\(UUID().uuidString).txt")
    try expected.write(to: fixture, atomically: true, encoding: .utf8)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: fixture)
  }

  /// Many short processes, several at a time - the load under which the race
  /// shows up. On the old code this loses whole outputs; every call must return
  /// exactly what `cat` wrote.
  func testShortProcessNeverLosesItsOutput() async throws {
    let path = fixture.path
    let want = expected
    let lost = try await withThrowingTaskGroup(of: Int.self) { group in
      for _ in 0..<8 {
        group.addTask {
          var bad = 0
          for _ in 0..<500 {
            let result = try await ProcessRunner.run("/bin/cat", [path], timeout: 30)
            if result.succeeded && result.stdout != want { bad += 1 }
          }
          return bad
        }
      }
      return try await group.reduce(0, +)
    }
    XCTAssertEqual(lost, 0, "\(lost) of 4000 calls ended with code 0 and incomplete stdout")
  }

  /// stderr goes through the same path and must not be cut short either.
  func testStderrIsCompleteToo() async throws {
    for _ in 0..<200 {
      let result = try await ProcessRunner.run(
        "/bin/sh", ["-c", "cat \"$0\" >&2; exit 3", fixture.path], timeout: 30)
      XCTAssertEqual(result.exitCode, 3)
      XCTAssertEqual(result.stderr, expected)
    }
  }

  /// The reason the final read must not wait for EOF: a child that inherits
  /// stdout (`rclone ... --daemon`) keeps the pipe open after the parent has
  /// exited. The result must come back right away, with what the parent wrote.
  func testInheritedPipeDoesNotHoldTheResult() async throws {
    let started = Date()
    let result = try await ProcessRunner.run(
      "/bin/sh", ["-c", "echo parent; /bin/sleep 20 & exit 0"], timeout: 60)
    XCTAssertEqual(result.stdout, "parent\n")
    XCTAssertLessThan(Date().timeIntervalSince(started), 5)
  }

  /// REGRESSION 11.10.2026: every call with `timeout:` kept its two pipe
  /// descriptors until `timeout + 10` s, long after the process had exited -
  /// the timers held the process and the readers. The audit measured +100
  /// descriptors for exactly this loop, and 76-92 pipes in the running app
  /// against a limit of 256. They must be back within moments of the exit.
  func testFinishedProcessesReleaseTheirDescriptors() async throws {
    // Settle what earlier tests left behind first, so it cannot be counted.
    try await Task.sleep(nanoseconds: 500_000_000)
    let before = Self.openDescriptors()
    for _ in 0..<50 {
      let result = try await ProcessRunner.run("/bin/echo", ["hello"], timeout: 30)
      XCTAssertEqual(result.stdout, "hello\n")
    }
    var leaked = Self.openDescriptors() - before
    for _ in 0..<20 where leaked > 10 {
      try await Task.sleep(nanoseconds: 100_000_000)
      leaked = Self.openDescriptors() - before
    }
    XCTAssertLessThanOrEqual(leaked, 10, "\(leaked) descriptors still open after 50 finished calls")
  }

  private static func openDescriptors() -> Int {
    (0..<min(Int32(getdtablesize()), 65536)).filter { fcntl($0, F_GETFD) != -1 }.count
  }
}
