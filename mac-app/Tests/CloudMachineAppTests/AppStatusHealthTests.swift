import XCTest

@testable import CloudMachineApp

/// Testy jednego zdania, ktore uzytkownik naprawde czyta: zielony znaczek
/// i naglowek w pasku menu.
///
/// Powstaly, bo mutacja wykazala luke: `healthy` i `headline` NIE mialy zadnego
/// testu, wiec poprawka dokladajaca do nich `erroredFiles` i `outOfSpace`
/// przechodzila, ale rownie dobrze przeszlaby jej odwrotnosc. Zepsute
/// i sprawne wygladalo identycznie takze w zestawie testow.
@MainActor
final class AppStatusHealthTests: XCTestCase {

  /// Stan, w ktorym wszystko naprawde dziala - punkt odniesienia.
  private func zdrowy() -> AppStatus {
    let status = AppStatus()
    status.dependencyState = .ready
    status.remoteConfigured = true
    status.timeMachineState = .registered(mountPoint: "/Volumes/CloudMachine")
    var buffer = BufferStatus()
    buffer.mounted = true
    buffer.imageAttached = true
    status.buffer = buffer
    return status
  }

  func testZdrowyStanJestZdrowy() {
    let status = zdrowy()
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.headline, "Gotowe")
  }

  /// TO jest ta awaria. Pasma, ktorych rclone nie wyslal, istnieja wylacznie
  /// na tym Macu - czyli backup nie jest kopia. Interfejs pokazywal wtedy
  /// zielony znaczek i "Gotowe".
  func testNiewyslanePlikiOdbierajaZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.erroredFiles = 7
    XCTAssertFalse(status.healthy, "Niewyslane pasma NIE moga uchodzic za zdrowy stan.")
    XCTAssertEqual(status.headline, "Nie wysłano 7 fragmentów kopii")
  }

  /// rclone melduje, ze nie ma juz gdzie odlozyc danych. Mocniejszy sygnal niz
  /// jakikolwiek nasz prog, bo pochodzi od tego, kto naprawde wie.
  func testPelnyBuforOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.outOfSpace = true
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Wysyłka nie nadąża za zapisem")
  }

  func testBrakMontowaniaOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.mounted = false
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Bufor nie dziala")
  }

  func testNiepodpietyObrazOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.imageAttached = false
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Obraz backupu niepodpiety")
  }

  func testPrzestawionyCelTimeMachineOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.timeMachineState = .notRegistered
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Time Machine nie wskazuje na CloudMachine")
  }

  /// Limit dobowy NIE wymaga reakcji, ale pasma leza wtedy tylko na tym Macu -
  /// wiec zielony znaczek sie nie nalezy.
  func testWyczerpanyLimitDriveOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.dailyQuotaExhausted = true
    XCTAssertFalse(status.healthy)
    XCTAssertFalse(status.buffer.uploadState.needsAttention)
  }

  /// Brak miejsca na Dysku to co INNEGO niz limit dobowy: nie minie samo.
  func testBrakMiejscaNaDyskuWymagaReakcji() {
    let status = zdrowy()
    status.buffer.driveFull = true
    XCTAssertFalse(status.healthy)
    XCTAssertTrue(status.buffer.uploadState.needsAttention)
  }

  func testNiepolaczonyDriveOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.remoteConfigured = false
    XCTAssertFalse(status.healthy)
  }

  /// Trwajaca wysylka to NIE awaria - dopoki kolejka maleje, wszystko idzie
  /// zgodnie z projektem. Bez tego testu "naprawa" polegajaca na alarmowaniu
  /// przy kazdej niepustej kolejce przeszlaby niezauwazona.
  func testTrwajacaWysylkaNieJestAwaria() {
    let status = zdrowy()
    status.buffer.uploadsQueued = 12
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.headline, "Wysyłanie na Google Drive — 12 w kolejce")
  }
}
