import XCTest

/// Durability of a Time Machine write: APFS inside the image relies on fsync
/// (F_FULLFSYNC -> SMB flush -> Samba fsync -> punchfs -> rclone) really
/// reaching the disk, because the machine can die hard with the Mac. These
/// tests pin the pieces of that chain that live in the repo's templates.
final class VMDurabilityTests: XCTestCase {
  private static let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()

  private func repoFile(_ path: String) throws -> String {
    try String(
      contentsOf: Self.repoRoot.appendingPathComponent(path), encoding: .utf8)
  }

  private func execStart(_ unit: String) throws -> String {
    let text = try repoFile(unit)
    // ExecStart may continue over several lines with a trailing backslash.
    var lines: [String] = []
    var inside = false
    for line in text.components(separatedBy: "\n") {
      if line.hasPrefix("ExecStart=") { inside = true }
      guard inside else { continue }
      let continued = line.hasSuffix("\\")
      lines.append(continued ? String(line.dropLast()) : line)
      if !continued { break }
    }
    return lines.joined(separator: " ")
  }

  /// `rclone mount` (cgofuse-less libfuse path) answers fsync with OK and
  /// does nothing; `mount2` (go-fuse) passes it on to the VFS cache item.
  func testRcloneUsesMount2() throws {
    let exec = try execStart("vm/systemd/rclone-tm.service")
    XCTAssertTrue(exec.contains("/usr/local/bin/rclone mount2 "), exec)
    XCTAssertFalse(exec.contains("/usr/local/bin/rclone mount "), exec)
  }

  /// punchfs must sync the filesystem that holds rclone's cache metadata
  /// (written without fsync), and it must be the cache dir rclone really uses.
  func testPunchfsSyncsRcloneCacheDirectory() throws {
    let punch = try execStart("vm/systemd/punchfs.service")
    let rclone = try execStart("vm/systemd/rclone-tm.service")
    let option = try XCTUnwrap(
      punch.range(of: "syncfs=/[^,\\s']+", options: .regularExpression).map { String(punch[$0]) },
      punch)
    let dir = String(option.dropFirst("syncfs=".count))
    XCTAssertEqual(dir, "/var/cache/rclone")
    XCTAssertTrue(rclone.contains("--cache-dir \(dir)"), "syncfs dir must be rclone's cache dir")
    XCTAssertTrue(punch.contains("source=/srv/tm,"), "other options keep working: \(punch)")
    XCTAssertTrue(punch.contains("allow_other"), punch)
  }

  /// The C side: the option exists, the directory is opened once, and both
  /// fsync handlers call syncfs and report its errno.
  func testPunchfsCodeSyncsOnFsync() throws {
    let source = try repoFile("vm/punchfs/punchfs.c")
    XCTAssertTrue(source.contains("\"syncfs=%s\""), "option syncfs=<dir> is parsed")
    func body(of function: String, returning type: String = "void") throws -> String {
      let start = try XCTUnwrap(source.range(of: "static \(type) \(function)("), function)
      let rest = source[start.lowerBound...]
      let end = rest.range(of: "\n}\n")?.upperBound ?? rest.endIndex
      return String(rest[..<end])
    }
    for handler in ["lo_fsync", "lo_fsyncdir"] {
      XCTAssertTrue(try body(of: handler).contains("lo_syncfs("), "\(handler) must sync the fs")
    }
    // The helper uses the descriptor opened once at start and reports errno.
    let helper = try body(of: "lo_syncfs", returning: "int")
    XCTAssertTrue(helper.contains("syncfs(lo->syncfs_fd)"), helper)
    XCTAssertTrue(helper.contains("errno"), helper)
    XCTAssertTrue(source.contains("O_DIRECTORY"), "the directory is opened at start")
  }

  /// The machine test exercises the chain for real and the template ships it.
  func testMachineTestChecksFsyncDurability() throws {
    let script = try repoFile("vm/punchfs/test-punchfs.sh")
    XCTAssertTrue(script.contains("mount2"), "the test mounts like production")
    XCTAssertTrue(script.contains("syncfs="))
    XCTAssertTrue(script.contains("Dirty"), "fsync must leave ~0 dirty pages")
    XCTAssertTrue(script.contains("vfsMeta"), "metadata file must cover the written range")
    // Detectors that can see a missing syncfs (the review found a test that
    // read the page cache and could not): dirty pages of the cache data file
    // per file, and the kernel's own record of syncfs calls.
    XCTAssertTrue(script.contains("kpageflags"), "dirty pages are read per file")
    XCTAssertTrue(script.contains("ext4_sync_fs"), "the kernel must have seen syncfs")
    XCTAssertTrue(script.contains("restart of rclone"), "xattr must survive rclone's restart")
    XCTAssertFalse(
      script.contains("| head -1"), "a `find | head` under pipefail aborted without a FAIL")
    XCTAssertFalse(
      script.contains("/proc/meminfo | grep") || script.contains("test \"$dirty\" -lt"),
      "the machine-wide Dirty figure is informational only: other writers fail it")
  }

