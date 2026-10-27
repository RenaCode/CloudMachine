import XCTest

@testable import CloudMachineCore

/// The pure parts of the machine layout: what is read from Lima, the
/// machine and macOS, and what is written into the machine's files.
final class VMLayoutTests: XCTestCase {

  // MARK: - Lima and the network

  func testInstanceStatusFromLimaList() {
    let list = """
      {"name":"other","status":"Running"}
      {"name":"cmsmb","status":"Stopped","vmType":"vz"}
      """
    XCTAssertEqual(VMLayout.instanceStatus(listJSON: list), "Stopped")
    XCTAssertNil(VMLayout.instanceStatus(listJSON: #"{"name":"other","status":"Running"}"#))
    XCTAssertNil(VMLayout.instanceStatus(listJSON: ""))
  }

  /// Lima's user-mode network is not reachable by Time Machine; the vzNAT
  /// address is.
  func testAddressSkipsLimaUserNetwork() {
    let output = """
      2: eth0    inet 192.168.5.15/24 metric 200 brd 192.168.5.255 scope global dynamic eth0
      3: lima0    inet 192.168.64.10/24 metric 100 brd 192.168.64.255 scope global dynamic lima0
      """
    XCTAssertEqual(VMLayout.vmAddress(ipAddrOutput: output), "192.168.64.10")
    XCTAssertNil(
      VMLayout.vmAddress(
        ipAddrOutput: "2: eth0    inet 192.168.5.15/24 scope global dynamic eth0"))
  }

  // MARK: - rclone rc

  func testReadingNeedsBothParts() {
    let json =
      #"{"diskCache":{"bytesUsed":53687091200,"uploadsQueued":12,"uploadsInProgress":8},"metadataCache":{}}"#
    let full = VMLayout.reading(scriptOutput: json + "\nCMFREE 107374182400\n")
    XCTAssertEqual(full?.buffer.bytesUsed, 53_687_091_200)
    XCTAssertEqual(full?.buffer.uploadsQueued, 12)
    XCTAssertEqual(full?.buffer.uploadsInProgress, 8)
    XCTAssertEqual(full?.freeBytes, 107_374_182_400)

    XCTAssertNil(VMLayout.reading(scriptOutput: json + "\n"), "no free space is no reading")
    XCTAssertNil(
      VMLayout.reading(scriptOutput: "\nCMFREE 107374182400\n"),
      "curl printing nothing (rclone down) is no reading, not an empty buffer")
    XCTAssertNil(VMLayout.reading(scriptOutput: "{\"error\":\"x\"}\nCMFREE 1\n"))
    XCTAssertNil(VMLayout.reading(scriptOutput: json + "\nCMFREE \n"), "empty df is no reading")
  }

  // MARK: - Writing into the machine

  func testShellQuoting() {
    XCTAssertEqual(VMLayout.shellQuoted("a b"), "'a b'")
    XCTAssertEqual(VMLayout.shellQuoted("it's"), #"'it'\''s'"#)
  }

  func testEnvLineSurvivesSpacesAndQuotes() {
    XCTAssertEqual(
      VMLayout.envLine("CM_BUNDLE", "Some Mac (3).sparsebundle"),
      #"CM_BUNDLE="Some Mac (3).sparsebundle""#)
    XCTAssertEqual(VMLayout.envLine("K", #"a"b\c"#), #"K="a\"b\\c""#)
  }

  // MARK: - Setup

  func testDestinationCommandShape() {
    XCTAssertEqual(
      VMSetup.destinationCommand(password: "Abc123", address: "192.168.64.10"),
      "sudo tmutil setdestination 'smb://tm:Abc123@192.168.64.10/CloudMachine'")
  }

  func testRandomPasswordIsLongAndPlain() throws {
    let password = try XCTUnwrap(VMSetup.randomPassword())
    XCTAssertEqual(password.count, 24)
    XCTAssertTrue(password.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) })
    XCTAssertNotEqual(password, VMSetup.randomPassword())
  }

  func testPasswordFileIsPrivateAndKept() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let file = dir.appendingPathComponent("tm-smb.pass")

    let first = try XCTUnwrap(VMSetup.loadOrCreatePassword(file: file))
    let mode = try FileManager.default.attributesOfItem(atPath: file.path)[.posixPermissions]
    XCTAssertEqual((mode as? NSNumber)?.intValue, 0o600)
    XCTAssertEqual(VMSetup.loadOrCreatePassword(file: file), first, "running again keeps it")
  }

  // MARK: - Status

  func testStatusReport() {
    let output = """
      SVC rclone-tm active
      SVC punchfs active
      SVC tm-bands-bind inactive
      SVC smbd active
      FD 910 1024
      BUNDLEENV 0
      IMAGES 1
      {"diskCache":{"bytesUsed":1073741824,"uploadsQueued":1,"uploadsInProgress":0,"erroredFiles":2,"outOfSpace":true}}
      CMFREE 2147483648
      """
    let report = VMStatus.report(scriptOutput: output)
    XCTAssertEqual(report.bundlePrepared, false)
    XCTAssertEqual(report.imageCount, 1)
    XCTAssertEqual(report.reading?.buffer.erroredFiles, 2)
    XCTAssertEqual(report.reading?.buffer.outOfSpace, true)
    XCTAssertEqual(report.services["punchfs"], "active")
    XCTAssertEqual(report.services["tm-bands-bind"], "inactive")
    XCTAssertEqual(report.punchfsOpenFiles, 910)
    XCTAssertEqual(report.punchfsFileLimit, 1024)
    XCTAssertEqual(report.reading?.freeBytes, 2_147_483_648)
  }

  /// `tm-bands-bind` may be skipped (inactive) before `vm-prepare-bundle`,
  /// never failed; a unit nobody reported is unknown, not fine.
  func testServicesVerdict() {
    var services = [
      "smb-throttle": "active", "rclone-tm": "active", "punchfs": "active",
      "tm-bands-bind": "inactive",
      "smbd": "active", "tm-meta-sync.timer": "active",
    ]
    XCTAssertEqual(VMStatus.servicesHealthy(services), true)
    services["tm-meta-sync.timer"] = "inactive"
    XCTAssertEqual(VMStatus.servicesHealthy(services), false)
    services["tm-meta-sync.timer"] = "active"
    services["tm-bands-bind"] = "failed"
    XCTAssertEqual(VMStatus.servicesHealthy(services), false)
    services["tm-bands-bind"] = "active"
    services["smbd"] = "inactive"
    XCTAssertEqual(VMStatus.servicesHealthy(services), false)
    services["smbd"] = nil
    XCTAssertNil(VMStatus.servicesHealthy(services))
  }

  /// An unknown backlog after `prepare-shutdown` must not read as "all uploaded".
  func testShutdownMessageNamesTheBacklog() {
    XCTAssertTrue(VMShutdown.outcomeMessage(unsentBytes: 0).contains("everything reached"))
    let left = VMShutdown.outcomeMessage(unsentBytes: 3 * VMGuard.gib)
    XCTAssertTrue(left.contains("3 GiB"), left)
    XCTAssertFalse(left.contains("everything reached"))
    let unknown = VMShutdown.outcomeMessage(unsentBytes: nil)
    XCTAssertFalse(unknown.contains("everything reached"))
    XCTAssertTrue(unknown.contains("did not say"))
  }

  func testPasswordIsRedactedInStatusLines() {
    XCTAssertEqual(
      VMStatus.redactedPassword("smb://tm:s3cret@192.168.64.10/CloudMachine"),
      "smb://tm:***@192.168.64.10/CloudMachine")
    XCTAssertEqual(
      VMStatus.redactedPassword("smb://tm@192.168.64.10/CloudMachine"),
      "smb://tm@192.168.64.10/CloudMachine")
    XCTAssertFalse(VMSetup.maskedDestinationCommand(address: "192.168.64.10").contains("s3cret"))
  }

  // MARK: - The template ships with the repo

  private static let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()

  /// Every file the Lima template copies in must exist - Lima reads them
  /// only when the machine is created, so a missing one shows up there.
  func testEveryFileTheTemplateNamesExists() throws {
    let vm = Self.repoRoot.appendingPathComponent("vm")
    let yaml = try String(contentsOf: vm.appendingPathComponent("cmsmb.yaml"), encoding: .utf8)
    let files = yaml.split(separator: "\n").compactMap { line -> String? in
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      guard trimmed.hasPrefix("file: ") else { return nil }
      return String(trimmed.dropFirst("file: ".count))
    }
    XCTAssertGreaterThanOrEqual(files.count, 9)
    for file in files {
      XCTAssertTrue(
        FileManager.default.fileExists(atPath: vm.appendingPathComponent(file).path),
        "vm/\(file) is named in cmsmb.yaml but missing")
      // Lima evaluates data files as Go templates.
      let text = try String(contentsOf: vm.appendingPathComponent(file), encoding: .utf8)
      XCTAssertFalse(text.contains("{{"), "vm/\(file) would be mangled by Lima's templating")
    }
  }

  /// The rclone download is pinned to a version AND a checksum, checked
  /// before anything is installed.
  func testRcloneIsPinnedWithAChecksum() throws {
    let yaml = try String(
      contentsOf: Self.repoRoot.appendingPathComponent("vm/cmsmb.yaml"), encoding: .utf8)
    XCTAssertTrue(yaml.contains("RCLONE_VERSION=v1.75.1"))
    XCTAssertNotNil(
      yaml.range(of: #"RCLONE_SHA256=[0-9a-f]{64}\n"#, options: .regularExpression))
    XCTAssertTrue(yaml.contains("sha256sum -c -"))
  }

  /// The descriptor limits that stopped the first full backup (EMFILE at
  /// 910 of 1024) must stay in the templates.
  func testDescriptorLimitsAreInTheTemplates() throws {
    let vm = Self.repoRoot.appendingPathComponent("vm")
    let punchfs = try String(
      contentsOf: vm.appendingPathComponent("systemd/punchfs.service"), encoding: .utf8)
    let smbd = try String(
      contentsOf: vm.appendingPathComponent("systemd/smbd.service.d/limits.conf"), encoding: .utf8)
    let smbConf = try String(
      contentsOf: vm.appendingPathComponent("samba/smb.conf"), encoding: .utf8)
    XCTAssertTrue(punchfs.contains("LimitNOFILE=524288"))
    XCTAssertTrue(smbd.contains("LimitNOFILE=524288"))
    XCTAssertTrue(smbConf.contains("max open files = 500000"))
  }

  /// 27.10.2026: policing (`police ... drop`) held SMB at ~2.7 MB/s; the
  /// shaper must stay a queue (ifb + htb), and the template must install it.
  func testSMBShaperQueuesInsteadOfDropping() throws {
    let vm = Self.repoRoot.appendingPathComponent("vm")
    let script = try String(
      contentsOf: vm.appendingPathComponent("smb-throttle.sh"), encoding: .utf8)
    let yaml = try String(contentsOf: vm.appendingPathComponent("cmsmb.yaml"), encoding: .utf8)
    XCTAssertTrue(script.contains("mirred egress redirect dev ifb0"))
    XCTAssertTrue(script.contains("htb rate"))
    XCTAssertFalse(script.contains("police rate"), "policing drops packets and collapses TCP")
    XCTAssertTrue(yaml.contains("file: systemd/smb-throttle.service"))
    XCTAssertTrue(yaml.contains("systemctl enable --now smb-throttle.service"))
  }

  /// The units `vm-setup` starts: a timer keeps its suffix, the rest are services.
  func testUnitNames() {
    XCTAssertEqual(VMLayout.unitName("smbd"), "smbd.service")
    XCTAssertEqual(VMLayout.unitName("tm-meta-sync.timer"), "tm-meta-sync.timer")
    XCTAssertTrue(VMLayout.services.contains("tm-meta-sync.timer"))
  }

  func testMetadataSyncIsReadFromTheMachinesClock() {
    func report(_ lines: String) -> VMStatus.Report { VMStatus.report(scriptOutput: lines) }
    let synced = report("BUNDLEENV 1\nMETASYNC 1000 1600")
    XCTAssertEqual(synced.metaSync, .age(600))
    XCTAssertEqual(VMStatus.metaSyncOverdue(synced), false)

    let stale = report("BUNDLEENV 1\nMETASYNC 1000 \(1000 + 3601)")
    XCTAssertEqual(VMStatus.metaSyncOverdue(stale), true)

    let never = report("BUNDLEENV 1\nMETASYNC 0 1600")
    XCTAssertEqual(never.metaSync, .never)
    XCTAssertEqual(VMStatus.metaSyncOverdue(never), true)

    // Before vm-prepare-bundle the unit is skipped by design.
    XCTAssertNil(VMStatus.metaSyncOverdue(report("BUNDLEENV 0\nMETASYNC 0 1600")))
    // Not read is not known - never "fine".
    XCTAssertNil(VMStatus.metaSyncOverdue(report("BUNDLEENV 1")))
    XCTAssertEqual(VMLayout.metaRemote, VMLayout.remote + "-meta")
  }

  /// A refusal newer than the last upload means the limit still holds; `0`
  /// from the machine means it does not; no line means not read.
  func testUploadLimitIsReadFromTheEndOfTheLog() {
    XCTAssertEqual(VMStatus.report(scriptOutput: "UPLOADLIMIT 1000 1600").uploadLimitAge, 600)
    XCTAssertEqual(VMStatus.report(scriptOutput: "UPLOADLIMIT 0 1600").uploadLimitAge, 0)
    XCTAssertNil(VMStatus.report(scriptOutput: "BUNDLEENV 1").uploadLimitAge)
    XCTAssertTrue(VMStatus.script.contains("Received upload limit error"))
  }

  /// 27.10.2026: the image's Info.plist, token and mapped/ were only on the
  /// machine's disk, so the bands on Drive could not be restored. The template
  /// must install the copy, and the copy must neither carry the bands nor
  /// wipe Drive from an image without its Info.plist.
  func testTemplateCopiesTheImageMetadataToDrive() throws {
    let vm = Self.repoRoot.appendingPathComponent("vm")
    let unit = try String(
      contentsOf: vm.appendingPathComponent("systemd/tm-meta-sync.service"), encoding: .utf8)
    let timer = try String(
      contentsOf: vm.appendingPathComponent("systemd/tm-meta-sync.timer"), encoding: .utf8)
    let yaml = try String(contentsOf: vm.appendingPathComponent("cmsmb.yaml"), encoding: .utf8)
    XCTAssertTrue(unit.contains("${CM_REMOTE}-meta/"))
    XCTAssertTrue(unit.contains(#"--exclude "*/bands/**""#))
    XCTAssertTrue(unit.contains(#"--exclude "*/lock""#))
    XCTAssertTrue(
      unit.contains(#"ExecCondition=/usr/bin/test -s "/srv/tm-local/${CM_BUNDLE}/Info.plist""#))
    XCTAssertTrue(unit.contains("ExecStartPost=/usr/bin/touch \(VMLayout.Guest.metaSyncStamp)"))
    XCTAssertTrue(timer.contains("OnUnitActiveSec=15min"))
    XCTAssertTrue(yaml.contains("file: systemd/tm-meta-sync.service"))
    XCTAssertTrue(yaml.contains("file: systemd/tm-meta-sync.timer"))
    XCTAssertTrue(yaml.contains("tm-meta-sync.timer\n"))
  }

  /// `install-launchd` installs every template in `launchd/`: exactly the
  /// four of the machine layout, and none of the retired disk-image agents.
  func testInstallLaunchdShipsOnlyTheMachineLayoutsAgents() throws {
    let launchd = Self.repoRoot.appendingPathComponent("launchd")
    let top = try FileManager.default.contentsOfDirectory(atPath: launchd.path).sorted()
    XCTAssertEqual(
      top,
      [
        "com.renacode.cloudmachine.app.plist.template",
        "com.renacode.cloudmachine.backup-health.plist.template",
        "com.renacode.cloudmachine.vm-guard.plist.template",
        "com.renacode.cloudmachine.vm-start.plist.template",
      ])
    for retired in AgentRepair.retired {
      XCTAssertFalse(top.contains { $0.contains(".\(retired).") }, retired)
    }
  }

  /// The guest's rclone remote control has no password: Lima must not forward
  /// it to the Mac's localhost, where any web page can reach it.
  func testTemplateForwardsNoPortsToTheMac() throws {
    let template = try String(
      contentsOf: Self.repoRoot.appendingPathComponent("vm/cmsmb.yaml"), encoding: .utf8)
    XCTAssertTrue(template.contains("portForwards:"), "no portForwards section")
    XCTAssertTrue(template.contains("ignore: true"))
  }

  func testTimeMachineTargetIsMatchedByWholeAddress() {
    let url = "smb://tm@192.168.64.10/CloudMachine"
    XCTAssertTrue(VMStatus.isMachineShare(url, address: "192.168.64.10"))
    XCTAssertFalse(VMStatus.isMachineShare(url, address: "192.168.64.1"))
    XCTAssertFalse(VMStatus.isMachineShare(url, address: "192.168.64.11"))
    XCTAssertTrue(VMStatus.isMachineShare(url, address: nil))
    XCTAssertFalse(VMStatus.isMachineShare("smb://nas/Backups", address: nil))
  }

  func testReadingCarriesTheUnsentBacklogFromVfsQueue() {
    let stats = #"{"diskCache":{"bytesUsed":124554051584,"uploadsQueued":2,"uploadsInProgress":1}}"#
    let queue = #"{"queue":[{"name":"bands/a","size":33554432},{"name":"bands/b","size":1048576}]}"#
    let r = VMLayout.reading(scriptOutput: "\(stats)\nCMQUEUE \(queue)\nCMFREE 1\n")
    XCTAssertEqual(r?.buffer.unsentBytes, 33_554_432 + 1_048_576)
    XCTAssertEqual(r?.buffer.bytesUsed, 124_554_051_584)
    let noQueue = VMLayout.reading(scriptOutput: "\(stats)\nCMQUEUE \nCMFREE 1\n")
    XCTAssertNotNil(noQueue, "stats and free space still make a reading")
    XCTAssertNil(noQueue?.buffer.unsentBytes, "an empty queue answer is unknown, not zero")
    XCTAssertEqual(VMLayout.unsentBytes(vfsQueueJSON: #"{"queue":[]}"#), 0)
  }
}
