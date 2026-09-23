import XCTest

@testable import CloudMachineCore

/// Testy samego ALARMU, a nie czujki.
///
/// Do 23.09.2026 `HealthAlert` nie mial ani jednego testu, mimo ze to on
/// decyduje, czy ktokolwiek dowie sie o awarii backupu. Obie naprawione tu
/// usterki sa tego samego rodzaju: alarm uznawal sie za zglosony, choc nikt
/// go nie zobaczyl.
final class HealthAlertTests: XCTestCase {

  private var katalog: URL!
  private var plikStanu: URL!

  override func setUpWithError() throws {
    katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-health-alert-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    plikStanu = katalog.appendingPathComponent("health-alert.json")
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: katalog)
  }

  private func raport(_ summaries: [String], lastSuccess: Date? = nil) -> BackupHealth.Report {
    BackupHealth.Report(
      problems: summaries.map { BackupHealth.Problem(summary: $0, detail: "szczegoly") },
      lastSuccess: lastSuccess, lastAttempt: nil)
  }

  // MARK: - Punkt 6: nieudane powiadomienie nie jest zgloszeniem

  /// TA awaria. `osascript` pada (odmowa uprawnien dla procesu launchd, brak
  /// sesji Aqua, limit czasu), a `report()` i tak zapisywalo `lastSummary`
  /// i `lastAlertAt` oraz zwracalo `true`. Od tej chwili `shouldAlert`
  /// blokowalo kolejne proby na 12 godzin - alarm ginal po cichu, czyli
  /// nadzor ginal razem z nadzorowanym.
  func testNieudanePowiadomienieNieUciszaAlarmu() async {
    let problemy = raport(["Brak udanej kopii od 5 h"])

    let pierwsze = await HealthAlert.report(
      problemy, now: Date(), stateFile: plikStanu, deliver: { _, _ in false })
    XCTAssertFalse(pierwsze, "Zgloszenie, ktorego nikt nie zobaczyl, nie jest zgloszeniem.")

    // Piec minut pozniej, ten sam problem: MUSI sprobowac jeszcze raz,
    // a nie czekac 12 godzin.
    let sprobowanoPonownie = LicznikProb()
    let drugie = await HealthAlert.report(
      problemy, now: Date().addingTimeInterval(300), stateFile: plikStanu,
      deliver: { _, _ in
        sprobowanoPonownie.zwieksz()
        return true
      })
    XCTAssertEqual(sprobowanoPonownie.ile, 1, "Po nieudanej probie alarm ma wrocic.")
    XCTAssertTrue(drugie)
  }

  /// Nieudane doreczenie ma byc WIDOCZNE - alarmu, ktory nie doszedl, nikt
  /// nie zauwazy z definicji, wiec musi dac sie go zobaczyc tam, gdzie
  /// czlowiek zaglada sam (`drive-status`).
  func testNieudaneDoreczenieDaSieOdczytac() async {
    let kiedy = Date(timeIntervalSince1970: 1_758_000_000)
    await HealthAlert.report(
      raport(["Obraz backupu nie jest podpiety"]), now: kiedy, stateFile: plikStanu,
      deliver: { _, _ in false })

    let awaria = HealthAlert.lastDeliveryFailure(stateFile: plikStanu)
    XCTAssertNotNil(awaria)
    XCTAssertEqual(awaria?.at, kiedy)
    XCTAssertEqual(awaria?.summary, "Obraz backupu nie jest podpiety")

    // Po udanym doreczeniu slad znika - inaczej wisialby tam na zawsze.
    await HealthAlert.report(
      raport(["Obraz backupu nie jest podpiety"]), now: kiedy.addingTimeInterval(3600),
      stateFile: plikStanu, deliver: { _, _ in true })
    XCTAssertNil(HealthAlert.lastDeliveryFailure(stateFile: plikStanu))
  }

  // MARK: - Punkt 8: odstep miedzy przypomnieniami

  /// TA usterka. Tekst problemu zawiera wiek awarii ("Brak udanej kopii od
  /// 3 h"), wiec przy trwajacej awarii zmienial sie CO GODZINE. Warunek
  /// "inny tekst = nowy problem" byl wtedy spelniony przy kazdym przebiegu
  /// i powiadomienie wracalo co godzine zamiast raz na dwanascie - a alarm
  /// bez odstepu zamienia sie w szum i przestaje cokolwiek znaczyc.
  func testRosnacyWiekAwariiNieJestNowymProblemem() async {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    let doreczone = await HealthAlert.report(
      raport(["Brak udanej kopii od 3 h"]), now: start, stateFile: plikStanu,
      deliver: { _, _ in true })
    XCTAssertTrue(doreczone)

    // Godzine pozniej ta sama awaria opisuje sie innym tekstem.
    let licznik = LicznikProb()
    let znowu = await HealthAlert.report(
      raport(["Brak udanej kopii od 4 h"]), now: start.addingTimeInterval(3600),
      stateFile: plikStanu,
      deliver: { _, _ in
        licznik.zwieksz()
        return true
      })
    XCTAssertEqual(licznik.ile, 0, "To ta sama awaria, tylko starsza - nie alarmujemy od nowa.")
    XCTAssertFalse(znowu)
  }

  /// Po okresie przypomnienia ta sama awaria ma sie odezwac ponownie -
  /// inaczej alarm zapala sie raz i gasnie na zawsze.
  func testPoOkresiePrzypomnieniaTaSamaAwariaWraca() {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    zapisz(identity: HealthAlert.identity(of: raport(["Brak udanej kopii od 3 h"]).problems), at: start)

    let odcisk = HealthAlert.identity(of: raport(["Brak udanej kopii od 15 h"]).problems)
    XCTAssertFalse(
      HealthAlert.shouldAlert(
        identity: odcisk, now: start.addingTimeInterval(11 * 3600), stateFile: plikStanu),
      "Przed uplywem 12 h milczymy.")
    XCTAssertTrue(
      HealthAlert.shouldAlert(
        identity: odcisk, now: start.addingTimeInterval(13 * 3600), stateFile: plikStanu),
      "Po 12 h przypominamy - awaria trwa, dopoki ktos jej nie naprawi.")
  }

  /// NOWY problem dolozony do listy musi zaalarmowac od razu, bez czekania na
  /// okno przypomnienia. Bez tego testu "naprawa" uciszajaca wszystko na
  /// 12 godzin przeszlaby niezauwazona.
  func testNowyProblemAlarmujeOdRazu() {
    let start = Date(timeIntervalSince1970: 1_758_000_000)
    zapisz(identity: HealthAlert.identity(of: raport(["Brak udanej kopii od 3 h"]).problems), at: start)

    let dwaProblemy = HealthAlert.identity(
      of: raport(["Brak udanej kopii od 4 h", "Obraz backupu nie jest podpiety"]).problems)
    XCTAssertTrue(
      HealthAlert.shouldAlert(
        identity: dwaProblemy, now: start.addingTimeInterval(600), stateFile: plikStanu))
  }

  /// Sam odcisk: liczby znikaja, tresc zostaje.
  func testOdciskWycinaLiczbyAleNieTresc() {
    XCTAssertEqual(
      HealthAlert.fingerprint("Brak udanej kopii od 3 h"),
      HealthAlert.fingerprint("Brak udanej kopii od 27 h"))
    XCTAssertNotEqual(
      HealthAlert.fingerprint("Brak udanej kopii od 3 h"),
      HealthAlert.fingerprint("Obraz backupu nie jest podpiety"))
    // Dwa RONE problemy roznia sie tylko liczba w nawiasie - to nadal ten
    // sam rodzaj awarii i nie ma powodu alarmowac od nowa przy kazdym GB.
    XCTAssertEqual(
      HealthAlert.fingerprint("Konczy sie miejsce na Google Drive (28 GB)"),
      HealthAlert.fingerprint("Konczy sie miejsce na Google Drive (12 GB)"))
  }

  /// Wyzdrowienie kasuje stan, zeby nastepna awaria zglosila sie od razu.
  func testWyzdrowienieKasujeStan() async {
    await HealthAlert.report(
      raport(["Brak udanej kopii od 3 h"]), stateFile: plikStanu, deliver: { _, _ in true })
    XCTAssertTrue(FileManager.default.fileExists(atPath: plikStanu.path))

    await HealthAlert.report(raport([]), stateFile: plikStanu, deliver: { _, _ in true })
    XCTAssertFalse(FileManager.default.fileExists(atPath: plikStanu.path))
  }

  // MARK: - Pomocnicze

  private func zapisz(identity: String, at date: Date) {
    let stan = HealthAlert.AlertState(
      lastSummary: "nieistotne", lastAlertAt: date, lastIdentity: identity, delivered: true,
      deliveryError: nil)
    let dane = try! JSONEncoder().encode(stan)
    try! dane.write(to: plikStanu)
  }

  /// Licznik prob doreczenia. Klasa, bo domkniecie `deliver` jest `@Sendable`.
  private final class LicznikProb: @unchecked Sendable {
    private let lock = NSLock()
    private var licznik = 0
    func zwieksz() {
      lock.lock()
      licznik += 1
      lock.unlock()
    }
    var ile: Int {
      lock.lock()
      defer { lock.unlock() }
      return licznik
    }
  }
}
