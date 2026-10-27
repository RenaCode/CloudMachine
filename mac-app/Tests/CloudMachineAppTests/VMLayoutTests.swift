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
      {"diskCache":{"bytesUsed":1073741824,"uploadsQueued":1,"uploadsInProgress":0}}
      CMFREE 2147483648
      """
    let report = VMStatus.report(scriptOutput: output)
    XCTAssertEqual(report.services["punchfs"], "active")
    XCTAssertEqual(report.services["tm-bands-bind"], "inactive")
    XCTAssertEqual(report.punchfsOpenFiles, 910)
    XCTAssertEqual(report.punchfsFileLimit, 1024)
    XCTAssertEqual(report.reading?.freeBytes, 2_147_483_648)
  }

  func testDestinationURLs() {
    let info = """
      ====================================================
      Name          : CloudMachine
      Kind          : Network
      URL           : smb://tm@192.168.64.10/CloudMachine
      ID            : 1234
      """
    XCTAssertEqual(
      VMStatus.destinationURLs(destinationInfo: info), ["smb://tm@192.168.64.10/CloudMachine"])
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

  /// `install-launchd` installs every template at the TOP of `launchd/`. The
  /// machine's agents must not be there: a Mac on the attached-image layout
  /// would get an agent starting a machine it does not have.
  func testMachineAgentsAreNotInstalledByInstallLaunchd() throws {
    let launchd = Self.repoRoot.appendingPathComponent("launchd")
    let top = try FileManager.default.contentsOfDirectory(atPath: launchd.path)
    XCTAssertFalse(top.contains { $0.contains("vm-") }, "\(top)")
    let vm = try FileManager.default.contentsOfDirectory(
      atPath: launchd.appendingPathComponent("vm").path
    ).sorted()
    XCTAssertEqual(
      vm,
      [
        "com.renacode.cloudmachine.vm-guard.plist.template",
        "com.renacode.cloudmachine.vm-start.plist.template",
      ])
  }

  func testTimeMachineTargetIsMatchedByWholeAddress() {
    let urls = ["smb://tm@192.168.64.10/CloudMachine"]
    XCTAssertTrue(VMStatus.targets(urls: urls, address: "192.168.64.10"))
    XCTAssertFalse(VMStatus.targets(urls: urls, address: "192.168.64.1"))
    XCTAssertFalse(VMStatus.targets(urls: urls, address: "192.168.64.11"))
    XCTAssertFalse(VMStatus.targets(urls: [], address: "192.168.64.10"))
  }
}
