import XCTest

@testable import CloudMachineCore

/// Testy stanu wlasnych poswiadczen OAuth.
///
/// Najwazniejszy przypadek to POLOWICZNA konfiguracja: wyglada na zrobiona, a
/// rclone i tak wraca na wspoldzielony `client_id`. Gdyby interfejs pokazywal
/// wtedy zielone "ustawione", uzytkownik mialby dowod na cos, co nie dziala.
final class RemoteCredentialsTests: XCTestCase {

  private typealias State = RemoteConfigurer.CredentialsState

  func testObaUstawioneToKonfiguracjaKompletna() {
    let state = State(hasClientID: true, hasClientSecret: true)
    XCTAssertTrue(state.isComplete)
    XCTAssertFalse(state.isPartial)
    XCTAssertTrue(state.summary.contains("ustawione"))
  }

  func testZadneNieUstawioneToBrakKonfiguracji() {
    let state = State(hasClientID: false, hasClientSecret: false)
    XCTAssertFalse(state.isComplete)
    XCTAssertFalse(state.isPartial, "Brak obu to nie jest stan polowiczny")
    XCTAssertTrue(state.summary.contains("Brak wlasnych poswiadczen"))
  }

  /// ZNANA ZLA PROBKA: sam `client_id`, bez sekretu.
  func testSamClientIdToStanPolowicznyANieKompletny() {
    let state = State(hasClientID: true, hasClientSecret: false)
    XCTAssertFalse(state.isComplete, "Bez sekretu rclone nie uzyje wlasnego client_id")
    XCTAssertTrue(state.isPartial)
    XCTAssertTrue(state.summary.contains("client_secret"), "Komunikat ma nazwac to, czego brakuje")
  }

  /// I odwrotnie - sam sekret bez identyfikatora.
  func testSamSekretToStanPolowiczny() {
    let state = State(hasClientID: false, hasClientSecret: true)
    XCTAssertFalse(state.isComplete)
    XCTAssertTrue(state.isPartial)
    XCTAssertTrue(state.summary.contains("client_id"))
  }

  /// Komunikat przy braku poswiadczen ma mowic, CO Z TEGO WYNIKA - inaczej
  /// nikt nie ma powodu tego uzupelniac. Wspoldzielony `client_id` rclone jest
  /// limitowany wspolnie i wycofywany w 2026.
  func testKomunikatTlumaczySkutekBrakuPoswiadczen() {
    let summary = State(hasClientID: false, hasClientSecret: false).summary
    XCTAssertTrue(summary.contains("wspoldzielonego client_id"))
    XCTAssertTrue(summary.contains("2026"))
  }

  func testNazwyKontWKeychainieSaStabilne() {
    // Zmiana tych nazw rozjezdza zapis z interfejsu i odczyt z agenta, a obie
    // strony milcza - agent po prostu wraca na wspoldzielony client_id.
    XCTAssertEqual(RemoteConfigurer.clientIDAccount, "client_id")
    XCTAssertEqual(RemoteConfigurer.clientSecretAccount, "client_secret")
    XCTAssertEqual(RemoteConfigurer.keychainService, "cloudmachine-gdrive")
  }
}
