import Foundation
import XCTest

@testable import CloudMachineCore

/// Czy wpis dziennika jest w pliku ZARAZ po zalogowaniu, czy dopiero po 16 KiB.
///
/// Pod launchd stdout agenta jest PLIKIEM (`StandardOutPath` w kazdym
/// szablonie z `launchd/`), a dla pliku stdio wybiera buforowanie BLOKOWE.
/// Zmierzone 25.09.2026: `launchd-buffer-guard.out.log` mial dokladnie 16384
/// bajty i date 2026-09-20, podczas gdy proces `buffer-guard` (`while true` +
/// `KeepAlive`, wiec nigdy nie dochodzi do oproznienia bufora przy wyjsciu)
/// zyl od 2026-09-25. Plik konczyl sie w pol slowa, wiec wygladal dokladnie
/// jak proces, ktory umarl piatego dnia.
///
/// Test NIE wola `CMLogger.log`, tylko sam zapis na stdout. Powod jest taki
/// sam, jak przy `HealthAlert.log`: `CMLogger.log` dopisuje do prawdziwego
/// `~/Library/Logs/CloudMachine/cloudmachine.log`, a ten plik jest jedynym
/// sladem po awariach backupu i nie ma prawa zbierac linii z przebiegow
/// `swift test`.
final class CMLoggerFlushTests: XCTestCase {

  /// TA usterka. Buforowanie blokowe ustawiamy JAWNIE (`_IOFBF`), zamiast
  /// liczyc na to, ze srodowisko testu je wybierze - inaczej wynik zalezalby
  /// od tego, czy `swift test` odpalono z terminala (stdout = tty, buforowanie
  /// liniowe, usterki nie widac) czy z CI (stdout = potok). Test ma mierzyc
  /// nasz kod, nie to, gdzie go uruchomiono.
  func testWpisJestWPlikuNatychmiast() throws {
    let plik = try przekierowanyStdout()
    defer { przywrocStdout() }

    CMLogger.emitToStandardOutput("[2026-09-25 22:00:00] pierwsza linia dziennika\n")

    // Czytamy BEZ zadnego `fflush` z naszej strony - dokladnie tak, jak
    // czlowiek zagladajacy do pliku w trakcie zycia procesu.
    let tresc = (try? String(contentsOf: plik, encoding: .utf8)) ?? ""
    XCTAssertTrue(
      tresc.contains("pierwsza linia dziennika"),
      """
      Wpis zostal w buforze stdio. Pod launchd znaczy to, ze plik, do ktorego \
      czlowiek zaglada NAJPIERW, jest z tylu az do uzbierania 16 KiB - \
      a ostatnia jego linia jest urwana w pol slowa. Dostalem: \
      "\(tresc)" (\(tresc.utf8.count) bajtow)
      """)
  }

  /// Druga strona tej samej poprawki: tresc MA byc kompletna, nie tylko
  /// wczesna. `fflush` po kazdym wpisie nie moze gubic ani sklejac linii.
  func testKolejneWpisyLadujaWKolejnosciIWCalosci() throws {
    let plik = try przekierowanyStdout()
    defer { przywrocStdout() }

    for numer in 1...5 {
      CMLogger.emitToStandardOutput("linia \(numer)\n")
    }

    let tresc = (try? String(contentsOf: plik, encoding: .utf8)) ?? ""
    XCTAssertEqual(tresc, "linia 1\nlinia 2\nlinia 3\nlinia 4\nlinia 5\n")
  }

  // MARK: - Podmiana stdout na plik (czyli to, co robi launchd)

  private var zapasowyDeskryptor: Int32 = -1
  private var katalog: URL?

  /// Podstawia plik pod deskryptor 1 i WYMUSZA buforowanie blokowe - czyli
  /// odtwarza warunki z launchd wewnatrz procesu testowego.
  private func przekierowanyStdout() throws -> URL {
    let katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-logger-flush-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    self.katalog = katalog
    let plik = katalog.appendingPathComponent("launchd-udawany.out.log")
    FileManager.default.createFile(atPath: plik.path, contents: nil)

    // Wszystko, co juz czeka na prawdziwym stdout, wypychamy PRZED podmiana -
    // inaczej wyladowaloby w naszym pliku i udawalo nasz wpis.
    fflush(stdout)
    zapasowyDeskryptor = dup(1)
    let nowy = open(plik.path, O_WRONLY | O_APPEND)
    XCTAssertGreaterThanOrEqual(nowy, 0, "nie udalo sie otworzyc \(plik.path)")
    dup2(nowy, 1)
    close(nowy)
    setvbuf(stdout, nil, _IOFBF, 16384)
    return plik
  }

  private func przywrocStdout() {
    fflush(stdout)
    if zapasowyDeskryptor >= 0 {
      dup2(zapasowyDeskryptor, 1)
      close(zapasowyDeskryptor)
      zapasowyDeskryptor = -1
    }
    setvbuf(stdout, nil, _IOLBF, 0)
    if let katalog { try? FileManager.default.removeItem(at: katalog) }
    katalog = nil
  }
}
