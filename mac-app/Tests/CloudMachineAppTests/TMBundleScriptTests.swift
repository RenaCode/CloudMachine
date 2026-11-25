import XCTest

@testable import CloudMachineCore

/// `vm/tm-bundle.sh` (in the machine: /usr/local/sbin/tm-bundle) finds the
/// image whose bands live on Drive before they are bound and before its
/// metadata is copied.
///
/// 25 Nov 2026: after a restart the Mac's name went from "Marcin Mac Studio (3)"
/// to "Marcin Mac Studio" and Time Machine renamed the image on the share to
/// match. bundle.env kept the old name, the bind failed ("mount point does
/// not exist"), Samba, which needs it, stayed down, Time Machine could not
/// mount its destination, and the metadata copy was skipped.
final class TMBundleScriptTests: XCTestCase {

  private static let script = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent().appendingPathComponent("vm/tm-bundle.sh")

  private var root: URL!
  private var local: URL { root.appendingPathComponent("tm-local") }
  private var envFile: URL { root.appendingPathComponent("bundle.env") }

  override func setUpWithError() throws {
    root = FileManager.default.temporaryDirectory
      .appendingPathComponent("tm-bundle-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: local, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: root)
  }

  // MARK: - Helpers

  /// An image as it lies in /srv/tm-local: Info.plist with its band size and
  /// a bands/ directory, empty once vm-prepare-bundle moved the bands to Drive.
  private func makeImage(
    _ name: String, bandSize: Int = VMBundlePrep.bandBytes, localBands: Int = 0,
    infoPlist: Bool = true
  ) throws {
    let image = local.appendingPathComponent(name)
    let bands = image.appendingPathComponent("bands")
    try FileManager.default.createDirectory(at: bands, withIntermediateDirectories: true)
    for band in 0..<localBands {
      try Data("x".utf8).write(to: bands.appendingPathComponent(String(band)))
    }
    guard infoPlist else { return }
    let plist = """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      \t<key>CFBundleInfoDictionaryVersion</key>
      \t<string>6.0</string>
      \t<key>band-size</key>
      \t<integer>\(bandSize)</integer>
      \t<key>diskimage-bundle-type</key>
      \t<string>com.apple.diskimage.sparsebundle</string>
      </dict>
      </plist>
      """
    try plist.write(
      to: image.appendingPathComponent("Info.plist"), atomically: true, encoding: .utf8)
  }

  private func writeEnv(_ name: String) throws {
    try "CM_BUNDLE=\"\(name)\"\n".write(to: envFile, atomically: true, encoding: .utf8)
  }

  private func env() throws -> String { try String(contentsOf: envFile, encoding: .utf8) }

  private struct Run {
    let status: Int32
    let stdout: String
    let stderr: String
  }

  /// The machine's /bin/sh is dash; on this Mac /bin/sh is bash in POSIX
  /// mode, which would let a bash-only construct through.
  private static let shell =
    FileManager.default.isExecutableFile(atPath: "/bin/dash") ? "/bin/dash" : "/bin/sh"

  private var stubs: URL { root.appendingPathComponent("stubs") }
  private var calls: URL { root.appendingPathComponent("calls") }

  /// Stand-ins for `mountpoint`, `mount` and `umount`: each records its
  /// arguments; `mountpoint -q X` succeeds for the paths in `mounted`.
  private func stubMounts(mounted: [URL] = []) throws {
    try FileManager.default.createDirectory(at: stubs, withIntermediateDirectories: true)
    let list = root.appendingPathComponent("mounted")
    try mounted.map { $0.path + "\n" }.joined().write(to: list, atomically: true, encoding: .utf8)
    let scripts = [
      "mountpoint": "[ \"$1\" = -q ] && shift; grep -qxF \"$1\" '\(list.path)'",
      "mount": "printf 'mount %s|%s|%s\\n' \"$1\" \"$2\" \"$3\" >> '\(calls.path)'",
      "umount": "printf 'umount %s|%s\\n' \"$1\" \"$2\" >> '\(calls.path)'",
    ]
    for (name, body) in scripts {
      let file = stubs.appendingPathComponent(name)
      try "#!/bin/sh\n\(body)\n".write(to: file, atomically: true, encoding: .utf8)
      try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: file.path)
    }
  }

  private func recordedCalls() -> String {
    (try? String(contentsOf: calls, encoding: .utf8)) ?? ""
  }

