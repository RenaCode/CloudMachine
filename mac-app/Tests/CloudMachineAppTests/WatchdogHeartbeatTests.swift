import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Nadzor nad samym nadzorem: czy da sie odroznic "czujka przebiegla i nie
/// miala o czym donosic" od "czujki nie ma".
///
/// `backup-health` chodzi ze `StartInterval 1800` i BEZ `KeepAlive`, a jedynym
/// objawem wyladowanego albo zawieszonego agenta jest cisza - przy czym cisza
/// jest tu stanem NORMALNYM (README: "Empty logs after a fresh install are
/// normal - the agents only write when something happens"). Do 25.09.2026
/// czujka nie zostawiala po sobie zadnego sladu, wiec te dwa stany wygladaly
/// identycznie.
@MainActor
final class WatchdogHeartbeatTests: XCTestCase {

  private var katalog: URL!
  private var znacznik: URL!

  override func setUpWithError() throws {
    katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-heartbeat-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    // KAZDY test podstawia plik - zaden nie ma prawa dotknac prawdziwego
    // znacznika w `~/Library/Application Support/CloudMachine/`, bo wtedy
    // przebieg `swift test` meldowalby czujke, ktora nie chodzila.
    znacznik = katalog.appendingPathComponent("backup-health-last-run")
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: katalog)
  }

  // MARK: - Sam znacznik

  /// TA usterka: przed poprawka nie bylo CZEGO odczytac.
  func testPrzebiegZostawiaSladDoOdczytania() throws {
    let teraz = Date(timeIntervalSince1970: 1_790_000_000)
    XCTAssertTrue(WatchdogHeartbeat.record(now: teraz, file: znacznik))
    let odczytane = try XCTUnwrap(
      WatchdogHeartbeat.lastRun(file: znacznik),
      "znacznik ma sie dac odczytac z powrotem - inaczej nie mowi nic")
    XCTAssertEqual(
      odczytane.timeIntervalSince1970, teraz.timeIntervalSince1970, accuracy: 1)
  }

  /// Plik ma byc czytelny dla czlowieka w trakcie diagnozy, nie tylko dla nas.
  func testZnacznikJestCzytelnymTekstem() throws {
    WatchdogHeartbeat.record(now: Date(timeIntervalSince1970: 1_790_000_000), file: znacznik)
    let tresc = try String(contentsOf: znacznik, encoding: .utf8)
    XCTAssertTrue(tresc.hasPrefix("2026-"), "dostalem: \(tresc)")
  }

  /// Brak znacznika to NIE "czujka nie chodzi od zera sekund" i nie awaria
  /// odczytu - to trzeci, osobny stan. Zdarza sie na swiezej instalacji.
  func testBrakZnacznikaToOsobnyStan() {
    XCTAssertNil(WatchdogHeartbeat.lastRun(file: znacznik))
    XCTAssertEqual(WatchdogHeartbeat.current(file: znacznik), .never)
  }

  // MARK: - Ocena wieku

  func testSwiezyPrzebiegJestSwiezy() {
    let teraz = Date()
    let ocena = WatchdogHeartbeat.freshness(
      lastRun: teraz.addingTimeInterval(-600), now: teraz)
    guard case .fresh = ocena else { return XCTFail("dostalem: \(ocena)") }
  }

  /// Dwa pominiete przebiegi z rzedu (StartInterval 1800) to juz nie przypadek.
  func testCiszaDluzszaNizLimitToNieSwiezosc() {
    let teraz = Date()
    let ocena = WatchdogHeartbeat.freshness(
      lastRun: teraz.addingTimeInterval(-3 * 3600), now: teraz)
    guard case .stale(_, let wiek) = ocena else { return XCTFail("dostalem: \(ocena)") }
    XCTAssertEqual(wiek, 3 * 3600, accuracy: 1)
  }

  /// Znacznik z przyszlosci (przestawiony zegar, plik przeniesiony z innej
  /// maszyny) NIE jest swiezoscia: nie wiemy, kiedy czujka chodzila. Mylimy sie
  /// w strone ostrzezenia, nie w strone spokoju.
  func testZnacznikZPrzyszlosciNieUchodziZaSwiezy() {
    let teraz = Date()
    let ocena = WatchdogHeartbeat.freshness(
      lastRun: teraz.addingTimeInterval(3600), now: teraz)
    guard case .stale = ocena else { return XCTFail("dostalem: \(ocena)") }
  }

  // MARK: - Wiersz, ktory czlowiek CZYTA (drive-status i panel)

  func testWierszDlaSwiezegoPrzebieguPodajeDateIWiek() {
    let teraz = Date()
    let linia = StatusLines.watchdogRun(
      WatchdogHeartbeat.freshness(lastRun: teraz.addingTimeInterval(-720), now: teraz))
    XCTAssertTrue(linia.contains("12 min temu"), "dostalem: \(linia)")
    XCTAssertFalse(linia.contains("MOZE NIE CHODZIC"), "dostalem: \(linia)")
  }

  /// Sedno punktu 13: wiersz musi POWIEDZIEC, ze czujka mogla przestac chodzic.
  /// Sama data bez tego zdania niczego nie zaklóca - czlowiek przesuwa po niej
  /// wzrokiem tak samo jak po dacie sprzed dwoch minut.
  func testWierszDlaMilczacejCzujkiOstrzega() {
    let teraz = Date()
    let linia = StatusLines.watchdogRun(
      WatchdogHeartbeat.freshness(lastRun: teraz.addingTimeInterval(-3 * 24 * 3600), now: teraz))
    XCTAssertTrue(linia.contains("CZUJKA MOZE NIE CHODZIC"), "dostalem: \(linia)")
    XCTAssertTrue(linia.contains("3 dni temu"), "dostalem: \(linia)")
  }

  func testWierszBezZnacznikaMowiWprost() {
    let linia = StatusLines.watchdogRun(.never)
    XCTAssertTrue(linia.contains("NIGDY"), "dostalem: \(linia)")
    XCTAssertFalse(linia.contains("Optional"), "dostalem: \(linia)")
  }

  // MARK: - Panel

  /// Niesprawdzone nie ma prawa swiecic na zielono - tak samo jak `queueKnown`
  /// i `BackupCycleStatus.known`.
  func testPanelNieUznajeNiesprawdzonejCzujkiZaDzialajaca() {
    let status = AppStatus()
    XCTAssertNil(status.watchdog)
    XCTAssertFalse(status.watchdogRunning)

    status.watchdog = WatchdogHeartbeat.freshness(
      lastRun: Date().addingTimeInterval(-3 * 3600))
    XCTAssertFalse(status.watchdogRunning, "czujka milczaca 3 h to nie czujka dzialajaca")

    status.watchdog = WatchdogHeartbeat.freshness(lastRun: Date().addingTimeInterval(-300))
    XCTAssertTrue(status.watchdogRunning)
  }
}
