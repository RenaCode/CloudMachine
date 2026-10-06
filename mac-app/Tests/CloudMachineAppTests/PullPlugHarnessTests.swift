import Foundation
import XCTest

@testable import CloudMachineCore
@testable import cloudmachine_poc

/// Whether the `pullplug` harness tells "I did not measure" apart from "I
/// measured and it is OK".
///
/// The harness measures the behaviour of hdiutil and FUSE-T, but the WAY it
/// reports on it is ordinary code - and it broke exactly like the rest of this
/// project: by merging a missing result with a result. No test here creates a
/// disk image; they touch only the pure parts.
final class PullPlugHarnessTests: XCTestCase {

  // MARK: - Test write: "never started" is not "interrupted"

  /// THE bug. `writeUntilItBreaks` returned `false` also when
  /// `createFile`/`FileHandle` failed immediately - and the harness printed
  /// "write interrupted, as expected" for it and ended with "The image survived
  /// every floor pull", without having written a single byte.
  func testWriteThatHadNowhereToStartIsNotInterrupted() {
    let nonexistent = URL(fileURLWithPath: "/no/such/directory/load.bin")
    let result = writeUntilItBreaks(to: nonexistent, megabytes: 1)

    guard case .neverStarted(let reason) = result else {
      return XCTFail("a write that never started must not look interrupted: \(result)")
    }
    XCTAssertTrue(
      reason.contains("load.bin"), "the reason has to name the file in question: \(reason)")
    XCTAssertNotEqual(result, .interrupted(megabytesWritten: 0))
  }

  /// The other side of the same fix: a write that GOT THROUGH the whole order
  /// is not a test success either - the floor disappeared only after it, so the
  /// round measured nothing. It is the same bug the comment about
  /// `arc4random_buf` warns about, only seen from the report's side.
  func testWriteToTheEndIsRecognizableAsNoMeasurement() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-pullplug-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let result = writeUntilItBreaks(
      to: directory.appendingPathComponent("load.bin"), megabytes: 1)
    XCTAssertEqual(result, .completed(megabytesWritten: 1))
  }

  // MARK: - fsck: "could not check" is not "inconsistent"

  func testFsckExitZeroIsConsistent() {
    XCTAssertEqual(
      PullPlugCommand.classify(fsck: ProcessResult(stdout: "ok", stderr: "", exitCode: 0)),
      .consistent)
  }

  func testNonZeroFsckExitIsInconsistency() {
    XCTAssertEqual(
      PullPlugCommand.classify(
        fsck: ProcessResult(stdout: "", stderr: "corrupt", exitCode: 1)),
      .inconsistent)
  }

  /// The pattern from `BackupImageService.verifyLocked()`: a `fsck_apfs` that
  /// never ran (missing binary, killed process, pulled device) gave the same
  /// `false` as a `fsck_apfs` that found damage - the harness then reported
  /// "backup lost" and counted an irreversible loss without having a single
  /// result.
  func testMissingFsckResultIsNotInconsistency() {
    let result = PullPlugCommand.classify(fsck: nil)
    XCTAssertNotEqual(result, .inconsistent, "a missing result must not pretend to be damage")
    guard case .notChecked = result else { return XCTFail("got: \(result)") }
  }

  // MARK: - The last sentence of the run

  func testRunWithoutLossesOrGapsDeclaresSurvival() {
    let lines = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 0, unmeasured: 0)
    XCTAssertTrue(
      lines.contains { $0.contains("survived every floor pull") }, "got: \(lines)")
  }

  /// The core of point 14: a run in which anything went unmeasured HAS NO
  /// RIGHT to declare that the image survived. The harness does not know
  /// whether it tried to kill it.
  func testRunWithAnUnmeasuredRoundDoesNotDeclareSurvival() {
    let lines = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 0, unmeasured: 1)
    XCTAssertFalse(
      lines.contains { $0.contains("survived") },
      "a round without a measurement must not end with a sentence about survival: \(lines)")
    XCTAssertTrue(
      lines.contains { $0.contains("PROVES NOTHING") }, "got: \(lines)")
    XCTAssertTrue(
      lines.contains { $0.contains("rounds without a measurement: 1") }, "got: \(lines)")
  }

  /// Zero executed rounds is not a success either - and with `rounds: 0` the
  /// counter of the old summary came out as "irreversible losses: 0", i.e.
  /// "survived".
  func testRunWithoutASingleRoundDeclaresNothing() {
    let lines = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 0, lost: 0, unmeasured: 0)
    XCTAssertFalse(lines.contains { $0.contains("survived") }, "got: \(lines)")
    XCTAssertTrue(lines.contains { $0.contains("MEASURED NOTHING") }, "got: \(lines)")
  }

  /// A detected loss is a result and has to stay visible even next to gaps -
  /// otherwise the "fix" would turn a false success into a hushed-up failure.
  func testDetectedLossDoesNotHideBehindMissingMeasurement() {
    let lines = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 1, unmeasured: 1)
    XCTAssertTrue(
      lines.contains { $0.contains("architecture loses the backup") }, "got: \(lines)")
    XCTAssertFalse(lines.contains { $0.contains("survived") }, "got: \(lines)")
  }
}
