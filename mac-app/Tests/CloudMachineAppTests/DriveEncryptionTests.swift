import XCTest

@testable import CloudMachineCore

/// `vm-encrypt`: the folder the machine uses, the scripts it runs in the
/// machine, and the gates in front of every step that could lose the backup.
final class DriveEncryptionTests: XCTestCase {

  // MARK: - Which folder

  /// An installation that never ran `vm-encrypt` keeps its folder: a release
  /// with this code must not move a live machine anywhere.
  func testWithoutEncryptionTheFolderIsUnchanged() {
    let plain = VMLayout.plainRemote(override: nil, folder: "mac-studio")
    XCTAssertEqual(plain, "gdrive:CloudMachine/mac-studio-tm")
    XCTAssertEqual(VMLayout.remote(plain: plain, encrypted: false), plain)
    XCTAssertEqual(VMLayout.remote(plain: plain, encrypted: true), "gdrive-crypt:tm")
    XCTAssertEqual(
      VMLayout.plainRemote(override: "gdrive:test-tm", folder: "mac-studio"), "gdrive:test-tm")
    XCTAssertEqual(DriveEncryption.cryptRoot(plain: plain), "gdrive:CloudMachine/mac-studio-crypt")
    XCTAssertEqual(DriveEncryption.cryptRoot(plain: "gdrive:test-tm"), "gdrive:test-crypt")
  }

  /// A throwaway machine never shares the live marker or the live folder:
  /// `delete-plain` there must not reach the real backup.
  func testThrowawayMachineIsIsolated() {
    XCTAssertEqual(DriveEncryption.markerName(instance: "cmsmb"), "drive-encryption")
    XCTAssertEqual(DriveEncryption.markerName(instance: "cmtest"), "drive-encryption-cmtest")
    let mac = "/Users/x/.config/rclone/rclone.conf"
    func refusal(_ instance: String, _ remote: String?, _ config: String?) -> String? {
      DriveEncryption.throwawayRefusal(
        instance: instance, remoteOverride: remote, rcloneConfig: config, defaultConfig: mac)
    }
    XCTAssertNil(refusal("cmsmb", nil, nil))
    XCTAssertNil(refusal("cmsmb", nil, mac))
    XCTAssertNotNil(refusal("cmtest", nil, "/tmp/cmtest/rclone.conf"))
    XCTAssertNil(refusal("cmtest", "gdrive:test-tm", "/tmp/cmtest/rclone.conf"))
  }

