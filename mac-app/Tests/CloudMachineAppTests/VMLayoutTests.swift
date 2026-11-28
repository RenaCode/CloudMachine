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

  /// `limactl list --json` of ALL instances fails when any one of them cannot
  /// be read ("bufio.Scanner: token too long", seen on 12.11 on a throwaway
  /// machine during its first boot) and then blinds everything that asks about
  /// `cmsmb`. Ask for the one instance; "unmatched instances" means it is not
  /// there, any other failure is an unanswered question.
  func testStatusOfOneInstanceDistinguishesMissingFromUnanswered() throws {
    let one = #"{"name":"cmsmb","status":"Running"}"#
    XCTAssertEqual(
      try VMLayout.instanceStatus(exitCode: 0, stdout: one, stderr: ""), "Running")
    XCTAssertNil(
      try VMLayout.instanceStatus(
        exitCode: 1, stdout: "",
        stderr: "level=warning msg=\"No instance matching cmsmb found.\"\n"
          + "level=fatal msg=\"unmatched instances\""))
    XCTAssertThrowsError(
      try VMLayout.instanceStatus(
        exitCode: 1, stdout: "", stderr: "level=fatal msg=\"bufio.Scanner: token too long\""))
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
    XCTAssertEqual(VMStatus.servicesHealthy(services, bundlePrepared: false), true)
    services["tm-meta-sync.timer"] = "inactive"
    XCTAssertEqual(VMStatus.servicesHealthy(services, bundlePrepared: false), false)
    services["tm-meta-sync.timer"] = "active"
    services["tm-bands-bind"] = "failed"
    XCTAssertEqual(VMStatus.servicesHealthy(services, bundlePrepared: false), false)
    services["tm-bands-bind"] = "active"
    services["smbd"] = "inactive"
    XCTAssertEqual(VMStatus.servicesHealthy(services, bundlePrepared: false), false)
    services["smbd"] = nil
    XCTAssertNil(VMStatus.servicesHealthy(services, bundlePrepared: false))
  }

  /// After `vm-prepare-bundle` an inactive bind is NOT "skipped by design":
  /// the bands then go to the machine's local disk instead of Drive, with
  /// every other service green. Whether the image is prepared not read =
  /// unknown, not fine.
  func testInactiveBindAfterPrepareIsNotHealthy() {
    let services = [
      "smb-throttle": "active", "rclone-tm": "active", "punchfs": "active",
      "tm-bands-bind": "inactive",
      "smbd": "active", "tm-meta-sync.timer": "active",
    ]
    XCTAssertEqual(VMStatus.servicesHealthy(services, bundlePrepared: true), false)
    XCTAssertNil(VMStatus.servicesHealthy(services, bundlePrepared: nil))
    var bound = services
    bound["tm-bands-bind"] = "active"
    XCTAssertEqual(VMStatus.servicesHealthy(bound, bundlePrepared: true), true)
    XCTAssertEqual(VMStatus.servicesHealthy(bound, bundlePrepared: nil), true)
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

  /// 12 and 13 Nov 2026: punchfs was (re)started and the bind ran before its
  /// FUSE mount showed `bands` ("special device /srv/tm-punch/bands does not
  /// exist"); the bind failed, and Samba, which Requires it, stayed down for
  /// a day. The bind must wait for the mount instead of racing it.
  func testBandsBindWaitsForThePunchfsMount() throws {
    let unit = try String(
      contentsOf: Self.repoRoot.appendingPathComponent("vm/systemd/tm-bands-bind.service"),
      encoding: .utf8)
    let pre = unit.split(separator: "\n").first { $0.hasPrefix("ExecStartPre=") }
    XCTAssertNotNil(pre, "tm-bands-bind needs an ExecStartPre that waits for punchfs")
    XCTAssertTrue(pre?.contains("mountpoint -q /srv/tm-punch") ?? false)
    XCTAssertTrue(pre?.contains("/srv/tm-punch/bands") ?? false)
    XCTAssertTrue(unit.contains("TimeoutStartSec="))
  }

  private func unit(_ path: String) throws -> String {
    try String(
      contentsOf: Self.repoRoot.appendingPathComponent(path), encoding: .utf8)
  }

  /// The marker's AGE comes with the report: -1 = no marker.
  func testHoldMarkerAgeIsReadFromTheStatusReport() {
    XCTAssertEqual(VMStatus.report(scriptOutput: "SMBDHOLD 90").smbdHoldAge, 90)
    XCTAssertNil(VMStatus.report(scriptOutput: "SMBDHOLD -1").smbdHoldAge)
    XCTAssertNil(VMStatus.report(scriptOutput: "BUNDLEENV 1").smbdHoldAge)
    XCTAssertTrue(VMStatus.script.contains("SMBDHOLD"))
    XCTAssertTrue(VMStatus.script.contains(VMLayout.Guest.smbdHold))
  }

  /// One rule: a hold is informational, until it outlasts the limit - then a
  /// forgotten marker no longer hides a Samba that is simply dead.
  func testHeldSambaIsNotAFailureUntilTheLimit() {
    let down = [
      "smb-throttle": "active", "rclone-tm": "active", "punchfs": "active",
      "tm-bands-bind": "active", "smbd": "inactive", "nmbd": "active",
      "tm-meta-sync.timer": "active",
    ]
    XCTAssertEqual(VMStatus.servicesHealthy(down, bundlePrepared: true), false)
    XCTAssertEqual(VMStatus.servicesHealthy(down, bundlePrepared: true, smbdHeld: true), true)
    var report = VMStatus.Report()
    report.services = down
    report.bundlePrepared = true
    report.smbdHoldAge = 60
    XCTAssertTrue(report.smbdHeld)
    report.smbdHoldAge = VMLayout.smbdHoldLimit + 1
    XCTAssertFalse(report.smbdHeld, "a hold older than the limit is a failure again")
    report.smbdHoldAge = nil
    XCTAssertFalse(report.smbdHeld)
    // Held does not excuse any other unit.
    var other = down
    other["punchfs"] = "failed"
    XCTAssertEqual(VMStatus.servicesHealthy(other, bundlePrepared: true, smbdHeld: true), false)
  }

  /// Runs a shell fragment with a fake `systemctl` and the marker in a temp dir.
  private func runWithFakeSystemctl(
    _ fragment: String, stopSucceeds: Bool, markerExists: Bool = false
  ) throws -> (marker: Bool, calls: String) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let marker = dir.appendingPathComponent("hold").path
    let log = dir.appendingPathComponent("calls").path
    let fake = dir.appendingPathComponent("systemctl")
    try
      "#!/bin/sh\necho \"$@\" >> \(log)\n[ \"$1\" = stop ] && exit \(stopSucceeds ? 0 : 1)\nexit 0\n"
      .write(to: fake, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fake.path)
    if markerExists { FileManager.default.createFile(atPath: marker, contents: nil) }
    let script = fragment.replacingOccurrences(of: VMLayout.Guest.smbdHold, with: marker)
      .replacingOccurrences(of: "/bin/systemctl", with: fake.path)
      .replacingOccurrences(of: "systemctl ", with: fake.path + " ")
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = ["-c", script]
    p.standardError = FileHandle.nullDevice
    try p.run()
    p.waitUntilExit()
    return (
      FileManager.default.fileExists(atPath: marker),
      (try? String(contentsOfFile: log, encoding: .utf8)) ?? ""
    )
  }

  /// A deliberate stop leaves the marker; one that FAILS must not leave a
  /// marker next to a running Samba.
  func testHoldSmbdLeavesTheMarkerOnlyWhenTheStopWorked() throws {
    let ok = try runWithFakeSystemctl(VMLayout.holdSmbd, stopSucceeds: true)
    XCTAssertTrue(ok.marker)
    XCTAssertTrue(ok.calls.contains("stop smbd"))
    let failed = try runWithFakeSystemctl(VMLayout.holdSmbd, stopSucceeds: false)
    XCTAssertFalse(failed.marker, "the stop failed: Samba is still running")
    XCTAssertTrue(VMLayout.Guest.smbdHold.hasPrefix("/run/"), "tmpfs: a reboot clears it")
  }

  /// Every deliberate stop in the app goes through `holdSmbd`; a bare
  /// `systemctl stop smbd` would leave no marker and the bind would restart Samba.
  /// The shutdown quiesce is the one exception: the machine goes down with
  /// /run, so a marker there would only outlive nothing.
  func testNoDeliberateStopBypassesTheMarker() throws {
    let core = Self.repoRoot.appendingPathComponent("mac-app/Sources/CloudMachineCore")
    var holds = 0
    for file in try FileManager.default.contentsOfDirectory(atPath: core.path)
    where file.hasSuffix(".swift") && !file.hasPrefix("L10n") {
      let text = try String(contentsOf: core.appendingPathComponent(file), encoding: .utf8)
      for line in text.split(separator: "\n") where line.contains("systemctl stop smbd") {
        let l = String(line)
        XCTAssertTrue(
          file == "VMLayout.swift" || l.contains("L10n")
            || l.trimmingCharacters(in: .whitespaces).hasPrefix("//"),
          "\(file): bare stop: \(l)")
      }
      holds += text.components(separatedBy: "VMLayout.holdSamba(").count - 1
    }
    XCTAssertEqual(holds, 2, "VMBundlePrep and DriveEncryption stop Samba through holdSamba")
    XCTAssertEqual(VMLayout.quiesceScript, "systemctl stop smbd; sync")
  }

  /// Lima copies the template's data files at every boot, so `vm-update` (new
  /// lima.yaml + two boots) reaches an existing machine - but only for files the
  /// template NAMES. Every unit and drop-in under vm/systemd must be named.
  func testEverySystemdFileIsInstalledByTheTemplate() throws {
    let yaml = try unit("vm/cmsmb.yaml")
    let root = Self.repoRoot.appendingPathComponent("vm/systemd")
    let walker = try XCTUnwrap(FileManager.default.enumerator(atPath: root.path))
    var count = 0
    for case let path as String in walker {
      var isDir: ObjCBool = false
      FileManager.default.fileExists(
        atPath: root.appendingPathComponent(path).path, isDirectory: &isDir)
      guard !isDir.boolValue else { continue }
      count += 1
      XCTAssertTrue(
        yaml.contains("file: systemd/\(path)"), "\(path) is not installed by cmsmb.yaml")
      let name = (path as NSString).lastPathComponent
      XCTAssertTrue(
        yaml.contains("/etc/systemd/system/" + path)
          || yaml.contains("/\(name)\n  file: systemd/\(path)"),
        "\(path) lands outside /etc/systemd/system")
    }
    XCTAssertGreaterThan(count, 5)
  }

  /// Units that stop (and, when the stopped unit is restarted, restart) with `unit`:
  /// the ones that list it in Requires= or BindsTo=.
  private func dependents(of unit: String, in files: [String: String]) -> Set<String> {
    var result = Set<String>()
    for (name, text) in files where name != unit {
      for line in text.split(separator: "\n") {
        let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2, ["Requires", "BindsTo"].contains(parts[0]) else { continue }
        if parts[1].split(separator: " ").contains(Substring(unit + ".service")) {
          result.insert(name)
        }
      }
    }
    return result
  }

  /// 27.11.2026 19:29: the kernel OOM-killed rclone. Stop propagates down the
  /// chain through Requires=/BindsTo= (a BindsTo= bind is unmounted when punchfs
  /// dies; a Requires= one would stay bound over a dead FUSE mount), but systemd
  /// does NOT start the dependents again after a Restart=always (measured
  /// 28.11.2026 with throw-away units). The healer (`cm-smb-heal`) does that,
  /// from the state; the bind itself still retries a failed start.
  func testRcloneRestartReachesSambaThroughTheDependencyChain() throws {
    let files = [
      "rclone-tm": try unit("vm/systemd/rclone-tm.service"),
      "punchfs": try unit("vm/systemd/punchfs.service"),
      "tm-bands-bind": try unit("vm/systemd/tm-bands-bind.service"),
      "smbd": try unit("vm/systemd/smbd.service.d/cloudmachine.conf"),
    ]
    var reached = Set<String>()
    var frontier = ["rclone-tm"]
    while let next = frontier.popLast() {
      for dependent in dependents(of: next, in: files) where reached.insert(dependent).inserted {
        frontier.append(dependent)
      }
    }
    XCTAssertEqual(reached, ["punchfs", "tm-bands-bind", "smbd"])
    // Event chains must not come back: the healer is the one reviver.
    for name in ["rclone-tm", "punchfs", "tm-bands-bind"] {
      XCTAssertFalse(files[name]!.contains("ExecStartPost"), "\(name): the healer revives")
    }
    let bind = files["tm-bands-bind"]!
    XCTAssertTrue(bind.contains("\nBindsTo=punchfs.service\n"))
    XCTAssertTrue(bind.contains("\nRestart=on-failure\n"))
    XCTAssertTrue(bind.contains("\nRestartSec="))
    XCTAssertTrue(bind.contains("\nStartLimitIntervalSec=0\n"), "retries must never run out")
  }

  /// Runs `vm/cm-smb-heal.sh` for real: only `systemctl` and `mountpoint` are
  /// fakes; `stat`, `date` and the file mtimes are the real ones. `holdAgeMinutes`
  /// = nil means no marker; `attention` = the persistent attention file exists.
  private func runHealer(
    active: Set<String>, mounted: Bool = true, holdAgeMinutes: Double? = nil,
    attention: Bool = false
  ) throws -> [String] {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    func write(_ name: String, _ body: String) throws {
      let url = dir.appendingPathComponent(name)
      try ("#!/bin/sh\n" + body + "\n").write(to: url, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }
    let log = dir.appendingPathComponent("calls").path
    let hold = dir.appendingPathComponent("hold").path
    let attentionFile = dir.appendingPathComponent("attention").path
    let env = dir.appendingPathComponent("bundle.env").path
    try "CM_BUNDLE=x\n".write(toFile: env, atomically: true, encoding: .utf8)
    let activeList = active.sorted().joined(separator: " ")
    try write(
      "systemctl",
      "if [ \"$1\" = is-active ]; then for u in \(activeList); do [ \"$u\" = \"$3\" ] && exit 0; done; exit 3; fi\necho \"$@\" >> \(log)"
    )
    try write("mountpoint", "exit \(mounted ? 0 : 1)")
    if let minutes = holdAgeMinutes {
      FileManager.default.createFile(
        atPath: hold, contents: nil,
        attributes: [.modificationDate: Date().addingTimeInterval(-minutes * 60)])
    }
    if attention { FileManager.default.createFile(atPath: attentionFile, contents: nil) }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = [Self.repoRoot.appendingPathComponent("vm/cm-smb-heal.sh").path]
    p.environment = [
      "PATH": dir.path + ":/usr/bin:/bin", "CM_SMBD_HOLD": hold,
      "CM_SMBD_ATTENTION": attentionFile, "CM_BUNDLE_ENV": env,
    ]
    p.standardError = FileHandle.nullDevice
    try p.run()
    p.waitUntilExit()
    let calls = (try? String(contentsOfFile: log, encoding: .utf8)) ?? ""
    return calls.split(separator: "\n").map(String.init)
  }

  /// The level-triggered healer replaces event chains (28.11.2026: after
  /// `kill -9` of a Restart=always unit, BindsTo= dependents stay inactive). It
  /// never blocks: starts are `--no-block`.
  func testHealerBringsTheChainBackFromTheState() throws {
    let up: Set<String> = ["punchfs"]
    XCTAssertEqual(try runHealer(active: up), ["--no-block start tm-bands-bind"])
    XCTAssertEqual(try runHealer(active: []), [], "punchfs dead: systemd restarts it")
    XCTAssertEqual(try runHealer(active: up, mounted: false), [])
    let bound: Set<String> = ["punchfs", "tm-bands-bind"]
    XCTAssertEqual(try runHealer(active: bound), ["--no-block start smbd"])
    XCTAssertEqual(try runHealer(active: bound.union(["smbd"])), [])
  }

  /// The age is counted in seconds against 7200, at the boundaries, on real
  /// files: 119 min = paused on purpose, 121 and 125 min = expired.
  func testHealerHoldBoundaries() throws {
    let bound: Set<String> = ["punchfs", "tm-bands-bind"]
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: 0), [])
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: 119), [])
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: 121), ["--no-block start smbd"])
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: 125), ["--no-block start smbd"])
  }

  /// A failed operation's attention file beats everything, expired marker or not.
  func testHealerNeverStartsSambaUnderAttention() throws {
    let bound: Set<String> = ["punchfs", "tm-bands-bind"]
    XCTAssertEqual(try runHealer(active: bound, attention: true), [])
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: 500, attention: true), [])
  }

  /// A deliberate stop writes the marker FRESH (`: >`, not `touch`): the old
  /// content or mtime of a previous run must not survive. Run for real.
  func testHoldSmbdRewritesTheMarkerAndLeavesAttentionAlone() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let hold = dir.appendingPathComponent("hold").path
    let attention = dir.appendingPathComponent("attention").path
    let fake = dir.appendingPathComponent("systemctl")
    try "#!/bin/sh\nexit 0\n".write(to: fake, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fake.path)
    try "attention\n".write(toFile: hold, atomically: true, encoding: .utf8)
    try "attention\n".write(toFile: attention, atomically: true, encoding: .utf8)
    let script = VMLayout.holdSmbd
      .replacingOccurrences(of: VMLayout.Guest.smbdHold, with: hold)
      .replacingOccurrences(of: VMLayout.Guest.smbdAttention, with: attention)
      .replacingOccurrences(of: "systemctl ", with: fake.path + " ")
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = ["-c", script]
    try p.run()
    p.waitUntilExit()
    XCTAssertEqual(p.terminationStatus, 0)
    XCTAssertEqual(try String(contentsOfFile: hold, encoding: .utf8), "", "old content is gone")
    XCTAssertTrue(
      FileManager.default.fileExists(atPath: attention),
      "only a successful vm-prepare-bundle clears attention")
  }

  /// The attention file is on the disk (a reboot must not start Samba on a
  /// half-installed image) and Samba's drop-in refuses to start while it exists.
  func testAttentionIsPersistentAndBlocksSamba() throws {
    XCTAssertFalse(VMLayout.holdSmbd.contains("smbdAttention"))
    XCTAssertTrue(VMLayout.Guest.smbdAttention.hasPrefix("/var/lib/"))
    let smbd = try unit("vm/systemd/smbd.service.d/cloudmachine.conf")
    XCTAssertTrue(smbd.contains("ConditionPathExists=!\(VMLayout.Guest.smbdAttention)"))
    XCTAssertTrue(VMLayout.flagSmbdNeedsAttention.contains(VMLayout.Guest.smbdAttention))
    XCTAssertTrue(VMStatus.script.contains(VMLayout.Guest.smbdAttention))
  }

  /// The script's 120 minutes are the app's limit.
  func testHealerLimitMatchesTheAppsLimit() throws {
    let text = try unit("vm/cm-smb-heal.sh")
    XCTAssertTrue(text.contains("-le \(Int(VMLayout.smbdHoldLimit))"))
  }

  /// The timer runs the healer every minute and is enabled by provisioning.
  func testHealerIsScheduledAndInstalled() throws {
    let yaml = try unit("vm/cmsmb.yaml")
    XCTAssertTrue(
      yaml.contains("path: /usr/local/sbin/cm-smb-heal\n  file: cm-smb-heal.sh\n  permissions: 755")
    )
    XCTAssertTrue(yaml.contains("enable --now smb-throttle.service cm-smb-heal.timer"))
    let timer = try unit("vm/systemd/cm-smb-heal.timer")
    XCTAssertTrue(timer.contains("OnUnitActiveSec=60s"))
    XCTAssertTrue(timer.contains("WantedBy=timers.target"))
    XCTAssertTrue(
      try unit("vm/systemd/cm-smb-heal.service").contains("ExecStart=/usr/local/sbin/cm-smb-heal"))
    XCTAssertFalse(
      try unit("vm/systemd/tm-bands-bind.service").contains("ExecStartPost"),
      "one mechanism: the healer starts Samba")
  }

  /// The status script's marker line, executed. `stat` is faked (GNU `-c %Y` is
  /// not on macOS): it answers with the mtime the test sets.
  func testStatusScriptReadsTheMarker() throws {
    func run(marker: String?, ageSeconds: Int = 0, attention: Bool = false) throws -> String {
      let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
      try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
      defer { try? FileManager.default.removeItem(at: dir) }
      let hold = dir.appendingPathComponent("hold").path
      let now = Int(Date().timeIntervalSince1970)
      let fakeStat = dir.appendingPathComponent("stat")
      try "#!/bin/sh\n[ -e \(hold) ] && echo \(now - ageSeconds) || exit 1\n".write(
        to: fakeStat, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: fakeStat.path)
      if let marker { try marker.write(toFile: hold, atomically: true, encoding: .utf8) }
      let flag = dir.appendingPathComponent("attention").path
      if attention { try "x".write(toFile: flag, atomically: true, encoding: .utf8) }
      let p = Process()
      p.executableURL = URL(fileURLWithPath: "/bin/sh")
      p.arguments = [
        "-c",
        VMStatus.holdScript.replacingOccurrences(of: VMLayout.Guest.smbdHold, with: hold)
          .replacingOccurrences(of: VMLayout.Guest.smbdAttention, with: flag),
      ]
      p.environment = ["PATH": dir.path + ":/usr/bin:/bin"]
      let out = Pipe()
      p.standardOutput = out
      try p.run()
      p.waitUntilExit()
      return String(decoding: out.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }
    XCTAssertEqual(VMStatus.report(scriptOutput: try run(marker: nil)).smbdHoldAge, nil)
    let fresh = VMStatus.report(scriptOutput: try run(marker: "", ageSeconds: 300)).smbdHoldAge
    XCTAssertEqual(try XCTUnwrap(fresh), 300, accuracy: 5)
    XCTAssertFalse(VMStatus.report(scriptOutput: try run(marker: nil)).smbdAttention)
    // The attention file is read, and it is a failure, not a pause, however fresh.
    let flagged = VMStatus.report(
      scriptOutput: try run(marker: "", ageSeconds: 10, attention: true))
    XCTAssertTrue(flagged.smbdAttention)
    var withSamba = flagged
    withSamba.services["smbd"] = "inactive"
    XCTAssertFalse(withSamba.smbdHeld)
  }

  /// `holdSamba` stops Samba through `holdSmbd`, starts the keep-alive only when
  /// the stop worked, and the keep-alive refreshes without creating the marker.
  func testHoldSambaStartsTheKeepAliveOnlyAfterASuccessfulStop() async throws {
    let counter = HoldCounter()
    let ran = HoldRecorder()
    let kept = await VMLayout.holdSamba(
      run: {
        await ran.add($0)
        return true
      }, every: 0.02, touch: { await counter.bump() })
    let task = try XCTUnwrap(kept)
    let scripts = await ran.scripts
    XCTAssertEqual(scripts, [VMLayout.holdSmbd])
    try await Task.sleep(nanoseconds: 150_000_000)
    task.cancel()
    let seen = await counter.value
    XCTAssertGreaterThanOrEqual(seen, 2)
    let failed = await VMLayout.holdSamba(
      run: { _ in false }, every: 0.02, touch: { await counter.bump() })
    XCTAssertNil(failed, "a failed stop starts no keep-alive and leaves no hold to keep")
    XCTAssertTrue(VMLayout.refreshHold.hasPrefix("touch -c "), "never re-creates the marker")
  }

  /// Runs a shell fragment with the given paths swapped in. `bin` holds fake
  /// commands (name -> script body).
  private func shellOutput(
    _ script: String, attention: String, hold: String? = nil, bin: [String: String] = [:]
  ) throws -> (status: Int32, stdout: String, stderr: String) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    for (name, body) in bin {
      let url = dir.appendingPathComponent(name)
      try ("#!/bin/sh\n" + body + "\n").write(to: url, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }
    // The real /var/lib/cloudmachine does not exist on the Mac running the tests.
    var text = script.replacingOccurrences(of: "mkdir -p /var/lib/cloudmachine && ", with: "")
      .replacingOccurrences(of: VMLayout.Guest.smbdAttention, with: attention)
    if let hold { text = text.replacingOccurrences(of: VMLayout.Guest.smbdHold, with: hold) }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = ["-c", text]
    p.environment = ["PATH": dir.path + ":/usr/bin:/bin"]
    let out = Pipe()
    let err = Pipe()
    p.standardOutput = out
    p.standardError = err
    try p.run()
    p.waitUntilExit()
    return (
      p.terminationStatus,
      String(decoding: out.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self),
      String(decoding: err.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    )
  }

  private func shell(
    _ script: String, attention: String, hold: String? = nil, bin: [String: String] = [:]
  ) throws -> Int32 {
    try shellOutput(script, attention: attention, hold: hold, bin: bin).status
  }

  private func tempDir() throws -> URL {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  /// With the attention file set, the repoint script and the pre-hold check
  /// refuse (exit 4) BEFORE touching Samba, the marker or any unit.
  func testOperationsRefuseUnderAttention() async throws {
    let dir = try tempDir()
    defer { try? FileManager.default.removeItem(at: dir) }
    let attention = dir.appendingPathComponent("attention").path
    let hold = dir.appendingPathComponent("hold").path
    let calls = dir.appendingPathComponent("calls").path
    let recorder = "echo \"$0 $@\" >> \(calls)"
    let bin = ["systemctl": recorder, "rclone": recorder, "curl": recorder, "cp": recorder]
    FileManager.default.createFile(atPath: attention, contents: nil)
    let repoint = DriveEncryption.repointScript(
      oldRemote: "gdrive:CloudMachine/m-tm", newRemote: "gdrive-crypt:tm", stamp: "s")
    XCTAssertEqual(try shell(repoint, attention: attention, hold: hold, bin: bin), 4)
    // The real `holdSamba`, its script run in a real shell: it must come back nil.
    let held = await VMLayout.holdSamba(
      refusingUnderAttention: true,
      run: { script in
        ((try? self.shell(script, attention: attention, hold: hold, bin: bin)) ?? 1) == 0
      }, every: 0.02, touch: {})
    XCTAssertNil(held, "holdSamba refuses under attention")
    XCTAssertFalse(FileManager.default.fileExists(atPath: hold), "no marker made")
    XCTAssertFalse(FileManager.default.fileExists(atPath: calls), "nothing was run")
    XCTAssertTrue(FileManager.default.fileExists(atPath: attention), "attention untouched")
    XCTAssertEqual(try shell(VMLayout.refuseUnderAttention, attention: attention), 4)
    try FileManager.default.removeItem(atPath: attention)
    XCTAssertEqual(try shell(VMLayout.refuseUnderAttention, attention: attention), 0)
  }

  /// The install script records attention in its OWN shell on any failure, and
  /// clears it (and the trap) only at the end. Including a failed write.
  func testInstallRecordsAttentionOnFailureInTheSameShell() throws {
    let dir = try tempDir()
    defer { try? FileManager.default.removeItem(at: dir) }
    let attention = dir.appendingPathComponent("attention").path
    let failing = "set -eu; MUTATED=1; \(VMLayout.recordAttentionOnFailure); false"
    XCTAssertNotEqual(try shell(failing, attention: attention), 0)
    XCTAssertTrue(FileManager.default.fileExists(atPath: attention), "recorded")
    // Success path: clears an old record and does not re-create it.
    let ok =
      "set -eu; MUTATED=1; \(VMLayout.recordAttentionOnFailure); \(VMLayout.clearAttention); true"
    XCTAssertEqual(try shell(ok, attention: attention), 0)
    XCTAssertFalse(FileManager.default.fileExists(atPath: attention), "cleared by success")
    // A failed WRITE (unwritable location): the script still fails, nothing is
    // recorded - and the app notices via attentionRecorded.
    let nowhere = dir.appendingPathComponent("no/such/dir/attention").path
    let broken = "set -eu; MUTATED=1; \(VMLayout.recordAttentionOnFailure); false"
    XCTAssertNotEqual(try shell(broken, attention: nowhere), 0)
    XCTAssertFalse(FileManager.default.fileExists(atPath: nowhere))
    // The real install script wires them in: trap first, clear just before the start.
    let script = VMBundlePrep.installScript(
      name: "n.sparsebundle", staging: "/tmp/s", aside: "/tmp/a", envLine: "CM_BUNDLE=n")
    let lines = script.split(separator: "\n").map(String.init)
    XCTAssertEqual(lines[1], "MUTATED=0")
    XCTAssertEqual(lines[2], VMLayout.recordAttentionOnFailure)
    let check = try XCTUnwrap(lines.firstIndex { $0.contains("appeared meanwhile") })
    let mutated = try XCTUnwrap(lines.firstIndex(of: "MUTATED=1"))
    let move = try XCTUnwrap(lines.firstIndex { $0.hasPrefix("mv ") })
    let copy = try XCTUnwrap(lines.firstIndex { $0.hasPrefix("cp -r") })
    XCTAssertLessThan(check, mutated, "the early exit 3 comes before any change")
    XCTAssertLessThan(mutated, move)
    XCTAssertLessThan(move, copy)
    XCTAssertEqual(lines[lines.count - 2], VMLayout.clearAttention)
    XCTAssertEqual(lines.last, VMLayout.startSmbd)
  }

  private func emptyDriveAndFakes() throws -> (dir: URL, drive: URL) {
    let dir = try tempDir()
    let drive = dir.appendingPathComponent("drive")
    try FileManager.default.createDirectory(at: drive, withIntermediateDirectories: true)
    return (dir, drive)
  }

  private func realInstallScript(drive: URL) -> String {
    VMBundlePrep.installScript(
      name: "n.sparsebundle", staging: "/tmp/s", aside: "/tmp/a", envLine: "CM_BUNDLE=n"
    ).replacingOccurrences(of: "/srv/tm/bands", with: drive.path)
  }

  /// The ONE proof that nothing changed: the early exit 3 prints `CM-UNCHANGED`.
  /// No attention file, no state-changing command. Real install script.
  func testEarlyInstallFailureIsProvenUnchanged() throws {
    let (dir, drive) = try emptyDriveAndFakes()
    defer { try? FileManager.default.removeItem(at: dir) }
    FileManager.default.createFile(
      atPath: drive.appendingPathComponent("a-band").path, contents: nil)
    let attention = dir.appendingPathComponent("attention").path
    let calls = dir.appendingPathComponent("calls").path
    let rec = "echo \"$0 $@\" >> \(calls)"
    let early = try shellOutput(
      realInstallScript(drive: drive), attention: attention,
      bin: ["mv": rec, "cp": rec, "tar": rec, "systemctl": rec, "install": rec])
    XCTAssertEqual(early.status, 3)
    XCTAssertFalse(FileManager.default.fileExists(atPath: attention), "nothing changed")
    XCTAssertFalse(FileManager.default.fileExists(atPath: calls), "no state-changing command ran")
    XCTAssertTrue(early.stdout.contains("CM-UNCHANGED"))
    XCTAssertFalse(early.stderr.contains("CM-MUTATED"), "an early exit proves nothing was changed")
    XCTAssertEqual(
      VMBundlePrep.installFailure(
        stdout: early.stdout, exitCode: early.status, attentionRecorded: false),
      .notChanged)
  }

  /// The late case, on the real script: the original is moved aside (`mv`), then
  /// the next step fails. The trap records attention in the same shell; nothing
  /// says "unchanged"; classified as half-installed.
  func testInterruptionAfterTheMoveIsHalfInstalled() throws {
    let (dir, drive) = try emptyDriveAndFakes()
    defer { try? FileManager.default.removeItem(at: dir) }
    let attention = dir.appendingPathComponent("attention").path
    let ok = "exit 0"
    let late = try shellOutput(
      realInstallScript(drive: drive), attention: attention,
      bin: ["install": ok, "mv": ok, "tar": "exit 1"])
    XCTAssertNotEqual(late.status, 0)
    XCTAssertTrue(FileManager.default.fileExists(atPath: attention), "recorded in the same shell")
    XCTAssertTrue(late.stderr.contains("CM-MUTATED"))
    XCTAssertFalse(late.stdout.contains("CM-UNCHANGED"))
    XCTAssertEqual(
      VMBundlePrep.installFailure(
        stdout: late.stdout, exitCode: late.status, attentionRecorded: true),
      .halfInstalled)
  }

  /// Anything that is not the explicit CM-UNCHANGED proof counts as half-done:
  /// no answer (timeout, limactl died), ssh's 255, a kill that skipped the trap,
  /// an unknown code, an exit 3 without the sentinel.
  func testOnlyTheSentinelProvesNothingChanged() {
    func classify(_ out: String?, _ code: Int32?, recorded: Bool = false)
      -> VMBundlePrep.InstallFailure
    {
      VMBundlePrep.installFailure(stdout: out, exitCode: code, attentionRecorded: recorded)
    }
    XCTAssertEqual(classify("CM-UNCHANGED\n", 3), .notChanged)
    XCTAssertEqual(classify(nil, nil), .halfInstalledUnrecorded, "timeout / limactl died")
    XCTAssertEqual(classify("", 255), .halfInstalledUnrecorded, "ssh dropped")
    XCTAssertEqual(classify("", 137), .halfInstalledUnrecorded, "SIGKILL / OOM, no trap")
    XCTAssertEqual(classify("", 3), .halfInstalledUnrecorded, "exit 3 without the proof")
    XCTAssertEqual(classify("CM-UNCHANGED\n", 1), .halfInstalledUnrecorded, "sentinel, wrong code")
    XCTAssertEqual(classify("", 1, recorded: true), .halfInstalled)
    XCTAssertEqual(classify(nil, nil, recorded: true), .halfInstalled)
    XCTAssertEqual(classify("x CM-INSTALLED\n", 1), .installedSambaDown)
  }

  /// "Installed, but Samba did not start" is its own case (the healer starts it);
  /// the messages follow the facts.
  func testInstallFailureMessages() {
    XCTAssertTrue(VMLayout.clearAttention.hasSuffix("echo CM-INSTALLED"))
    let started = VMBundlePrep.notChangedMessage("boom", sambaStarted: true)
    XCTAssertTrue(started.contains("smbd started again"))
    let notStarted = VMBundlePrep.notChangedMessage("boom", sambaStarted: false)
    XCTAssertEqual(notStarted, "boom", "no claim that Samba started")
  }

  /// The app-side flow with an injected runner: for no answer (nil), ssh's 255 and
  /// a kill (137), the app writes the attention file, asks again, keeps Samba
  /// stopped and says the original MAY have been moved - not that it was.
  func testUncertainInstallResultsWriteAttentionAndSayMay() async {
    for (code, stderr) in [(nil, nil), (255, ""), (137, "")] as [(Int32?, String?)] {
      let recorder = HoldRecorder()
      let flag = VMLayout.flagSmbdNeedsAttention
      let check = "[ -e \(VMLayout.Guest.smbdAttention) ]"
      let written = Flag()
      let resolution = await VMBundlePrep.resolveInstallFailure(
        stdout: code == nil ? nil : "", stderr: stderr, exitCode: code, tail: "tail",
        aside: "/aside",
        run: { script in
          await recorder.add(script)
          if script == flag { await written.set() }
          return script == check ? await written.isSet : true
        })
      let scripts = await recorder.scripts
      XCTAssertEqual(
        scripts, [check, flag, check], "check, write, check again (\(String(describing: code)))")
      guard case .stopped(let message) = resolution else {
        return XCTFail("Samba must stay stopped (\(String(describing: code))): \(resolution)")
      }
      XCTAssertTrue(message.contains("MAY have been moved to /aside"), message)
      XCTAssertFalse(message.contains("The original is in"), "no claim that it was moved")
      XCTAssertFalse(message.contains("could not record"), "the write worked")
    }
  }

  /// When the write fails too, the message says so; a proven move says "is in".
  func testUnrecordedAndProvenResolutions() async {
    let unrecorded = await VMBundlePrep.resolveInstallFailure(
      stdout: nil, stderr: nil, exitCode: nil, tail: "t", aside: "/a", run: { _ in false })
    guard case .stopped(let message) = unrecorded else { return XCTFail("\(unrecorded)") }
    XCTAssertTrue(message.contains("could not record that Samba must stay stopped"))
    let proven = await VMBundlePrep.resolveInstallFailure(
      stdout: "", stderr: "CM-MUTATED\n", exitCode: 1, tail: "t", aside: "/a", run: { _ in true })
    guard case .stopped(let said) = proven else { return XCTFail("\(proven)") }
    XCTAssertTrue(said.contains("The original is in /a"), said)
    let early = await VMBundlePrep.resolveInstallFailure(
      stdout: "CM-UNCHANGED\n", stderr: "", exitCode: 3, tail: "t", aside: "/a",
      run: { _ in false })
    XCTAssertEqual(early, .restoreSamba("t"))
  }

  /// The repoint script's exit 4 is the refusal; nothing else is.
  func testRepointExitFourIsTheAttentionRefusal() {
    XCTAssertTrue(DriveEncryption.isAttentionRefusal(exitCode: 4))
    XCTAssertFalse(DriveEncryption.isAttentionRefusal(exitCode: nil))
    XCTAssertFalse(DriveEncryption.isAttentionRefusal(exitCode: 1))
    XCTAssertFalse(DriveEncryption.isAttentionRefusal(exitCode: 0))
  }

  /// The pre-check text and the exit-4 refusal of the other operations say what
  /// to do: the image is half-installed, restore or verify the bands.
  func testRefusalTextPointsAtTheReadme() {
    let text = DriveEncryption.attentionRefusal
    XCTAssertTrue(text.contains("half-installed"))
    XCTAssertTrue(text.contains("vm/README.md"))
    let readme = (try? unit("vm/README.md")) ?? ""
    XCTAssertTrue(readme.contains("sudo rm /var/lib/cloudmachine/smbd-attention"))
    XCTAssertTrue(readme.contains("half-installed"))
  }

  func testAttentionRecordedAsksTheMachine() async {
    let ran = HoldRecorder()
    let yes = await VMLayout.attentionRecorded(run: {
      await ran.add($0)
      return true
    })
    let no = await VMLayout.attentionRecorded(run: { _ in false })
    XCTAssertTrue(yes)
    XCTAssertFalse(no, "a failed write is reported, not assumed")
    let scripts = await ran.scripts
    XCTAssertEqual(scripts, ["[ -e \(VMLayout.Guest.smbdAttention) ]"])
  }

  /// `systemctl start smbd` exits 0 when Samba's condition skips it; only
  /// is-active tells the truth.
  func testStartSmbdChecksThatSambaRuns() throws {
    let dir = try tempDir()
    defer { try? FileManager.default.removeItem(at: dir) }
    let skipped = ["systemctl": "[ \"$1\" = is-active ] && exit 3\nexit 0"]
    XCTAssertNotEqual(try shell(VMLayout.startSmbd, attention: "/x", bin: skipped), 0)
    let running = ["systemctl": "exit 0"]
    XCTAssertEqual(try shell(VMLayout.startSmbd, attention: "/x", bin: running), 0)
  }

  /// A future mtime (clock jump) is an expired pause, not an eternal one.
  func testFutureMarkerIsExpired() throws {
    let bound: Set<String> = ["punchfs", "tm-bands-bind"]
    XCTAssertEqual(try runHealer(active: bound, holdAgeMinutes: -30), ["--no-block start smbd"])
    XCTAssertNil(VMStatus.report(scriptOutput: "SMBDHOLD -50").smbdHoldAge)
  }

  /// A failed conversion flags attention in the persistent file.
  func testFlagNeedsAttentionWritesThePersistentFile() {
    XCTAssertTrue(VMLayout.flagSmbdNeedsAttention.hasSuffix("> \(VMLayout.Guest.smbdAttention)"))
  }

  /// 27.11.2026: rclone grew to 1.57 GB in the 2 GiB, swapless VM. Budget:
  /// 4 transfers x 32M chunks = 128M, read buffers 8M each, GOMEMLIMIT 900M for
  /// the heap; MemoryMax 1400M leaves 600M for Samba and the system. NO
  /// MemoryHigh: throttling would stall FUSE (and Samba on it) instead of
  /// ending in a clean kill and restart.
  func testRcloneMemoryIsCapped() throws {
    let rclone = try unit("vm/systemd/rclone-tm.service")
    XCTAssertTrue(rclone.contains("\nMemoryMax=1400M\n"))
    XCTAssertFalse(rclone.contains("MemoryHigh"), "throttling stalls the FUSE mount")
    XCTAssertTrue(rclone.contains("\nOOMPolicy=stop\n"))
    XCTAssertTrue(rclone.contains("\nRestart=always\n"))
    XCTAssertTrue(rclone.contains("GOMEMLIMIT=900MiB"))
    XCTAssertTrue(rclone.contains("--use-mmap"))
    XCTAssertTrue(rclone.contains("--buffer-size 8M"))
    XCTAssertTrue(rclone.contains("--transfers 4"))
    XCTAssertTrue(rclone.contains("--drive-chunk-size 32M"))
    // Samba must outlive rclone when memory is short.
    let smbd = try unit("vm/systemd/smbd.service.d/limits.conf")
    XCTAssertTrue(smbd.contains("OOMScoreAdjust=-"))
  }

  /// 13 Nov 2026 06:10: unattended-upgrades updated libc and needrestart
  /// restarted punchfs and Samba in the middle of a backup. The backup stack
  /// is restarted only by CloudMachine (vm-update) or at the next boot.
  func testUpgradesDoNotRestartTheBackupStack() throws {
    let vm = Self.repoRoot.appendingPathComponent("vm")
    let yaml = try String(contentsOf: vm.appendingPathComponent("cmsmb.yaml"), encoding: .utf8)
    XCTAssertTrue(yaml.contains("path: /etc/needrestart/conf.d/cloudmachine.conf"))
    let conf = try String(
      contentsOf: vm.appendingPathComponent("needrestart-cloudmachine.conf"), encoding: .utf8)
    for unit in ["rclone-tm", "punchfs", "tm-bands-bind", "smbd", "nmbd", "smb-throttle"] {
      XCTAssertTrue(conf.contains(unit), "needrestart may still restart \(unit)")
    }
    XCTAssertTrue(conf.contains("$nrconf{override_rc}"))
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

  /// 03.11.2026: after restarts rclone scanned a 120 GB VFS cache (~4.5 min)
  /// before mounting; systemd's default 90 s start limit killed it in a loop
  /// and punchfs/smbd never came up. The start limit must outlast that scan.
  func testRcloneStartLimitOutlastsTheCacheScan() throws {
    let unit = try String(
      contentsOf: Self.repoRoot.appendingPathComponent("vm/systemd/rclone-tm.service"),
      encoding: .utf8)
    // An uncommented line inside [Service]; a comment or [Unit] would do nothing.
    let afterService = try XCTUnwrap(unit.components(separatedBy: "[Service]").last)
    let service = try XCTUnwrap(afterService.components(separatedBy: "\n[").first)
    XCTAssertTrue(service.contains("\nTimeoutStartSec=45min\n"))
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
    // No Info.plist, no copy; TMBundleScriptTests checks what `has-info` decides.
    XCTAssertTrue(unit.contains("ExecCondition=/usr/local/sbin/tm-bundle has-info\n"))
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

  /// 27.10.2026, the machine's network cut: eight uploads "in progress" for
  /// 47 min, no error line. In progress + nothing uploaded for 15 min = hangs;
  /// nothing in progress, or a log with no upload yet, is not.
  func testUploadThatHangsIsTold() {
    func report(inProgress: Int, lastUpload: String) -> VMStatus.Report {
      var report = VMStatus.report(scriptOutput: "LASTUPLOAD \(lastUpload)")
      report.reading = VMLayout.Reading(
        buffer: VMLayout.BufferStats(
          bytesUsed: 0, uploadsQueued: 8, uploadsInProgress: inProgress, unsentBytes: 0),
        freeBytes: 0)
      return report
    }
    XCTAssertEqual(VMStatus.uploadStalledFor(report(inProgress: 8, lastUpload: "1000 3820")), 2820)
    XCTAssertNil(VMStatus.uploadStalledFor(report(inProgress: 8, lastUpload: "1000 1600")))
    XCTAssertNil(VMStatus.uploadStalledFor(report(inProgress: 0, lastUpload: "1000 9000")))
    XCTAssertNil(VMStatus.uploadStalledFor(report(inProgress: 8, lastUpload: "0 9000")))
    XCTAssertNil(VMStatus.uploadStalledFor(VMStatus.report(scriptOutput: "")))
  }

  /// vm-update replaces only what a template may change: never the disk or
  /// the VM type of an existing machine.
  func testUpdateRefusesToChangeTheMachineItself() {
    let current =
      "vmType: vz\narch: aarch64\ncpus: 2\nmemory: 2GiB\ndisk: 200GiB\nprovision:\n- mode: data\n"
    XCTAssertEqual(
      VMUpdate.fixedDifferences(current: current, new: current + "- mode: system\n"), [])
    XCTAssertEqual(
      VMUpdate.fixedDifferences(
        current: current, new: current.replacingOccurrences(of: "200GiB", with: "300GiB")),
      ["disk: 200GiB -> 300GiB"])
    XCTAssertEqual(VMUpdate.topLevel("# disk: 1\ndisk: 200GiB\n  cpus: 9\n"), ["disk": "200GiB"])
  }
}

private actor HoldCounter {
  private(set) var value = 0
  func bump() { value += 1 }
}

private actor HoldRecorder {
  private(set) var scripts: [String] = []
  func add(_ s: String) { scripts.append(s) }
}

private actor Flag {
  private(set) var isSet = false
  func set() { isSet = true }
}
