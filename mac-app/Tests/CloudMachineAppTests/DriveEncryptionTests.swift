import XCTest

@testable import CloudMachineCore

/// `vm-encrypt`: the folder the machine uses, the scripts it runs in the
/// machine, and the gates in front of every step that could lose the backup.
final class DriveEncryptionTests: XCTestCase {

  // MARK: - Which folder

  /// An installation that never ran `vm-encrypt` keeps its folder: a release
  /// with this code must not move a live machine anywhere.
  func testWithoutEncryptionTheFolderIsUnchanged() {
    XCTAssertEqual(
      VMLayout.remote(override: nil, encrypted: false, folder: "mac-studio"),
      "gdrive:CloudMachine/mac-studio-tm")
    XCTAssertEqual(
      VMLayout.remote(override: nil, encrypted: true, folder: "mac-studio"), "gdrive-crypt:tm")
    XCTAssertEqual(
      VMLayout.remote(override: "gdrive:test-tm", encrypted: true, folder: "mac-studio"),
      "gdrive:test-tm")
    XCTAssertEqual(
      DriveEncryption.cryptRoot(folder: "mac-studio"), "gdrive:CloudMachine/mac-studio-crypt")
  }

  /// Only a complete marker moves the machine; a half-written file is none.
  func testMarker() {
    XCTAssertEqual(
      DriveEncryption.marker(text: "rclone-crypt 1793000000\n"),
      Date(timeIntervalSince1970: 1_793_000_000))
    XCTAssertNil(DriveEncryption.marker(text: "rclone-crypt"))
    XCTAssertNil(DriveEncryption.marker(text: ""))
    XCTAssertNil(DriveEncryption.marker(text: "yes 1793000000"))
    let date = Date(timeIntervalSince1970: 1_793_000_000)
    XCTAssertEqual(
      DriveEncryption.marker(text: DriveEncryption.markerText(switchedAt: date)), date)
  }

  func testConfigSection() {
    let section = DriveEncryption.configSection(
      cryptRoot: "gdrive:CloudMachine/mac-studio-crypt", obscuredPassword: "OBP",
      obscuredSalt: "OBS")
    XCTAssertTrue(section.contains("\n[gdrive-crypt]\ntype = crypt\n"))
    XCTAssertTrue(section.contains("remote = gdrive:CloudMachine/mac-studio-crypt\n"))
    XCTAssertTrue(section.contains("password = OBP\npassword2 = OBS\n"))
    XCTAssertTrue(section.contains("filename_encryption = standard\n"))
    XCTAssertTrue(section.contains("directory_name_encryption = true\n"))
    XCTAssertTrue(DriveEncryption.hasSection("[gdrive]\ntype = drive\n" + section))
    XCTAssertFalse(DriveEncryption.hasSection("[gdrive]\ntype = drive\n"))
  }

