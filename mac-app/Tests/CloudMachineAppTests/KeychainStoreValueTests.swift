import XCTest

@testable import CloudMachineCore

/// What `KeychainStore.save` actually hands to `security` - without touching
/// this Mac's Keychain.
///
/// The encryption password goes to `rclone obscure` exactly as typed. If the
/// Keychain copy were trimmed, a password with a leading or trailing space
/// would be stored DIFFERENT from the one that encrypts the backup, and the
/// copy meant for recovery would not decrypt it.
final class KeychainStoreValueTests: XCTestCase {

  func testExactValueKeepsLeadingAndTrailingSpaces() throws {
    XCTAssertEqual(
      try KeychainStore.valueToStore("  pass phrase with spaces ", exact: true),
      "  pass phrase with spaces ")
  }

  func testDefaultTrimsPastedNewlinesAndSpaces() throws {
    // A pasted client_id / client_secret often carries a newline.
    XCTAssertEqual(try KeychainStore.valueToStore(" client-id\n"), "client-id")
  }

  func testEmptyIsRefusedInBothModes() {
    XCTAssertThrowsError(try KeychainStore.valueToStore("  \n"))
    XCTAssertThrowsError(try KeychainStore.valueToStore("", exact: true))
  }

  /// What `DriveEncryption.setup` stores is what `obscure` encrypted with:
  /// the value as `KeychainStore.save` would hand it to `security`.
  func testEncryptionSetupStoresPasswordAndSaltExactly() throws {
    let password = " edge spaces password "
    let salt = "c2FsdA=="
    let stored = try DriveEncryption.keychainItems(password: password, salt: salt).map {
      ($0.account, try KeychainStore.valueToStore($0.value, exact: $0.exact))
    }
    XCTAssertEqual(stored.map(\.0), [DriveEncryption.passwordAccount, DriveEncryption.saltAccount])
    XCTAssertEqual(stored.map(\.1), [password, salt])
  }

  func testExactWhitespaceOnlyIsRefused() {
    // Nothing meaningful to keep - same refusal as before.
    XCTAssertThrowsError(try KeychainStore.valueToStore("   ", exact: true))
  }
}
