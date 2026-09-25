import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Trzy odpowiedzi `tmutil destinationinfo` MUSZA dac trzy rozne stany panelu.
///
/// Do 25.09.2026 panel pytal `TimeMachineStatus.currentDestinationMountPoint()`,
/// ktora zwraca `nil` i przy braku celu, i przy braku odpowiedzi tmutil - obie
/// sciezki konczyly sie tym samym `.notRegistered`, czyli napisem "Time Machine
/// nie wskazuje na CloudMachine". Kierunek pomylki byl bezpieczny (falszywy
/// alarm), ale zdanie jest falszywe i kaze zrobic zla rzecz: rejestrowac cel,
/// ktory jest caly. Czujka `backup-health` rozroznia te dwa przypadki od
/// 23.09.2026 (`destinationReading()`), panel byl ostatnim miejscem, ktore je
/// zlewalo.
@MainActor
final class TimeMachineDestinationStateTests: XCTestCase {

  private let cel = "/Volumes/CloudMachine"

  // MARK: - Przeklad odpowiedzi tmutil na stan panelu

  func testZarejestrowanyCelToNaszObraz() {
    XCTAssertEqual(
      TimeMachineState.from(.mountPoint(cel), target: cel), .registered(mountPoint: cel))
  }

  /// Cel istnieje, ale wskazuje gdzie indziej - backupu na Drive NIE MA.
  func testCelWskazujacyGdzieIndziejToBrakRejestracji() {
    XCTAssertEqual(
      TimeMachineState.from(.mountPoint("/Volumes/ObcyDysk"), target: cel), .notRegistered)
  }

  /// tmutil odpowiedzial i zadnego celu nie ma - TO jest "nie wskazuje".
  func testBrakCeluToBrakRejestracji() {
    XCTAssertEqual(TimeMachineState.from(.none, target: cel), .notRegistered)
  }

  /// TA usterka. Brak odpowiedzi tmutil nie ma prawa wygladac jak przestawiony
  /// cel. `tmutil destinationinfo` siega na montowanie lezace na Google Drive
  /// i przy chorym montowaniu nie odpowiada wcale - a wtedy o celu nie wiemy
  /// nic, co jest inna informacja niz "celu nie ma".
  func testBrakOdpowiedziTmutilToNieBrakRejestracji() {
    let stan = TimeMachineState.from(.noAnswer, target: cel)
    XCTAssertNotEqual(
      stan, .notRegistered,
      "brak odpowiedzi tmutil nie moze udawac przestawionego celu")
    XCTAssertEqual(stan, .noAnswer)
  }

  // MARK: - Zdanie, ktore czlowiek CZYTA

  /// Naglowek jest jedyna forma, w jakiej ktokolwiek to zobaczy, wiec o tym
  /// rozroznieniu musi mowic on, a nie tylko typ wewnetrzny.
  func testNaglowekPrzyBrakuOdpowiedziNieOskarzaCelu() {
    let status = stanPoza(timeMachine: .noAnswer)
    XCTAssertNotEqual(
      status.headline, "Time Machine nie wskazuje na CloudMachine",
      "to zdanie kaze rejestrowac cel na nowo - czynnosc zbedna, gdy cel jest caly")
    XCTAssertTrue(
      status.headline.contains("NIE WIADOMO"), "dostalem: \(status.headline)")
    XCTAssertFalse(
      status.healthy,
      "brak wiedzy o celu to NIE zielony znaczek - nikt nie potwierdzil, ze backup dochodzi")
  }

  /// Druga strona tego samego: PRAWDZIWIE przestawiony cel nadal musi to
  /// powiedziec wprost. Inaczej "poprawka" polegalaby na uciszeniu komunikatu.
  func testNaglowekPrzyPrawdziwiePrzestawionymCeluNieZmiekl() {
    let status = stanPoza(timeMachine: .notRegistered)
    XCTAssertEqual(status.headline, "Time Machine nie wskazuje na CloudMachine")
    XCTAssertFalse(status.healthy)
  }

  /// Stan, w ktorym wszystko poza celem Time Machine jest w porzadku - zeby
  /// naglowek mowil wlasnie o celu, a nie o czyms wczesniejszym.
  private func stanPoza(timeMachine: TimeMachineState) -> AppStatus {
    let status = AppStatus()
    status.dependencyState = .ready
    status.remoteConfigured = true
    var buffer = BufferStatus()
    buffer.mounted = true
    buffer.imageAttached = true
    buffer.queueKnown = true
    buffer.freeDiskGB = 400
    status.buffer = buffer
    status.backupCycle = BackupCycleStatus(
      known: true, lastSuccess: Date().addingTimeInterval(-1800), problems: [],
      checkedAt: Date())
    status.timeMachineState = timeMachine
    return status
  }
}
