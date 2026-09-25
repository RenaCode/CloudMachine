import XCTest

@testable import CloudMachineCore

/// Wiersze `drive-status`. To jest tekst, ktory czlowiek CZYTA, pytajac "czy
/// backup dziala" - a psul sie dotad dokladnie tam, gdzie brak danych
/// zamieniano na jakas wartosc.
final class StatusLinesTests: XCTestCase {

  // MARK: - Montowanie

  func testZamontowaneINiezamontowane() {
    XCTAssertEqual(StatusLines.mounted(true), "OK")
    XCTAssertEqual(StatusLines.mounted(false), "BRAK")
  }

  /// „BRAK" znaczy „sprawdzilem i nie ma". Przy nieudanym odczycie tablicy
  /// montowan nikt nie ma prawa wyciagnac tego wniosku - a na tej odpowiedzi
  /// stoi decyzja o podpieciu obrazu.
  func testNieodczytanaTablicaToNieBrakMontowania() {
    let linia = StatusLines.mounted(nil)
    XCTAssertNotEqual(linia, "BRAK")
    XCTAssertNotEqual(linia, "OK")
    XCTAssertTrue(linia.contains("NIE WIADOMO"), "dostalem: \(linia)")
  }

  // MARK: - Wolne miejsce

  func testZmierzoneWolneMiejsceJestLiczba() {
    XCTAssertEqual(StatusLines.freeDisk(427), "427 GB")
  }

  /// Regresja z 23 wrzesnia 2026: po zmianie `BufferGuardService.freeGB()` na
  /// `Int?` wiersz wypisywal `Wolne na dysku: Optional(427) GB`. Kompilator
  /// zglaszal to ostrzezeniem, nie bledem, wiec ani build, ani testy tego nie
  /// zatrzymaly.
  func testBrakPomiaruNieWypisujeOptional() {
    let linia = StatusLines.freeDisk(nil)
    XCTAssertFalse(linia.contains("Optional"), "dostalem: \(linia)")
    XCTAssertFalse(linia.contains("nil"), "dostalem: \(linia)")
  }

  /// Zero to KONKRETNA liczba, na ktorej dozorca wstrzymuje Time Machine -
  /// podstawienie go za brak pomiaru bylo pierwotnym bledem, ktory drugi agent
  /// naprawial zmiana typu. Wiersz nie moze go przywrocic tylnymi drzwiami.
  func testBrakPomiaruToNieZero() {
    XCTAssertNotEqual(StatusLines.freeDisk(nil), StatusLines.freeDisk(0))
    XCTAssertEqual(StatusLines.freeDisk(0), "0 GB")
  }

  func testBrakPomiaruJestNAZWANY() {
    let linia = StatusLines.freeDisk(nil)
    XCTAssertTrue(linia.contains("NIE ZMIERZONO"), "dostalem: \(linia)")
    XCTAssertTrue(
      linia.contains("dozorca"),
      "wiersz ma powiedziec, CO z tego wynika - ze dysk nie jest chroniony. Dostalem: \(linia)")
  }

  // MARK: - Niedoreczony alarm

  func testBrakNiedoreczonegoAlarmuNicNieWypisuje() {
    XCTAssertEqual(StatusLines.undeliveredAlert(nil), [])
  }

  /// Sens poprawki w `HealthAlert`: nieudane powiadomienie ma dac sie ZOBACZYC.
  /// Dopoki `drive-status` o tym milczal, alarm istnial tylko w pliku stanu.
  func testNiedoreczonyAlarmJestWidoczny() {
    let kiedy = Date(timeIntervalSince1970: 1_790_000_000)
    let linie = StatusLines.undeliveredAlert(
      (at: kiedy, summary: "Backup nie powstal od 30 h", reason: "osascript kod 1: brak uprawnien"))

    let tekst = linie.joined(separator: "\n")
    XCTAssertTrue(tekst.contains("NIEDORECZONY ALARM"), tekst)
    XCTAssertTrue(tekst.contains("Backup nie powstal od 30 h"), "tresc alarmu ma byc widoczna")
    XCTAssertTrue(tekst.contains("brak uprawnien"), "powod niedoreczenia ma byc widoczny")
    XCTAssertTrue(
      tekst.contains(BackupHealth.stamp(kiedy)),
      "bez daty nie wiadomo, czy alarm jest swiezy, czy sprzed tygodnia")
  }

  // MARK: - Cache a zaleglosc: DWIE rozne wielkosci

  /// Jeden wiersz "Bufor: 103 GB z 100G" odpowiadal na pytanie, na ktore nie
  /// umial odpowiedziec: czy wysylka nadaza. Cache stoi pod limitem stale,
  /// a o zaleglosci mowi dopiero drugi wiersz - dlatego sa dwa.
  func testCacheIZaleglocSaOsobnymiWierszami() {
    XCTAssertEqual(StatusLines.cacheSize(103, limitGB: 100), "103 GB z 100G")
    XCTAssertEqual(StatusLines.backlog(14, items: 462), "~14 GB (462 pozycji)")
  }

  /// "~" nie jest ozdoba: gigabajty zaleglosci sa SZACOWANE z liczby pozycji,
  /// a liczba pozycji jest pomiarem. Wiersz podajacy szacunek jako pomiar
  /// ukrywa, jak mocna jest podstawa decyzji o wstrzymaniu backupu.
  func testZaleglocJestOznaczonaJakoSzacunekIPodajePomiar() {
    let linia = StatusLines.backlog(14, items: 462)
    XCTAssertTrue(linia.hasPrefix("~"), "dostalem: \(linia)")
    XCTAssertTrue(linia.contains("462"), "dostalem: \(linia)")
  }

  /// Brak odpowiedzi rclone nie moze wygladac na zero ani na "Optional(0)".
  func testBrakOdpowiedziRcloneJestNazwanyWObuWierszach() {
    let cache = StatusLines.cacheSize(nil, limitGB: 100)
    XCTAssertTrue(cache.contains("NIE ZMIERZONO"), "dostalem: \(cache)")
    XCTAssertFalse(cache.contains("0 GB"), "dostalem: \(cache)")

    let zaleglosc = StatusLines.backlog(nil, items: nil)
    XCTAssertTrue(zaleglosc.contains("NIE WIADOMO"), "dostalem: \(zaleglosc)")
    XCTAssertFalse(zaleglosc.contains("Optional"), "dostalem: \(zaleglosc)")
    XCTAssertFalse(zaleglosc.contains("~0"), "dostalem: \(zaleglosc)")
  }
}
