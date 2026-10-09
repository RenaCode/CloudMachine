import XCTest

@testable import CloudMachineCore

final class RemoteConfigurerTests: XCTestCase {
  func testExtractToken_validOutput() {
    let output =
      "Paste the following into the remote machine --->\n{\"access_token\":\"abc123\"}\n<---End paste"
    XCTAssertEqual(
      RemoteConfigurer.extractToken(from: output),
      "{\"access_token\":\"abc123\"}"
    )
  }

  func testExtractToken_missingMarkers() {
    XCTAssertNil(RemoteConfigurer.extractToken(from: "something went wrong, no markers"))
  }

  func testExtractToken_onlyStartMarker() {
    XCTAssertNil(RemoteConfigurer.extractToken(from: "text ---> rest without an end"))
  }

  // MARK: - Is the remote there

  /// REGRESSION 09.10.2026: no answer from rclone read as "no remote", and
  /// `connect` went on to overwrite the working token.
  func testNoAnswerIsUnknownNotAbsent() {
    XCTAssertNil(RemoteConfigurer.remoteListed("gdrive", in: nil))
  }

  /// An unreadable or broken `rclone.conf` makes rclone print nothing on
  /// stdout and exit with 1 (checked on rclone 1.75.1).
  func testFailedListremotesIsUnknown() {
    let result = ProcessResult(
      stdout: "", stderr: "CRITICAL: Failed to load config file: permission denied", exitCode: 1)
    XCTAssertNil(RemoteConfigurer.remoteListed("gdrive", in: result))
  }

  func testListedRemoteIsFound() {
    let result = ProcessResult(stdout: "other:\ngdrive:\n", stderr: "", exitCode: 0)
    XCTAssertEqual(RemoteConfigurer.remoteListed("gdrive", in: result), true)
  }

  func testOnlyAWholeLineMatches() {
    let result = ProcessResult(stdout: "mygdrive:\n", stderr: "", exitCode: 0)
    XCTAssertEqual(RemoteConfigurer.remoteListed("gdrive", in: result), false)
  }

  func testAnsweredWithoutTheRemoteIsAbsent() {
    XCTAssertEqual(
      RemoteConfigurer.remoteListed(
        "gdrive", in: ProcessResult(stdout: "", stderr: "", exitCode: 0)),
      false)
  }
}
