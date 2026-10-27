import XCTest

@testable import CloudMachineCore

/// The Mac side of Google Drive: the rclone download, free space, and the
/// Drive quota answer.
final class DriveLayerTests: XCTestCase {

  // MARK: - rclone checksum

  private let sums = """
    3a1f0000000000000000000000000000000000000000000000000000000000aa  rclone-v1.75.1-osx-amd64.zip
    c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f  rclone-v1.75.1-osx-arm64.zip
    9b2c0000000000000000000000000000000000000000000000000000000000bb  rclone-v1.75.1-linux-amd64.zip
    """

  func testExpectedChecksumPicksTheRightArchive() {
    XCTAssertEqual(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v1.75.1-osx-arm64.zip"),
      "c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f")
  }

  /// A missing entry MUST give nil, not some other checksum - otherwise the
  /// installer would compare the archive with another file's checksum and
  /// either reject a correct download or (worse) let an incorrect one through.
  func testExpectedChecksumReturnsNilWhenArchiveMissing() {
    XCTAssertNil(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v9.9.9-osx-arm64.zip"))
  }

  /// Free space has to be counted pessimistically, like `df`. The "important
  /// usage" measure included space taken by snapshots and showed 1202 GB where
  /// `df` said 427 GB.
  func testFreeSpaceMatchesStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let expected = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BackupHealth.macFreeGB(), expected)
  }

  /// `rclone about --json`: an account without a limit has no `total`, and
  /// then there is nothing to watch - not "zero free".
  func testDriveFreeSpaceFromRcloneAbout() {
    XCTAssertEqual(
      BackupHealth.driveFreeBytes(aboutJSON: #"{"total":100,"used":30,"free":70}"#), 70)
    XCTAssertEqual(BackupHealth.driveFreeBytes(aboutJSON: #"{"total":100,"used":30}"#), 70)
    XCTAssertNil(BackupHealth.driveFreeBytes(aboutJSON: #"{"used":30}"#))
    XCTAssertNil(BackupHealth.driveFreeBytes(aboutJSON: "not json"))
  }
}
