import Foundation
import XCTest

@testable import CloudMachineCore
@testable import cloudmachine_poc

/// Czy harness `pullplug` odroznia "nie zmierzylem" od "zmierzylem i jest OK".
///
/// Harness mierzy zachowanie hdiutil i FUSE-T, ale SPOSOB, w jaki zdaje z tego
/// relacje, jest zwyklym kodem - i psul sie dokladnie tak, jak reszta tego
/// projektu: przez zlanie braku wyniku z wynikiem. Zaden test tutaj nie tworzy
/// obrazu dyskowego; dotykaja wylacznie czystych czesci.
final class PullPlugHarnessTests: XCTestCase {

  // MARK: - Proba zapisu: "nie zaczalem" to nie "przerwano"

  /// TA usterka. `writeUntilItBreaks` zwracalo `false` takze wtedy, gdy
  /// `createFile`/`FileHandle` padly od razu - a harness drukowal na to "zapis
  /// przerwany, zgodnie z oczekiwaniem" i konczyl "Obraz przezyl kazde wyrwanie
  /// podlogi", nie napisawszy ani jednego bajtu.
  func testZapisKtoryNieMialGdzieSieZaczacNieJestPrzerwanym() {
    let nieistniejacy = URL(fileURLWithPath: "/nie/ma/takiego/katalogu/obciazenie.bin")
    let wynik = writeUntilItBreaks(to: nieistniejacy, megabytes: 1)

    guard case .neverStarted(let powod) = wynik else {
      return XCTFail("zapis, ktory sie nie zaczal, nie moze wygladac jak przerwany: \(wynik)")
    }
    XCTAssertTrue(
      powod.contains("obciazenie.bin"), "powod ma nazwac plik, o ktory chodzi: \(powod)")
    XCTAssertNotEqual(wynik, .interrupted(megabytesWritten: 0))
  }

  /// Druga strona tej samej poprawki: zapis, ktory PRZESZEDL cale zamowienie,
  /// tez nie jest sukcesem testu - podloga zniknela juz po nim, wiec runda nic
  /// nie zmierzyla. To ten sam blad, przed ktorym ostrzega komentarz o
  /// `arc4random_buf`, tylko widziany od strony raportu.
  func testZapisDoKoncaJestRozpoznawalnyJakoBrakPomiaru() throws {
    let katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-pullplug-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: katalog) }

    let wynik = writeUntilItBreaks(
      to: katalog.appendingPathComponent("obciazenie.bin"), megabytes: 1)
    XCTAssertEqual(wynik, .completed(megabytesWritten: 1))
  }

  // MARK: - fsck: "nie udalo sie sprawdzic" to nie "niespojny"

  func testWynikFsckZeroToSpojny() {
    XCTAssertEqual(
      PullPlugCommand.classify(fsck: ProcessResult(stdout: "ok", stderr: "", exitCode: 0)),
      .consistent)
  }

  func testNiezerowyKodFsckToNiespojnosc() {
    XCTAssertEqual(
      PullPlugCommand.classify(
        fsck: ProcessResult(stdout: "", stderr: "corrupt", exitCode: 1)),
      .inconsistent)
  }

  /// Wzorzec z `BackupImageService.verifyLocked()`: nieuruchomiony `fsck_apfs`
  /// (brak binarki, ubity proces, wyrwane urzadzenie) dawal to samo `false`, co
  /// `fsck_apfs`, ktory znalazl uszkodzenie - harness meldowal wtedy "backup
  /// stracony" i liczyl nieodwracalna strate, nie majac ani jednego wyniku.
  func testBrakWynikuFsckToNieNiespojnosc() {
    let wynik = PullPlugCommand.classify(fsck: nil)
    XCTAssertNotEqual(wynik, .inconsistent, "brak wyniku nie moze udawac uszkodzenia")
    guard case .notChecked = wynik else { return XCTFail("dostalem: \(wynik)") }
  }

  // MARK: - Ostatnie zdanie przebiegu

  func testPrzebiegBezStratIBezDziurOrzekaPrzezycie() {
    let linie = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 0, unmeasured: 0)
    XCTAssertTrue(
      linie.contains { $0.contains("przezyl kazde wyrwanie podlogi") }, "dostalem: \(linie)")
  }

  /// Sedno punktu 14: przebieg, w ktorym cokolwiek nie zostalo zmierzone, NIE
  /// MA PRAWA orzekac, ze obraz przezyl. Harness nie wie, czy probowal go zabic.
  func testPrzebiegZRundaBezPomiaruNieOrzekaPrzezycia() {
    let linie = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 0, unmeasured: 1)
    XCTAssertFalse(
      linie.contains { $0.contains("przezyl") },
      "runda bez pomiaru nie moze konczyc sie zdaniem o przezyciu: \(linie)")
    XCTAssertTrue(
      linie.contains { $0.contains("NIC NIE DOWODZI") }, "dostalem: \(linie)")
    XCTAssertTrue(
      linie.contains { $0.contains("rund bez pomiaru: 1") }, "dostalem: \(linie)")
  }

  /// Zero wykonanych rund tez nie jest sukcesem - a przy `rounds: 0` w liczniku
  /// dawnego podsumowania wychodzilo "nieodwracalnych strat: 0", czyli
  /// "przezyl".
  func testPrzebiegBezAniJednejRundyNiczegoNieOrzeka() {
    let linie = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 0, lost: 0, unmeasured: 0)
    XCTAssertFalse(linie.contains { $0.contains("przezyl") }, "dostalem: \(linie)")
    XCTAssertTrue(linie.contains { $0.contains("NIC NIE ZMIERZYL") }, "dostalem: \(linie)")
  }

  /// Stwierdzona strata jest wynikiem i ma byc widoczna nawet obok dziur -
  /// inaczej "poprawka" zamienilaby falszywy sukces na przemilczana awarie.
  func testStwierdzonaStrataNieZnikaZaBrakiemPomiaru() {
    let linie = PullPlugCommand.summary(
      requestedRounds: 3, executedRounds: 3, lost: 1, unmeasured: 1)
    XCTAssertTrue(
      linie.contains { $0.contains("architektura gubi backup") }, "dostalem: \(linie)")
    XCTAssertFalse(linie.contains { $0.contains("przezyl") }, "dostalem: \(linie)")
  }
}
