import XCTest

@testable import CloudMachineCore

/// Testy czekania na gotowy bufor.
///
/// Kazdy odtwarza konkretny wyscig, ktory juz zdarzyl sie na zywo - nie
/// sprawdzamy, ze funkcja "dziala", tylko ze zachowuje sie inaczej niz wersja,
/// ktora 13 wrz 2026 zostawila Time Machine bez celu.
final class BufferReadinessTests: XCTestCase {

  /// Zegar, ktory rusza sie tylko wtedy, gdy kod naprawde by spal. Dzieki temu
  /// test mierzy CZEKANIE, a nie predkosc maszyny.
  private final class FakeClock {
    private(set) var now = Date(timeIntervalSince1970: 1_757_700_000)
    func sleep(_ seconds: TimeInterval) { now.addTimeInterval(seconds) }
  }

  // MARK: - Warunek gotowosci

  /// To jest ten drugi wyscig: montowanie juz stoi, ale rclone nie wczytal
  /// jeszcze brudnego cache, wiec katalog jest pusty. Stara wersja uznawala to
  /// za gotowosc i podpiecie odpadalo na "Brak obrazu".
  func testMontowanieBezObrazuToNieGotowosc() {
    XCTAssertFalse(BufferReadiness.isReady(mounted: true, imageVisible: false))
  }

  func testObrazBezMontowaniaToNieGotowosc() {
    XCTAssertFalse(BufferReadiness.isReady(mounted: false, imageVisible: true))
  }

  func testJednoIDrugieToGotowosc() {
    XCTAssertTrue(BufferReadiness.isReady(mounted: true, imageVisible: true))
  }

  // MARK: - Czekanie

  /// ZNANA ZLA PROBKA: bufor staje po 150 s. Stary limit 120 s poddawal sie
  /// dziesiec sekund za wczesnie i wlasnie to zdarzylo sie 13 wrz 2026.
  func testDoczekaSieBuforaKtoryStajePo150s() async {
    let clock = FakeClock()
    let gotowyOd = clock.now.addingTimeInterval(150)

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { clock.now >= gotowyOd })

    XCTAssertTrue(ready, "Bufor stanal po 150 s - czekanie musi go zlapac")
  }

  /// Dowod, ze poprzedni test nie przechodzi dlatego, ze funkcja zwraca zawsze
  /// `true`: bufor, ktory nie staje NIGDY, musi zostac zgloszony jako awaria.
  func testPoddajeSieGdyBuforNieStajeWcale() async {
    let clock = FakeClock()

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { false })

    XCTAssertFalse(ready, "Bufor nigdy nie stanal - to musi byc awaria, nie cisza")
  }

  /// Czekanie ma sie skonczyc mniej wiecej na zadeklarowanym limicie, a nie
  /// ciagnac w nieskonczonosc: launchd czeka na ten proces.
  func testKonczyCzekanieNaZadeklarowanymLimicie() async {
    let clock = FakeClock()
    let start = clock.now

    _ = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { false })

    let elapsed = clock.now.timeIntervalSince(start)
    XCTAssertGreaterThanOrEqual(elapsed, BufferReadiness.defaultTimeout)
    XCTAssertLessThan(elapsed, BufferReadiness.defaultTimeout + BufferReadiness.defaultPoll * 2)
  }

  /// Gotowy bufor nie moze kosztowac ani jednego uspienia - `attach-image`
  /// chodzi tez z reki i po kazdym tyknieciu launchd.
  func testGotowyBuforNieCzekaWcale() async {
    let clock = FakeClock()
    let start = clock.now

    let ready = await BufferReadiness.wait(
      now: { clock.now },
      sleep: { clock.sleep($0) },
      probe: { true })

    XCTAssertTrue(ready)
    XCTAssertEqual(clock.now, start, "Gotowy bufor ma wracac natychmiast")
  }

  /// Limit musi byc wiekszy niz zaobserwowane 150 s, inaczej naprawa jest
  /// pozorna. Zapisane wprost, zeby nikt go nie scial z powrotem do dwoch minut.
  func testLimitJestWiekszyNizZaobserwowanyWyscig() {
    XCTAssertGreaterThan(BufferReadiness.defaultTimeout, 150)
  }
}
