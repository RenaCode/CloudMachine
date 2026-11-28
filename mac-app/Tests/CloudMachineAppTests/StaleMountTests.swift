import XCTest

@testable import CloudMachineCore

/// 28 Nov 2026, v1.3.33, restart-chain.sh step 2: `kill -9` of rclone left a dead
/// FUSE mount on /srv/tm ("Transport endpoint is not connected"). Every start
/// then failed with "directory already mounted" and the unit looped; punchfs
/// failed to unmount /srv/tm-punch and stayed failed; the bind over
/// /srv/tm-local/<bundle>/bands stayed dead too. Only a manual `umount -l`
/// revived the chain. `vm/cm-unmount-stale.sh` is the ExecStartPre= that does it.
final class StaleMountTests: XCTestCase {
  private static let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()

  private func unit(_ path: String) throws -> String {
    try String(contentsOf: Self.repoRoot.appendingPathComponent(path), encoding: .utf8)
  }

  /// Runs the script for real. Fakes: `stat` (`statOK`: nil = hangs), `umount`
  /// (`umountOK`) and `fusermount3`; `timeout` and the shell are the real ones.
  /// `mounts` is the content of /proc/mounts. Returns the exit status and the
  /// calls the fakes saw.
  private func run(
    _ args: [String], mounts: String, healthy: Set<String> = [], hanging: Set<String> = [],
    umountOK: Bool = true
  ) throws -> (status: Int32, calls: [String]) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    func write(_ name: String, _ body: String) throws {
      let url = dir.appendingPathComponent(name)
      try ("#!/bin/sh\n" + body + "\n").write(to: url, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }
    let log = dir.appendingPathComponent("calls").path
    let mountsFile = dir.appendingPathComponent("mounts").path
    try mounts.write(toFile: mountsFile, atomically: true, encoding: .utf8)
    // stat -t <path>: 0 healthy, 124-style hang for `hanging`, else ENOTCONN-like failure.
    var cases = ""
    for p in healthy { cases += "\"\(p)\") exit 0;;\n" }
    for p in hanging { cases += "\"\(p)\") sleep 30;;\n" }
    try write("stat", "echo \"stat $*\" >> \(log)\ncase \"$2\" in\n\(cases)*) exit 1;;\nesac")
    try write("umount", "echo \"umount $*\" >> \(log)\nexit \(umountOK ? 0 : 1)")
    try write("fusermount3", "echo \"fusermount3 $*\" >> \(log)\nexit 0")
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = [Self.repoRoot.appendingPathComponent("vm/cm-unmount-stale.sh").path] + args
    p.environment = [
      "PATH": dir.path + ":/usr/bin:/bin:/opt/homebrew/bin:/usr/local/bin", "CM_MOUNTS": mountsFile,
      "CM_LOCAL": "/srv/tm-local", "CM_STAT_TIMEOUT": "1",
    ]
    p.standardError = FileHandle.nullDevice
    try p.run()
    p.waitUntilExit()
    let calls = (try? String(contentsOfFile: log, encoding: .utf8)) ?? ""
    return (p.terminationStatus, calls.split(separator: "\n").map(String.init))
  }

  private let rcloneMount = "rclone: /srv/tm fuse.rclone rw,nosuid,nodev 0 0\n"
  private let punchMount = "punchfs /srv/tm-punch fuse.punchfs rw,nosuid,nodev 0 0\n"

  func testDeadMountIsLazilyUnmounted() throws {
    let r = try run(["/srv/tm"], mounts: rcloneMount)
    XCTAssertEqual(r.status, 0)
    XCTAssertTrue(r.calls.contains("umount -l /srv/tm"), "\(r.calls)")
  }

  func testHealthyMountIsNeverTouched() throws {
    let r = try run(["/srv/tm"], mounts: rcloneMount, healthy: ["/srv/tm"])
    XCTAssertEqual(r.status, 0)
    XCTAssertFalse(r.calls.contains { $0.hasPrefix("umount") || $0.hasPrefix("fusermount") })
  }

