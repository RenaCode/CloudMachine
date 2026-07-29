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
    XCTAssertEqual(progress?.bytes, 46755840)
    XCTAssertEqual(progress?.totalBytes, 1596906082304)
    XCTAssertEqual(progress?.files, 83)
    XCTAssertEqual(progress?.totalFiles, 3022847)
  }

  // Regresja dla bledu z 2026-07-29: kod wczesniej zgadywal mount point z
  // twardo zakodowanej nazwy woluminu zamiast pytac o rzeczywisty
  // zarejestrowany cel - po recznej zmianie nazwy woluminu (np. na
  // "TimeMachine") GUI/watchdogi mylnie pokazywaly "brak woluminu". Jeden
  // wpis w destinationinfo, bo funkcja zaklada dokladnie jeden aktywny cel
  // (gwarancja architektury, patrz jej doc-comment) - nie "pierwszy z wielu".
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
}
