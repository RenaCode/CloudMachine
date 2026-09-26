import XCTest

@testable import CloudMachineCore

/// Testy czujki cyklu backupu.
///
/// Kazdy z nich WSTRZYKUJE ZNANA ZLA PROBKE i sprawdza, ze czujka to ZGLASZA.
/// Cisza detektora niczego nie dowodzi - wczesniej caly "monitoring" tego
/// projektu polegal na tym, ze nikt nie widzial ostrzezenia, i to uchodzilo za
/// dowod, ze wszystko dziala.
final class BackupHealthTests: XCTestCase {

  private let now = Date(timeIntervalSince1970: 1_757_700_000)

  /// Wszystko sprawne - punkt odniesienia. Bez niego test "wykrywa awarie"
  /// przechodzilby tez dla czujki, ktora krzyczy zawsze.
  private func healthyInput(
    lastSuccess: Date? = nil,
    lastAttempt: Date? = nil,
    result: Int? = 0,
    mounted: Bool = true,
    attached: Bool? = true,
    destinationRegistered: Bool = true,
    erroredFiles: Int = 0,
    outOfSpace: Bool = false,
    queueReadable: Bool = true,
    imageProbeTimedOut: Bool = false
  ) -> BackupHealth.Report {
    BackupHealth.evaluate(
      lastSuccess: lastSuccess ?? now.addingTimeInterval(-1800),
      lastAttempt: lastAttempt ?? now.addingTimeInterval(-1800),
      result: result,
      now: now,
      mounted: mounted,
      attached: attached,
      destinationRegistered: destinationRegistered,
      erroredFiles: erroredFiles,
      outOfSpace: outOfSpace,
      queueReadable: queueReadable,
      imageProbeTimedOut: imageProbeTimedOut)
  }