  func testNotMountedMeansNothingToDo() throws {
    let r = try run(["/srv/tm"], mounts: punchMount)
    XCTAssertEqual(r.status, 0)
    XCTAssertEqual(r.calls, [], "a path that is not a mount is not even probed")
  }

  /// Only the exact mount point counts: /srv/tm is not a prefix match of /srv/tm-punch.
  func testOnlyTheNamedMountPointIsChecked() throws {
    let r = try run(["/srv/tm"], mounts: rcloneMount + punchMount, healthy: ["/srv/tm"])
    XCTAssertFalse(r.calls.contains { $0.contains("/srv/tm-punch") })
  }

  /// A mount that merely answers slowly (cache scan, big directory) is alive.
  func testSlowMountIsNotTreatedAsDead() throws {
    let r = try run(["/srv/tm"], mounts: rcloneMount, hanging: ["/srv/tm"])
    XCTAssertEqual(r.status, 0)
    XCTAssertFalse(r.calls.contains { $0.hasPrefix("umount") || $0.hasPrefix("fusermount") })
  }

  func testFallsBackToFusermountWhenUmountFails() throws {
    let r = try run(["/srv/tm"], mounts: rcloneMount, umountOK: false)
    XCTAssertEqual(r.status, 0, "ExecStartPre must never block the start")
    XCTAssertTrue(r.calls.contains("fusermount3 -uz /srv/tm"), "\(r.calls)")
  }

  func testSeveralMountPointsAreHandledInOrder() throws {
    let r = try run(
      ["/srv/tm-punch", "/srv/tm"], mounts: rcloneMount + punchMount, healthy: ["/srv/tm"])
    XCTAssertEqual(r.calls.filter { $0.hasPrefix("umount") }, ["umount -l /srv/tm-punch"])
  }

  /// The bind sits over /srv/tm-local/<image>/bands; image names contain spaces,
  /// which /proc/mounts writes as \040.
  func testDeadBandsBindIsUnmountedHealthyOnesAreNot() throws {
    let mounts =
      rcloneMount
      + "punchfs /srv/tm-local/Marcin\\040Mac\\040Studio.sparsebundle/bands fuse.punchfs rw 0 0\n"
      + "punchfs /srv/tm-local/ok.sparsebundle/bands fuse.punchfs rw 0 0\n"
      + "tmpfs /srv/tm-local/ok.sparsebundle/other tmpfs rw 0 0\n"
    let r = try run(["--bands"], mounts: mounts, healthy: ["/srv/tm-local/ok.sparsebundle/bands"])
    XCTAssertEqual(r.status, 0)
    XCTAssertEqual(
      r.calls.filter { $0.hasPrefix("umount") },
      ["umount -l /srv/tm-local/Marcin Mac Studio.sparsebundle/bands"])
  }

  func testNoArgumentsIsHarmless() throws {
    XCTAssertEqual(try run([], mounts: rcloneMount).status, 0)
  }

  // MARK: - The units and the template

  func testEveryChainUnitClearsItsStaleMountBeforeStarting() throws {
    let expectations: [(String, [String])] = [
      ("rclone-tm", ["--bands", "/srv/tm-punch", "/srv/tm"]),
      ("punchfs", ["--bands", "/srv/tm-punch"]),
      ("tm-bands-bind", ["--bands"]),
    ]
    for (name, args) in expectations {
      let text = try unit("vm/systemd/\(name).service")
      let line = try XCTUnwrap(
        text.split(separator: "\n").first { $0.contains("cm-unmount-stale") },
        "\(name) has no ExecStartPre= for the stale mount")
      XCTAssertTrue(line.hasPrefix("ExecStartPre=-/usr/local/sbin/cm-unmount-stale "), "\(line)")
      XCTAssertTrue(line.hasSuffix(" " + args.joined(separator: " ")), "\(name): \(line)")
    }
  }

