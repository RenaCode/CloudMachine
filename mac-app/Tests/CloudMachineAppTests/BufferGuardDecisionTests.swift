import XCTest

@testable import CloudMachineCore

/// Decyzje dozorcy bufora przechodzone CALA sciezka - przez `step()`, ze
/// zmiana stanu wlacznie - a nie tylko przez czyste funkcje pomocnicze.
///
/// Powod: wszystkie trzy awarie naprawione 23.09.2026 (wyrzucany wynik
/// `stopbackup`, wspolna galaz wznowienia dla braku miejsca na Dysku,
/// zmyslone zero z nieudanego `statfs`) siedzialy w SEKWENCJI krokow, a nie
/// w pojedynczym wyrazeniu. Test czystego predykatu przeszedlby dla kazdej
/// z nich. Dlatego `BufferGuardService` ma teraz wstrzykiwalne `Probes` -
/// ten sam zabieg, co `preferencesFile` w `BackupHealth.currentReport`.
final class BufferGuardDecisionTests: XCTestCase {

  /// Zapisuje, co dozorca zrobil, i pozwala sterowac tym, co "widzi".
  /// Klasa, nie struktura, bo te same wartosci czyta i zmienia kilka domkniec.
  private final class Atrapa: @unchecked Sendable {
    private let lock = NSLock()

    private var _bufferGB = 0
    private var _freeGB: Int? = 500
    private var _running: Bool? = true
    private var _quotaHit = false
    private var _driveFreeBytes: UInt64? = 1_000 * 1_073_741_824
    private var _stopSucceeds = true
    private var _stopCalls = 0
    private var _startCalls = 0
    private var _log: [String] = []

    private func read<T>(_ body: () -> T) -> T {
      lock.lock()
      defer { lock.unlock() }
      return body()
    }
    private func write(_ body: () -> Void) {
      lock.lock()
      defer { lock.unlock() }
      body()
    }

    var bufferGB: Int {
      get { read { _bufferGB } }
      set { write { _bufferGB = newValue } }
    }
    var freeGB: Int? {
      get { read { _freeGB } }
      set { write { _freeGB = newValue } }
    }
    var running: Bool? {
      get { read { _running } }
      set { write { _running = newValue } }
    }
    var quotaHit: Bool {
      get { read { _quotaHit } }
      set { write { _quotaHit = newValue } }
    }
    var driveFreeBytes: UInt64? {
      get { read { _driveFreeBytes } }
      set { write { _driveFreeBytes = newValue } }
    }
    var stopSucceeds: Bool {
      get { read { _stopSucceeds } }
      set { write { _stopSucceeds = newValue } }
    }
    var stopCalls: Int { read { _stopCalls } }
    var startCalls: Int { read { _startCalls } }
    var log: [String] { read { _log } }

    func probes() -> BufferGuardService.Probes {
      BufferGuardService.Probes(
        // Rozmiar bufora dozorca liczy z `bytesUsed`; podajemy go wprost.
        queueStats: { [self] in
          DriveBufferService.QueueStats(
            uploadsInProgress: 0, uploadsQueued: 0, files: 0, erroredFiles: 0,
            bytesUsed: UInt64(max(0, bufferGB)) * 1_073_741_824, outOfSpace: false)
        },
        freeGB: { [self] in freeGB },
        backupRunning: { [self] in running },
        progressPercent: { 0 },
        hitStorageQuota: { [self] in quotaHit },
        uploadStalled: { false },
        driveFreeBytes: { [self] in driveFreeBytes },
        stopBackup: { [self] in
          write { _stopCalls += 1 }
          return stopSucceeds
        },
        startBackup: { [self] in
          write { _startCalls += 1 }
          return true
        },
        // Zgloszenie zatoru dotyka pliku znacznika w katalogu uzytkownika
        // i pokazuje powiadomienie - w tescie nie ma tam czego szukac.
        reportStall: { _ in },
        log: { [self] line in write { _log.append(line) } })
    }
  }

  private let progi = BufferGuardService.Thresholds(
    highGB: 150, lowGB: 40, minFreeGB: 80, minDriveFreeGB: 30)

