import XCTest

@testable import CloudMachineCore

/// Two ways to end up with a second, empty backup next to an invisible one
/// (second audit, 10.10.2026):
///
/// - N-W1: the panel suggested `configure-remote --replace-existing` after
///   every credential change. The new sign-in (`drive.file`, another
///   `client_id`) does not see the existing backup.
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

  /// THE case: no file, and this Mac has already set up the machine.
  func testMissingConfigNextToABackupIsUnknown() {
    XCTAssertNil(RemoteConfigurer.absentAnswer(configFileExists: false, machineSetUp: true))
    XCTAssertNil(RemoteConfigurer.absentAnswer(configFileExists: nil, machineSetUp: true))
  }

  func testNewMacWithoutConfigHasNoRemote() {
    XCTAssertEqual(
      RemoteConfigurer.absentAnswer(configFileExists: false, machineSetUp: false), false)
    XCTAssertEqual(RemoteConfigurer.absentAnswer(configFileExists: nil, machineSetUp: false), false)
    // A file rclone read and found no remote in is an answer.
    XCTAssertEqual(RemoteConfigurer.absentAnswer(configFileExists: true, machineSetUp: true), false)
  }

  /// What the old and the new token see is `bands/` in the machine's folder.
  func testBackupPresenceIsTheBandsDirectory() {
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(succeeded: true, stdout: "bands/\n", stderr: ""),
      .present)
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(succeeded: true, stdout: "other/\n", stderr: ""),
      .absent)
    XCTAssertEqual(
      RemoteConfigurer.classifyRemoteListing(
        succeeded: false, stdout: "", stderr: "error: directory not found"),
      .absent)
    if case .unknown = RemoteConfigurer.classifyRemoteListing(
      succeeded: false, stdout: "", stderr: "couldn't connect")
    {
    } else {
      XCTFail("an error other than a missing folder is not an answer")
    }
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

  func testNewTokenMustSeeTheBackupTheOldOneSaw() {
    // The old token saw the backup: the new one has to as well.
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

}
