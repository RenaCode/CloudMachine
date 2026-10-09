import XCTest

@testable import CloudMachineCore

final class TimeMachineStatusTests: XCTestCase {
  private let idleStatus = """
    Backup session status:
    {
        ClientID = "com.apple.backupd";
        Percent = "-1";
        Running = 0;
    }
    """

  private let copyingStatus = """
    Backup session status:
    {
        BackupPhase = Copying;
        ClientID = "com.apple.backupd";
        DestinationID = "C4B0056F-6CE8-486E-8726-75B45E2E7A56";
        DestinationMountPoint = "/Volumes/TimeMachine";
        Progress =     {
            Percent = "0.2766528592339472";
            bytes = 46755840;
            totalBytes = 1596906082304;
            files = 83;
            totalFiles = 3022847;
        };
        Running = 1;
    }
    """

  private let twoDestinationsInfo = """
    ====================================================
    Name          : Mac
    Kind          : Local
    Mount Point   : /Volumes/Mac
    ID            : DEAD2007-8BC5-4D7B-BCF3-A5646B636CCD
    Quota         : 300 GB
    ====================================================
    Name          : TimeMachine
    Kind          : Local
    Mount Point   : /Volumes/TimeMachine
    ID            : C4B0056F-6CE8-486E-8726-75B45E2E7A56
    """

  func testIsRunning_copying() {
    XCTAssertTrue(TimeMachineStatus.isRunning(statusOutput: copyingStatus))
  }

  func testIsRunning_idle() {
    XCTAssertFalse(TimeMachineStatus.isRunning(statusOutput: idleStatus))
  }

  func testCurrentProgress_idle_returnsNil() {
    XCTAssertNil(TimeMachineStatus.currentProgress(statusOutput: idleStatus))
  }

  func testCurrentProgress_copying_parsesFields() {
    let progress = TimeMachineStatus.currentProgress(statusOutput: copyingStatus)
    XCTAssertEqual(progress?.phase, "Copying")
    XCTAssertEqual(progress?.bytes, 46_755_840)
    XCTAssertEqual(progress?.totalBytes, 1_596_906_082_304)
    XCTAssertEqual(progress?.files, 83)
    XCTAssertEqual(progress?.totalFiles, 3_022_847)
  }

  // Regression for the bug of 2026-07-29: the code used to guess the mount
  // point from a hard-coded volume name instead of asking for the actual
  // registered destination - after a manual volume rename (e.g. to
  // "TimeMachine") the GUI/watchdogs wrongly showed "no volume". One entry in
  // destinationinfo, because the function assumes exactly one active
  // destination (an architectural guarantee, see its doc comment) - not "the
  // first of many".
  func testCurrentDestinationMountPoint_returnsRealMountPoint() {
    let singleDestinationInfo = """
      ====================================================
      Name          : TimeMachine
      Kind          : Local
      Mount Point   : /Volumes/TimeMachine
      ID            : C4B0056F-6CE8-486E-8726-75B45E2E7A56
      """
    XCTAssertEqual(
      TimeMachineStatus.currentDestinationMountPoint(
        destinationInfoOutput: singleDestinationInfo),
      "/Volumes/TimeMachine")
  }

  func testCurrentDestinationMountPoint_noDestinations_returnsNil() {
    XCTAssertNil(TimeMachineStatus.currentDestinationMountPoint(destinationInfoOutput: ""))
  }

  func testDestinationID_matchesCorrectBlock() {
    XCTAssertEqual(
      TimeMachineStatus.destinationID(
        forMountPointContaining: "/Volumes/TimeMachine", destinationInfoOutput: twoDestinationsInfo
      ),
      "C4B0056F-6CE8-486E-8726-75B45E2E7A56")
    XCTAssertEqual(
      TimeMachineStatus.destinationID(
        forMountPointContaining: "/Volumes/Mac", destinationInfoOutput: twoDestinationsInfo),
      "DEAD2007-8BC5-4D7B-BCF3-A5646B636CCD")
  }

  func testDestinationQuotaGB_parsesGBValue() {
    XCTAssertEqual(
      TimeMachineStatus.destinationQuotaGB(
        forMountPointContaining: "/Volumes/Mac", destinationInfoOutput: twoDestinationsInfo),
      300)
  }

  func testDestinationQuotaGB_missingQuota_returnsNil() {
    XCTAssertNil(
      TimeMachineStatus.destinationQuotaGB(
        forMountPointContaining: "/Volumes/TimeMachine", destinationInfoOutput: twoDestinationsInfo)
    )
  }

  func testAllDestinationIDs_returnsBothIDs() {
    XCTAssertEqual(
      TimeMachineStatus.allDestinationIDs(destinationInfoOutput: twoDestinationsInfo),
      ["DEAD2007-8BC5-4D7B-BCF3-A5646B636CCD", "C4B0056F-6CE8-486E-8726-75B45E2E7A56"])
  }

  // MARK: - What counts as an answer

  /// REGRESSION 09.10.2026: an empty stdout (lost by `ProcessRunner`, or from a
  /// failed tmutil) was parsed as "no destination" and raised the "destination
  /// changed" alarm.
  func testEmptyOutputIsNoAnswer() {
    XCTAssertNil(TimeMachineStatus.answer(from: ProcessResult(stdout: "", stderr: "", exitCode: 0)))
    XCTAssertNil(
      TimeMachineStatus.answer(from: ProcessResult(stdout: "\n", stderr: "", exitCode: 0)))
  }

  func testFailedTmutilIsNoAnswerEvenWithOutput() {
    XCTAssertNil(
      TimeMachineStatus.answer(
        from: ProcessResult(stdout: idleStatus, stderr: "tmutil: error", exitCode: 1)))
  }

  func testWorkingTmutilIsAnAnswer() {
    XCTAssertEqual(
      TimeMachineStatus.answer(
        from: ProcessResult(stdout: twoDestinationsInfo, stderr: "", exitCode: 0)),
      twoDestinationsInfo)
  }

  /// "No destination" is an answer whatever exit code tmutil pairs it with -
  /// otherwise a Mac without a destination would read as "tmutil is silent".
  func testNoDestinationsSentenceIsAnAnswer() {
    for code: Int32 in [0, 1] {
      let answer = TimeMachineStatus.answer(
        from: ProcessResult(
          stdout: "tmutil: No destinations configured.\n", stderr: "", exitCode: code))
      XCTAssertNotNil(answer)
      XCTAssertNil(TimeMachineStatus.currentDestinationMountPoint(destinationInfoOutput: answer!))
    }
  }
}