  private func run(_ command: String) throws -> Run {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: Self.shell)
    process.arguments = [Self.script.path, command]
    process.environment = [
      "PATH": "\(stubs.path):/usr/bin:/bin:/usr/sbin:/sbin",
      "CM_LOCAL": local.path,
      "CM_BUNDLE_ENV": envFile.path,
      "CM_PUNCH_BANDS": "/punch/bands",
    ]
    let out = Pipe()
    let err = Pipe()
    process.standardOutput = out
    process.standardError = err
    try process.run()
    let stdout = out.fileHandleForReading.readDataToEndOfFile()
    let stderr = err.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return Run(
      status: process.terminationStatus,
      stdout: String(decoding: stdout, as: UTF8.self),
      stderr: String(decoding: stderr, as: UTF8.self))
  }

  // MARK: - resolve

  func testNamedImageThatExistsIsKept() throws {
    try makeImage("Marcin Mac Studio (3).sparsebundle")
    try makeImage("Other.sparsebundle")
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    let result = try run("resolve")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(result.stdout, "Marcin Mac Studio (3).sparsebundle\n")
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio (3).sparsebundle\"\n")
  }

  /// The 25 Nov case: the prepared image was renamed by Time Machine.
  func testImageRenamedByTimeMachineIsFollowed() throws {
    try makeImage("Marcin Mac Studio.sparsebundle")
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    let result = try run("resolve")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(result.stdout, "Marcin Mac Studio.sparsebundle\n")
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio.sparsebundle\"\n")
    XCTAssertTrue(result.stderr.contains("Marcin Mac Studio (3).sparsebundle"), result.stderr)
    XCTAssertTrue(result.stderr.contains("Marcin Mac Studio.sparsebundle"), result.stderr)
  }

  /// A new image Time Machine started itself still has its own 875 MB bands.
  /// Binding the Drive bands over it would mix two images: refuse.
  func testNewUnpreparedImageIsNotTakenForTheRenamedOne() throws {
    try makeImage("Marcin Mac Studio.sparsebundle", bandSize: 917_504_000)
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    let result = try run("resolve")

    XCTAssertNotEqual(result.status, 0)
    XCTAssertEqual(result.stdout, "")
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio (3).sparsebundle\"\n")
  }

  /// Bands on the local disk mean the image is not one whose bands are on Drive,
  /// whatever its Info.plist says.
  func testImageWithLocalBandsIsRefused() throws {
    try makeImage("Marcin Mac Studio.sparsebundle", localBands: 2)
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    let result = try run("resolve")

    XCTAssertNotEqual(result.status, 0)
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio (3).sparsebundle\"\n")
  }

  func testTwoCandidatesAreNotGuessedBetween() throws {
    try makeImage("A.sparsebundle")
    try makeImage("B.sparsebundle")
    try writeEnv("Gone.sparsebundle")

    let result = try run("resolve")

    XCTAssertNotEqual(result.status, 0)
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Gone.sparsebundle\"\n")
    XCTAssertTrue(result.stderr.contains("A.sparsebundle"), result.stderr)
    XCTAssertTrue(result.stderr.contains("B.sparsebundle"), result.stderr)
  }

  func testNoImageAtAllIsRefused() throws {
    try writeEnv("Gone.sparsebundle")

    let result = try run("resolve")

    XCTAssertNotEqual(result.status, 0)
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Gone.sparsebundle\"\n")
  }

  func testImageWithoutInfoPlistIsRefused() throws {
    try makeImage("Marcin Mac Studio.sparsebundle", infoPlist: false)
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    XCTAssertNotEqual(try run("resolve").status, 0)
  }

  /// vm-prepare-bundle escapes `"` and `\\` (VMLayout.envLine); the stored
  /// name is read back unescaped.
  func testEscapedStoredNameIsReadBack() throws {
    try makeImage(#"Mac "Pro".sparsebundle"#)
    try #"CM_BUNDLE="Mac \"Pro\".sparsebundle""#.appending("\n")
      .write(to: envFile, atomically: true, encoding: .utf8)

    let result = try run("resolve")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(result.stdout, "Mac \"Pro\".sparsebundle\n")
  }

  /// bundle.env is sourced as shell by root elsewhere (DriveEncryption): a
  /// name off the share with shell syntax in it is never written there.
  func testRenameToANameWithShellSyntaxIsRefused() throws {
    for name in [
      #"X$(id).sparsebundle"#, "X`id`.sparsebundle", #"X".sparsebundle"#, #"X\.sparsebundle"#,
    ] {
      try? FileManager.default.removeItem(at: local)
      try makeImage(name)
      try writeEnv("Old.sparsebundle")

      let result = try run("resolve")

      XCTAssertNotEqual(result.status, 0, name)
      XCTAssertEqual(try env(), "CM_BUNDLE=\"Old.sparsebundle\"\n", name)
    }
  }

  /// No bundle.env means vm-prepare-bundle has not run: nothing to follow,
  /// and the file is not created behind its back.
  func testWithoutBundleEnvNothingIsWritten() throws {
    try makeImage("Mac.sparsebundle")

    XCTAssertNotEqual(try run("resolve").status, 0)
    XCTAssertFalse(FileManager.default.fileExists(atPath: envFile.path))
  }

  // MARK: - In the machine: mountpoint, bind, unbind

  /// The likeliest real case: Time Machine renames the image while the bind
  /// is up, so bands/ is the mount, full of bands - still the prepared image.
  func testRenameWhileBoundIsFollowed() throws {
    try makeImage("Marcin Mac Studio.sparsebundle", localBands: 3)
    try writeEnv("Marcin Mac Studio (3).sparsebundle")
    let bands = local.appendingPathComponent("Marcin Mac Studio.sparsebundle/bands")
    try stubMounts(mounted: [bands])

    let result = try run("has-info")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio.sparsebundle\"\n")
  }

  func testBindMountsDriveBandsIntoTheRenamedImage() throws {
    try makeImage("Marcin Mac Studio.sparsebundle")
    try writeEnv("Marcin Mac Studio (3).sparsebundle")
    try stubMounts()

    let result = try run("bind")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(
      recordedCalls(),
      "mount --bind|/punch/bands|\(local.path)/Marcin Mac Studio.sparsebundle/bands\n")
  }

  func testBindDoesNothingWhenTheImageIsUnclear() throws {
    try makeImage("A.sparsebundle")
    try makeImage("B.sparsebundle")
    try writeEnv("Gone.sparsebundle")
    try stubMounts()

    XCTAssertNotEqual(try run("bind").status, 0)
    XCTAssertEqual(recordedCalls(), "")
  }

  /// After a rename the stored name is stale: unbind finds the mount itself.
  func testUnbindUnmountsTheBoundImageWhateverItIsCalled() throws {
    try makeImage("New.sparsebundle", localBands: 1)
    try makeImage("Other.sparsebundle", bandSize: 917_504_000, localBands: 1)
    try writeEnv("Old.sparsebundle")
    try stubMounts(mounted: [local.appendingPathComponent("New.sparsebundle/bands")])

    let result = try run("unbind")

    XCTAssertEqual(result.status, 0, result.stderr)
    XCTAssertEqual(recordedCalls(), "umount -l|\(local.path)/New.sparsebundle/bands\n")
  }

  // MARK: - has-info (tm-meta-sync's condition)

  /// After a rename the metadata copy must go on: without it the bands on
  /// Drive cannot be opened again.
  func testMetadataCopyFollowsTheRename() throws {
    try makeImage("Marcin Mac Studio.sparsebundle")
    try writeEnv("Marcin Mac Studio (3).sparsebundle")

    XCTAssertEqual(try run("has-info").status, 0)
    XCTAssertEqual(try env(), "CM_BUNDLE=\"Marcin Mac Studio.sparsebundle\"\n")
  }

  /// `rclone sync` deletes on Drive what is gone locally: no Info.plist, no copy.
  func testMetadataCopyIsSkippedWithoutInfoPlist() throws {
    try makeImage("Mac.sparsebundle", infoPlist: false)
    try writeEnv("Mac.sparsebundle")

    XCTAssertNotEqual(try run("has-info").status, 0)
  }

  func testUnknownCommandFails() throws {
    XCTAssertNotEqual(try run("frobnicate").status, 0)
  }

  // MARK: - Wiring

  private static func repoFile(_ path: String) throws -> String {
    try String(
      contentsOf: script.deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent(path), encoding: .utf8)
  }

  func testUnitsUseTheScriptInsteadOfTheStoredName() throws {
    let bind = try Self.repoFile("vm/systemd/tm-bands-bind.service")
    XCTAssertTrue(bind.contains("ExecStart=/usr/local/sbin/tm-bundle bind\n"), bind)
    XCTAssertTrue(bind.contains("ExecStop=/usr/local/sbin/tm-bundle unbind\n"), bind)
    XCTAssertFalse(bind.contains("${CM_BUNDLE}"), "the bind must not trust a stale name")

    let meta = try Self.repoFile("vm/systemd/tm-meta-sync.service")
    XCTAssertTrue(meta.contains("ExecCondition=/usr/local/sbin/tm-bundle has-info\n"), meta)
    XCTAssertFalse(meta.contains("${CM_BUNDLE}"))

    let yaml = try Self.repoFile("vm/cmsmb.yaml")
    XCTAssertTrue(
      yaml.contains(
        "  path: /usr/local/sbin/tm-bundle\n  file: tm-bundle.sh\n  permissions: 755\n"), yaml)
  }
}
