import XCTest
@testable import CloudMachineApp

final class CloudMachineControllerTests: XCTestCase {

    // MARK: - normalizedMachineKey
    // Musi zostac zsynchronizowane z `cm_machine_key` w scripts/common.sh -
    // oba wywodza klucz maszyny z tego samego `scutil --get ComputerName`.

    func testNormalizedMachineKey_lowercasesAndReplacesSpaces() {
        XCTAssertEqual(
            CloudMachineController.normalizedMachineKey(fromComputerName: "Marcin Mac Studio"),
            "marcin-mac-studio"
        )
    }

    func testNormalizedMachineKey_stripsDisallowedCharacters() {
        XCTAssertEqual(
            CloudMachineController.normalizedMachineKey(fromComputerName: "Marcin's MacBook Pro (2)"),
            "marcins-macbook-pro-2"
        )
    }

    func testNormalizedMachineKey_stripsAccentedCharacters() {
        // scutil moze zwrocic nazwe z polskimi znakami - te nie sa w dozwolonym
        // zbiorze [a-z0-9-], wiec musza zniknac, a nie np. wywalic caly proces.
        XCTAssertEqual(
            CloudMachineController.normalizedMachineKey(fromComputerName: "Łukasza-iMac"),
            "ukasza-imac"
        )
    }

    func testNormalizedMachineKey_emptyInput() {
        XCTAssertEqual(CloudMachineController.normalizedMachineKey(fromComputerName: ""), "")
    }

    // MARK: - extractToken

    func testExtractToken_validOutput() {
        let output = "Paste the following into the remote machine --->\n{\"access_token\":\"abc123\"}\n<---End paste"
        XCTAssertEqual(
            CloudMachineController.extractToken(from: output),
            "{\"access_token\":\"abc123\"}"
        )
    }

    func testExtractToken_missingMarkers() {
        XCTAssertNil(CloudMachineController.extractToken(from: "cos posz\u{142}o nie tak, brak markerow"))
    }

    func testExtractToken_onlyStartMarker() {
        XCTAssertNil(CloudMachineController.extractToken(from: "tekst ---> reszta bez konca"))
    }
}
