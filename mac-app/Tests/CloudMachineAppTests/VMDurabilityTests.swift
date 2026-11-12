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
      punch.range(of: "syncfs=[^,\\s]+", options: .regularExpression).map { String(punch[$0]) },
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
  }
}