  /// The stale-mount cleanup of the bind runs before it waits for punchfs.
  func testBindCleansBeforeItWaits() throws {
    let text = try unit("vm/systemd/tm-bands-bind.service")
    let clean = try XCTUnwrap(text.range(of: "cm-unmount-stale"))
    let wait = try XCTUnwrap(text.range(of: "until mountpoint"))
    XCTAssertLessThan(clean.lowerBound, wait.lowerBound)
  }

  /// punchfs's ExecStop= failed with "Invalid argument" on the dead mount and
  /// left the unit failed: a failing unmount is not a failing stop.
  func testUnmountOnStopCannotFailTheUnit() throws {
    for name in ["rclone-tm", "punchfs"] {
      let text = try unit("vm/systemd/\(name).service")
      XCTAssertTrue(text.contains("\nExecStop=-/bin/fusermount3 -uz "), "\(name)")
    }
  }

  func testScriptIsInstalledExecutable() throws {
    let yaml = try unit("vm/cmsmb.yaml")
    XCTAssertTrue(
      yaml.contains(
        "path: /usr/local/sbin/cm-unmount-stale\n  file: cm-unmount-stale.sh\n  permissions: 755"))
  }

  // MARK: - The healer resets units stuck on the start limit

  private func runHealer(active: Set<String>, startLimit: Set<String>) throws -> [String] {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    func write(_ name: String, _ body: String) throws {
      let url = dir.appendingPathComponent(name)
      try ("#!/bin/sh\n" + body + "\n").write(to: url, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }
    let log = dir.appendingPathComponent("calls").path
    let env = dir.appendingPathComponent("bundle.env").path
    try "CM_BUNDLE=x\n".write(toFile: env, atomically: true, encoding: .utf8)
    let activeList = active.sorted().joined(separator: " ")
    let limitList = startLimit.sorted().joined(separator: " ")
    try write(
      "systemctl",
      """
      if [ "$1" = is-active ]; then for u in \(activeList); do [ "$u" = "$3" ] && exit 0; done; exit 3; fi
      if [ "$1" = show ]; then
        for u in \(limitList); do [ "$u" = "$5" ] && { echo start-limit-hit; exit 0; }; done
        echo exit-code; exit 0
      fi
      echo "$@" >> \(log)
      """)
    try write("mountpoint", "exit 1")
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = [Self.repoRoot.appendingPathComponent("vm/cm-smb-heal.sh").path]
    p.environment = [
      "PATH": dir.path + ":/usr/bin:/bin", "CM_SMBD_HOLD": dir.appendingPathComponent("h").path,
      "CM_SMBD_ATTENTION": dir.appendingPathComponent("a").path, "CM_BUNDLE_ENV": env,
    ]
    p.standardError = FileHandle.nullDevice
    try p.run()
    p.waitUntilExit()
    let calls = (try? String(contentsOfFile: log, encoding: .utf8)) ?? ""
    return calls.split(separator: "\n").map(String.init)
  }

  /// 28 Nov 2026: punchfs hit its start limit and stayed failed; systemd never
  /// retries such a unit by itself.
  func testHealerResetsAChainUnitThatHitTheStartLimit() throws {
    XCTAssertEqual(
      try runHealer(active: [], startLimit: ["punchfs"]),
      ["reset-failed punchfs", "--no-block start punchfs"])
  }

  /// Any other failure (the old-binary exit 78, a real crash) is left visible.
  func testHealerLeavesOtherFailuresAlone() throws {
    XCTAssertEqual(try runHealer(active: [], startLimit: []), [])
  }

  func testHealerDoesNotResetARunningUnit() throws {
    XCTAssertEqual(try runHealer(active: ["rclone-tm"], startLimit: ["rclone-tm"]), [])
  }
}
