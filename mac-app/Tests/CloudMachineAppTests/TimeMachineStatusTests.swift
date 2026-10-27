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
  /// The machine's share as this Mac's tmutil prints it (27.10.2026): a
  /// network destination has no Mount Point while it is not mounted.
  private let networkInfo = """
    ====================================================
    Name          : CloudMachine
    Kind          : Network
    URL           : smb://tm@192.168.64.10/CloudMachine
    ID            : 469C129A-962F-4353-BD32-C8E797B4D20B
    """

  func testBlocksAreParsedInOrder() {
    let destinations = TimeMachineStatus.destinations(destinationInfoOutput: twoDestinationsInfo)
    XCTAssertEqual(
      destinations.map(\.id),
      [
        "DEAD2007-8BC5-4D7B-BCF3-A5646B636CCD", "C4B0056F-6CE8-486E-8726-75B45E2E7A56",
      ])
    XCTAssertEqual(destinations.map(\.mountPoint), ["/Volumes/Mac", "/Volumes/TimeMachine"])
    XCTAssertEqual(destinations.map(\.quotaGB), [300, nil])
  }

  func testNetworkDestinationHasURLAndNoMountPoint() {
    let destinations = TimeMachineStatus.destinations(destinationInfoOutput: networkInfo)
    XCTAssertEqual(
      destinations,
      [
        TimeMachineStatus.Destination(
          name: "CloudMachine", kind: "Network", url: "smb://tm@192.168.64.10/CloudMachine",
          id: "469C129A-962F-4353-BD32-C8E797B4D20B")
      ])
  }

  /// A `Name` line starts a new destination even without the separator.
  func testBlocksWithoutSeparatorsStillSplit() {
    let text = twoDestinationsInfo.replacingOccurrences(
      of: "====================================================\n", with: "")
    XCTAssertEqual(TimeMachineStatus.destinations(destinationInfoOutput: text).count, 2)
  }

  func testNoDestinationsParseToNone() {
    XCTAssertEqual(TimeMachineStatus.destinations(destinationInfoOutput: ""), [])
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
      XCTAssertEqual(TimeMachineStatus.destinations(destinationInfoOutput: answer!), [])
    }
  }

  /// 27.10.2026: tmutil printed the 2450 GB quota as `2,45 TB` (Polish
  /// region), and the status kept asking to set a quota that was set.
  func testQuotaIsReadInTheUnitTmutilPrints() {
    XCTAssertEqual(TimeMachineStatus.quotaGB("300 GB"), 300)
    XCTAssertEqual(TimeMachineStatus.quotaGB("2,45 TB"), 2450)
    XCTAssertEqual(TimeMachineStatus.quotaGB("2.45 TB"), 2450)
    XCTAssertNil(TimeMachineStatus.quotaGB("none"))
    let parsed = TimeMachineStatus.destinations(
      destinationInfoOutput: "Name          : CloudMachine\nQuota         : 2,45 TB\n")
    XCTAssertEqual(parsed.first?.quotaGB, 2450)
    XCTAssertTrue(MachineBudget.quotaMatches(currentQuotaGB: 2450, limitGB: 3500))
    XCTAssertFalse(MachineBudget.quotaMatches(currentQuotaGB: 2000, limitGB: 3500))
  }
}
