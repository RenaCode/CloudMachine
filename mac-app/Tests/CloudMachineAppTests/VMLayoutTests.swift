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

  /// The last sync may outlast the 2 h limit: the marker is touched while the
  /// operation runs and the touching stops with it.
  func testKeepHoldFreshTouchesUntilCancelled() async throws {
    let counter = HoldCounter()
    let task = VMLayout.keepHoldFresh(every: 0.02) { await counter.bump() }
    try await Task.sleep(nanoseconds: 200_000_000)
    task.cancel()
    await task.value
    let seen = await counter.value
    XCTAssertGreaterThanOrEqual(seen, 3)
    try await Task.sleep(nanoseconds: 100_000_000)
    let after = await counter.value
    XCTAssertEqual(after, seen, "no touching after the operation ended")
  }

  func testLongOperationsKeepTheHoldFresh() throws {
    let core = Self.repoRoot.appendingPathComponent("mac-app/Sources/CloudMachineCore")
    for file in ["VMBundlePrep.swift", "DriveEncryption.swift"] {
      let text = try String(contentsOf: core.appendingPathComponent(file), encoding: .utf8)
      XCTAssertTrue(text.contains("VMLayout.keepHoldFresh()"), file)
    }
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
      holds += text.components(separatedBy: "VMLayout.holdSmbd").count - 1
    }
    XCTAssertEqual(holds, 3, "VMBundlePrep (1) and DriveEncryption (2) stop Samba on purpose")
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

  /// 27.11.2026 19:29: the kernel OOM-killed rclone and the dependent units were
  /// stopped with it. The ONE mechanism that brings them back is systemd's own
  /// restart propagation along Requires=/BindsTo= (no ExecStartPost that starts
  /// units: `start` on an active unit does nothing, so a bind left over a dead
  /// FUSE mount would survive). Killing rclone must reach smbd through the chain,
  /// and the bind, a one-shot with no retry of its own, must retry.
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
    // The old second mechanism must not come back.
    for name in ["rclone-tm", "punchfs"] {
      XCTAssertFalse(files[name]!.contains("ExecStartPost"), "\(name): one mechanism only")
    }
    let bind = files["tm-bands-bind"]!
    XCTAssertTrue(bind.contains("\nBindsTo=punchfs.service\n"))
    XCTAssertTrue(bind.contains("\nRestart=on-failure\n"))
    XCTAssertTrue(bind.contains("\nRestartSec="))
    XCTAssertTrue(bind.contains("\nStartLimitIntervalSec=0\n"), "retries must never run out")
  }

  /// A bind that failed leaves Samba "dependency failed" - but systemd reports
  /// that unit as Result=success, exactly like a Samba stopped on purpose
  /// (measured with throw-away units 28.11.2026). So the bind starts Samba after
  /// a successful bind unless the hold marker exists; the marker is made by every
  /// path that stops Samba on purpose and removed whenever Samba starts.
  func testBindStartsSambaUnlessHeldOnPurpose() throws {
    let bind = try unit("vm/systemd/tm-bands-bind.service")
    let post = try XCTUnwrap(bind.split(separator: "\n").first { $0.hasPrefix("ExecStartPost=") })
    XCTAssertTrue(post.contains(VMLayout.Guest.smbdHold))
    XCTAssertTrue(post.contains("--no-block start smbd.service"))
    XCTAssertFalse(post.contains("Result"), "Result= never says dependency for a service")
    let smbd = try unit("vm/systemd/smbd.service.d/cloudmachine.conf")
    XCTAssertTrue(smbd.contains("ExecStartPost=-/bin/rm -f \(VMLayout.Guest.smbdHold)"))
  }

  /// Runs the bind's ExecStartPost shell with a fake `systemctl` to prove the
  /// behaviour: hold marker absent -> Samba is started; present -> it is not.
  func testBindsSambaStartLogicBehaviour() throws {
    let bind = try unit("vm/systemd/tm-bands-bind.service")
    var post = try XCTUnwrap(
      bind.split(separator: "\n").first { $0.hasPrefix("ExecStartPost=") }.map(String.init))
    post.removeFirst("ExecStartPost=-".count)  // "-" = ignore exit status
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let marker = dir.appendingPathComponent("hold").path
    let log = dir.appendingPathComponent("calls").path
    try "#!/bin/sh\necho \"$@\" >> \(log)\n".write(
      to: dir.appendingPathComponent("systemctl"), atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes(
      [.posixPermissions: 0o755], ofItemAtPath: dir.appendingPathComponent("systemctl").path)
    // Systemd would run /bin/systemctl; the test points both at the fake.
    let script = post.replacingOccurrences(of: VMLayout.Guest.smbdHold, with: marker)
      .replacingOccurrences(of: "/bin/systemctl", with: dir.path + "/systemctl")
    func run() throws -> String {
      try? FileManager.default.removeItem(atPath: log)
      let p = Process()
      p.executableURL = URL(fileURLWithPath: "/bin/sh")
      // `post` is `/bin/sh -c '...'` or a plain command line; hand it to sh.
      p.arguments = ["-c", script]
      p.standardError = FileHandle.nullDevice
      try p.run()
      p.waitUntilExit()
      return (try? String(contentsOfFile: log, encoding: .utf8)) ?? ""
    }
    // Failed bind earlier, now repaired; nobody stopped Samba on purpose.
    XCTAssertEqual(
      try run().trimmingCharacters(in: .whitespacesAndNewlines), "--no-block start smbd.service")
    // Stopped on purpose (image conversion): stays down.
    FileManager.default.createFile(atPath: marker, contents: nil)
    XCTAssertEqual(try run(), "")
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
