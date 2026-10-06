import Foundation
import XCTest

@testable import CloudMachineCore

/// Whether a log entry is in the file RIGHT AFTER logging, or only after 16 KiB.
///
/// Under launchd the agent's stdout is a FILE (`StandardOutPath` in every
/// template in `launchd/`), and for a file stdio chooses BLOCK buffering.
/// Measured 25.09.2026: `launchd-buffer-guard.out.log` was exactly 16384 bytes
/// and dated 2026-09-20, while the `buffer-guard` process (`while true` +
/// `KeepAlive`, so it never gets to flush the buffer on exit) had been alive
/// since 2026-09-25. The file ended mid-word, so it looked exactly like a
/// process that died on the fifth day.
///
/// The test does NOT call `CMLogger.log`, only the write to stdout itself. The
/// reason is the same as with `HealthAlert.log`: `CMLogger.log` appends to the
/// real `~/Library/Logs/CloudMachine/cloudmachine.log`, and that file is the
/// only trace of backup failures and has no right to collect lines from
/// `swift test` runs.
final class CMLoggerFlushTests: XCTestCase {

  /// THAT defect. We set block buffering EXPLICITLY (`_IOFBF`) instead of
  /// counting on the test environment to choose it - otherwise the result
  /// would depend on whether `swift test` was started from a terminal (stdout
  /// = tty, line buffering, the defect is invisible) or from CI (stdout =
  /// pipe). The test is meant to measure our code, not where it was run.
  func testEntryIsInTheFileImmediately() throws {
    let file = try redirectedStdout()
    defer { restoreStdout() }

    CMLogger.emitToStandardOutput("[2026-09-25 22:00:00] first log line\n")

    // We read WITHOUT any `fflush` on our side - exactly like a person looking
    // into the file while the process is alive.
    let content = (try? String(contentsOf: file, encoding: .utf8)) ?? ""
    XCTAssertTrue(
      content.contains("first log line"),
      """
      The entry stayed in the stdio buffer. Under launchd this means the file \
      a person looks at FIRST lags behind until 16 KiB accumulate - and its \
      last line is cut off mid-word. Got: \
      "\(content)" (\(content.utf8.count) bytes)
      """)
  }

  /// The other side of the same fix: the content MUST be complete, not just
  /// early. `fflush` after every entry must not lose or merge lines.
  func testSuccessiveEntriesLandInOrderAndInFull() throws {
    let file = try redirectedStdout()
    defer { restoreStdout() }

    for number in 1...5 {
      CMLogger.emitToStandardOutput("line \(number)\n")
    }

    let content = (try? String(contentsOf: file, encoding: .utf8)) ?? ""
    XCTAssertEqual(content, "line 1\nline 2\nline 3\nline 4\nline 5\n")
  }

  // MARK: - Replacing stdout with a file (i.e. what launchd does)

  private var savedDescriptor: Int32 = -1
  private var directory: URL?

  /// Puts a file under descriptor 1 and FORCES block buffering - i.e.
  /// reproduces the launchd conditions inside the test process.
  private func redirectedStdout() throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-logger-flush-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    self.directory = directory
    let file = directory.appendingPathComponent("launchd-fake.out.log")
    FileManager.default.createFile(atPath: file.path, contents: nil)

    // Everything already waiting on the real stdout is pushed out BEFORE the
    // swap - otherwise it would land in our file and pose as our entry.
    fflush(stdout)
    savedDescriptor = dup(1)
    let replacement = open(file.path, O_WRONLY | O_APPEND)
    XCTAssertGreaterThanOrEqual(replacement, 0, "could not open \(file.path)")
    dup2(replacement, 1)
    close(replacement)
    setvbuf(stdout, nil, _IOFBF, 16384)
    return file
  }

  private func restoreStdout() {
    fflush(stdout)
    if savedDescriptor >= 0 {
      dup2(savedDescriptor, 1)
      close(savedDescriptor)
      savedDescriptor = -1
    }
    setvbuf(stdout, nil, _IOLBF, 0)
    if let directory { try? FileManager.default.removeItem(at: directory) }
    directory = nil
  }
}