  /// With encryption the `:drive:` check cannot read names: any folder in the
  /// encrypted root is the backup.
  func testEncryptedFolderListing() {
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(
        succeeded: true, stdout: "q1b2c3d4/\n", stderr: "", anyFolderCounts: true), .present)
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(
        succeeded: true, stdout: "", stderr: "", anyFolderCounts: true), .absent)
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(succeeded: true, stdout: "q1b2c3d4/\n", stderr: ""),
      .absent)
  }

  // MARK: - The background copy

  func testCopyState() {
    func state(_ load: String, _ active: String, _ sub: String, _ result: String)
      -> DriveEncryption.CopyState
    {
      DriveEncryption.copyState(
        showOutput: "LoadState=\(load)\nActiveState=\(active)\nSubState=\(sub)\nResult=\(result)\n")
    }
    XCTAssertEqual(state("not-found", "inactive", "dead", "success"), .notRun)
    XCTAssertEqual(state("loaded", "active", "running", "success"), .running)
    XCTAssertEqual(state("loaded", "active", "exited", "success"), .done)
    XCTAssertEqual(state("loaded", "failed", "failed", "exit-code"), .failed("exit-code"))
    XCTAssertEqual(DriveEncryption.copyState(showOutput: ""), .unknown)
  }

  func testCopyKeepsAFinishedUnitVisible() {
    // The rclone lines are quoted once more inside `bash -c '...'`.
    let script = DriveEncryption.copyScript(.init(plain: "gdrive:CloudMachine/m-tm"))
      .replacingOccurrences(of: #"'\''"#, with: "'")
    XCTAssertTrue(script.contains("-p RemainAfterExit=yes"))
    XCTAssertTrue(script.contains("copy 'gdrive:CloudMachine/m-tm' 'gdrive-crypt:tm'"))
    XCTAssertTrue(script.contains("copy 'gdrive:CloudMachine/m-tm-meta' 'gdrive-crypt:tm-meta'"))
    XCTAssertTrue(script.contains("--drive-stop-on-upload-limit"))
    XCTAssertFalse(script.contains(" sync "))
  }

  // MARK: - Switch

  private let remotes = DriveEncryption.Remotes(plain: "gdrive:CloudMachine/m-tm")

  func testFinalSyncChecksEveryFileEitherWay() {
    let forward = DriveEncryption.finalSyncScript(remotes, direction: .encrypt)
    XCTAssertTrue(forward.hasPrefix("set -euo pipefail\n"))
    XCTAssertTrue(forward.contains("sync 'gdrive:CloudMachine/m-tm' 'gdrive-crypt:tm'"))
    XCTAssertTrue(forward.contains("cryptcheck 'gdrive:CloudMachine/m-tm' 'gdrive-crypt:tm'"))
    XCTAssertTrue(
      forward.contains("cryptcheck 'gdrive:CloudMachine/m-tm-meta' 'gdrive-crypt:tm-meta'"))
    let back = DriveEncryption.finalSyncScript(remotes, direction: .decrypt)
    XCTAssertTrue(back.contains("sync 'gdrive-crypt:tm' 'gdrive:CloudMachine/m-tm'"))
    XCTAssertTrue(back.contains("cryptcheck 'gdrive:CloudMachine/m-tm' 'gdrive-crypt:tm'"))
  }

  func testCachePaths() {
    XCTAssertEqual(
      DriveEncryption.cachePaths(remote: "gdrive:CloudMachine/m-tm"),
      [
        "/var/cache/rclone/vfs/gdrive/CloudMachine/m-tm",
        "/var/cache/rclone/vfs/gdrive/CloudMachine/m-tm".replacingOccurrences(
          of: "/vfs/", with: "/vfsMeta/"),
      ])
    XCTAssertEqual(
      DriveEncryption.cachePaths(remote: "gdrive-crypt:tm").first,
      "/var/cache/rclone/vfs/gdrive-crypt/tm")
  }

  /// The order is the safety: the queue is checked empty before anything
  /// changes, the way back is armed before the units stop, and only the old
  /// remote's buffer is deleted.
  func testRepointOrder() {
    let script = DriveEncryption.repointScript(
      oldRemote: "gdrive:CloudMachine/m-tm", newRemote: "gdrive-crypt:tm", stamp: "S")
    let lines = script.split(separator: "\n").map(String.init)
    func index(_ text: String) -> Int {
      lines.firstIndex { $0.contains(text) } ?? Int.max
    }
    XCTAssertEqual(lines.first, "set -euo pipefail")
    // Starts only from the folder it was asked to leave.
    XCTAssertLessThan(
      index(#"grep -qx 'CM_REMOTE="gdrive:CloudMachine/m-tm"'"#), index("systemctl stop smbd"))
    XCTAssertLessThan(index("systemctl cat rclone-tm"), index("systemctl stop smbd"))
    XCTAssertLessThan(index("unsent=$("), index("cp -p /etc/cloudmachine/vm.env"))
    XCTAssertLessThan(index("trap '"), index("systemctl stop tm-bands-bind"))
    XCTAssertLessThan(index("systemctl stop tm-bands-bind"), index("rm -rf"))
    XCTAssertTrue(script.contains(#"CM_REMOTE="gdrive-crypt:tm""#))
    XCTAssertTrue(script.contains("rm -rf '/var/cache/rclone/vfs/gdrive/CloudMachine/m-tm'"))
    XCTAssertFalse(script.contains("rm -rf '/var/cache/rclone/vfs/gdrive-crypt"))
    XCTAssertLessThan(index("test \"$after\" -eq \"$before\""), index("trap - ERR"))
  }

  private func goodSwitch(_ direction: DriveEncryption.Direction = .encrypt)
    -> DriveEncryption.SwitchFacts
  {
    DriveEncryption.SwitchFacts(
      direction: direction, enabled: direction == .decrypt, cryptRemoteInMachine: true,
      timeMachineRunning: false,
      reading: .init(
        buffer: .init(bytesUsed: 100 << 30, uploadsQueued: 0, uploadsInProgress: 0, unsentBytes: 0),
        freeBytes: 50 << 30),
      copyState: .done, guardHoldsPause: false)
  }

  func testSwitchGate() {
    XCTAssertNil(DriveEncryption.switchRefusal(goodSwitch()))
    var facts = goodSwitch()
    facts.enabled = true
    XCTAssertNotNil(DriveEncryption.switchRefusal(facts))
    for change: (inout DriveEncryption.SwitchFacts) -> Void in [
      { $0.cryptRemoteInMachine = nil }, { $0.cryptRemoteInMachine = false },
      { $0.timeMachineRunning = nil }, { $0.timeMachineRunning = true },
      { $0.reading = nil }, { $0.reading?.buffer.unsentBytes = nil },
      { $0.reading?.buffer.unsentBytes = 1 }, { $0.reading?.buffer.uploadsInProgress = 1 },
      { $0.reading?.buffer.erroredFiles = 1 }, { $0.guardHoldsPause = true },
      { $0.copyState = .running }, { $0.copyState = .notRun },
      { $0.copyState = .failed("exit-code") }, { $0.copyState = .unknown },
    ] {
      var bad = goodSwitch()
      change(&bad)
      XCTAssertNotNil(DriveEncryption.switchRefusal(bad), "\(bad)")
    }
  }

  /// Going back decrypts in the last sync itself; the forward copy's state
  /// does not matter, being on the encrypted folder does.
  func testRollbackGate() {
    var facts = goodSwitch(.decrypt)
    facts.copyState = .notRun
    XCTAssertNil(DriveEncryption.switchRefusal(facts))
    facts.enabled = false
    XCTAssertNotNil(DriveEncryption.switchRefusal(facts))
  }

  // MARK: - Deleting the plain folder

  private let switched = Date(timeIntervalSince1970: 1_793_000_000)

  private func goodDelete() -> DriveEncryption.DeleteFacts {
    DriveEncryption.DeleteFacts(
      switchedAt: switched, lastBackup: switched.addingTimeInterval(3600),
      lastMetaSync: switched.addingTimeInterval(4000),
      reading: .init(
        buffer: .init(bytesUsed: 1, uploadsQueued: 0, uploadsInProgress: 0, unsentBytes: 0),
        freeBytes: 1),
      secretsSavedElsewhere: true, restoreChecked: true)
  }

  func testDeleteGate() {
    XCTAssertNil(DriveEncryption.deleteRefusal(goodDelete()))
    for change: (inout DriveEncryption.DeleteFacts) -> Void in [
      { $0.switchedAt = nil }, { $0.secretsSavedElsewhere = false }, { $0.restoreChecked = false },
      { $0.lastBackup = nil }, { $0.lastBackup = self.switched },
      { $0.lastMetaSync = nil }, { $0.lastMetaSync = self.switched.addingTimeInterval(60) },
      { $0.reading = nil }, { $0.reading?.buffer.unsentBytes = 5 },
      { $0.reading?.buffer.erroredFiles = 1 },
    ] {
      var bad = goodDelete()
      change(&bad)
      XCTAssertNotNil(DriveEncryption.deleteRefusal(bad), "\(bad)")
    }
  }

  func testDeleteGoesToTheBinAndTouchesOnlyThePlainFolder() {
    let script = DriveEncryption.deletePlainScript(plain: "gdrive:CloudMachine/m-tm")
    XCTAssertTrue(script.contains("purge --drive-use-trash=true 'gdrive:CloudMachine/m-tm'"))
    XCTAssertTrue(script.contains("purge --drive-use-trash=true 'gdrive:CloudMachine/m-tm-meta'"))
    XCTAssertFalse(script.contains("gdrive-crypt"))
    XCTAssertFalse(script.contains("use-trash=false"))
  }

  func testMetaSyncDate() {
    XCTAssertEqual(
      DriveEncryption.metaSyncDate("1793000000\n"), Date(timeIntervalSince1970: 1_793_000_000))
    XCTAssertNil(DriveEncryption.metaSyncDate("stat: cannot stat"))
  }
}
