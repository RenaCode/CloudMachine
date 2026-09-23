import XCTest

@testable import CloudMachineCore

/// Blokada wzajemnego wykluczenia. Testy chodza po PRAWDZIWYM katalogu -
/// atrapa systemu plikow nie sprawdzilaby tu niczego, bo caly mechanizm to
/// atomowosc `mkdir` i to, czy zapisany PID da sie odczytac z powrotem.
/// Katalog jest wlasny i tymczasowy, zeby test nie dotykal blokad
/// produkcyjnych w `~/Library/Logs/CloudMachine`.
final class CMLockTests: XCTestCase {

  private var dir: URL!

  override func setUpWithError() throws {
    dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("CMLockTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: dir)
  }

  private var lockPath: URL { dir.appendingPathComponent("image.lock.d") }

  func testDrugaInstancjaNieDostajeTrzymanejBlokady() {
    let first = CMLock(directory: lockPath)
    XCTAssertTrue(first.acquire())
    defer { first.release() }

    let second = CMLock(directory: lockPath)
    XCTAssertFalse(
      second.acquire(),
      "blokade trzyma zywy proces (ten test) - druga instancja nie ma prawa jej dostac")
  }

  func testPoZwolnieniuBlokadaJestZnowDoWziecia() {
    let first = CMLock(directory: lockPath)
    XCTAssertTrue(first.acquire())
    first.release()
    XCTAssertFalse(
      FileManager.default.fileExists(atPath: lockPath.path),
      "zwolnienie ma usunac katalog blokady, nie tylko zapomniec o nim")

    let second = CMLock(directory: lockPath)
    XCTAssertTrue(second.acquire())
    second.release()
  }

  /// Dokladnie ten stan, ktory zostawia proces ubity miedzy `createDirectory`
  /// a zapisem PID-a: katalog blokady jest, pliku `pid` nie ma. Konkurent ma
  /// prawo go przejac - bo nikt zywy sie do niego nie przyznaje.
  func testKatalogBezPidJestOsieroconyIDaSiePrzejac() throws {
    try FileManager.default.createDirectory(at: lockPath, withIntermediateDirectories: false)

    let lock = CMLock(directory: lockPath)
    XCTAssertTrue(lock.acquire())
    defer { lock.release() }

    let pid = try String(
      contentsOf: lockPath.appendingPathComponent("pid"), encoding: .utf8)
    XCTAssertEqual(
      pid.split(separator: "\n").first.map(String.init), "\(getpid())",
      "po przejeciu w pliku ma stac NASZ PID - inaczej nastepny konkurent uzna blokade za wolna")
  }

  /// Blokada po martwym procesie nie moze zostac na zawsze - watchdog
  /// przerwany SIGKILL-em nie zdazy wywolac `release()`.
  func testBlokadaPoMartwymPidzieJestPrzejmowana() throws {
    try FileManager.default.createDirectory(at: lockPath, withIntermediateDirectories: false)
    // PID, ktorego na pewno nie ma: `kill(pid, 0)` odmawia z ESRCH.
    try "999999\n".write(
      to: lockPath.appendingPathComponent("pid"), atomically: true, encoding: .utf8)

    let lock = CMLock(directory: lockPath)
    XCTAssertTrue(lock.acquire())
    lock.release()
  }
}
