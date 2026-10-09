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
}
