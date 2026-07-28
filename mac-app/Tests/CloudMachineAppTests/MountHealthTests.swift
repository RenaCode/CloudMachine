import XCTest

@testable import CloudMachineCore

final class MountHealthTests: XCTestCase {
  private let sampleMountOutput = """
    localhost:/CloudMachine-imac on /Users/test/CloudMachine-Mount/imac (nfs, nodev, nosuid, mounted by test)
    /dev/disk5s1 on /Volumes/CloudMachine-Backup-imac (apfs, local, nodev, nosuid, journaled, mounted by test)
    """

  func testIsMountedIn_exactPath_matches() {
    XCTAssertTrue(
      MountHealth.isMountedIn(sampleMountOutput, path: "/Users/test/CloudMachine-Mount/imac"))
    XCTAssertTrue(
      MountHealth.isMountedIn(sampleMountOutput, path: "/Volumes/CloudMachine-Backup-imac"))
  }

  func testIsMountedIn_pathIsPrefixOfAnotherMachineKey_doesNotFalsePositive() {
    // "imac" nie powinien wygladac na zamontowany tylko dlatego, ze
    // "imac-2" naprawde jest - to byl blad zwyklego "contains(podciag)".
    let output = """
      localhost:/CloudMachine-imac-2 on /Users/test/CloudMachine-Mount/imac-2 (nfs, nodev, nosuid, mounted by test)
      """
    XCTAssertFalse(MountHealth.isMountedIn(output, path: "/Users/test/CloudMachine-Mount/imac"))
    XCTAssertTrue(MountHealth.isMountedIn(output, path: "/Users/test/CloudMachine-Mount/imac-2"))
  }

  func testIsMountedIn_notMounted_returnsFalse() {
    XCTAssertFalse(MountHealth.isMountedIn(sampleMountOutput, path: "/Volumes/DoesNotExist"))
  }

  func testIsMountedIn_emptyOutput_returnsFalse() {
    XCTAssertFalse(MountHealth.isMountedIn("", path: "/Volumes/CloudMachine-Backup-imac"))
  }

  // MARK: - detectStuckBand

  private func line(_ s: String) -> Substring { Substring(s) }

  func testDetectStuckBand_singleBandQueuedRepeatedlyWithoutCompleting_isDetected() {
    var lines: [Substring] = []
    for _ in 0..<250 {
      lines.append(
        line(
          "2026/07/27 21:14:54 INFO  : backup.sparsebundle/bands/2c3: vfs cache: queuing for upload in 5s"
        ))
    }
    XCTAssertEqual(MountHealth.detectStuckBand(logLines: lines, minQueueEvents: 200), "2c3")
  }

  func testDetectStuckBand_bandEventuallyCompletes_isNotStuck() {
    var lines: [Substring] = []
    for _ in 0..<250 {
      lines.append(line("... backup.sparsebundle/bands/2c3: vfs cache: queuing for upload in 5s"))
    }
    lines.append(line("... backup.sparsebundle/bands/2c3: Copied (new)"))
    XCTAssertNil(MountHealth.detectStuckBand(logLines: lines, minQueueEvents: 200))
  }

  func testDetectStuckBand_manyDifferentBandsEachBelowThreshold_isNotStuck() {
    var lines: [Substring] = []
    for i in 0..<300 {
      lines.append(line("... backup.sparsebundle/bands/\(i): vfs cache: queuing for upload in 5s"))
    }
    XCTAssertNil(MountHealth.detectStuckBand(logLines: lines, minQueueEvents: 200))
  }

  func testDetectStuckBand_belowMinQueueEvents_isNotStuck() {
    var lines: [Substring] = []
    for _ in 0..<50 {
      lines.append(line("... backup.sparsebundle/bands/2c3: vfs cache: queuing for upload in 5s"))
    }
    XCTAssertNil(MountHealth.detectStuckBand(logLines: lines, minQueueEvents: 200))
  }

  func testDetectStuckBand_emptyLog_isNotStuck() {
    XCTAssertNil(MountHealth.detectStuckBand(logLines: [], minQueueEvents: 200))
  }
}
