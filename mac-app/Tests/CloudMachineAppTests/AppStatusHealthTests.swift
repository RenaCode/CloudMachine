import CloudMachineCore
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
    // Musi byc jawne: `BufferStatus` zaczyna od "kolejki nie odczytano", zeby
    // swiezy, niesprawdzony stan nie uchodzil za pusta kolejke.
    buffer.queueKnown = true
    buffer.freeDiskGB = 400
    status.buffer = buffer
    // ZMIANA 23.09.2026: "wszystko podpiete" przestalo wystarczac do zielonego
    // znaczka. Punkt odniesienia musi teraz zawierac takze fakt, ze kopia
    // FAKTYCZNIE powstala - bo dokladnie tego brakowalo w awarii, dla ktorej
    // `BackupHealth` w ogole powstal. Wczesniej ten helper opisywal stan
    // urzadzen i milczal o tym, czy backup sie udal; test "zdrowy stan jest
    // zdrowy" przechodzil wiec takze dla Maca, ktory nie zrobil kopii od
    // dwoch dni.
    status.backupCycle = BackupCycleStatus(
      known: true, lastSuccess: Date().addingTimeInterval(-1800), problems: [],
      checkedAt: Date())
    return status
  }

  /// REGRESJA 23.09.2026: `rclone rc` nie odpowiedzial w limicie czasu,
  /// wolajacy podstawil zera i pasek menu pokazal "Gotowe" przy 386 pasmach
  /// czekajacych w kolejce.
  func testNieodczytanaKolejkaOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.buffer.queueKnown = false
    XCTAssertFalse(status.healthy, "Nie wiadomo = nie zielono.")
    XCTAssertNotEqual(status.headline, "Gotowe")
    XCTAssertEqual(status.buffer.uploadState, .queueUnknown)
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

  // MARK: - Wiek ostatniej UDANEJ kopii

  /// TA awaria. Montowanie stoi, obraz podpiety, kolejka pusta, cel Time
  /// Machine ustawiony - a ostatnia ZAKONCZONA kopia ma dwa dni. Panel
  /// pokazywal wtedy "Sprawny / Gotowe", bo nie pytal o to ani razu:
  /// `grep -rn "BackupHealth" Sources/CloudMachineApp/` nie dawal trafien.
  func testStaraKopiaOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.backupCycle.lastSuccess = Date().addingTimeInterval(-48 * 3600)
    XCTAssertFalse(
      status.healthy,
      "Wszystkie urzadzenia moga byc sprawne, a kopii moze nie byc od dwoch dni.")
    XCTAssertEqual(status.headline, "Brak ukończonej kopii od 2 dni")
  }

  /// Granica progu. Tuz pod nia jest jeszcze dobrze, tuz nad nia juz nie -
  /// bez tego testu "naprawa" ustawiajaca prog na 100 lat przeszlaby cicho.
  func testProgWiekuKopiiDzialaWObieStrony() {
    let tuzPrzed = zdrowy()
    tuzPrzed.backupCycle.lastSuccess = Date().addingTimeInterval(
      -(BackupHealth.maxAgeHours * 3600 - 60))
    XCTAssertTrue(tuzPrzed.healthy)

    let tuzPo = zdrowy()
    tuzPo.backupCycle.lastSuccess = Date().addingTimeInterval(
      -(BackupHealth.maxAgeHours * 3600 + 60))
    XCTAssertFalse(tuzPo.healthy)
  }

  /// Nieodczytany licznik kopii to NIE to samo, co kopia sprzed chwili.
  /// Domyslny `BackupCycleStatus` ma `known == false` wlasnie po to, zeby
  /// panel nie swiecil na zielono, zanim ktokolwiek o cokolwiek zapytal.
  func testNieodczytanyLicznikKopiiOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.backupCycle = BackupCycleStatus()
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Nie wiadomo, kiedy powstała ostatnia kopia")
  }

  /// Odczytano preferencje i nie ma w nich ANI JEDNEJ udanej kopii - co jest
  /// czyms innym niz "nie udalo sie odczytac" i musi brzmiec inaczej.
  func testBrakJakiejkolwiekKopiiOdbieraZielonyZnaczek() {
    let status = zdrowy()
    status.backupCycle = BackupCycleStatus(known: true, lastSuccess: nil, checkedAt: Date())
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Nie ma ani jednej ukończonej kopii")
  }
}
