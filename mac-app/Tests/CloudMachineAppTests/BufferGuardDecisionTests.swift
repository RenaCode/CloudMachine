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
///
/// Piec awarii naprawionych 25.09.2026 (miara bufora, trzeci stan rozmiaru,
/// martwa ochrona dysku w pauzie, pauza na jeden przebieg, nieczytelny log
/// czytany jako "nie ma problemu") siedzialo tam samo i tez wymagalo calej
/// sekwencji: kazda z nich objawia sie dopiero w DRUGIM albo TRZECIM kroku,
/// po zmianie stanu.
final class BufferGuardDecisionTests: XCTestCase {

  /// Zapisuje, co dozorca zrobil, i pozwala sterowac tym, co "widzi".
  /// Klasa, nie struktura, bo te same wartosci czyta i zmienia kilka domkniec.
  private final class Atrapa: @unchecked Sendable {
    private let lock = NSLock()

    /// ZALEGLOSC NIEWYSLANA w GB. Atrapa przeklada ja na POZYCJE w kolejce,
    /// bo dokladnie tak widzi ja dozorca (`backlogGB` szacuje gigabajty
    /// z liczby pozycji po 32 MiB). Podanie jej wprost w GB pozwalalo
    /// atrapie udawac, ze rclone podaje bajty - a nie podaje.
    private var _backlogGB = 0
    /// Rozmiar cache'a rclone. Trzymany OSOBNO od zaleglosci, bo na tym
    /// rozroznieniu stoi cala poprawka: cache przy `--vfs-cache-max-age 9999h`
    /// siedzi pod limitem stale (na produkcji 281 pomiarow, minimum 99 GB),
    /// niezaleznie od tego, ile zostalo do wyslania. Domyslnie wiec 100.
    private var _cacheGB: Int? = 100
    /// Czy interfejs sterujacy rclone odpowiada. `false` = `vfs/stats` oddaje
    /// `nil`, czyli produkcyjny przebieg z 23.09.2026.
    private var _statsAvailable = true
    private var _outOfSpace = false
    private var _freeGB: Int? = 500
    private var _running: Bool? = true
    /// `nil` = logu rclone NIE DA SIE PRZECZYTAC (prawa `-rw-r-----`,
    /// przeniesienie na `.1` przy starcie).
    private var _quotaHit: Bool? = false
    private var _stalled: Bool? = false
    private var _driveFreeBytes: UInt64? = 1_000 * 1_073_741_824
    private var _stopSucceeds = true
    private var _stopCalls = 0
    private var _startCalls = 0
    private var _log: [String] = []
    /// Co dozorca zglosil o zatorze. `Bool?`, bo "nie wiem" MUSI dojsc do
    /// zgloszenia jako "nie wiem" - inaczej gasi znacznik zatoru.
    private var _stallReports: [Bool?] = []

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

    var backlogGB: Int {
      get { read { _backlogGB } }
      set { write { _backlogGB = newValue } }
    }
    var cacheGB: Int? {
      get { read { _cacheGB } }
      set { write { _cacheGB = newValue } }
    }
    var statsAvailable: Bool {
      get { read { _statsAvailable } }
      set { write { _statsAvailable = newValue } }
    }
    var outOfSpace: Bool {
      get { read { _outOfSpace } }
      set { write { _outOfSpace = newValue } }
    }
    var freeGB: Int? {
      get { read { _freeGB } }
      set { write { _freeGB = newValue } }
    }
    var running: Bool? {
      get { read { _running } }
      set { write { _running = newValue } }
    }
    var quotaHit: Bool? {
      get { read { _quotaHit } }
      set { write { _quotaHit = newValue } }
    }
    var stalled: Bool? {
      get { read { _stalled } }
      set { write { _stalled = newValue } }
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
    var stallReports: [Bool?] { read { _stallReports } }

    func probes() -> BufferGuardService.Probes {
      BufferGuardService.Probes(
        queueStats: { [self] in
          guard statsAvailable else { return nil }
          return DriveBufferService.QueueStats(
            uploadsInProgress: 0,
            // 1 GiB zaleglosci to 32 pasma po 32 MiB - tak samo, jak liczy to
            // `BufferGuardService.backlogGB`.
            uploadsQueued: max(0, backlogGB) * 32,
            files: 0, erroredFiles: 0,
            bytesUsed: UInt64(max(0, cacheGB ?? 0)) * 1_073_741_824,
            outOfSpace: outOfSpace)
        },
        cacheSizeGB: { [self] _ in cacheGB },
        freeGB: { [self] in freeGB },
        backupRunning: { [self] in running },
        progressPercent: { 0 },
        hitStorageQuota: { [self] in quotaHit },
        uploadStalled: { [self] in stalled },
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
        // i pokazuje powiadomienie - w tescie zapisujemy tylko, CO uslyszalo.
        reportStall: { [self] value in write { _stallReports.append(value) } },
        log: { [self] line in write { _log.append(line) } })
    }
  }

