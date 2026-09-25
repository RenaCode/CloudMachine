import XCTest

@testable import CloudMachineCore

/// Ustalenie 15b: wynik `backupCorruptFile()` byl ignorowany.
///
/// Ta funkcja przy porazce kopiowania oddaje `nil`, a jej wlasny komentarz
/// nazywa ta kopie JEDYNA siecia bezpieczenstwa miedzy "plik sie nie sparsowal"
/// a "auto-zapis cicho nadpisal go pusta konfiguracja". `loadOrInitialize()`
/// wolalo ja przez `backupCorruptFile()` bez sprawdzenia wyniku i oddawalo
/// `(.empty, error)`, a CLI logowalo "oryginal zachowany na dysku z kopia
/// zapasowa obok" - zdanie nieprawdziwe dokladnie w tym przypadku, w ktorym
/// jedyny egzemplarz danych mial zginac przy nastepnym zapisie.
final class ConfigStoreTests: XCTestCase {

  private var katalog: URL!
  private var plik: URL!

  override func setUpWithError() throws {
    katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-config-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    plik = katalog.appendingPathComponent("machines.json")
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: katalog)
  }

  private struct Uszkodzony: Error {
    var localizedDescription: String { "nieoczekiwany znak na pozycji 12" }
  }

  // MARK: - Brak kopii przerywa

  /// SEDNO poprawki. Bez kopii nie ma konfiguracji do pracy - `config` jest
  /// `nil`, a nie "pusta". Wolajacy nie ma wiec czego zapisac i nie moze
  /// nadpisac uszkodzonego-ale-mozliwego-do-odzyskania pliku.
  func testBrakKopiiNieDajeKonfiguracjiDoPracy() {
    let wynik = ConfigStore.decideAfterCorruption(backup: nil, error: Uszkodzony())
    XCTAssertNil(
      wynik.config,
      "brak kopii musi PRZERWAC, a nie oddac pusta konfiguracje do nadpisania oryginalu")
    XCTAssertNotNil(wynik.corruption, "powod uszkodzenia musi dojsc do czlowieka")
  }

  /// Gdy kopia POWSTALA, praca na pustej konfiguracji jest bezpieczna - oryginal
  /// da sie odzyskac z pliku obok. Bez tego testu "naprawa" przerywajaca
  /// zawsze przeszlaby niezauwazona, a config uszkodzony reczna edycja
  /// blokowalby cale narzedzie.
  func testUdanaKopiaPozwalaPracowacDalej() {
    let kopia = katalog.appendingPathComponent("machines.json.corrupt-1")
    let wynik = ConfigStore.decideAfterCorruption(backup: kopia, error: Uszkodzony())
    XCTAssertNotNil(wynik.config)
    XCTAssertNotNil(wynik.corruption, "uszkodzenie nadal musi byc widoczne")
    guard case .corruptButBackedUp(_, let gdzie, _) = wynik else {
      return XCTFail("oczekiwalem .corruptButBackedUp, dostalem \(wynik)")
    }
    XCTAssertEqual(gdzie, kopia, "komunikat ma powiedziec, GDZIE lezy kopia")
  }

  /// Zdrowy plik nie jest uszkodzeniem.
  func testZdrowaKonfiguracjaNieZglaszaUszkodzenia() {
    XCTAssertNil(ConfigInitialization.ready(.empty).corruption)
    XCTAssertNotNil(ConfigInitialization.ready(.empty).config)
  }

  // MARK: - Sama kopia

  func testKopiaUszkodzonegoPlikuPowstajeObok() throws {
    try "{ to nie jest json".write(to: plik, atomically: true, encoding: .utf8)

    let kopia = try XCTUnwrap(ConfigStore.backupCorruptFile(configPath: plik))
    XCTAssertTrue(FileManager.default.fileExists(atPath: kopia.path))
    XCTAssertEqual(try String(contentsOf: kopia, encoding: .utf8), "{ to nie jest json")
    XCTAssertTrue(
      FileManager.default.fileExists(atPath: plik.path),
      "kopia nie moze zabierac oryginalu - to kopia, nie przeniesienie")
    XCTAssertTrue(kopia.lastPathComponent.contains("corrupt-"), kopia.lastPathComponent)
  }

  /// Nieudana kopia MUSI byc rozpoznawalna po wyniku - tu przez sciezke
  /// w katalogu, ktorego nie ma.
  func testNieudanaKopiaOddajeNil() {
    let nieistniejacy = katalog.appendingPathComponent("nie-ma-takiego-katalogu")
      .appendingPathComponent("machines.json")
    XCTAssertNil(ConfigStore.backupCorruptFile(configPath: nieistniejacy))
  }
}
