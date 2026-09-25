import Foundation

/// Pilnuje, zeby bufor nie zjadl dysku - port `gdrive/buffer-guard.sh`.
///
/// Time Machine pisze do podpietego obrazu z predkoscia SSD (zmierzone
/// 267 MB/s), a rclone wysyla z predkoscia lacza (~41 MB/s przy 332 Mb/s
/// uploadu). Roznica laduje w buforze.
///
/// `--vfs-cache-max-size` jest limitem MIEKKIM: rclone usuwa z bufora tylko
/// dane juz wyslane, wiec gdy wszystko czeka w kolejce, bufor rosnie dalej
/// i moze zapelnic dysk. Przy pierwszym backupie liczonym w terabajtach to nie
/// jest teoria - zmierzony przyrost netto na starcie wynosil 32 MB/s.
///
/// Dozorca wstrzymuje Time Machine, gdy ZALEGLOSC NIEWYSLANA przekroczy prog,
/// i wznawia, gdy wysylka nadgoni. Backup staje sie wolniejszy, ale konczy sie
/// zamiast wysypac maszyne.
///
/// Trzy rzeczy, ktore trzeba tu wiedziec, bo kazda byla kiedys zrobiona
/// odwrotnie i kazda kosztowala cala ochrone:
///
/// 1. Mierzymy ZALEGLOSC, nie rozmiar cache'a. Rozmiar cache'a stoi pod
///    limitem stale i nie odpowiada na pytanie, czy wysylka nadaza
///    (patrz `backlogGB` i `Thresholds.init`).
/// 2. "Nie wiem" nie jest ani pauza, ani wznowieniem. Brak odpowiedzi rclone
///    nie zamienia sie na liczbe, a nieczytelny log rclone nie zamienia sie
///    na "nie ma problemu".
/// 3. Pauza trwa tyle, ile ja podtrzymujemy. `tmutil stopbackup` anuluje
///    TRWAJACY backup i nie rusza harmonogramu, wiec macOS startuje kolejny
///    w swoim cyklu godzinowym - dlatego wstrzymanie ponawia sie przy kazdym
///    tyknieciu, a nie tylko przy zmianie stanu (patrz `keepPaused`).
public actor BufferGuardService {

  public struct Thresholds: Sendable {
    /// Powyzej tylu GB ZALEGLOSCI NIEWYSLANEJ wstrzymujemy Time Machine.
    ///
    /// Zaleglosc, nie rozmiar cache'a - patrz `backlogGB` po powod.
    public var highGB: Int
    /// Ponizej tylu GB zaleglosci wznawiamy.
    public var lowGB: Int
    /// Ponizej tylu GB wolnych na dysku wstrzymujemy niezaleznie od bufora.
    public var minFreeGB: Int
    /// Ponizej tylu GB wolnych NA DYSKU GOOGLE nie wolno zdjac pauzy
    /// zalozonej z powodu braku miejsca na Dysku.
    ///
    /// Ta sama liczba, ktora `BackupHealth` uwaza za prog ostrzegawczy dla
    /// Dysku - jedno zrodlo prawdy. Przy przyroscie rzedu 600 MB na cykl
    /// godzinowy 30 GB to okolo dwoch tygodni zapasu, czyli tyle, zeby
    /// wznowiony backup mial gdzie sie zmiescic, a nie wrocil pod sciane
    /// w kolejnej godzinie.
    public var minDriveFreeGB: Int

    /// Progi wyliczane z rozmiaru bufora, nie wpisane z palca - ale liczone
    /// OD NOWA, odkad dozorca mierzy zaleglosc niewyslana, a nie rozmiar
    /// cache'a. Dawne 1,5x i 0,4x `cacheSizeGB` nie sa tu przeliczone, bo
    /// odnosily sie do innej wielkosci i w tej nie znacza nic.
    ///
    /// CO BYLO ZLE
    ///
    /// Stara para (150 GB / 40 GB) odnosila sie do `bytesUsed`, czyli do
    /// rozmiaru CALEGO cache'a. Ten przy `--vfs-cache-max-size 100G` i
    /// `--vfs-cache-max-age 9999h` stoi pod limitem stale: w dzienniku 281
    /// pomiarow, minimum 99 GB. Prog wznowienia 40 GB byl wiec wartoscia
    /// NIEOSIAGALNA, a prog pauzy 150 GB - osiagalnym tylko przez wynik
    /// obchodu katalogu, czyli przez INNA miare. Widac to w logu wprost:
    /// JEDNA linia PAUZA (23.09.2026 03:34, "bufor 155 GB") i ZERO linii
    /// WZNOWIENIE.
    ///
    /// DLACZEGO PROGI SA FRAKCJA `cacheSizeGB`, ALE PONIZEJ NIEGO
    ///
    /// Zaleglosc niewyslana to dokladnie ta czesc cache'a, ktorej rclone NIE
    /// MOZE usunac - usuwa tylko to, co juz wyslal. Dopoki zaleglosc jest
    /// mniejsza od `cacheSizeGB`, cache ma z czego sie kurczyc i limit
    /// dziala. Gdy zaleglosc dobija do `cacheSizeGB`, zapasu nie ma i kazdy
    /// kolejny gigabajt zapisu idzie PONAD limit, prosto w wolne miejsce na
    /// dysku. Prog pauzy musi wiec lezec PONIZEJ rozmiaru cache'a - odwrotnie
    /// niz dawne 150 GB, ktore lezalo powyzej.
    ///
    /// `highGB` = polowa bufora, dzis 50 GB:
    ///  - zostawia 50 GB zapasu usuwalnego, czyli okolo 26 minut przy
    ///    zmierzonym przyroscie netto 32 MB/s - z zapasem na tykniecie co
    ///    30 s i na to, zeby `tmutil stopbackup` zdazyl zadzialac;
    ///  - lezy ponad trzykrotnie powyzej najwyzszej zaleglosci widzianej
    ///    w normalnej pracy (462 pozycje, czyli okolo 15 GB), wiec zwykly
    ///    backup ani zator na dobowym limicie Google nie wstrzymuja kopii.
    ///    To ostatnie jest zamierzone i opisane nizej w `step()`.
    ///
    /// `lowGB` = jedna dziesiata bufora, dzis 10 GB:
    ///  - musi byc OSIAGALNY, bo na tym przewrocila sie poprzednia wersja.
    ///    Po pauzie nowe pasma nie powstaja, odroczenie `writeBackSeconds`
    ///    mija i kolejka schodzi z predkoscia lacza (zmierzone 23.09: 96 Mb/s,
    ///    czyli okolo 43 GB/h), wiec droga 50 -> 10 GB to okolo godziny;
    ///  - histereza 40 GB to przy zmierzonej roznicy predkosci (267 MB/s
    ///    zapisu Time Machine, 41 MB/s wysylki, netto 226 MB/s) okolo trzech
    ///    minut pracy miedzy kolejnymi pauzami. Prog wznowienia blisko progu
    ///    pauzy dawalby start/stop przy niemal kazdym tyknieciu.
    ///
    /// Ochrona dysku NIE zalezy od tych dwoch liczb: `minFreeGB` i zglaszany
    /// przez rclone `outOfSpace` dzialaja niezaleznie od zaleglosci i w KAZDYM
    /// stanie dozorcy (patrz `step()`).
    public init(
      highGB: Int = DriveBufferService.cacheSizeGB / 2,
      lowGB: Int = DriveBufferService.cacheSizeGB / 10,
      minFreeGB: Int = 80,
      minDriveFreeGB: Int = BackupHealth.driveFreeWarningGB
    ) {
      self.highGB = highGB
      self.lowGB = lowGB
      self.minFreeGB = minFreeGB
      self.minDriveFreeGB = minDriveFreeGB
    }
  }

  public enum State: String, Sendable {
    /// Nadzorujemy trwajacy backup.
    case running
    case pausedForBuffer
    case pausedForQuota
    /// Backup nie trwa - czuwamy do nastepnego.
    ///
    /// Dozorca NIE konczy pracy po skonczonym backupie. Dziala pod launchd
    /// z KeepAlive, wiec wyjscie oznaczaloby natychmiastowy restart, a przy
    /// niedzialajacym Time Machine - ciasna petle restartow ograniczana tylko
    /// przez ThrottleInterval.
    case idle
  }

  public struct Snapshot: Sendable {
    public var state: State
    /// Zaleglosc niewyslana w GB. `nil` = rclone nie odpowiedzial, czyli NIE
    /// WIADOMO - i wtedy dozorca ANI nie wstrzymuje, ANI nie wznawia backupu.
    public var backlogGB: Int?
    /// `nil` = pomiaru NIE BYLO (statfs zawiodl), a nie "zero gigabajtow".
    public var freeGB: Int?
    /// `nil` = tmutil nie odpowiedzial, czyli nie wiadomo.
    public var backupRunning: Bool?
    public var percent: Double
  }

  /// Zrodla pomiarow i sterowania.
  ///
  /// Domyslne (`live`) czytaja prawdziwy system. Test podstawia wlasne i dzieki
  /// temu przechodzi CALA sciezke decyzji dozorcy - pauze, zmiane stanu,
  /// wznowienie - bez tmutil, rclone i prawdziwego backupu. Ten sam wzorzec,
  /// co `preferencesFile` w `BackupHealth.currentReport`: nie da sie inaczej
  /// wstrzyknac ZNANEJ ZLEJ probki, a wlasnie w decyzjach dozorcy (a nie
  /// w parsowaniu) siedzialy tu ciche awarie.
  public struct Probes: Sendable {
    public var queueStats: @Sendable () async -> DriveBufferService.QueueStats?
    /// Rozmiar cache'a na dysku - WYLACZNIE do jednej linii w logu.
    ///
    /// Osobna sonda, a nie wywolanie w miejscu, z dwoch powodow. Pierwszy:
    /// wolamy ja tylko wtedy, gdy raportujemy brak odpowiedzi rclone, bo
    /// w wersji `live` to obchod 6504 plikow na dysku, po ktorym leci backup.
    /// Drugi: test musi umiec pokazac, ze ta liczba nie bierze udzialu w
    /// ZADNEJ decyzji - podaje jej 155 GB z produkcyjnego przebiegu 23.09
    /// i sprawdza, ze dozorca nadal nie wstrzymuje Time Machine.
    public var cacheSizeGB: @Sendable (DriveBufferService.QueueStats?) -> Int?
    /// `nil` = nie zmierzono.
    public var freeGB: @Sendable () -> Int?
    /// `nil` = tmutil nie odpowiedzial.
    public var backupRunning: @Sendable () async -> Bool?
    public var progressPercent: @Sendable () async -> Double
    /// Czy na Dysku Google skonczylo sie miejsce. `nil` = LOGU RCLONE NIE DA
    /// SIE PRZECZYTAC, czyli nie wiadomo - a nie "nie ma problemu".
    public var hitStorageQuota: @Sendable () -> Bool?
    /// Czy wysylka stoi na dobowym limicie. `nil` jak wyzej.
    public var uploadStalled: @Sendable () -> Bool?
    /// Wolne bajty na Dysku Google. `nil` = NIE WIADOMO (rclone nie
    /// odpowiedzial) - i to nie jest zgoda na wznowienie.
    public var driveFreeBytes: @Sendable () async -> UInt64?
    /// `true` TYLKO gdy tmutil potwierdzil wykonanie polecenia.
    public var stopBackup: @Sendable () async -> Bool
    public var startBackup: @Sendable () async -> Bool
    /// Zgloszenie zatoru wysylki. `nil` ("nie wiem") NIE MA PRAWA gasic
    /// znacznika zatoru - patrz `reportUploadStall`.
    public var reportStall: @Sendable (Bool?) async -> Void
    /// Wydzielone, zeby test nie dopisywal swoich zmyslonych "PAUZA (prog)"
    /// do produkcyjnego `cloudmachine.log` - ten log sluzy do diagnozy
    /// prawdziwych awarii i nie moze zawierac zdarzen, ktore sie nie zdarzyly.
    public var log: @Sendable (String) -> Void

    public init(
      queueStats: @escaping @Sendable () async -> DriveBufferService.QueueStats?,
      cacheSizeGB: @escaping @Sendable (DriveBufferService.QueueStats?) -> Int?,
      freeGB: @escaping @Sendable () -> Int?,
      backupRunning: @escaping @Sendable () async -> Bool?,
      progressPercent: @escaping @Sendable () async -> Double,
      hitStorageQuota: @escaping @Sendable () -> Bool?,
      uploadStalled: @escaping @Sendable () -> Bool?,
      driveFreeBytes: @escaping @Sendable () async -> UInt64?,
      stopBackup: @escaping @Sendable () async -> Bool,
      startBackup: @escaping @Sendable () async -> Bool,
      reportStall: @escaping @Sendable (Bool?) async -> Void,
      log: @escaping @Sendable (String) -> Void
    ) {
      self.queueStats = queueStats
      self.cacheSizeGB = cacheSizeGB
      self.freeGB = freeGB
      self.backupRunning = backupRunning
      self.progressPercent = progressPercent
      self.hitStorageQuota = hitStorageQuota
      self.uploadStalled = uploadStalled
      self.driveFreeBytes = driveFreeBytes
      self.stopBackup = stopBackup
      self.startBackup = startBackup
      self.reportStall = reportStall
      self.log = log
    }

    public static let live = Probes(
      queueStats: { await DriveBufferService.queueStats() },
      cacheSizeGB: { BufferGuardService.cacheSizeGB(stats: $0) },
      freeGB: { BufferGuardService.freeGB() },
      backupRunning: { await TimeMachineStatus.runningState() },
      progressPercent: { (await TimeMachineStatus.currentProgress())?.percent ?? 0 },
      // Wersje `...State()`, nie `hitStorageQuota()`/`uploadStalled()`: te
      // drugie sa do wyswietlenia i zamieniaja "nie wiem" na `false`.
      hitStorageQuota: { DriveBufferService.hitStorageQuotaState() },
      uploadStalled: { DriveBufferService.uploadStalledState() },
      driveFreeBytes: { await DriveBufferService.remoteQuota()?.free },
      stopBackup: { await BufferGuardService.tmutil("stopbackup") },
      startBackup: { await BufferGuardService.tmutil("startbackup") },
      reportStall: { await BufferGuardService.reportUploadStall($0) },
      log: { CMLogger.log($0) })
  }

  private let thresholds: Thresholds
  private let probes: Probes
  private var state: State = .idle
  /// Czy od ostatniego przejscia w czuwanie widzielismy dzialajacy backup -
  /// zeby zameldowac zakonczenie raz, a nie przy kazdym tyknieciu.
  private var sawBackupRunning = false
  /// Czy poprzedni krok juz zglosil nieudane wstrzymanie - zeby przy awarii
  /// trwajacej godzinami log nie urosl o linie co 30 sekund, ale zeby samo
  /// zdarzenie NIE zniknelo (patrz `EdgeTriggeredLog`, ten sam powod).
  private var reportedStopFailure = false
  /// To samo dla braku pomiaru wolnego miejsca.
  private var reportedFreeUnknown = false
  /// To samo dla braku odpowiedzi o zaleglosci niewyslanej.
  private var reportedBacklogUnknown = false
  /// To samo dla nieczytelnego logu rclone.
  private var reportedLogUnreadable = false
  /// To samo dla Time Machine, ktory ruszyl w trakcie pauzy.
  private var reportedRestop = false
  /// To samo dla pauzy z powodu braku miejsca na Dysku trzymanej bez dowodu.
  private var reportedQuotaHold = false

  public init(thresholds: Thresholds = Thresholds(), probes: Probes = .live) {
    self.thresholds = thresholds
    self.probes = probes
  }

  // MARK: - Pomiary

  /// ZALEGLOSC NIEWYSLANA w GB - jedyna miara, na ktorej dozorca decyduje
  /// o pauzie i o wznowieniu. `nil` = rclone nie odpowiedzial, czyli NIE WIEMY.
  ///
  /// DLACZEGO NIE ROZMIAR CACHE'A
  ///
  /// Do 25.09.2026 dozorca patrzyl na `stats.bytesUsed`, czyli na rozmiar
  /// calego cache'a rclone. Przy `--vfs-cache-max-size 100G` i
  /// `--vfs-cache-max-age 9999h` ta liczba stoi pod limitem zawsze - rclone
  /// trzyma w cache'u takze to, co dawno wyslal. Dozorca mierzyl wiec stan
  /// prawie STALY i pytal go o rzecz ZMIENNA: czy wysylka nadaza za zapisem.
  /// Skutek w dzienniku: 281 pomiarow, minimum 99 GB, jedna pauza i ani jedno
  /// wznowienie. Zaleglosc niewyslana to ta sama wielkosc, ktora decyduje
  /// o tym, czy cache w ogole moze sie skurczyc - patrz `Thresholds.init`.
  ///
  /// DLACZEGO Z LICZBY POZYCJI, A NIE Z BAJTOW
  ///
  /// `vfs/stats` nie podaje liczby niewyslanych BAJTOW: ma liczniki pozycji
  /// (`uploadsQueued`, `uploadsInProgress`) i `bytesUsed` calego cache'a.
  /// Rozmiary pozycji wystawia `vfs/queue`, ale to DRUGIE wywolanie interfejsu
  /// rc w kazdym tyknieciu, a samo `vfs/stats` bylo tu zmierzone na 36,7 s
  /// przy zapchanym buforze (patrz `DriveBufferService.queueStats`) -
  /// podwojenie tego kosztu wydluza reakcje dokladnie wtedy, gdy zaleglosc
  /// rosnie najszybciej. I prawie nic by nie dalo: kazda pozycja w tej kolejce
  /// to pasmo sparsebundle o STALYM rozmiarze `BackupImageService.bandSectors`
  /// (32 MiB), wiec suma rozmiarow to niemal dokladnie liczba pozycji razy
  /// 32 MiB. Kontrola na prawdziwych liczbach: 462 pozycje z 23.09 daja stad
  /// 14 GB, a wlasciciel liczyl "okolo 15 GB".
  ///
  /// TO JEST SZACUNEK, nie pomiar - i tak jest opisany w logu (znak "~").
  /// Blad idzie w JEDNA strone: pasma niepelne i drobne pliki metadanych sa
  /// MNIEJSZE niz 32 MiB, wiec szacunek zawyza zaleglosc, a zawyzona zaleglosc
  /// wstrzymuje backup wczesniej. Przy ochronie dysku to wlasciwy kierunek
  /// pomylki.
  public static func backlogGB(stats: DriveBufferService.QueueStats?) -> Int? {
    guard let stats else { return nil }
    let bandBytes = UInt64(BackupImageService.bandSectors) * 512
    return Int(UInt64(max(0, stats.unsentItems)) * bandBytes / 1_073_741_824)
  }

  /// Rozmiar cache'a rclone w GB - do PODGLADU I LOGU, nigdy do decyzji.
  /// `nil` = nie zmierzono ani jedna droga.
  ///
  /// Dwa zrodla tej liczby NIE SA ROWNOWAZNE i dlatego nie wolno ich mieszac
  /// w decyzji: rclone podaje rozmiar wlasnego cache'a, a obchod katalogu
  /// MIEJSCE ZAJETE NA DYSKU, ktore limit `--vfs-cache-max-size` potrafi
  /// przekroczyc (stad "155 GB" przy limicie 100 GB). Do wiersza statusu oba
  /// nadaja sie na tyle, na ile nadaje sie kazde przyblizenie; do wstrzymania
  /// Time Machine nie nadaje sie zadne - patrz
  /// `DriveBufferService.cacheSizeBytesByWalk`.
  public static func cacheSizeGB(stats: DriveBufferService.QueueStats? = nil) -> Int? {
    if let bytes = stats?.bytesUsed, bytes > 0 { return Int(bytes / 1_073_741_824) }
    guard let walked = DriveBufferService.cacheSizeBytesByWalk() else { return nil }
    return Int(walked / 1_073_741_824)
  }

  /// Rozmiar cache'a dla interfejsu, ktory nie ma gdzie pokazac "nie wiem"
  /// (`BufferStatus.sizeGB`). Zachowuje sie dokladnie tak, jak zachowywal sie
  /// dawny `bufferGB` - z podstawionym zerem wlacznie.
  ///
  /// ZADNA DECYZJA nie ma prawa tego wolac; dozorca uzywa `backlogGB`. Zero za
  /// brak pomiaru zostaje tu do usuniecia razem z `BufferStatus` i
  /// `CloudMachineController`, ktore trzeba nauczyc trzeciego stanu - to
  /// osobna zmiana, poza ta galezia.
  public static func bufferGB(stats: DriveBufferService.QueueStats? = nil) -> Int {
    cacheSizeGB(stats: stats) ?? 0
  }

  /// Wolne miejsce liczone tak, jak liczy je `df` - czyli PESYMISTYCZNIE.
  ///
  /// Kusi, zeby uzyc `volumeAvailableCapacityForImportantUsageKey`, ale to
  /// miara optymistyczna: wlicza miejsce zajete przez lokalne migawki, ktore
  /// system dopiero MOGLBY zwolnic. Na tej maszynie pokazywala 1202 GB, gdy
  /// `df` mowilo 427 GB. Dozorca ma wstrzymywac backup, zanim dysk sie zapelni,
  /// wiec musi patrzec na miejsce faktycznie dostepne teraz, a nie na obietnice.
  ///
  /// `nil` znaczy "NIE ZMIERZONO", i to nie jest kosmetyka. Wczesniej nieudany
  /// `statfs` zwracal `0`, czyli liczbe - a wtedy warunek pauzy
  /// (`free <= minFreeGB`) byl spelniony natychmiast, warunek wznowienia
  /// (`free > minFreeGB`) NIGDY, i dozorca wstrzymywal Time Machine na zawsze.
  /// Rownolegle czujka meldowala "Konczy sie miejsce na dysku Maca (0 GB)" -
  /// alarm o stanie, ktorego nikt nie zmierzyl. To samo rozroznienie, ktore
  /// `BufferStatus.queueKnown` wprowadzil juz dla kolejki wysylki.
  public static func freeGB() -> Int? {
    var stats = statfs()
    guard statfs("/System/Volumes/Data", &stats) == 0 else { return nil }
    let available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
    return Int(available / 1_073_741_824)
  }

  /// Czy wolno wznowic Time Machine, patrzac WYLACZNIE na pomiary lokalne.
  ///
  /// Czysta funkcja - decyzja da sie sprawdzic testem bez dysku i bez tmutil.
  /// `free == nil` nie wznawia: brak pomiaru to nie jest dowod, ze miejsce
  /// jest. Wznowienie sprawdza wolne miejsce TAK SAMO jak pauza, bo pauza
  /// chroniaca dysk nie moze byc odwolywana przez warunek, ktory o dysku nic
  /// nie wie.
  ///
  /// `backlog == nil` tez nie wznawia, i to jest ta sama regula zastosowana do
  /// drugiej liczby. Wczesniej brak odpowiedzi rclone konczyl sie obchodem
  /// katalogu, a nieudany obchod - zerem; zero zas spelnia warunek wznowienia
  /// natychmiast, czyli ZDEJMOWALO pauze zalozona dlatego, ze bufor byl pelny.
  static func canResumeLocally(backlog: Int?, free: Int?, thresholds: Thresholds) -> Bool {
    guard let backlog, let free else { return false }
    return backlog <= thresholds.lowGB && free > thresholds.minFreeGB
  }

  /// Czy na Dysku Google jest DOWIEDZIONE miejsce na dalsza prace.
  ///
  /// `nil` (rclone nie odpowiedzial) to NIE jest zgoda - patrz `step()`.
  static func driveHasRoom(freeBytes: UInt64?, minGB: Int) -> Bool {
    guard let freeBytes else { return false }
    return freeBytes / 1_073_741_824 >= UInt64(max(0, minGB))
  }

  // MARK: - Jeden krok

  /// Wykonuje jeden krok nadzoru i zwraca stan. Wydzielone z petli, zeby dalo
  /// sie sprawdzic decyzje testem bez czekania w czasie rzeczywistym.
  ///
  /// UKLAD TEJ FUNKCJI JEST CZESCIA POPRAWKI. Do 25.09.2026 sprawdzenia
  /// `stats?.outOfSpace` i wolnego miejsca siedzialy WYLACZNIE w galezi
  /// `.running`, a galaz `.pausedForBuffer` nie patrzyla na nic poza warunkiem
  /// wznowienia. Po jednej pauzie dozorca przestawal wiec pilnowac dysku -
  /// czyli ochrona, dla ktorej ten proces istnieje, wylaczala sie do restartu
  /// agenta. Zmierzone: 53 godziny w tym stanie (pauza 23.09.2026 03:34 ->
  /// restart procesu 25.09.2026 08:46). Dlatego ochrona dysku i `outOfSpace`
  /// stoja TERAZ PRZED `switch state` i nie da sie ich pominac zadna sciezka
  /// przez te funkcje.
  @discardableResult
  public func step() async -> Snapshot {
    let stats = await probes.queueStats()
    let backlog = Self.backlogGB(stats: stats)
    let free = probes.freeGB()
    let running = await probes.backupRunning()
    let percent = await probes.progressPercent()
    // Oba pytania ida do logu rclone i oba sa trzystanowe: nieczytelny plik
    // to "nie wiem", nie "nie ma problemu".
    let quota = probes.hitStorageQuota()
    let stalled = probes.uploadStalled()

    func snapshot() -> Snapshot {
      Snapshot(
        state: state, backlogGB: backlog, freeGB: free, backupRunning: running, percent: percent)
    }

    // Nieudany pomiar wolnego miejsca NIE moze przejsc po cichu: od tej liczby
    // zalezy jedyna ochrona dysku przed zapelnieniem, a bez niej dozorca nie
    // wstrzyma Time Machine (i slusznie - nie zgaduje). Czlowiek musi o tym
    // wiedziec z logu, a nie z pelnego dysku.
    if free == nil, !reportedFreeUnknown {
      probes.log(
        "UWAGA: nie da sie zmierzyc wolnego miejsca na dysku (statfs zawiodl) - dozorca nie wstrzyma Time Machine z powodu dysku, bo nie ma na czym oprzec decyzji."
      )
    }
    reportedFreeUnknown = (free == nil)

    // Brak odpowiedzi rclone tez nie moze przejsc po cichu - ale tym razem NIE
    // ZAMIENIAMY go na liczbe. 23.09.2026 dozorca w tej sytuacji schodzil na
    // obchod katalogu, dostawal 155 GB (miejsce zajete na dysku - miara
    // nieporownywalna z limitem 100 GB), przekraczal tym prog i wstrzymywal
    // Time Machine; godzine pozniej czujka zapisala "Interfejs sterujacy
    // rclone nie odpowiada". Pauza stala wiec na liczbie wzietej stad, ze
    // pomiaru nie bylo. Rozmiar cache'a wypisujemy nadal - ale JAKO CO INNEGO,
    // raz na epizod i bez zadnego wplywu na decyzje.
    if backlog == nil, !reportedBacklogUnknown {
      let cache = probes.cacheSizeGB(stats)
      probes.log(
        "UWAGA: interfejs sterujacy rclone nie odpowiada - nie wiadomo, ile zostalo do wyslania. Dozorca ANI nie wstrzyma, ANI nie wznowi Time Machine na tej podstawie. Cache zajmuje na dysku \(cache.map { "\($0) GB" } ?? "nie wiadomo ile") - to MIEJSCE NA DYSKU, nie zaleglosc do wyslania, i nie jest podstawa do pauzy. Ochrona dysku dziala dalej: wolne \(describe(free)), prog \(thresholds.minFreeGB) GB."
      )
    }
    reportedBacklogUnknown = (backlog == nil)

    // Nieczytelny log rclone znaczy "nie wiem" po OBU pytaniach zadawanych
    // temu plikowi. Wczesniej znaczyl "nie ma problemu", a to mialo dwa
    // skutki: dozorca nie wstrzymywal backupu przy braku miejsca na Dysku,
    // a `reportStall(false)` KASOWAL znacznik zatoru i meldowal "Wysylka na
    // Google Drive ruszyla z powrotem" - twierdzenie o zdarzeniu, ktorego
    // nikt nie sprawdzil. Log ma prawa `-rw-r-----`, a przy starcie rclone
    // jest przenoszony na `.1`, wiec nieczytelny log to stan spodziewany,
    // nie hipoteza.
    let logUnreadable = (quota == nil || stalled == nil)
    if logUnreadable, !reportedLogUnreadable {
      probes.log(
        "UWAGA: nie da sie przeczytac logu rclone (\(DriveBufferService.logFile.path)) - dozorca nie rozpozna ani braku miejsca na Google Drive, ani zatoru wysylki. Znacznik zatoru zostaje bez zmian, bo 'nie wiem' go nie gasi."
      )
    }
    reportedLogUnreadable = logUnreadable

    // Dobowy limit uploadu to CO INNEGO i celowo NIE wstrzymuje backupu.
    //
    // Zmierzone na dwoch epizodach (12 i 15 wrzesnia 2026): przy zatorze
    // trwajacym kilka godzin bufor ani drgnal - 99-103 GB, dokladnie tyle,
    // co zwykle - a kolejka rozeszla sie sama, gdy okno kroczace 24 h
    // przesunelo sie do przodu. Pauza kosztowalaby wtedy kopie i nie dalaby
    // nic w zamian. Przed zapelnieniem dysku chronia progi ponizej i one
    // dzialaja niezaleznie od tego, co jest przyczyna zatoru.
    //
    // Zglaszamy natomiast ZAWSZE, bo zator z 12 wrzesnia przeszedl zupelnie
    // niezauwazony - trzy godziny bez wysylki i ani jednego sladu poza
    // surowym logiem rclone. `nil` idzie dalej jako `nil`: zgloszenie samo
    // wie, ze "nie wiem" niczego nie gasi.
    await probes.reportStall(stalled)

    // Brak MIEJSCA na Dysku ma pierwszenstwo i nie minie sam: dopoki
    // uzytkownik czegos nie skasuje, wysylka nie ruszy, a dalsza praca
    // Time Machine tylko pompuje bufor. `nil` (nieczytelny log) NIE wstrzymuje
    // - brak odpowiedzi nie jest dowodem awarii, tak samo jak nie jest
    // dowodem jej braku; zglosilismy go wyzej w logu.
    if quota == true {
      if state == .pausedForQuota {
        await keepPaused(backupRunning: running)
      } else {
        await pause(
          reason:
            "PAUZA (brak miejsca na Google Drive): zaleglosc \(describeBacklog(backlog)), wolne \(describe(free))",
          into: .pausedForQuota, backupRunning: running)
      }
      return snapshot()
    }

    // OCHRONA DYSKU - W KAZDYM STANIE, nie tylko w `.running`.
    //
    // `outOfSpace` pochodzi od rclone i znaczy "nie mam juz gdzie odlozyc
    // danych" - to twardszy fakt niz jakikolwiek nasz prog, i nie przestaje
    // byc faktem dlatego, ze dozorca wlasnie stoi w pauzie.
    //
    // Brak pomiaru wolnego miejsca (`free == nil`) NIE wstrzymuje backupu.
    // Wczesniej nieudany `statfs` dawal zero, zero spelnialo warunek pauzy
    // i dozorca wstrzymywal Time Machine na podstawie liczby, ktorej nigdy
    // nie zmierzyl - a potem nie umial go wznowic, bo warunek wznowienia
    // przy zerze nie zachodzi nigdy.
    let lowDisk = free.map { $0 <= thresholds.minFreeGB } ?? false
    let bufferFull = stats?.outOfSpace == true
    if bufferFull || lowDisk {
      let why =
        bufferFull ? "rclone zglasza brak miejsca w buforze" : "malo wolnego miejsca na dysku"
      switch state {
      case .pausedForBuffer, .pausedForQuota:
        // Juz stoimy, wiec nie ma czego oglaszac - ale Time Machine mogl
        // ruszyc sam w swoim cyklu godzinowym, wiec wstrzymanie ponawiamy.
        // WAZNE: nie wracamy stad do wznawiania. Dopoki dysk jest pod sciana,
        // zaden warunek wznowienia nie ma prawa zdjac pauzy.
        await keepPaused(backupRunning: running)
      case .running, .idle:
        // Takze z `.idle`: dysk zapelnia sie niezaleznie od tego, czy backup
        // trwa w tej sekundzie, a macOS zaczyna kolejny co godzine. Wejscie
        // w pauze sprawia, ze nastepne tykniecie go zatrzyma.
        await pause(
          reason:
            "PAUZA (\(why)): zaleglosc \(describeBacklog(backlog)), wolne \(describe(free)) - czekam na wysylke",
          into: .pausedForBuffer, backupRunning: running)
      }
      return snapshot()
    }

    switch state {
    case .idle:
      // Tylko JAWNE "tak". `nil` (tmutil nie odpowiedzial) zostawia stan bez
      // zmiany - nie zaczynamy nadzoru nad czyms, o czym nic nie wiemy.
      if running == true {
        probes.log("Backup ruszyl - nadzoruje zaleglosc wysylki")
        sawBackupRunning = true
        state = .running
      }

    case .running:
      // `backlog == nil` NIE wstrzymuje: to ten sam wzorzec, co przy `free`.
      // Brak odpowiedzi rclone nie jest liczba i nie ma prawa uruchomic
      // nieodwracalnej pauzy.
      if let backlog, backlog >= thresholds.highGB {
        await pause(
          reason:
            "PAUZA (prog zaleglosci \(thresholds.highGB) GB): zaleglosc \(describeBacklog(backlog)), wolne \(describe(free)) - czekam na wysylke",
          into: .pausedForBuffer, backupRunning: running)
      } else if running == false {
        if sawBackupRunning {
          probes.log("Time Machine zakonczyl. Zaleglosc \(describeBacklog(backlog))")
          sawBackupRunning = false
        }
        state = .idle
      }

    case .pausedForBuffer:
      // Wznawiamy dopiero, gdy wysylka faktycznie nadgonila - inaczej
      // wpadlibysmy w oscylacje start/stop przy progu. Dopoki nie nadgonila,
      // PODTRZYMUJEMY wstrzymanie: `tmutil stopbackup` z chwili pauzy dotyczyl
      // tylko tego jednego przebiegu.
      if Self.canResumeLocally(backlog: backlog, free: free, thresholds: thresholds) {
        await resume(backlogGB: backlog, freeGB: free)
      } else {
        await keepPaused(backupRunning: running)
      }

    case .pausedForQuota:
      // Pauza z powodu BRAKU MIEJSCA na Dysku wymaga do zdjecia POZYTYWNEGO
      // dowodu, ze miejsce jest. To nie jest ostroznosc na zapas:
      //
      // `hitStorageQuota()` czyta wpisy z ostatnich 30 minut logu rclone.
      // Po wstrzymaniu Time Machine nowe pasma przestaja powstawac, rclone
      // przestaje probowac wysylac, wpisy sie starzeja i funkcja zaczyna
      // zwracac `false` - mimo ze na Dysku jak nie bylo miejsca, tak nie ma.
      // Przy spokojnym buforze (a po pauzie bufor sie wlasnie oprozni)
      // wspolny warunek wznowienia byl wtedy spelniony natychmiast: dozorca
      // puszczal Time Machine, ten pisal kolejne pasma, ktorych nie ma jak
      // wyslac, i cala pauza konczyla sie po kilkudziesieciu minutach bez
      // zmiany czegokolwiek po stronie Dysku. `UploadState` mowi wprost, ze
      // ten stan NIE mija sam.
      guard Self.canResumeLocally(backlog: backlog, free: free, thresholds: thresholds) else {
        await keepPaused(backupRunning: running)
        break
      }
      let driveFree = await probes.driveFreeBytes()
      guard Self.driveHasRoom(freeBytes: driveFree, minGB: thresholds.minDriveFreeGB) else {
        // Brak odpowiedzi od rclone PODTRZYMUJE pauze - "nie wiem" nigdy nie
        // jest zgoda na wznowienie czegos, co zapelnia dysk.
        if !reportedQuotaHold {
          let ile =
            driveFree.map { "\($0 / 1_073_741_824) GB" } ?? "nie wiadomo (rclone nie odpowiedzial)"
          probes.log(
            "PAUZA (brak miejsca na Dysku) utrzymana: wolne na Google Drive \(ile), wymagane co najmniej \(thresholds.minDriveFreeGB) GB."
          )
          reportedQuotaHold = true
        }
        await keepPaused(backupRunning: running)
        break
      }
      reportedQuotaHold = false
      await resume(backlogGB: backlog, freeGB: free)
    }

    return snapshot()
  }

  public func currentState() -> State { state }

  /// Wolne miejsce do logu. Brak pomiaru MUSI wygladac inaczej niz zero,
  /// inaczej linia w logu klamie tak samo, jak klamala sama liczba.
  private func describe(_ freeGB: Int?) -> String {
    freeGB.map { "\($0) GB" } ?? "nie zmierzono"
  }

  /// Zaleglosc do logu. Znak "~" nie jest ozdoba: ta liczba jest SZACOWANA
  /// z liczby pozycji w kolejce (patrz `backlogGB`), a log, ktory podaje
  /// szacunek jako pomiar, klamie o tym, jak mocna jest podstawa decyzji.
  private func describeBacklog(_ gb: Int?) -> String {
    gb.map { "~\($0) GB" } ?? "nie wiadomo (rclone nie odpowiedzial)"
  }

  // MARK: - Sterowanie Time Machine

  /// Wstrzymuje Time Machine i przechodzi w `into` TYLKO gdy sie udalo.
  ///
  /// TO jest ta poprawka. Wczesniej wynik `tmutil stopbackup` byl wyrzucany
  /// (`_ = try? await ...`), a stan zmienial sie BEZWARUNKOWO. Gdy polecenie
  /// padalo - brak uprawnien, przekroczony limit czasu - dozorca uznawal pauze
  /// za wykonana, a poniewaz `stopBackup()` wola sie wylacznie przy ZMIANIE
  /// stanu, nie ponawial jej nigdy. Time Machine pisal dalej, dozorca czekal
  /// na drenaz, dysk zapelnial sie do konca, a w logu stalo "PAUZA ... czekam
  /// na wysylke".
  ///
  /// Przy niepowodzeniu stan zostaje na `.running`, wiec warunek pauzy
  /// (nadal spelniony) wyzwoli kolejna probe przy nastepnym tyknieciu - czyli
  /// za 30 sekund, bez zadnego dodatkowego mechanizmu ponawiania.
  ///
  /// `backupRunning == false` (tmutil mowi WPROST, ze backup nie trwa) jest
  /// osobna sciezka: nie ma wtedy czego wstrzymywac, a wolanie `stopbackup`
  /// bez trwajacego backupu potrafi zwrocic blad - i dozorca zameldowalby
  /// wtedy "Time Machine PISZE DALEJ", czyli twierdzenie o zdarzeniu, ktorego
  /// nikt nie sprawdzil. `nil` ("tmutil nie odpowiedzial") idzie sciezka
  /// scisla, bo brak odpowiedzi nie jest dowodem ciszy.
  private func pause(reason: String, into paused: State, backupRunning: Bool?) async {
    probes.log(reason)
    if backupRunning == false {
      state = paused
      reportedStopFailure = false
      return
    }
    if await probes.stopBackup() {
      state = paused
      reportedStopFailure = false
      return
    }
    if !reportedStopFailure {
      probes.log(
        "NIE UDALO SIE wstrzymac Time Machine (tmutil stopbackup). Stan zostaje na '\(state.rawValue)', ponawiam przy kazdym kolejnym sprawdzeniu. Time Machine PISZE DALEJ - dysk moze sie zapelnic."
      )
      reportedStopFailure = true
    }
  }

  /// PODTRZYMUJE wstrzymanie w stanie pauzy - przy kazdym tyknieciu.
  ///
  /// TO jest ta poprawka. `stopBackup()` wolalo sie WYLACZNIE przy zmianie
  /// stanu, a `tmutil stopbackup` anuluje tylko TRWAJACY backup i nie rusza
  /// harmonogramu (`tmutil disable` nie wystepuje w tym repo ani razu).
  /// Godzine po pauzie macOS startowal wiec kolejny backup: dozorca go nie
  /// zatrzymywal i nie nadzorowal, bo galaz `.pausedForBuffer` nie patrzyla na
  /// nic poza warunkiem wznowienia - a w logu stalo "czekam na wysylke".
  /// Pauza wstrzymywala zapis na jeden przebieg, choc sam stan trwal
  /// 53 godziny. Dokladnie te wade opisuje i naprawia `pause` dla galezi
  /// PORAZKI `stopbackup`; dla powodzenia zostala nietknieta do 25.09.2026.
  ///
  /// Ponawiamy tylko wtedy, gdy tmutil nie mowi wprost "backup nie trwa":
  /// "nie wiem" (`nil`) liczy sie tu jak "trwa", bo brak odpowiedzi nie jest
  /// dowodem ciszy. Przy stojacym Time Machine oszczedza to dwa procesy
  /// (sudo + tmutil) co 30 sekund przez cala pauze - w epizodzie z 23.09
  /// byloby ich ponad 12 tysiecy.
  ///
  /// ODRZUCONA ALTERNATYWA: `tmutil disable`. Wylacza harmonogram raz i na
  /// dobre, wiec pauza trzymalaby sie bez ponawiania - ale stan pauzy dozorca
  /// trzyma W PAMIECI PROCESU, a chodzi pod launchd z `KeepAlive`. Po jego
  /// smierci (albo po restarcie Maca) nikt nie wiedzialby, ze Time Machine
  /// zostal wylaczony i ze trzeba go wlaczyc z powrotem - cicha utrata
  /// backupu na zawsze zamiast wolniejszego backupu. Ponawiane `stopbackup`
  /// jest odwracalne samo z siebie: gdy dozorca przestaje dzialac, Time
  /// Machine wraca do pracy w swoim cyklu godzinowym.
  private func keepPaused(backupRunning: Bool?) async {
    guard backupRunning != false else {
      reportedRestop = false
      return
    }
    if !reportedRestop {
      probes.log(
        "Time Machine pracuje w trakcie pauzy (stan '\(state.rawValue)') - ponawiam wstrzymanie. `tmutil stopbackup` anuluje tylko trwajacy przebieg, a macOS startuje kolejny w swoim cyklu godzinowym."
      )
      reportedRestop = true
    }
    if await probes.stopBackup() {
      reportedStopFailure = false
      return
    }
    if !reportedStopFailure {
      probes.log(
        "NIE UDALO SIE ponowic wstrzymania Time Machine (tmutil stopbackup) w stanie '\(state.rawValue)'. Time Machine PISZE DALEJ do bufora, ktorego oprozniania wlasnie czekamy - dysk moze sie zapelnic."
      )
      reportedStopFailure = true
    }
  }

  /// Wznawia Time Machine.
  ///
  /// Asymetria wzgledem `pause` jest celowa. Nieudane `stopbackup` grozi
  /// zapelnieniem dysku, wiec nie wolno udawac, ze pauza zaszla. Nieudane
  /// `startbackup` nie grozi niczym: Time Machine i tak ruszy sam w swoim
  /// cyklu godzinowym, a `startbackup` jest tylko przyspieszeniem tego.
  /// Gdybysmy przy jego niepowodzeniu zostawali w pauzie, dozorca tkwilby
  /// w stanie, z ktorego jedyne wyjscie wlasnie nie dziala.
  private func resume(backlogGB: Int?, freeGB: Int?) async {
    probes.log("WZNOWIENIE: zaleglosc \(describeBacklog(backlogGB)), wolne \(describe(freeGB))")
    reportedRestop = false
    if await probes.startBackup() == false {
      probes.log(
        "tmutil startbackup nie powiodlo sie - Time Machine ruszy sam w swoim cyklu godzinowym.")
    }
    state = .running
  }

  /// Co zrobic ze znacznikiem zatoru. Czysta funkcja, zeby "nie wiem" dalo sie
  /// sprawdzic testem bez pliku znacznika, bez powiadomienia i bez logu.
  ///
  /// `stalled == nil` to `.doNothing`, i to jest cala poprawka. Wczesniej
  /// nieczytelny log rclone wychodzil z `uploadStalled()` jako `false`, `false`
  /// oznaczal "zator minal" - wiec znacznik byl USUWANY, a do logu szlo
  /// "Wysylka na Google Drive ruszyla z powrotem". Twierdzenie o zdarzeniu,
  /// ktorego nikt nie sprawdzil, i zgaszenie zgloszenia dokladnie w tym
  /// przypadku, dla ktorego ono istnieje.
  enum StallAction: Equatable {
    case raise
    case clear
    case doNothing
  }

  static func stallAction(stalled: Bool?, markerExists: Bool) -> StallAction {
    guard let stalled else { return .doNothing }
    guard stalled != markerExists else { return .doNothing }
    return stalled ? .raise : .clear
  }

  /// Zglasza poczatek i koniec zatoru wysylki - raz na zmiane stanu.
  ///
  /// Stan trzymamy w pliku, a nie w polu, bo `buffer-guard` chodzi pod
  /// launchd z `KeepAlive`: po kazdym wskrzeszeniu procesu pole zaczynaloby
  /// od zera i ten sam zator zglaszalby sie od nowa co 30 sekund.
  ///
  /// `nil` = "nie wiem" i wtedy nie ruszamy NICZEGO - patrz `stallAction`.
  static func reportUploadStall(_ stalled: Bool?) async {
    let marker = CMPaths.appSupportDir.appendingPathComponent(".upload-stalled")
    let reported = FileManager.default.fileExists(atPath: marker.path)
    let action = stallAction(stalled: stalled, markerExists: reported)
    guard action != .doNothing else { return }

    if action == .raise {
      let message = "Wysylka na Google Drive stoi - wyczerpany limit dobowy."
      CMLogger.log("\(message) Kopie ida dalej, zator mija sam w kilka godzin.")
      // Znacznik zakladamy DOPIERO po doreczeniu powiadomienia. Zalozony
      // wczesniej zamykal sprawe takze wtedy, gdy powiadomienie nie doszlo -
      // czyli gasil zgloszenie dokladnie w przypadku, dla ktorego istnieje
      // (ten sam blad, co w `HealthAlert.report`, patrz tamtejszy komentarz).
      if await HealthAlert.notify(title: "CloudMachine: wysylka na Dysk stoi", message: message) {
        FileManager.default.createFile(atPath: marker.path, contents: nil)
      } else {
        CMLogger.log(
          "Powiadomienie o zatorze wysylki NIE zostalo doreczone - sprobuje ponownie przy nastepnym sprawdzeniu."
        )
      }
    } else {
      try? FileManager.default.removeItem(at: marker)
      CMLogger.log("Wysylka na Google Drive ruszyla z powrotem.")
    }
  }

  /// Wola `tmutil <polecenie>` i mowi, czy NAPRAWDE sie udalo.
  ///
  /// Najpierw przez `sudo -n`: `tmutil stopbackup` i `startbackup` wymagaja
  /// uprawnien roota, a dozorca chodzi pod launchd w sesji uzytkownika.
  /// Istniejacy `runTmutilUnattended` byl tu nieuzyty, mimo ze powstal
  /// dokladnie do tego. Regula NOPASSWD w `/etc/sudoers.d/cloudmachine` nie
  /// jest przez nic w tym repo zakladana (sprawdzone: zaden instalator jej
  /// nie pisze), wiec `sudo -n` dzis odmawia natychmiast - i wlasnie dlatego
  /// przy odmowie AUTORYZACJI probujemy jeszcze bez sudo, zamiast uznawac
  /// sprawe za przegrana. `isSudoAuthFailure` odroznia "sudo nas nie wpuscilo"
  /// od "polecenie sie wykonalo i zwrocilo blad".
  static func tmutil(_ command: String) async -> Bool {
    if let viaSudo = try? await ProcessRunner.runTmutilUnattended([command], timeout: 120) {
      if viaSudo.succeeded { return true }
      if !viaSudo.isSudoAuthFailure {
        CMLogger.log(
          "sudo tmutil \(command): kod \(viaSudo.exitCode) \(shortError(viaSudo))")
        return false
      }
    }
    guard let direct = try? await ProcessRunner.run("/usr/bin/tmutil", [command], timeout: 120)
    else {
      CMLogger.log("tmutil \(command): BRAK ODPOWIEDZI w limicie czasu.")
      return false
    }
    if !direct.succeeded {
      CMLogger.log("tmutil \(command): kod \(direct.exitCode) \(shortError(direct))")
    }
    return direct.succeeded
  }

  private static func shortError(_ result: ProcessResult) -> String {
    let text = (result.stderr + " " + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "(bez komunikatu)" : text.replacingOccurrences(of: "\n", with: " ")
  }
}
