import XCTest

@testable import CloudMachineCore

/// Co sie dzieje, gdy `tmutil` NIE ODPOWIADA.
///
/// Do 23.09.2026 odpowiedz brzmiala "nic": wywolania `tmutil` nie mialy
/// limitu czasu, wiec przy martwym montowaniu FUSE-T (incydent ENXIO z 22.09)
/// `destinationinfo` wchodzil w nieprzerywalne I/O i `BackupHealth.
/// currentReport()` nie wracal nigdy. launchd ze `StartInterval` nie
/// uruchamia drugiej instancji, dopoki zyje pierwsza - czujka milkla NA STALE,
/// a naglowek `BackupHealth` deklarowal dokladnie odwrotnie.
final class TimeMachineTimeoutTests: XCTestCase {

  /// Limit MUSI istniec i MUSI miescic sie w oknie uruchomienia czujki.
  ///
  /// `ProcessRunner` poddaje sie dopiero `timeout + 10` s (SIGTERM, SIGKILL,
  /// a na koniec porzucenie procesu, bo SIGKILL nie dziala na proces
  /// zawieszony w jadrze). To ta liczba, nie sam `timeout`, jest realnym
  /// czasem czekania i to ona musi zmiescic sie w `StartInterval` czujki
  /// (1800 s), inaczej limit tylko przesuwalby zawieszenie, zamiast je
  /// przerywac.
  func testLimitCzasuTmutilIstniejeIMiesciSieWOknieCzujki() {
    XCTAssertGreaterThan(TimeMachineStatus.commandTimeout, 0, "Brak limitu to ta awaria.")
    let najdluzszeCzekanie = TimeMachineStatus.commandTimeout + 10
    XCTAssertLessThan(
      najdluzszeCzekanie, 1800,
      "Czekanie dluzsze niz StartInterval czujki (1800 s) zjada jej wlasne okno uruchomienia.")
    // Zapas nad przypadkiem zdrowym (ulamek sekundy) ma byc duzy, bo projekt
    // ma juz jedna wpadke z limitem dobranym dla CZYSTEGO startu: 120 s
    // wystarczalo po restarcie, a po awarii zabraklo 10 s.
    XCTAssertGreaterThanOrEqual(
      TimeMachineStatus.commandTimeout, 60,
      "Limit dobrany 'na zdrowy system' padnie przy pierwszej powaznej awarii.")
  }