  /// Decision 04.11: a throwaway machine never writes the Mac's rclone.conf
  /// or the live Keychain entry. Without its own RCLONE_CONFIG every step
  /// refuses and says what to set; its Keychain entry is its own by name.
  func testThrowawayMachineNeedsItsOwnConfigAndKeychainEntry() {
    let mac = "/Users/x/.config/rclone/rclone.conf"
    func refusal(_ config: String?) -> String? {
      DriveEncryption.throwawayRefusal(
        instance: "cmtest", remoteOverride: "gdrive:test-tm", rcloneConfig: config,
        defaultConfig: mac)
    }
    for config in [nil, "", mac, "/Users/x/.config/rclone/../rclone/rclone.conf"] {
      let text = refusal(config)
      XCTAssertNotNil(text, "\(String(describing: config))")
      XCTAssertTrue(text?.contains("RCLONE_CONFIG") == true)
    }
    XCTAssertNil(refusal("/tmp/cmtest/rclone.conf"))

    XCTAssertEqual(DriveEncryption.keychainService(instance: "cmsmb"), "cloudmachine-drive-crypt")
    XCTAssertEqual(
      DriveEncryption.keychainService(instance: "cmtest"), "cloudmachine-drive-crypt-cmtest")
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

  /// A wrong password in the machine's rclone.conf: `gdrive-crypt:tm` then
  /// encrypts to another folder name, `sync` finds "nothing" there, uploads
  /// the whole backup again under the wrong key and `cryptcheck` agrees with
  /// it (container test, 03.11: switch succeeded, 182 files in the folder).
  /// Listing the crypt root with `--crypt-strict-names` fails on the folders
  /// the right key wrote, before anything is copied.
  func testSyncAndCopyRefuseAnotherKey() {
    let check = "lsf --dirs-only --crypt-strict-names 'gdrive-crypt:'"
    for direction in [DriveEncryption.Direction.encrypt, .decrypt] {
      let script = DriveEncryption.finalSyncScript(remotes, direction: direction)
      let lines = script.split(separator: "\n").map(String.init)
      let listed = lines.firstIndex { $0.contains(check) } ?? Int.max
      let synced = lines.firstIndex { $0.contains(" sync ") } ?? -1
      XCTAssertLessThan(listed, synced, "\(direction)")
      // The copy has run, so both folders must be readable with this key -
      // checked before anything is synced.
      for folder in ["grep -qx 'tm/'", "grep -qx 'tm-meta/'"] {
        let grepped = lines.firstIndex { $0.contains(folder) } ?? Int.max
        XCTAssertLessThan(grepped, synced, "\(direction) \(folder)")
      }
    }
    // The copy starts from an empty folder, but a resumed one must not
    // continue under another key.
    let copy = DriveEncryption.copyScript(.init(plain: "gdrive:CloudMachine/m-tm"))
      .replacingOccurrences(of: #"'\''"#, with: "'")
    let listed = copy.range(of: check)?.lowerBound
    let copied = copy.range(of: "copy 'gdrive:CloudMachine/m-tm'")?.lowerBound
    XCTAssertNotNil(listed)
    XCTAssertNotNil(copied)
    if let listed, let copied { XCTAssertLessThan(listed, copied) }
    // Before the first copy the folder does not exist and `lsf` fails on it
    // (the container test's first try of this check: every copy failed).
    let made = copy.range(of: "mkdir 'gdrive-crypt:'")?.lowerBound
    XCTAssertNotNil(made)
    if let made, let listed { XCTAssertLessThan(made, listed) }
  }

  /// A nested encrypted folder: the listing of the crypt root shows only its
  /// first component, so that is what is looked for.
  func testEncryptedFolderChecks() {
    XCTAssertEqual(
      DriveEncryption.encryptedFolderChecks(.init(plain: "gdrive:m-tm")), ["tm/", "tm-meta/"])
    XCTAssertEqual(
      DriveEncryption.encryptedFolderChecks(
        .init(plain: "gdrive:m-tm", encrypted: "gdrive-crypt:a/tm")), ["a/"])
  }

  /// The listing check cannot see a key that was wrong from the first copy
  /// on: everything is then consistently under that key. What can see it is
  /// the Mac: `setup` writes the same section to both files, so the machine's
  /// password, salt and folder must equal the Mac's, character for character.
  func testMachineKeyMustEqualTheMacs() {
    let mac = """
      [gdrive]
      type = drive

      [gdrive-crypt]
      type = crypt
      remote = gdrive:CloudMachine/m-crypt
      password = AAA
      password2 = BBB
      filename_encryption = standard

      [other]
      password = ZZZ
      """
    let keys = DriveEncryption.cryptKeys(config: mac)
    XCTAssertEqual(
      keys,
      ["remote": "gdrive:CloudMachine/m-crypt", "password": "AAA", "password2": "BBB"])
    // The machine's half, as `sed -n '/^\[gdrive-crypt\]/,/^\[/p'` prints it.
    let same = [
      "[gdrive-crypt]", "type = crypt", "remote = gdrive:CloudMachine/m-crypt",
      "password = AAA", "password2 = BBB", "[other]", "",
    ].joined(separator: "\n")
    XCTAssertNil(DriveEncryption.keyRefusal(mac: mac, machine: same))
    for (from, to) in [("AAA", "XXX"), ("BBB", "XXX")] {
      XCTAssertNotNil(
        DriveEncryption.keyRefusal(
          mac: mac, machine: same.replacingOccurrences(of: from, with: to)), from)
    }
    XCTAssertNotNil(
      DriveEncryption.keyRefusal(
        mac: mac, machine: same.replacingOccurrences(of: "m-crypt", with: "x-crypt")))
    // Not read, or no section on one side: refused like a difference.
    XCTAssertNotNil(DriveEncryption.keyRefusal(mac: nil, machine: same))
    XCTAssertNotNil(DriveEncryption.keyRefusal(mac: mac, machine: nil))
    XCTAssertNotNil(DriveEncryption.keyRefusal(mac: "[gdrive]\n", machine: "[gdrive]\n"))
  }

  /// A failed listing of foreign-key folders says what to do, not only
  /// rclone's last lines.
  func testForeignFoldersAreExplained() {
    let out =
      "ERROR : error listing: there were 2 undecryptable name errors."
      + " first error: 0b3t: undecryptable dir name detected"
    let hint = DriveEncryption.syncFailureHint(out, cryptRoot: "gdrive:CloudMachine/m-crypt")
    XCTAssertNotNil(hint)
    XCTAssertTrue(hint?.contains("gdrive:CloudMachine/m-crypt") == true)
    XCTAssertNil(DriveEncryption.syncFailureHint("directory not found", cryptRoot: "x"))
  }

  /// Every guest script parses (`bash -n`); the container test ran them.
  func testScriptsParse() throws {
    let plain = "gdrive:CloudMachine/m-tm"
    let r = DriveEncryption.Remotes(plain: plain)
    let scripts = [
      DriveEncryption.copyScript(r), DriveEncryption.copyStateScript,
      DriveEncryption.finalSyncScript(r, direction: .encrypt),
      DriveEncryption.finalSyncScript(r, direction: .decrypt),
      DriveEncryption.repointScript(oldRemote: plain, newRemote: r.encrypted, stamp: "S"),
      DriveEncryption.repointScript(oldRemote: r.encrypted, newRemote: plain, stamp: "S"),
      DriveEncryption.deletePlainScript(plain: plain),
    ]
    for script in scripts {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/bin/bash")
      process.arguments = ["-n", "-c", script]
      try process.run()
      process.waitUntilExit()
      XCTAssertEqual(process.terminationStatus, 0, script)
    }
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
    // `move` stopped Samba before the last sync. A failure before the way
    // back is armed (no bands, a preflight miss) must not leave it stopped:
    // container test, 03.11, `before=0` left smbd inactive.
    XCTAssertLessThan(index("trap 'systemctl start smbd' ERR"), index("systemctl cat rclone-tm"))
    XCTAssertLessThan(index("trap 'systemctl start smbd' ERR"), index("test \"$before\" -gt 0"))
    XCTAssertLessThan(index("trap 'systemctl start smbd' ERR"), index("trap 'echo \"FAILED"))
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
