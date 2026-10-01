import XCTest

@testable import CloudMachineCore

/// Testy czekania na wysylke przed `hdiutil attach`.
///
/// Odtwarzaja rozruch z 01.10.2026: ~600 pasm zaleglosci schodzacych przez
/// ~6 min. Stare czekanie (sztywne 120 s) poddawalo sie w polowie i hdiutil
/// ruszal w pelnej wysylce.
final class UploadDrainTests: XCTestCase {

  private final class FakeClock {
    private(set) var now = Date(timeIntervalSince1970: 1_757_700_000)
    func sleep(_ seconds: TimeInterval) { now.addTimeInterval(seconds) }
  }

  /// ZNANA ZLA PROBKA: 600 pozycji schodzi ~2 na sekunde, czyli ~5 min.
  /// Sztywne 120 s puscilo by hdiutil przy ~360 pozycjach w kolejce.
  func testCzekaNaZaleglosciKtoraSchodziDluzejNizDwieMinuty() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: { max(0, 600 - Int(clock.now.timeIntervalSince(start) * 2)) })
    XCTAssertEqual(outcome, .idle)
    XCTAssertGreaterThanOrEqual(clock.now.timeIntervalSince(start), 300)
  }

  /// Wyczerpany limit dobowy: kolejka stoi. Nie czekamy wtedy pelnych 20 min,
  /// tylko `stallTimeout`.
  func testPoddajeSieGdyKolejkaStoi() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {}, unsent: { 42 })
    XCTAssertEqual(outcome, .stalled(unsent: 42))
    let elapsed = clock.now.timeIntervalSince(start)
    XCTAssertGreaterThanOrEqual(elapsed, UploadDrain.defaultStallTimeout)
    XCTAssertLessThan(elapsed, UploadDrain.defaultStallTimeout + UploadDrain.defaultPoll * 2)
  }

  /// Wahania w gore (TM dopisuje) nie sa postepem - liczy sie nowe minimum.
  func testWahaniaBezNowegoMinimumToNiePostep() async {
    let clock = FakeClock()
    var flip = false
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: {
        flip.toggle()
        return flip ? 50 : 60
      })
    XCTAssertEqual(outcome, .stalled(unsent: 50))
  }

  /// Twardy sufit: kolejka schodzi, ale wolniej, niz trzeba.
  func testTwardySufitPrzyPowolnymPostepie() async {
    let clock = FakeClock()
    let start = clock.now
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {},
      unsent: { 100_000 - Int(clock.now.timeIntervalSince(start)) })
    guard case .timedOut = outcome else { return XCTFail("\(outcome)") }
    XCTAssertLessThan(
      clock.now.timeIntervalSince(start), UploadDrain.defaultMaxTotal + UploadDrain.defaultPoll * 2)
  }

  /// rclone milczy - to nie postep i nie pusta kolejka.
  func testBrakOdpowiedziNieJestPustaKolejka() async {
    let clock = FakeClock()
    let outcome = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: {}, unsent: { nil })
    XCTAssertEqual(outcome, .noAnswer)
  }

  /// Pozycje wczytane z brudnego cache PO pierwszym przesunieciu terminow
  /// dostaja pelne 10 min - przesuniecie trzeba ponawiac.
  func testPonawiaPrzesuniecieTerminow() async {
    let clock = FakeClock()
    var expiries = 0
    _ = await UploadDrain.wait(
      now: { clock.now }, sleep: { clock.sleep($0) }, expire: { expiries += 1 }, unsent: { 7 })
    XCTAssertGreaterThanOrEqual(expiries, 2)
  }
}