  /// Brak odpowiedzi od tmutil jest AWARIA, a nie "cel przestawiony".
  ///
  /// To rozroznienie jest calym sensem limitu czasu. Gdyby zawieszony tmutil
  /// zglaszal sie jako `destinationRegistered: false`, czujka wysylalaby
  /// czlowieka do przestawiania celu, ktory jest ustawiony poprawnie - a
  /// prawdziwa przyczyna (martwe montowanie) zostalaby nietknieta.
  func testBrakOdpowiedziTmutilJestOsobnaAwaria() {
    let teraz = Date(timeIntervalSince1970: 1_758_000_000)

    let nieWiadomo = BackupHealth.evaluate(
      lastSuccess: teraz.addingTimeInterval(-1800), lastAttempt: teraz.addingTimeInterval(-1800),
      result: 0, now: teraz, mounted: true, attached: true, destinationRegistered: nil,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertFalse(nieWiadomo.healthy, "Nie wiadomo = nie zdrowo.")
    XCTAssertTrue(
      nieWiadomo.problems.contains { $0.summary.contains("tmutil nie odpowiada") },
      "Zawieszony tmutil musi byc nazwany po imieniu.")
    XCTAssertFalse(
      nieWiadomo.problems.contains { $0.summary == "Time Machine nie wskazuje na CloudMachine" },
      "To NIE jest przestawiony cel - taki komunikat wysyla czlowieka w zla strone.")
  }

  /// Odpowiedz "cel jest przestawiony" nadal ma brzmiec jak dawniej -
  /// bez tego testu naprawa mogla zamienic jeden komunikat na drugi.
  func testPrzestawionyCelNadalJestZglaszanyOsobno() {
    let teraz = Date(timeIntervalSince1970: 1_758_000_000)

    let przestawiony = BackupHealth.evaluate(
      lastSuccess: teraz.addingTimeInterval(-1800), lastAttempt: teraz.addingTimeInterval(-1800),
      result: 0, now: teraz, mounted: true, attached: true, destinationRegistered: false,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertTrue(
      przestawiony.problems.contains { $0.summary == "Time Machine nie wskazuje na CloudMachine" })
    XCTAssertFalse(przestawiony.problems.contains { $0.summary.contains("tmutil nie odpowiada") })
  }

  /// Poprawnie ustawiony cel nie zglasza zadnego z tych dwoch problemow.
  func testUstawionyCelNieZglaszaNiczego() {
    let teraz = Date(timeIntervalSince1970: 1_758_000_000)

    let dobrze = BackupHealth.evaluate(
      lastSuccess: teraz.addingTimeInterval(-1800), lastAttempt: teraz.addingTimeInterval(-1800),
      result: 0, now: teraz, mounted: true, attached: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertTrue(dobrze.healthy)
  }

  // MARK: - Nieodczytana tablica montowan

  /// Punkt odniesienia dla tej grupy: wszystko sprawne.
  private func zdrowa(
    mounted: Bool? = true, attached: Bool? = true, imageDeadErrno: Int32? = nil
  ) -> BackupHealth.Report {
    let teraz = Date(timeIntervalSince1970: 1_758_000_000)
    return BackupHealth.evaluate(
      lastSuccess: teraz.addingTimeInterval(-1800), lastAttempt: teraz.addingTimeInterval(-1800),
      result: 0, now: teraz, mounted: mounted, attached: attached, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, imageDeadErrno: imageDeadErrno)
  }

  /// TA cisza. `BackupImageService.Attachment` dostal czwarty przypadek
  /// `.unknown` ("tablicy montowan nie udalo sie odczytac"), a wolajacy
  /// przekazywal do czujki `attachment != .detached` - czyli `.unknown`
  /// wchodzilo jako `true`, "podpiety". Czujka, ktorej JEDYNYM zadaniem jest
  /// nie twierdzic rzeczy, ktorych nie wie, milczala o stanie, ktorego nie
  /// znala. To jedyne miejsce w tej turze, gdzie "nie wiem" szlo w strone
  /// ciszy, a nie alarmu.
  func testNieodczytanyStanObrazuNieJestCisza() {
    let nieWiadomo = zdrowa(attached: nil)

    XCTAssertFalse(nieWiadomo.healthy, "Nie wiadomo = nie zdrowo. Cisza tu nie wolno.")
    XCTAssertTrue(
      nieWiadomo.problems.contains { $0.summary == "Nie wiadomo, czy obraz backupu jest podpiety" })
  }

  /// ...i nie jest tym samym, co realne odpiecie. Komunikat "nie jest
  /// podpiety" wyslalby czlowieka do podpinania obrazu, ktory moze byc
  /// podpiety poprawnie - ta sama zasada, co przy przestawionym celu.
  func testNieodczytanyStanObrazuBrzmiInaczejNizOdpiecie() {
    let nieWiadomo = zdrowa(attached: nil)
    let odpiety = zdrowa(attached: false)

    XCTAssertFalse(
      nieWiadomo.problems.contains { $0.summary == "Obraz backupu nie jest podpiety" },
      "Brak odczytu NIE jest odpieciem.")
    XCTAssertTrue(odpiety.problems.contains { $0.summary == "Obraz backupu nie jest podpiety" })
    XCTAssertFalse(
      odpiety.problems.contains { $0.summary.hasPrefix("Nie wiadomo, czy obraz") },
      "Realne odpiecie jest FAKTEM, a nie niewiadoma.")
  }

  /// To samo dla montowania. `isMounted` to `mountedState() ?? false`, wiec
  /// nieodczytana tablica montowan zglaszala sie jako "montowanie nie dziala"
  /// - alarm o stanie, ktorego nikt nie zmierzyl, wysylajacy czlowieka do
  /// naprawiania czegos, co moze byc sprawne.
  func testNieodczytaneMontowanieBrzmiInaczejNizBrakMontowania() {
    let nieWiadomo = zdrowa(mounted: nil)
    let brak = zdrowa(mounted: false)

    XCTAssertFalse(nieWiadomo.healthy)
    XCTAssertTrue(
      nieWiadomo.problems.contains {
        $0.summary == "Nie wiadomo, czy montowanie Google Drive dziala"
      })
    XCTAssertFalse(
      nieWiadomo.problems.contains { $0.summary == "Montowanie Google Drive nie dziala" })
    XCTAssertTrue(brak.problems.contains { $0.summary == "Montowanie Google Drive nie dziala" })
  }

  /// Podpiety, ale MARTWY obraz musi nadal byc zglaszany - przebudowa galezi
  /// `attached` na trojstanowa nie moze zgubic tego przypadku, bo kosztowal
  /// juz 15 godzin bez kopii.
  func testMartwyObrazNadalJestZglaszany() {
    let martwy = zdrowa(attached: true, imageDeadErrno: 6)
    XCTAssertTrue(martwy.problems.contains { $0.summary.contains("MARTWY (errno 6)") })
    // Przy nieznanym stanie NIE zgadujemy, ze obraz zyje.
    XCTAssertFalse(zdrowa(attached: nil).problems.contains { $0.summary.contains("MARTWY") })
  }

  /// `runningState()` istnieje po to, zeby "nie trwa" i "nie wiadomo" dalo
  /// sie rozroznic. `isRunning()` zostaje jako skrot dla miejsc czysto
  /// informacyjnych i tam wolno mu zlewac te dwa przypadki.
  func testParsowanieStatusuNieZmieniloSie() {
    XCTAssertTrue(TimeMachineStatus.isRunning(statusOutput: "Running = 1;"))
    XCTAssertFalse(TimeMachineStatus.isRunning(statusOutput: "Running = 0;"))
    XCTAssertFalse(TimeMachineStatus.isRunning(statusOutput: ""))
  }
}
