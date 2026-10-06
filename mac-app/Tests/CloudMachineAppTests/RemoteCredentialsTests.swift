import XCTest

@testable import CloudMachineCore

/// Tests for the state of the own OAuth credentials.
///
/// The most important case is a HALF-DONE configuration: it looks done, and
/// rclone falls back to the shared `client_id` anyway. If the interface then
/// showed a green "set", the user would have proof of something that does not
/// work.
final class RemoteCredentialsTests: XCTestCase {

  private typealias State = RemoteConfigurer.CredentialsState

  func testBothSetIsACompleteConfiguration() {
    let state = State(hasClientID: true, hasClientSecret: true)
    XCTAssertTrue(state.isComplete)
    XCTAssertFalse(state.isPartial)
    XCTAssertTrue(state.summary.contains("set."))
  }

  func testNeitherSetIsNoConfiguration() {
    let state = State(hasClientID: false, hasClientSecret: false)
    XCTAssertFalse(state.isComplete)
    XCTAssertFalse(state.isPartial, "Both missing is not a half-done state")
    XCTAssertTrue(state.summary.contains("No own credentials"))
  }

  /// KNOWN BAD SAMPLE: `client_id` alone, without the secret.
  func testClientIdAloneIsHalfDoneNotComplete() {
    let state = State(hasClientID: true, hasClientSecret: false)
    XCTAssertFalse(state.isComplete, "Without the secret rclone will not use its own client_id")
    XCTAssertTrue(state.isPartial)
    XCTAssertTrue(
      state.summary.contains("client_secret"), "The message must name what is missing")
  }

  /// And the other way round - the secret alone without the identifier.
  func testSecretAloneIsHalfDone() {
    let state = State(hasClientID: false, hasClientSecret: true)
    XCTAssertFalse(state.isComplete)
    XCTAssertTrue(state.isPartial)
    XCTAssertTrue(state.summary.contains("client_id"))
  }

  /// The message for missing credentials must say WHAT FOLLOWS FROM IT -
  /// otherwise nobody has a reason to fill them in. rclone's shared
  /// `client_id` is rate-limited jointly and being retired in 2026.
  func testMessageExplainsConsequenceOfMissingCredentials() {
    let summary = State(hasClientID: false, hasClientSecret: false).summary
    XCTAssertTrue(summary.contains("shared client_id"))
    XCTAssertTrue(summary.contains("2026"))
  }

  func testKeychainAccountNamesAreStable() {
    // Changing these names makes the write from the interface and the read
    // from the agent drift apart, and both sides stay silent - the agent
    // simply falls back to the shared client_id.
    XCTAssertEqual(RemoteConfigurer.clientIDAccount, "client_id")
    XCTAssertEqual(RemoteConfigurer.clientSecretAccount, "client_secret")
    XCTAssertEqual(RemoteConfigurer.keychainService, "cloudmachine-gdrive")
  }
}
