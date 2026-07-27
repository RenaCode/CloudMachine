import XCTest

@testable import CloudMachineCore

final class MachineIdentityTests: XCTestCase {
  // Musi zostac zsynchronizowane z tym, co kiedys bylo `cm_machine_key` w
  // scripts/common.sh - oba wywodza klucz maszyny z tego samego
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
    // scutil moze zwrocic nazwe z polskimi znakami - te nie sa w dozwolonym
    // zbiorze [a-z0-9-], wiec musza zniknac, a nie np. wywalic caly proces.
    XCTAssertEqual(
      MachineIdentity.normalizedKey(fromComputerName: "Łukasza-iMac"),
      "ukasza-imac"
    )
  }

  func testNormalizedKey_emptyInput() {
    XCTAssertEqual(MachineIdentity.normalizedKey(fromComputerName: ""), "")
  }
}