  /// Sonda czytelnosci nie odpowiedziala w czasie. To NIE jest "obraz nie jest
  /// podpiety" (obraz siedzi w tablicy montowan) i NIE jest "obraz MARTWY"
  /// (urzadzenie nie odpowiedzialo wcale, a nie bledem). Pierwszy komunikat
  /// wyslalby czlowieka podpinac cos, co jest podpiete; drugi - odpinac NA
  /// SILE urzadzenie, ktore moze byc zywe i trzymac niewyslane dane.
  ///
  /// Najwazniejsze jednak jest to, ze czujka W OGOLE tu dociera: przed
  /// poprawka ten odczyt nie mial limitu czasu, a `StartInterval 1800` bez
  /// `KeepAlive` znaczy, ze jedno zawieszenie uciszalo czujke NA STALE.
  func testSondaBezOdpowiedziJestZglaszanaJakoBrakWiedzy() {
    let report = healthyInput(attached: nil, imageProbeTimedOut: true)
    XCTAssertFalse(report.healthy, "cisza o stanie, ktorego nie znamy, jest tu awaria")
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("oddaje dane") },
      "czujka ma DOKONCZYC przebieg i zglosic brak wiedzy: \(report.problems)")
    XCTAssertFalse(report.problems.contains { $0.summary.contains("nie jest podpiety") })
    XCTAssertFalse(report.problems.contains { $0.summary.contains("MARTWY") })
  }

  /// Dwie przyczyny "nie wiem" wysylaja czlowieka w dwa rozne miejsca, wiec
  /// nie moga dostac tego samego zdania.
  func testDwiePrzyczynyBrakuWiedzyOObrazieMajaRozneKomunikaty() {
    let sonda = healthyInput(attached: nil, imageProbeTimedOut: true).problems
    let tablica = healthyInput(attached: nil).problems
    XCTAssertNotEqual(sonda, tablica)
    XCTAssertFalse(sonda.isEmpty)
    XCTAssertFalse(tablica.isEmpty)
  }

  /// Obraz w tablicy montowan, ale odczyt pada - 22 wrz 2026 przez 15 h zaden
  /// czujnik nie mial dla tego stanu nazwy. Teraz ma.
  func testMartwyObrazAlarmuje() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, imageDeadErrno: ENXIO)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("MARTWY") })
    XCTAssertFalse(
      report.problems.contains { $0.summary.contains("nie jest podpiety") },
      "Martwy to inny stan niz niepodpiety - jeden alarm, nie dwa.")
  }

  func testSprawnyCyklNieAlarmuje() {
    XCTAssertTrue(healthyInput().healthy, "Czujka, ktora alarmuje zawsze, nie niesie informacji.")
  }

  // MARK: - Znane zle probki

  /// TO jest awaria, ktorej caly dotychczasowy system NIE wykrywal:
  /// montowanie stoi, obraz podpiety, cel zarejestrowany - a kopia nie
  /// powstala od dwoch dni. Interfejs pokazywal wtedy zielony znaczek.
  func testCichaAwariaCykluJestZglaszana() {
    let report = healthyInput(
      lastSuccess: now.addingTimeInterval(-48 * 3600),
      lastAttempt: now.addingTimeInterval(-48 * 3600))
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("Brak udanej kopii") },
      "Wiek ostatniej UDANEJ kopii to jedyny licznik, ktory rosnie tylko przy sukcesie.")
  }

  /// Proba nowsza niz sukces = backup ruszyl i padl. Sam prog wieku tego nie
  /// zlapie, dopoki nie minie - a ten sygnal jest dostepny od razu.
  func testProbaBezSukcesuJestZglaszana() {
    let report = healthyInput(
      lastSuccess: now.addingTimeInterval(-2 * 3600),
      lastAttempt: now.addingTimeInterval(-90 * 60))
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("nie skonczyla sie kopia") })
  }

  func testNiezerowyResultJestZglaszany() {
    let report = healthyInput(result: 27)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("RESULT=27") })
  }

  /// Pasma, ktorych rclone nie wyslal, istnieja tylko na tym Macu. Kopia na
  /// Dysku jest wtedy NIEPELNA i moze sie nie otworzyc.
  func testNiewyslanePlikiSaZglaszane() {
    let report = healthyInput(erroredFiles: 12)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("12 plikow") })
  }

  func testBrakMontowaniaJestZglaszany() {
    XCTAssertTrue(
      healthyInput(mounted: false).problems.contains { $0.summary.contains("Montowanie") })
  }

  func testNiepodpietyObrazJestZglaszany() {
    XCTAssertTrue(
      healthyInput(attached: false).problems.contains { $0.summary.contains("nie jest podpiety") })
  }

  func testPrzestawionyCelTimeMachineJestZglaszany() {
    XCTAssertTrue(
      healthyInput(destinationRegistered: false).problems.contains {
        $0.summary.contains("nie wskazuje")
      })
  }

  func testPelnyBuforJestZglaszany() {
    XCTAssertTrue(healthyInput(outOfSpace: true).problems.contains { $0.summary.contains("Bufor") })
  }

  /// Brak odczytu ze stanu kolejki NIE moze uchodzic za "wszystko dobrze" -
  /// przy pytaniu o bezpieczenstwo danych milczenie musi znaczyc "nie wiem",
  /// a "nie wiem" traktujemy jak awarie.
  func testNieczytelnaKolejkaJestZglaszana() {
    XCTAssertTrue(
      healthyInput(queueReadable: false).problems.contains { $0.summary.contains("rclone") })
  }

  /// Brak JAKIEJKOLWIEK udanej kopii to nie to samo co swieza kopia - a przy
  /// naiwnym porownaniu dat `nil` latwo wpada w "nie przekroczono progu".
  func testBrakJakiejkolwiekKopiiJestZglaszany() {
    let report = BackupHealth.evaluate(
      lastSuccess: nil, lastAttempt: nil, result: 0, now: now, mounted: true, attached: true,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("ANI JEDNEJ") })
  }

  // MARK: - Odczyt preferencji Time Machine

  /// Ksztalt odwzorowany z prawdziwego
  /// `/Library/Preferences/com.apple.TimeMachine.plist` na dzialajacej
  /// instalacji: `SnapshotDates` dostaje wpis dopiero po ZAKONCZONYM backupie,
  /// `AttemptDates` liczy takze te, ktore padly.
  private func preferences(volumeName: String = "CloudMachine") -> [String: Any] {
    [
      "Destinations": [
        [
          "LastKnownVolumeName": "JakisInnyDysk",
          "SnapshotDates": [Date(timeIntervalSince1970: 1)],
          "AttemptDates": [Date(timeIntervalSince1970: 1)],
          "RESULT": NSNumber(value: 5),
        ],
        [
          "LastKnownVolumeName": volumeName,
          "SnapshotDates": [
            Date(timeIntervalSince1970: 1_757_600_000),
            Date(timeIntervalSince1970: 1_757_698_000),
          ],
          "AttemptDates": [Date(timeIntervalSince1970: 1_757_699_000)],
          "RESULT": NSNumber(value: 0),
        ],
      ]
    ]
  }

  func testOdczytBierzeNAJNOWSZAKopie() {
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "CloudMachine")
    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1_757_698_000))
    XCTAssertEqual(lastAttempt, Date(timeIntervalSince1970: 1_757_699_000))
    XCTAssertEqual(result, 0)
  }

  /// Mac moze miec wiecej niz jeden zarejestrowany cel Time Machine. Branie
  /// pierwszego z brzegu czytaloby cudze daty - i pokazywaloby cudzy sukces
  /// jako nasz.
  func testOdczytWybieraWlasciwyCelPoNazwieWolumenu() {
    let (lastSuccess, _, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "JakisInnyDysk")
    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1))
    XCTAssertEqual(result, 5)
  }

  func testOdczytNieZgadujePrzyBrakuNaszegoCelu() {
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "CalkiemInny")
    XCTAssertNil(lastSuccess)
    XCTAssertNil(lastAttempt)
    XCTAssertNil(result)
  }

  /// Domyka luke miedzy PLIKIEM a ocena: zapis do pliku, odczyt tak samo jak
  /// robi to `currentReport`, i dopiero potem `dates`. Testy na samym
  /// `evaluate` nie pokrywaja serializacji, a to wlasnie tam "czujka milczy"
  /// wyglada identycznie jak "wszystko dobrze".
  func testOdczytPrzezPrawdziwyPlikPlistDajeTeSameDaty() throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-health-\(UUID().uuidString).plist")
    defer { try? FileManager.default.removeItem(at: url) }

    let data = try PropertyListSerialization.data(
      fromPropertyList: preferences(), format: .binary, options: 0)
    try data.write(to: url)

    let raw = try Data(contentsOf: url)
    let parsed = try XCTUnwrap(
      PropertyListSerialization.propertyList(from: raw, format: nil) as? [String: Any])
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: parsed, volumeNamed: "CloudMachine")

    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1_757_698_000))
    XCTAssertEqual(lastAttempt, Date(timeIntervalSince1970: 1_757_699_000))
    XCTAssertEqual(result, 0)
  }

  /// Nieczytelny plik NIE moze wygladac jak zdrowy cykl.
  func testNieczytelnyPlikNiePrzechodziZaSukces() async {
    let report = await BackupHealth.currentReport(
      preferencesFile: "/nie/ma/takiego/pliku.plist")
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("preferencji Time Machine") })
  }

  // MARK: - Zglaszanie

  /// Komunikat z cudzyslowem musi przejsc przez AppleScript bez rozwalenia
  /// skryptu - inaczej alarm ginie po cichu, czyli zachowuje sie dokladnie
  /// tak jak awaria, ktora mial zglosic. Komunikaty rclone cudzyslowy maja.
  func testCudzyslowWKomunikacieNieRozwalaPowiadomienia() {
    XCTAssertEqual(
      HealthAlert.appleScriptLiteral("Post \"https://x\" anulowano"),
      "\"Post \\\"https://x\\\" anulowano\"")
  }

  func testOdwrotnyUkosnikTezJestUciekany() {
    XCTAssertEqual(HealthAlert.appleScriptLiteral("a\\b"), "\"a\\\\b\"")
  }

  func testNowaLiniaNieRozwalaPowiadomienia() {
    XCTAssertFalse(HealthAlert.appleScriptLiteral("a\nb").contains("\n"))
  }

  // MARK: - Ustalenie 15c: Pelny dostep do dysku sprawdza sie PROBUJAC

  /// ZNANA ZLA PROBKA: katalog. `FileManager.isReadableFile(atPath:)` -
  /// czyli `access(R_OK)` - mowi o katalogu "czytelny", a odczytac go jako plik
  /// nie da sie wcale. Interfejs pytal dokladnie tak i dokladnie o katalog
  /// (`~/Library/Application Support/com.apple.TCC`), wiec odpowiadal "Pelny
  /// dostep jest" niezaleznie od stanu uprawnien - w tym w chwili, w ktorej
  /// czujka nie mogla odczytac ani jednej daty kopii.
  ///
  /// Do TCC nie ma pytania, jest tylko proba. Ten test porownuje oba sposoby na
  /// tej samej sciezce.
  func testKatalogNieDowodziCzytelnosciPliku() throws {
    let katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-fda-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: katalog) }

    XCTAssertTrue(
      FileManager.default.isReadableFile(atPath: katalog.path),
      "access(R_OK) na katalogu mowi 'czytelny' - i to bylo cale dawne sprawdzenie")
    XCTAssertFalse(
      BackupHealth.preferencesReadable(preferencesFile: katalog.path),
      "realny odczyt musi powiedziec NIE - katalog nie jest plistem z historia kopii")
  }

  /// Plik, ktorego nie ma, to brak dostepu do jego tresci - a nie milczenie.
  func testBrakPlikuToBrakDostepu() {
    XCTAssertFalse(
      BackupHealth.preferencesReadable(
        preferencesFile: "/nie-ma-takiej-sciezki/com.apple.TimeMachine.plist"))
  }

  /// I odwrotny blad: czytelny plik MUSI wychodzic jako czytelny, inaczej panel
  /// straszylby brakiem uprawnien na sprawnej maszynie.
  func testCzytelnyPlikWychodziJakoCzytelny() throws {
    let plik = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-fda-\(UUID().uuidString).plist")
    try Data("cokolwiek".utf8).write(to: plik)
    defer { try? FileManager.default.removeItem(at: plik) }
    XCTAssertTrue(BackupHealth.preferencesReadable(preferencesFile: plik.path))
  }
}
