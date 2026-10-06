import XCTest

@testable import CloudMachineCore

final class MachineIdentityTests: XCTestCase {
  // Must stay in sync with what used to be `cm_machine_key` in
  // scripts/common.sh - both derive the machine key from the same
  // `scutil --get ComputerName`.

  func testNormalizedKey_lowercasesAndReplacesSpaces() {
    XCTAssertEqual(
      MachineIdentity.normalizedKey(fromComputerName: "Marcin Mac Studio"),
      "marcin-mac-studio"
    )
  }

  func testNormalizedKey_stripsDisallowedCharacters() {
    XCTAssertEqual(
      MachineIdentity.normalizedKey(fromComputerName: "Marcin's MacBook Pro (2)"),
      "marcins-macbook-pro-2"
    )
  }

  func testNormalizedKey_stripsAccentedCharacters() {
    // scutil may return a name with Polish characters - those are not in the
    // allowed set [a-z0-9-], so they must disappear rather than, say, crash
    // the whole process.
    let name = "Łukasza-iMac"  // l10n-polish-ok: test input with a Polish letter
    XCTAssertEqual(MachineIdentity.normalizedKey(fromComputerName: name), "ukasza-imac")
  }

  func testNormalizedKey_emptyInput() {
    XCTAssertEqual(MachineIdentity.normalizedKey(fromComputerName: ""), "")
  }
}