  /// Doprowadza dozorce do stanu `.running` - punkt wyjscia dla reszty.
  private func nadzorujacy(_ atrapa: Atrapa) async -> BufferGuardService {
    let dozorca = BufferGuardService(thresholds: progi, probes: atrapa.probes())
    atrapa.bufferGB = 10
    atrapa.running = true
    await dozorca.step()
    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running, "Punkt wyjscia: dozorca ma nadzorowac trwajacy backup.")
    return dozorca
  }

  // MARK: - Punkt 2: nieudane wstrzymanie NIE jest pauza

  /// TA awaria. `tmutil stopbackup` pada (brak uprawnien albo limit czasu),
  /// a dozorca i tak przechodzil w `.pausedForBuffer`. Poniewaz wstrzymanie
  /// wola sie wylacznie przy ZMIANIE stanu, nie ponawial go juz nigdy:
  /// Time Machine pisal dalej, dozorca czekal na drenaz, dysk zapelnial sie
  /// do konca, a w logu stalo "PAUZA ... czekam na wysylke".
  func testNieudaneWstrzymanieNieZmieniaStanuIJestPonawiane() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.stopSucceeds = false
    atrapa.bufferGB = 200  // powyzej progu pauzy
    await dozorca.step()

    var stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .running,
      "Nieudane 'tmutil stopbackup' NIE jest pauza - Time Machine nadal pisze.")
    XCTAssertEqual(atrapa.stopCalls, 1)
    XCTAssertTrue(
      atrapa.log.contains { $0.contains("NIE UDALO SIE wstrzymac") },
      "Cicha porazka jest gorsza od glosnej - musi byc slad w logu.")

    // Kolejny krok MUSI sprobowac jeszcze raz - bez tego jedna nieudana proba
    // zostawiala backup bez nadzoru az do restartu agenta.
    await dozorca.step()
    XCTAssertEqual(atrapa.stopCalls, 2, "Dozorca ma ponawiac wstrzymanie przy kazdym kroku.")
    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running)

    // Gdy wreszcie sie uda - dopiero wtedy stan sie zmienia.
    atrapa.stopSucceeds = true
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer)
    XCTAssertEqual(atrapa.stopCalls, 3)
  }

  // MARK: - Punkt 3: pauza za brak miejsca na Dysku wymaga DOWODU

  /// TA awaria. `hitStorageQuota()` patrzy na wpisy z ostatnich 30 minut logu
  /// rclone. Po wstrzymaniu Time Machine nowe pasma nie powstaja, rclone
  /// przestaje probowac, wpisy sie starzeja - i funkcja zaczyna zwracac
  /// `false`, mimo ze na Dysku jak nie bylo miejsca, tak nie ma. Wspolna
  /// galaz wznowienia patrzyla wtedy wylacznie na bufor i wolne miejsce
  /// LOKALNE, czyli na dwie liczby, ktore o Dysku Google nie wiedza nic,
  /// i zdejmowala pauze natychmiast.
  func testPauzaZaBrakMiejscaNaDyskuNieMijaSama() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.quotaHit = true
    await dozorca.step()
    var stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForQuota)

    // Wpisy w logu sie zestarzaly, bufor sie oprozail, dysk lokalny pusty -
    // czyli DOKLADNIE sytuacja, w ktorej stara wersja wznawiala backup.
    atrapa.quotaHit = false
    atrapa.bufferGB = 5
    atrapa.freeGB = 900

    // 1. rclone nie odpowiada: "nie wiem" NIE jest zgoda na wznowienie.
    atrapa.driveFreeBytes = nil
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .pausedForQuota,
      "Brak odpowiedzi o pojemnosci Dysku ma PODTRZYMAC pauze, nie ja zniesc.")
    XCTAssertEqual(atrapa.startCalls, 0)

    // 2. rclone odpowiada, ale miejsca nadal praktycznie nie ma.
    atrapa.driveFreeBytes = 2 * 1_073_741_824
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForQuota, "2 GB to nie jest miejsce na dalsze kopie.")
    XCTAssertEqual(atrapa.startCalls, 0)

    // 3. Miejsce faktycznie sie znalazlo - dopiero to jest dowod.
    atrapa.driveFreeBytes = 500 * 1_073_741_824
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running)
    XCTAssertEqual(atrapa.startCalls, 1)
  }

  /// Pauza z powodu BUFORA nie potrzebuje niczego od Dysku Google - inaczej
  /// nieosiagalny rclone blokowalby kazde wznowienie w systemie.
  func testPauzaZaBuforWznawiaSieBezPytaniaODysk() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.bufferGB = 200
    await dozorca.step()
    var stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer)

    atrapa.bufferGB = 10
    atrapa.driveFreeBytes = nil  // rclone milczy, ale to nie ta pauza
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running)
  }

  // MARK: - Punkt 4: nieudany pomiar wolnego miejsca

  /// TA awaria. `freeGB()` zwracalo `0`, gdy `statfs` zawiodl. Zero spelnialo
  /// warunek pauzy (`free <= minFreeGB`) natychmiast i NIGDY nie spelnialo
  /// warunku wznowienia (`free > minFreeGB`) - dozorca wstrzymywal Time
  /// Machine na podstawie liczby, ktorej nie zmierzyl, i nie wznawial go juz
  /// nigdy.
  func testNieudanyPomiarWolnegoMiejscaNieWstrzymujeBackupu() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.freeGB = nil
    atrapa.bufferGB = 10  // bufor w porzadku, wiec jedyny powod pauzy to dysk
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .running,
      "Brak pomiaru to nie jest pomiar zerowy - nie wolno na nim wstrzymywac backupu.")
    XCTAssertEqual(atrapa.stopCalls, 0)
    XCTAssertTrue(
      atrapa.log.contains { $0.contains("nie da sie zmierzyc wolnego miejsca") },
      "...ale nie wolno tez o tym milczec: to awaria samej ochrony dysku.")
  }

  /// Zmierzone zero to co INNEGO niz brak pomiaru - i musi pauzowac.
  /// Bez tego testu "naprawa" polegajaca na zignorowaniu wolnego miejsca
  /// w ogole przeszlaby niezauwazona.
  func testZmierzoneZeroNadalWstrzymujeBackup() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.freeGB = 0
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer)
    XCTAssertEqual(atrapa.stopCalls, 1)
  }

  /// Brak pomiaru nie moze tez UDAWAC zgody na wznowienie.
  func testNieudanyPomiarNieWznawiaBackupu() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.bufferGB = 200
    await dozorca.step()
    var stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer)

    atrapa.bufferGB = 5
    atrapa.freeGB = nil
    await dozorca.step()
    stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .pausedForBuffer,
      "Wznowienie wymaga dowodu, ze miejsce JEST - brak pomiaru dowodem nie jest.")
    XCTAssertEqual(atrapa.startCalls, 0)
  }

  /// `freeGB()` na prawdziwym systemie ma oddawac to samo, co `df`, i ma to
  /// byc wartosc OPCJONALNA. Sciezka udana - odpowiednik dawnego
  /// `testFreeSpaceMatchesStatfs`, ktory jako jedyny testowal te funkcje.
  func testPomiarWolnegoMiejscaZgadzaSieZeStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let oczekiwane = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BufferGuardService.freeGB(), oczekiwane)
  }

  // MARK: - Czyste predykaty

  func testWznowienieWymagaObuWarunkowIPomiaru() {
    // Bufor nadgonil i miejsce jest - jedyny przypadek, ktory wznawia.
    XCTAssertTrue(
      BufferGuardService.canResumeLocally(buffer: 10, free: 500, thresholds: progi))
    // Bufor nadgonil, ale dysk nadal pelny.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(buffer: 10, free: 10, thresholds: progi))
    // Dysk pusty, ale bufor jeszcze nie zszedl.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(buffer: 100, free: 500, thresholds: progi))
    // Brak pomiaru - nie wiadomo, wiec nie wznawiamy.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(buffer: 10, free: nil, thresholds: progi))
  }

  func testMiejsceNaDyskuLiczySieTylkoGdyJestZmierzone() {
    XCTAssertFalse(BufferGuardService.driveHasRoom(freeBytes: nil, minGB: 30))
    XCTAssertFalse(BufferGuardService.driveHasRoom(freeBytes: 0, minGB: 30))
    XCTAssertFalse(
      BufferGuardService.driveHasRoom(freeBytes: 29 * 1_073_741_824, minGB: 30))
    XCTAssertTrue(
      BufferGuardService.driveHasRoom(freeBytes: 30 * 1_073_741_824, minGB: 30))
  }

  /// Galaz "nie wiem" w czujce MUSI byc zywa.
  ///
  /// Przeglad zlapal moment, w ktorym `BackupHealth` porownywal do `nil`
  /// wartosc nieopcjonalna - takie porownanie zawsze daje falsz, wiec galaz
  /// byla martwa, a kod i tak sie kompilowal i testy przechodzily. Ten test
  /// sprawdza SAMA galaz, nie typ: przy braku pomiaru ma powstac problem,
  /// przy pomiarze - nie.
  func testBrakPomiaruDyskuJestZglaszanyPrzezCzujke() {
    let brak = BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: nil)
    XCTAssertEqual(brak.count, 1, "Nieudany statfs to awaria ochrony dysku, nie cisza.")
    // `first`, nie `[0]`: przy porazce tej asercji indeks przerwalby CALY
    // przebieg fatal errorem zamiast zglosic jeden nieudany test.
    XCTAssertEqual(brak.first?.summary, "Nie da sie zmierzyc wolnego miejsca na dysku Maca")

    XCTAssertTrue(
      BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: 400).isEmpty,
      "Udany pomiar nie ma prawa niczego zglaszac.")
    // Zmierzone zero to WYNIK, a nie brak wyniku - o niskim stanie mowi
    // osobny prog w `evaluate`, nie ta funkcja.
    XCTAssertTrue(BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: 0).isEmpty)
  }

  /// Prog wolnego miejsca na Dysku jest ten sam, ktory `BackupHealth` uznaje
  /// za ostrzegawczy - jedno zrodlo prawdy, zeby czujka i dozorca nie mogly
  /// twierdzic czegos innego o tej samej liczbie.
  func testProgMiejscaNaDyskuZgadzaSieZCzujka() {
    XCTAssertEqual(
      BufferGuardService.Thresholds().minDriveFreeGB, BackupHealth.driveFreeWarningGB)
  }
}
