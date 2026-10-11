import XCTest

@testable import CloudMachineCore

/// Two ways to end up with a second, empty backup next to an invisible one
/// (second audit, 10.10.2026):
///
/// - N-W1: the panel suggested `configure-remote --replace-existing` after
///   every credential change. The new sign-in (`drive.file`, another
///   `client_id`) does not see the existing image; `create-image` then sees
///   nothing to protect.
/// - S4: without `rclone.conf`, `rclone listremotes` exits 0 with nothing,
///   which read as "no remote" - and a Mac whose backup lives in
///   `mac-studio` got a new folder for good.
final class BackupVisibilityTests: XCTestCase {

  private var directory: URL!

  override func setUpWithError() throws {
    try super.setUpWithError()
    directory = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cm-visibility-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: directory)
    try super.tearDownWithError()
  }

  private func makeDirectory(_ path: String) throws {
    try FileManager.default.createDirectory(
      at: directory.appendingPathComponent(path), withIntermediateDirectories: true)
  }

  // MARK: - Traces on the local disk

  /// The cache directory carries a suffix when the mount overrides backend
  /// options - `gdrive{hekjD}` on this project's own Mac.
  func testCachedFoldersAreFoundUnderTheSuffixedRemoteOnly() throws {
    try makeDirectory("vfs/gdrive{hekjD}/CloudMachine/mac-studio/mac-studio.sparsebundle")
    try makeDirectory("vfs/gdrive2/CloudMachine/someone-else")
    try makeDirectory("vfs/gdrive/Other/not-ours")

    XCTAssertEqual(InstallationTraces.cachedFolders(cacheDir: directory), ["mac-studio"])
    XCTAssertEqual(
      InstallationTraces.cachedImage(
        folder: "mac-studio", imageName: "mac-studio", cacheDir: directory)?.lastPathComponent,
      "mac-studio.sparsebundle")
    XCTAssertNil(
      InstallationTraces.cachedImage(
        folder: "home-mac-studio-3", imageName: "home-mac-studio-3", cacheDir: directory))
  }

  func testNoCacheMeansNoTraces() {
    XCTAssertEqual(InstallationTraces.cachedFolders(cacheDir: directory), [])
  }

  func testRememberedImageIsATraceOnlyForTheSameRemotePath() throws {
    let marker = directory.appendingPathComponent("known-image")
    InstallationTraces.rememberImage(remotePath: "CloudMachine/mac-studio", file: marker)

    XCTAssertEqual(
      InstallationTraces.knownImageTrace(
        folder: "mac-studio", imageName: "mac-studio", remotePath: "CloudMachine/mac-studio",
        knownImageFile: marker, cacheDir: directory),
      marker.path)
    XCTAssertNil(
      InstallationTraces.knownImageTrace(
        folder: "other", imageName: "other", remotePath: "CloudMachine/other",
        knownImageFile: marker, cacheDir: directory))
  }

  // MARK: - S4: a missing rclone.conf is not "no remote"

  func testConfigFileAnswerIsRead() throws {
    let missing = ProcessResult(
      stdout:
        "Configuration file doesn't exist, but rclone will use this path:\n/Users/x/.config/rclone/rclone.conf\n",
      stderr: "", exitCode: 0)
    XCTAssertEqual(RemoteConfigurer.configFileExists(in: missing), false)

    let file = directory.appendingPathComponent("rclone.conf")
    try "".write(to: file, atomically: true, encoding: .utf8)
    let present = ProcessResult(
      stdout: "Configuration file is stored at:\n\(file.path)\n", stderr: "", exitCode: 0)
    XCTAssertEqual(RemoteConfigurer.configFileExists(in: present), true)

    XCTAssertNil(RemoteConfigurer.configFileExists(in: nil))
    XCTAssertNil(
      RemoteConfigurer.configFileExists(in: ProcessResult(stdout: "", stderr: "x", exitCode: 1)))
  }

  /// THE case: no file, and a mount of this remote has run here.
  func testMissingConfigNextToABackupIsUnknown() {
    XCTAssertNil(
      RemoteConfigurer.absentAnswer(configFileExists: false, cachedFolders: ["mac-studio"]))
    XCTAssertNil(
      RemoteConfigurer.absentAnswer(configFileExists: nil, cachedFolders: ["mac-studio"]))
  }

  func testNewMacWithoutConfigHasNoRemote() {
    XCTAssertEqual(RemoteConfigurer.absentAnswer(configFileExists: false, cachedFolders: []), false)
    XCTAssertEqual(RemoteConfigurer.absentAnswer(configFileExists: nil, cachedFolders: []), false)
    // A file rclone read and found no remote in is an answer.
    XCTAssertEqual(
      RemoteConfigurer.absentAnswer(configFileExists: true, cachedFolders: ["mac-studio"]), false)
  }

  /// Whatever rclone says, a cached `mac-studio` keeps this Mac in it.
  func testCachedLegacyFolderKeepsTheLegacyName() {
    for remote in [false, nil] as [Bool?] {
      let evidence = DriveFolder.legacyEvidence(
        remoteConfigured: remote, cachedFolders: ["mac-studio"])
      XCTAssertEqual(evidence, true)
      XCTAssertEqual(
        DriveFolder.decide(
          existing: nil, requested: nil, legacyEvidence: evidence,
          machineKey: "home-mac-studio-3"),
        .assign("mac-studio"))
    }
    XCTAssertEqual(DriveFolder.legacyEvidence(remoteConfigured: false, cachedFolders: []), false)
    XCTAssertNil(DriveFolder.legacyEvidence(remoteConfigured: nil, cachedFolders: []))
    XCTAssertEqual(
      DriveFolder.legacyEvidence(remoteConfigured: false, cachedFolders: ["home-mac-studio-3"]),
      false)
  }

  // MARK: - N-W1: replacing the connection

  /// The panel must never steer a connected Mac towards replacing the remote.
  func testSavedCredentialsMessageDoesNotSuggestReplacing() {
    for configured in [true, nil] as [Bool?] {
      let message = RemoteConfigurer.credentialsSavedMessage(remoteConfigured: configured)
      XCTAssertFalse(message.contains("--replace-existing"), message)
      XCTAssertTrue(message.contains("drive.file"), message)
    }
    XCTAssertFalse(
      RemoteConfigurer.credentialsSavedMessage(remoteConfigured: false)
        .contains("--replace-existing"))
  }

  func testReplacingTakesTwoFlags() {
    XCTAssertNil(
      RemoteConfigurer.replacementGate(
        configured: false, replaceExisting: false, acceptScopeChange: false, remoteName: "gdrive"))
    let none = RemoteConfigurer.replacementGate(
      configured: true, replaceExisting: false, acceptScopeChange: false, remoteName: "gdrive")
    XCTAssertEqual(none?.succeeded, false)
    let one = RemoteConfigurer.replacementGate(
      configured: true, replaceExisting: true, acceptScopeChange: false, remoteName: "gdrive")
    XCTAssertEqual(one?.succeeded, false)
    XCTAssertTrue(one?.message.contains("--accept-scope-change") == true)
    XCTAssertTrue(one?.message.contains("drive.file") == true)
    XCTAssertNil(
      RemoteConfigurer.replacementGate(
        configured: true, replaceExisting: true, acceptScopeChange: true, remoteName: "gdrive"))
  }

  func testNewTokenMustSeeTheImageTheOldOneSaw() {
    // The old token saw the image: the new one has to as well.
    XCTAssertNil(
      RemoteConfigurer.replacementVerdict(before: .present, after: .present, remoteName: "gdrive"))
    XCTAssertEqual(
      RemoteConfigurer.replacementVerdict(before: .present, after: .absent, remoteName: "gdrive")?
        .succeeded, false)
    XCTAssertEqual(
      RemoteConfigurer.replacementVerdict(
        before: .present, after: .unknown("timeout"), remoteName: "gdrive")?.succeeded, false)
    // Nothing visible before: nothing for the new token to miss.
    XCTAssertNil(
      RemoteConfigurer.replacementVerdict(before: .absent, after: .absent, remoteName: "gdrive"))
  }

  /// `create-image` with an image this Mac remembers but Drive does not show.
  func testRememberedButInvisibleImageIsNotCreatedAgain() {
    XCTAssertNil(BackupImageService.absentImageVerdict(trace: nil))
    let refusal = BackupImageService.absentImageVerdict(trace: "/tmp/known-image")
    XCTAssertEqual(refusal?.succeeded, false)
    XCTAssertTrue(refusal?.message.contains("/tmp/known-image") == true)
  }
}