  /// Progi jak na produkcji po 25.09.2026: liczone od ZALEGLOSCI niewyslanej
  /// i lezace PONIZEJ rozmiaru cache'a (100 GB).
  private let progi = BufferGuardService.Thresholds(
    highGB: 50, lowGB: 10, minFreeGB: 80, minDriveFreeGB: 30)

  /// Doprowadza dozorce do stanu `.running` - punkt wyjscia dla reszty.
  private func nadzorujacy(_ atrapa: Atrapa) async -> BufferGuardService {
    let dozorca = BufferGuardService(thresholds: progi, probes: atrapa.probes())
    atrapa.backlogGB = 2
    atrapa.running = true
    await dozorca.step()
    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running, "Punkt wyjscia: dozorca ma nadzorowac trwajacy backup.")
    return dozorca
  }

  /// Doprowadza dozorce do pauzy za zaleglosc - punkt wyjscia dla testow pauzy.
  private func wstrzymany(_ atrapa: Atrapa) async -> BufferGuardService {
    let dozorca = await nadzorujacy(atrapa)
    atrapa.backlogGB = 200
    await dozorca.step()
    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer, "Punkt wyjscia: dozorca ma stac w pauzie.")
    return dozorca
  }

  // MARK: - Ustalenie 1: miara bufora i progi

  /// Progi MUSZA lezec ponizej rozmiaru cache'a, bo odnosza sie do zaleglosci
  /// niewyslanej - czyli do tej czesci cache'a, ktorej rclone nie moze usunac.
  /// Stara para (150/40) odnosila sie do rozmiaru CALEGO cache'a i dlatego
  /// prog pauzy byl nieosiagalny bez siegania po inna miare, a prog wznowienia
  /// nieosiagalny w ogole.
  func testProgiOdnoszaSieDoZaleglosciILezaPonizejRozmiaruBufora() {
    let domyslne = BufferGuardService.Thresholds()
    XCTAssertEqual(domyslne.highGB, DriveBufferService.cacheSizeGB / 2)
    XCTAssertEqual(domyslne.lowGB, DriveBufferService.cacheSizeGB / 10)
    XCTAssertLessThan(
      domyslne.highGB, DriveBufferService.cacheSizeGB,
      "Prog pauzy powyzej rozmiaru cache'a jest osiagalny tylko przez pomiar INNEJ wielkosci.")
    XCTAssertLessThan(
      domyslne.lowGB, domyslne.highGB,
      "Bez histerezy dozorca przelaczalby stan przy niemal kazdym tyknieciu.")
  }

  /// Zaleglosc liczy sie z POZYCJI w kolejce, bo `vfs/stats` nie podaje
  /// niewyslanych bajtow. Kontrola na produkcyjnej liczbie: 462 pozycje
  /// z 23.09.2026, ktore wlasciciel oszacowal na "okolo 15 GB".
  func testSzacunekZaleglosciLiczySieZPozycjiKolejki() {
    func stats(queued: Int, inProgress: Int = 0, cacheGB: Int = 100)
      -> DriveBufferService.QueueStats
    {
      DriveBufferService.QueueStats(
        uploadsInProgress: inProgress, uploadsQueued: queued, files: 0, erroredFiles: 0,
        bytesUsed: UInt64(cacheGB) * 1_073_741_824, outOfSpace: false)
    }

    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 462)), 14)
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 32)), 1)
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 0)), 0)
    // Pozycja w trakcie wysylki tez jeszcze nie jest na Dysku.
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 16, inProgress: 16)), 1)
    // Pelny cache przy pustej kolejce to ZERO zaleglosci - to jest cala
    // roznica miedzy stara i nowa miara.
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 0, cacheGB: 100)), 0)
    XCTAssertNil(
      BufferGuardService.backlogGB(stats: nil),
      "Brak odpowiedzi rclone to nie zero pozycji.")
  }

  /// TA awaria, ta z dziennika: JEDNA linia PAUZA i ZERO linii WZNOWIENIE.
  ///
  /// Prog wznowienia 40 GB odnosil sie do rozmiaru cache'a, a ten stoi pod
  /// limitem 100 GB caly czas - takze wtedy, gdy kolejka jest juz pusta, bo
  /// rclone trzyma w cache'u dane dawno wyslane (`--vfs-cache-max-age 9999h`).
  /// Warunek wznowienia nie mial wiec jak zachodzic i dozorca zostawal
  /// w pauzie do restartu procesu.
  func testWznowienieNastepujeGdyKolejkaOpustialaChocCacheStoiPodLimitem() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)

    // Wysylka nadgonila: kolejka pusta. Cache nadal pelny - i to jest
    // dokladnie stan, w ktorym stara wersja nie wznawiala nigdy.
    atrapa.backlogGB = 0
    atrapa.cacheGB = 100
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .running,
      "Pusta kolejka to nadgoniona wysylka - pelny cache nie ma prawa trzymac pauzy.")
    XCTAssertEqual(atrapa.startCalls, 1)
  }

  // MARK: - Ustalenie 6: rozmiar bufora potrzebuje trzeciego stanu

  /// TA awaria, odtworzona z produkcji krok po kroku (23.09.2026 03:34).
  ///
  /// rclone nie odpowiada -> dozorca schodzi na obchod katalogu -> obchod
  /// oddaje 155 GB, bo liczy MIEJSCE ZAJETE NA DYSKU (miare, ktora limit
  /// cache'a potrafi przekroczyc) -> 155 >= prog -> nieodwracalna pauza.
  /// Godzine pozniej czujka zapisala "Interfejs sterujacy rclone nie
  /// odpowiada", czyli pauza stala na liczbie wzietej stad, ze pomiaru nie
  /// bylo.
  ///
  /// Po poprawce ta liczba moze sie pojawic w LOGU, ale nie w decyzji.
  func testBrakOdpowiedziRcloneNieWstrzymujeBackupu() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.statsAvailable = false
    atrapa.cacheGB = 155  // dokladnie liczba z tamtej jedynej linii PAUZA
    atrapa.freeGB = 300  // dysku nic nie grozi, wiec pauza moglaby wyjsc TYLKO z tej liczby
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .running,
      "Brak odpowiedzi rclone zamieniony na liczbe z innej miary uruchamial pauze.")
    XCTAssertEqual(atrapa.stopCalls, 0)
    XCTAssertTrue(
      atrapa.log.contains { $0.contains("interfejs sterujacy rclone nie odpowiada") },
      "...ale milczec tez nie wolno: dozorca wlasnie przestal umiec wstrzymac backup.")
    XCTAssertTrue(
      atrapa.log.contains { $0.contains("155 GB") && $0.contains("MIEJSCE NA DYSKU") },
      "Skoro podajemy te liczbe, musi byc nazwana jako CO INNEGO niz zaleglosc.")
  }

  /// Zgloszenie raz na epizod - jak dla `freeGB()`. Przy awarii trwajacej
  /// 53 godziny linia co 30 sekund zatopilaby log.
  func testOstrzezenieOBrakuOdpowiedziLogujeSieRaz() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.statsAvailable = false
    await dozorca.step()
    await dozorca.step()
    await dozorca.step()

    let ostrzezenia = atrapa.log.filter { $0.contains("interfejs sterujacy rclone nie odpowiada") }
    XCTAssertEqual(ostrzezenia.count, 1, "dostalem: \(atrapa.log)")
  }

  /// Druga strona tego samego klamstwa. Gdy obchod katalogu PADL, oddawal `0`,
  /// a zero wygladalo jak pusty bufor - czyli zdejmowalo pauze zalozona
  /// dlatego, ze bufor byl pelny.
  func testBrakOdpowiedziRcloneNieZdejmujePauzy() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)

    atrapa.statsAvailable = false
    atrapa.cacheGB = nil  // obchod katalogu tez sie nie udal
    atrapa.freeGB = 900  // wszystko inne sprzyja wznowieniu
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .pausedForBuffer,
      "Wznowienie wymaga dowodu, ze wysylka nadgonila - brak pomiaru dowodem nie jest.")
    XCTAssertEqual(atrapa.startCalls, 0)
  }

  // MARK: - Ustalenie 1a: ochrona dysku dziala w KAZDYM stanie

  /// TA awaria. `stats?.outOfSpace`, prog i `lowDisk` siedzialy WYLACZNIE
  /// w galezi `.running`. Po jednej pauzie dozorca przestawal patrzyc na dysk,
  /// a galaz pauzy sprawdzala tylko warunek wznowienia - wiec rclone moglo
  /// krzyczec "nie mam gdzie odlozyc danych", a dozorca w tej samej chwili
  /// wznawial Time Machine, bo kolejka akurat zeszla.
  func testRcloneBezMiejscaNieDajeSieZignorowacWPauzie() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)

    atrapa.backlogGB = 0  // kolejka zeszla, czyli warunek wznowienia spelniony
    atrapa.freeGB = 900
    atrapa.outOfSpace = true  // ...ale rclone nie ma gdzie odlozyc danych
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .pausedForBuffer,
      "outOfSpace to twardszy fakt niz nasz prog i nie przestaje nim byc w pauzie.")
    XCTAssertEqual(atrapa.startCalls, 0)
  }

  /// To samo w pauzie za brak miejsca na Dysku Google: dowod z `rclone about`
  /// nie ma prawa zdjac pauzy, gdy BUFOR jest pod sciana.
  func testRcloneBezMiejscaNieDajeSieZignorowacWPauzieZaDyskGoogle() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.quotaHit = true
    await dozorca.step()
    var stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForQuota)

    atrapa.quotaHit = false  // wpisy w logu rclone sie zestarzaly
    atrapa.backlogGB = 0
    atrapa.freeGB = 900
    atrapa.driveFreeBytes = 500 * 1_073_741_824  // miejsce na Dysku faktycznie sie znalazlo
    atrapa.outOfSpace = true  // ale bufor nie ma gdzie odlozyc danych
    await dozorca.step()

    stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForQuota, "Dowod o Dysku nie jest dowodem o buforze.")
    XCTAssertEqual(atrapa.startCalls, 0)
  }

  /// Konczace sie miejsce na dysku musi wstrzymywac takze wtedy, gdy backup
  /// wlasnie nie trwa: macOS zaczyna kolejny co godzine, a galaz `.idle`
  /// patrzyla dotad wylacznie na to, czy backup ruszyl.
  func testMaloMiejscaNaDyskuWstrzymujeTakzeGdyBackupNieTrwa() async {
    let atrapa = Atrapa()
    let dozorca = BufferGuardService(thresholds: progi, probes: atrapa.probes())
    atrapa.running = false  // czuwanie, nie nadzor
    atrapa.freeGB = 10  // ponizej minFreeGB
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(
      stan, .pausedForBuffer,
      "Dysk zapelnia sie niezaleznie od tego, czy backup trwa w tej sekundzie.")
    XCTAssertTrue(atrapa.log.contains { $0.contains("malo wolnego miejsca na dysku") })
    // Nie ma czego wstrzymywac, wiec `stopbackup` nie leci - i slusznie:
    // jego porazka kazalaby dozorcy zameldowac "Time Machine PISZE DALEJ".
    XCTAssertEqual(atrapa.stopCalls, 0)
  }

  // MARK: - Ustalenie 2: pauza trwa tyle, ile ja podtrzymujemy

  /// TA awaria. `tmutil stopbackup` anuluje TRWAJACY backup i nie rusza
  /// harmonogramu, a `stopBackup()` wolalo sie wylacznie przy ZMIANIE stanu.
  /// Godzine po pauzie macOS startowal kolejny backup, dozorca go nie
  /// zatrzymywal - a w logu stalo "czekam na wysylke". Stan trwal 53 godziny,
  /// wstrzymanie zapisu jeden przebieg.
  func testWstrzymanieJestPonawianeWKazdymTyknieciuPauzy() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)
    XCTAssertEqual(atrapa.stopCalls, 1)

    // Time Machine ruszyl sam w swoim cyklu godzinowym, zaleglosc nadal duza.
    atrapa.running = true
    await dozorca.step()
    XCTAssertEqual(atrapa.stopCalls, 2, "Kolejne tykniecie MUSI ponowic wstrzymanie.")
    await dozorca.step()
    XCTAssertEqual(atrapa.stopCalls, 3)

    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .pausedForBuffer)
    XCTAssertEqual(atrapa.startCalls, 0)
    XCTAssertTrue(
      atrapa.log.contains { $0.contains("ponawiam wstrzymanie") },
      "Ponowne wstrzymanie to zdarzenie warte sladu - znaczy, ze backup ruszyl w pauzie.")
  }

  /// ...ale bez potrzeby nie ponawiamy. Gdy tmutil mowi wprost, ze backup nie
  /// trwa, nie ma czego wstrzymywac - dwa procesy co 30 sekund przez 53
  /// godziny to ponad 12 tysiecy wywolan za nic.
  func testWstrzymanieNieJestPonawianeGdyBackupNieTrwa() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)
    XCTAssertEqual(atrapa.stopCalls, 1)

    atrapa.running = false
    await dozorca.step()
    await dozorca.step()
    XCTAssertEqual(atrapa.stopCalls, 1)

    // "Nie wiem" to NIE jest "nie trwa" - brak odpowiedzi tmutil liczy sie
    // jak trwajacy backup.
    atrapa.running = nil
    await dozorca.step()
    XCTAssertEqual(atrapa.stopCalls, 2)
  }

  // MARK: - Ustalenie 7: nieczytelny log rclone

  /// TA awaria, w jej najgrozniejszej czesci. `recentLog` oddaje `nil` przy
  /// nieotwieralnym pliku, a `uploadStalled()` zamienialo to na `false`;
  /// `false` znaczy "zator minal", wiec `reportStall` USUWAL znacznik i pisal
  /// "Wysylka na Google Drive ruszyla z powrotem" - o zdarzeniu, ktorego nikt
  /// nie sprawdzil. Log rclone ma prawa `-rw-r-----`, a przy starcie jest
  /// przenoszony na `.1`, wiec to nie jest przypadek teoretyczny.
  func testNieWiemNieGasiZnacznikaZatoru() {
    XCTAssertEqual(
      BufferGuardService.stallAction(stalled: nil, markerExists: true), .doNothing,
      "Nieczytelny log nie jest dowodem, ze zator minal.")
    XCTAssertEqual(
      BufferGuardService.stallAction(stalled: nil, markerExists: false), .doNothing)
    // Zmierzone odpowiedzi dzialaja jak dotad - inaczej "naprawa" polegajaca
    // na wylaczeniu zgloszen przeszlaby niezauwazona.
    XCTAssertEqual(BufferGuardService.stallAction(stalled: true, markerExists: false), .raise)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: false, markerExists: true), .clear)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: true, markerExists: true), .doNothing)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: false, markerExists: false), .doNothing)
  }

  /// "Nie wiem" musi DOJSC do zgloszenia jako "nie wiem". Podstawienie `false`
  /// juz w sondzie zamykalo sprawe, zanim ktokolwiek zdazyl sie zastanowic.
  func testNieczytelnyLogIdzieDoZgloszeniaJakoNieWiem() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.stalled = nil
    await dozorca.step()

    XCTAssertEqual(atrapa.stallReports.count, 2)
    XCTAssertEqual(atrapa.stallReports.first, .some(false))
    XCTAssertNil(
      atrapa.stallReports.last!, "Brak odczytu logu nie ma prawa zglosic 'zator minal'.")
  }

  /// Nieczytelny log nie wstrzymuje backupu (bo nie jest dowodem awarii), ale
  /// nie wolno o nim milczec: dozorca wlasnie przestal umiec rozpoznac brak
  /// miejsca na Dysku Google.
  func testNieczytelnyLogAniNieWstrzymujeAniNieMilczy() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.quotaHit = nil
    atrapa.stalled = nil
    await dozorca.step()
    await dozorca.step()

    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running)
    XCTAssertEqual(atrapa.stopCalls, 0)
    let ostrzezenia = atrapa.log.filter { $0.contains("nie da sie przeczytac logu rclone") }
    XCTAssertEqual(ostrzezenia.count, 1, "Raz na epizod - dostalem: \(atrapa.log)")
  }

  // MARK: - Punkt 2 z 23.09: nieudane wstrzymanie NIE jest pauza

  /// TA awaria. `tmutil stopbackup` pada (brak uprawnien albo limit czasu),
  /// a dozorca i tak przechodzil w `.pausedForBuffer`. Poniewaz wstrzymanie
  /// wola sie wylacznie przy ZMIANIE stanu, nie ponawial go juz nigdy:
  /// Time Machine pisal dalej, dozorca czekal na drenaz, dysk zapelnial sie
  /// do konca, a w logu stalo "PAUZA ... czekam na wysylke".
  func testNieudaneWstrzymanieNieZmieniaStanuIJestPonawiane() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.stopSucceeds = false
    atrapa.backlogGB = 200  // powyzej progu pauzy
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

  // MARK: - Punkt 3 z 23.09: pauza za brak miejsca na Dysku wymaga DOWODU

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

    // Wpisy w logu sie zestarzaly, kolejka zeszla, dysk lokalny pusty -
    // czyli DOKLADNIE sytuacja, w ktorej stara wersja wznawiala backup.
    atrapa.quotaHit = false
    atrapa.backlogGB = 1
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

  /// Pauza z powodu ZALEGLOSCI nie potrzebuje niczego od Dysku Google -
  /// inaczej nieosiagalny rclone blokowalby kazde wznowienie w systemie.
  func testPauzaZaZaleglocWznawiaSieBezPytaniaODysk() async {
    let atrapa = Atrapa()
    let dozorca = await wstrzymany(atrapa)

    atrapa.backlogGB = 2
    atrapa.driveFreeBytes = nil  // rclone milczy, ale to nie ta pauza
    await dozorca.step()
    let stan = await dozorca.currentState()
    XCTAssertEqual(stan, .running)
  }

  // MARK: - Punkt 4 z 23.09: nieudany pomiar wolnego miejsca

  /// TA awaria. `freeGB()` zwracalo `0`, gdy `statfs` zawiodl. Zero spelnialo
  /// warunek pauzy (`free <= minFreeGB`) natychmiast i NIGDY nie spelnialo
  /// warunku wznowienia (`free > minFreeGB`) - dozorca wstrzymywal Time
  /// Machine na podstawie liczby, ktorej nie zmierzyl, i nie wznawial go juz
  /// nigdy.
  func testNieudanyPomiarWolnegoMiejscaNieWstrzymujeBackupu() async {
    let atrapa = Atrapa()
    let dozorca = await nadzorujacy(atrapa)

    atrapa.freeGB = nil
    atrapa.backlogGB = 2  // zaleglosc w porzadku, wiec jedyny powod pauzy to dysk
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
    let dozorca = await wstrzymany(atrapa)

    atrapa.backlogGB = 1
    atrapa.freeGB = nil
    await dozorca.step()
    let stan = await dozorca.currentState()
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
    // Wysylka nadgonila i miejsce jest - jedyny przypadek, ktory wznawia.
    XCTAssertTrue(
      BufferGuardService.canResumeLocally(backlog: 2, free: 500, thresholds: progi))
    // Wysylka nadgonila, ale dysk nadal pelny.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 2, free: 10, thresholds: progi))
    // Dysk pusty, ale zaleglosc jeszcze nie zeszla.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 100, free: 500, thresholds: progi))
    // Brak pomiaru wolnego miejsca - nie wiadomo, wiec nie wznawiamy.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 2, free: nil, thresholds: progi))
    // Brak odpowiedzi o zaleglosci - to samo.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: nil, free: 500, thresholds: progi))
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
