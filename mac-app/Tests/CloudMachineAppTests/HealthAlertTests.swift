import XCTest

@testable import CloudMachineCore

/// Testy samego ALARMU, a nie czujki.
///
/// Do 23.09.2026 `HealthAlert` nie mial ani jednego testu, mimo ze to on
/// decyduje, czy ktokolwiek dowie sie o awarii backupu. Obie naprawione tu
/// usterki sa tego samego rodzaju: alarm uznawal sie za zglosony, choc nikt
/// go nie zobaczyl.
///
/// Kazdy test PODSTAWIA dziennik (`log:`) - patrz `zglos(_:now:deliver:)`.
/// Wyjatek jest jeden i celowy: `testPrawdziwyPrzebiegNadalPiszeDoDziennika`,
/// ktory musi uzyc prawdziwego, zeby udowodnic, ze podstawienie nie uciszylo
/// produkcji.
final class HealthAlertTests: XCTestCase {

  private var katalog: URL!
  private var plikStanu: URL!
  private var dziennik: PrzechwyconyDziennik!

  override func setUpWithError() throws {
    katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-health-alert-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    plikStanu = katalog.appendingPathComponent("health-alert.json")
    dziennik = PrzechwyconyDziennik()
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: katalog)
  }

  private func raport(_ summaries: [String], lastSuccess: Date? = nil) -> BackupHealth.Report {
    BackupHealth.Report(
      problems: summaries.map { BackupHealth.Problem(summary: $0, detail: "szczegoly") },
      lastSuccess: lastSuccess, lastAttempt: nil)
  }

  /// `HealthAlert.report` z podstawionym plikiem stanu I podstawionym
  /// dziennikiem. Wolamy to zamiast `HealthAlert.report` wprost, zeby nie dalo
  /// sie dopisac testu, ktory przez zapomnienie jednego argumentu znow zacznie
  /// zasmiecac produkcyjny `cloudmachine.log`.
  @discardableResult
  private func zglos(
    _ report: BackupHealth.Report, now: Date = Date(),
    deliver: @escaping @Sendable (String, String) async -> Bool
  ) async -> Bool {
    await HealthAlert.report(
      report, now: now, stateFile: plikStanu, deliver: deliver, log: dziennik.zapisz)
  }

  // MARK: - Ustalenie 3: testy nie pisza do produkcyjnego dziennika

  /// TA usterka. `report()` logowalo przez `CMLogger.log(...)` na sztywno,
  /// wiec podstawic dalo sie plik stanu i doreczenie, ale nie dziennik.
  /// Zmierzone 25.09.2026: `~/Library/Logs/CloudMachine/cloudmachine.log`
  /// zawieral 117 linii ze slowem "szczegoly", ktore pochodzi wylacznie
  /// z `raport(_:)` powyzej - wszystkie z jednego dnia, czyli z przebiegow
  /// `swift test`. Produkcyjny dziennik jest jedynym sladem po awariach
  /// backupu i przestal pozwalac odroznic zdarzenia prawdziwe od testowych.
  func testZgloszenieZPodstawionymDziennikiemNieDotykaProdukcyjnego() async {
    let znacznik = "CM-TEST-\(UUID().uuidString)"
    XCTAssertEqual(
      liniiWProdukcyjnymDzienniku(z: znacznik), 0,
      "znacznik jest swiezym UUID - przed testem nie moze go tam byc")

    let doreczone = await zglos(
      raport(["Brak udanej kopii od 5 h \(znacznik)"]), deliver: { _, _ in false })
    XCTAssertFalse(doreczone)

    // Tresc MA powstac - tylko nie w produkcyjnym pliku. Gdyby zniknela,
    // "naprawa" polegalaby na uciszeniu alarmu, a nie na przekierowaniu go.
    XCTAssertTrue(
      dziennik.linie.contains { $0.contains(znacznik) },
      "podstawiony dziennik ma dostac tresc zgloszenia: \(dziennik.linie)")
    XCTAssertTrue(
      dziennik.linie.contains { $0.contains("NIE UDALO SIE pokazac powiadomienia") },
      "nieudane doreczenie tez musi byc zapisane - tam, gdzie test je widzi")

    XCTAssertEqual(
      liniiWProdukcyjnymDzienniku(z: znacznik), 0,
      "test nie moze dopisac ani jednej linii do \(CMPaths.combinedLogFile.path)")
  }

  /// Druga strona tej samej poprawki - i jedyny test w tej klasie, ktory
  /// SWIADOMIE pisze do produkcyjnego dziennika (jedna linia, oznaczona jako
  /// kanarka).
  ///
  /// Bez tego testu poprawka mogla uciszyc PRAWDZIWE alarmy i nikt by tego nie
  /// zauwazyl: awaria backupu nie przeszkadza w codziennej pracy, a dziennik
  /// jest jedynym sladem, po ktorym da sie ja pozniej odtworzyc. Cisza w logu
  /// wygladalaby dokladnie tak samo jak dzialajacy backup.
  func testPrawdziwyPrzebiegNadalPiszeDoDziennika() async throws {
    let znacznik = "KANARKA-TESTU-\(UUID().uuidString)"
    let kanarka = BackupHealth.Report(
      problems: [
        BackupHealth.Problem(
          summary: "to nie byla awaria, to kanarka testu \(znacznik)",
          detail:
            "linie dopisal HealthAlertTests, zeby dowiesc, ze zgloszenie bez podstawionego dziennika nadal trafia do cloudmachine.log"
        )
      ], lastSuccess: nil, lastAttempt: nil)

    XCTAssertEqual(liniiWProdukcyjnymDzienniku(z: znacznik), 0)

    // `log:` NIE jest podstawiane - to sedno testu. `deliver:` jest, i tylko
    // dlatego, ze inaczej na ekranie uzytkownika wyskoczyloby powiadomienie
    // o awarii, ktorej nie ma; zwracamy `true`, zeby nie doszla do dziennika
    // druga linia (o nieudanym doreczeniu).
    await HealthAlert.report(
      kanarka, stateFile: plikStanu, deliver: { _, _ in true })

    XCTAssertEqual(
      liniiWProdukcyjnymDzienniku(z: znacznik), 1,
      """
      Prawdziwe zgloszenie MUSI trafic do \(CMPaths.combinedLogFile.path). \
      Jesli tu jest 0, to poprawka uciszyla alarm zamiast go przekierowac.
      """)
  }

  /// Ile linii ogona produkcyjnego dziennika zawiera `znacznik`.
  ///
  /// Czytamy OGON, a nie caly plik: `CMLogger.rotateIfLarge` przycina go
  /// dopiero przy 200 MB, wiec wciagniecie calosci do pamieci w tescie to
  /// zaproszenie do testu, ktory z czasem zaczyna trwac sekundy. Znacznik jest
  /// swiezym UUID, wiec interesuja nas wylacznie linie dopisane w trakcie tego
  /// przebiegu - te zawsze sa na koncu.
  private func liniiWProdukcyjnymDzienniku(z znacznik: String) -> Int {
    let plik = CMPaths.combinedLogFile
    guard let handle = try? FileHandle(forReadingFrom: plik) else { return 0 }
    defer { try? handle.close() }
    let rozmiar = (try? handle.seekToEnd()) ?? 0
    let ogon: UInt64 = 256 * 1024
    try? handle.seek(toOffset: rozmiar > ogon ? rozmiar - ogon : 0)
    guard let dane = try? handle.readToEnd(), let tekst = String(data: dane, encoding: .utf8)
    else { return 0 }
    return tekst.split(separator: "\n").filter { $0.contains(znacznik) }.count
  }

  // MARK: - Punkt 6: nieudane powiadomienie nie jest zgloszeniem

  /// TA awaria. `osascript` pada (odmowa uprawnien dla procesu launchd, brak
  /// sesji Aqua, limit czasu), a `report()` i tak zapisywalo `lastSummary`
  /// i `lastAlertAt` oraz zwracalo `true`. Od tej chwili `shouldAlert`
  /// blokowalo kolejne proby na 12 godzin - alarm ginal po cichu, czyli
  /// nadzor ginal razem z nadzorowanym.
  func testNieudanePowiadomienieNieUciszaAlarmu() async {
    let problemy = raport(["Brak udanej kopii od 5 h"])

    let pierwsze = await zglos(problemy, deliver: { _, _ in false })
    XCTAssertFalse(pierwsze, "Zgloszenie, ktorego nikt nie zobaczyl, nie jest zgloszeniem.")

    // Piec minut pozniej, ten sam problem: MUSI sprobowac jeszcze raz,
    // a nie czekac 12 godzin.
    let sprobowanoPonownie = LicznikProb()
    let drugie = await zglos(
      problemy, now: Date().addingTimeInterval(300),
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
    await zglos(
      raport(["Obraz backupu nie jest podpiety"]), now: kiedy, deliver: { _, _ in false })

    let awaria = HealthAlert.lastDeliveryFailure(stateFile: plikStanu)
    XCTAssertNotNil(awaria)
    XCTAssertEqual(awaria?.at, kiedy)
    XCTAssertEqual(awaria?.summary, "Obraz backupu nie jest podpiety")

    // Po udanym doreczeniu slad znika - inaczej wisialby tam na zawsze.
    await zglos(
      raport(["Obraz backupu nie jest podpiety"]), now: kiedy.addingTimeInterval(3600),
      deliver: { _, _ in true })
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
    let doreczone = await zglos(
      raport(["Brak udanej kopii od 3 h"]), now: start, deliver: { _, _ in true })
    XCTAssertTrue(doreczone)

    // Godzine pozniej ta sama awaria opisuje sie innym tekstem.
    let licznik = LicznikProb()
    let znowu = await zglos(
      raport(["Brak udanej kopii od 4 h"]), now: start.addingTimeInterval(3600),
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
    zapisz(
      identity: HealthAlert.identity(of: raport(["Brak udanej kopii od 3 h"]).problems),
      at: start)

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
    zapisz(
      identity: HealthAlert.identity(of: raport(["Brak udanej kopii od 3 h"]).problems),
      at: start)

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
    await zglos(raport(["Brak udanej kopii od 3 h"]), deliver: { _, _ in true })
    XCTAssertTrue(FileManager.default.fileExists(atPath: plikStanu.path))

    await zglos(raport([]), deliver: { _, _ in true })
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

  /// Dziennik zbierany do pamieci. Klasa, bo domkniecie `log` jest `@Sendable`.
  private final class PrzechwyconyDziennik: @unchecked Sendable {
    private let lock = NSLock()
    private var zebrane: [String] = []

    /// Referencja do metody idzie wprost jako argument `log:`.
    func zapisz(_ linia: String) {
      lock.lock()
      zebrane.append(linia)
      lock.unlock()
    }

    var linie: [String] {
      lock.lock()
      defer { lock.unlock() }
      return zebrane
    }
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