  /// Partial deployment: the unit reaches the machine before the binary is
  /// rebuilt. An old punchfs does not know `-o syncfs`; with Restart=always
  /// that was a restart loop. It must end once, visibly (exit 78).
  func testPunchfsUnitRefusesAnOldBinaryWithoutLooping() throws {
    let unit = try repoFile("vm/systemd/punchfs.service")
    let exec = try execStart("vm/systemd/punchfs.service")
    XCTAssertTrue(exec.contains("--help"), "the binary is asked whether it has the option")
    XCTAssertTrue(exec.contains("syncfs=<dir>"), exec)
    XCTAssertTrue(exec.contains("exit 78"), exec)
    XCTAssertTrue(unit.contains("RestartPreventExitStatus=78"), "no restart loop")
    XCTAssertTrue(exec.contains("exec /usr/local/bin/punchfs"), "the real process is punchfs")
  }

  /// rclone's mount2 inodes come from a counter of the process, so they
  /// change when rclone restarts: the attributes (sparse flag, Apple streams)
  /// must be keyed by the path below `source`, not by inode.
  func testPunchfsKeysExtendedAttributesByPathNotInode() throws {
    let source = try repoFile("vm/punchfs/punchfs.c")
    func body(of function: String) throws -> String {
      let start = try XCTUnwrap(source.range(of: "static int \(function)("), function)
      let rest = source[start.lowerBound...]
      return String(rest[..<(rest.range(of: "\n}\n")?.upperBound ?? rest.endIndex)])
    }
    let dir = try body(of: "xdir_of")
    XCTAssertTrue(dir.contains("rel_path_of"), dir)
    XCTAssertFalse(dir.contains("->ino"), "the inode must not be the key: \(dir)")
    XCTAssertFalse(
      source.contains("rclone's inode is a hash of the path"), "the false claim is gone")
    XCTAssertTrue(source.contains("xattr_move("), "rename moves the attributes")
    XCTAssertTrue(source.contains("xattr_forget("), "unlink removes them")
    XCTAssertTrue(source.contains("xattr_drop_old_layout"), "the old inode-keyed layout goes")
  }

  // MARK: - Lima's 64 KiB limit

  /// `limactl list --json` of a RUNNING machine fails with "bufio.Scanner:
  /// token too long" once its JSON (which carries every embedded `file:` of the
  /// template) passes 64 KiB. Measured 12.11: 61,980 bytes worked, a template
  /// with 12.8 KB more did not - and with it `vm-status`, `vm-guard`,
  /// `backup-health` and `vm-hold` lose sight of the machine. The punchfs
  /// sources (the bulk) therefore ship as ONE compressed, base64 archive that
  /// the machine unpacks; `vm/punchfs/pack.sh` makes it.
  func testTemplateStaysFarBelowLimasLineLimit() throws {
    let template = try repoFile("vm/cmsmb.yaml")
    let files = template.components(separatedBy: "\n")
      .compactMap { line -> String? in
        guard line.hasPrefix("  file: ") else { return nil }
        return String(line.dropFirst("  file: ".count))
      }
    XCTAssertFalse(files.isEmpty)
    var total = 0
    for file in files {
      total += try Data(contentsOf: Self.repoRoot.appendingPathComponent("vm/" + file)).count
    }
    // The JSON limit is 65,536 bytes, reached at about 54 KB of embedded files
    // (61,980 bytes of JSON for 51 KB): keep a wide margin below it.
    XCTAssertLessThan(total, 42_000, "embedded files: \(total) bytes")
    for big in ["punchfs/punchfs.c", "punchfs/test-punchfs.sh", "punchfs/passthrough_helpers.h"] {
      XCTAssertFalse(files.contains(big), "\(big) must ship inside the archive")
    }
    XCTAssertTrue(files.contains("punchfs/src.tar.gz.b64"))
  }

  /// The archive is generated; it must hold exactly the files in the repo.
  func testPunchfsArchiveMatchesTheSources() throws {
    let work = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-pack-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: work) }
    let archive = Self.repoRoot.appendingPathComponent("vm/punchfs/src.tar.gz.b64").path
    let unpack = Process()
    unpack.executableURL = URL(fileURLWithPath: "/bin/sh")
    unpack.arguments = ["-c", "base64 -D < '\(archive)' | tar -xz -C '\(work.path)'"]
    try unpack.run()
    unpack.waitUntilExit()
    XCTAssertEqual(unpack.terminationStatus, 0, "the archive unpacks")
    for name in ["punchfs.c", "passthrough_helpers.h", "test-punchfs.sh"] {
      let packed = try Data(contentsOf: work.appendingPathComponent(name))
      let plain = try Data(
        contentsOf: Self.repoRoot.appendingPathComponent("vm/punchfs/" + name))
      XCTAssertEqual(packed, plain, "\(name) in src.tar.gz.b64 is stale: run vm/punchfs/pack.sh")
    }
    let attributes = try FileManager.default.attributesOfItem(
      atPath: work.appendingPathComponent("test-punchfs.sh").path)
    XCTAssertEqual((attributes[.posixPermissions] as? Int ?? 0) & 0o111 != 0, true)
  }

  /// The machine unpacks it before it builds.
  func testProvisioningUnpacksBeforeBuilding() throws {
    let template = try repoFile("vm/cmsmb.yaml")
    let unpack = try XCTUnwrap(template.range(of: "base64 -d"))
    let build = try XCTUnwrap(template.range(of: "gcc -Wall"))
    XCTAssertLessThan(unpack.lowerBound, build.lowerBound)
    XCTAssertTrue(template.contains("/opt/cloudmachine/punchfs/src.tar.gz.b64"))
  }
}
