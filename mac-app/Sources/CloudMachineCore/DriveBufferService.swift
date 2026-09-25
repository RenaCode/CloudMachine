import Foundation

/// Bufor miedzy Time Machine a Google Drive - port `gdrive/mount-drive.sh`.
///
/// Montuje Drive jako wolumen z lokalnym cache zapisu. Zapis konczy sie
/// w momencie trafienia do cache, wysylka idzie w tle - dlatego zerwanie lacza
/// wstrzymuje drenaz zamiast przerywac backup.
///
/// Proces rclone zostaje na pierwszym planie; cyklem zycia zarzadza launchd
/// (KeepAlive).
public enum DriveBufferService {

  // MARK: - Sciezki i ustawienia

  public static var root: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var mountPoint: URL { root.appendingPathComponent("drive") }
  public static var cacheDir: URL { root.appendingPathComponent("cache") }
  public static var logFile: URL { root.appendingPathComponent("rclone.log") }

  public static let remoteName = "gdrive"
  public static let remotePath = "CloudMachine/mac-studio"
  /// Rozmiar bufora. Trzymany jako liczba, bo progi dozorcy sa z niego
  /// wyliczane - inaczej zmiana jednego bez drugiego daje progi, ktore nigdy
  /// nie zadzialaja albo dzialaja natychmiast.
  public static let cacheSizeGB = 100
  public static var cacheSize: String { "\(cacheSizeGB)G" }

  /// Ile rclone czeka od ostatniej zmiany pasma, zanim je wysle.
  ///
  /// To NIE jest ustawienie ostroznosciowe, tylko zderzak na wzmocnienie
  /// zapisu. Time Machine przepisuje te same pasma przez caly przebieg, a przy
  /// krotkim odroczeniu kazde dotkniecie to pelne 32 MB wysylane od nowa.
  /// Zmierzone na wlasnym logu (56 533 odstepow miedzy kolejnymi wysylkami
  /// TEGO SAMEGO pasma): mediana odstepu to 9,5 minuty, wiec 10 minut sklei
  /// okolo polowy powtorzen. Dalsze wydluzanie oplaca sie coraz slabiej
  /// (15 min -> 57%, 30 min -> 70%), a rosnie okno, w ktorym dane sa TYLKO
  /// lokalnie.
  ///
  /// Historia: bylo 30 s i przy tej wartosci doba 14/15 wrzesnia 2026
  /// wypchnela 823 GB na Dysk przy realnej zmianie okolo 45 GB - czyli ponad
  /// dobowy limit Google (750 GB), co zablokowalo wysylke na kilka godzin.
  ///
  /// Kazda sciezka wygaszania MUSI wymuszac wysylke przez
  /// `expireQueuedUploads()`, inaczej odpiecie czekaloby tyle, co to odroczenie.
  public static let writeBackSeconds = 600

  /// Adres interfejsu sterujacego rclone. Slucha tylko na petli zwrotnej, ale
  /// kazdy lokalny proces moze przez niego sterowac montowaniem - jesli kiedys
  /// uznamy to za zbyt luzne, trzeba dolozyc `--rc-user`/`--rc-pass`.
  public static let rcAddress = "127.0.0.1:5572"

  /// Powyzej tego rozmiaru log rclone jest przycinany przy starcie. rclone nie
  /// rotuje wlasnego logu, a ten projekt stracil juz raz 3.3 GiB na logu,
  /// ktory rosl bez ograniczen.
  private static let logSizeLimit: UInt64 = 100 * 1024 * 1024

  // MARK: - Stan

  /// Punkty montowania prosto z tablicy jadra. `nil` = tablicy NIE UDALO SIE
  /// odczytac, co jest czyms innym niz "nic nie jest zamontowane".
  ///
  /// DLACZEGO NIE `/sbin/mount`
  ///
  /// Do 23 wrzesnia 2026 bylo tu uruchomienie `/sbin/mount` z
  /// `readDataToEndOfFile()` + `waitUntilExit()` BEZ limitu czasu. Przy martwym
  /// montowaniu FUSE-T (incydent ENXIO z 22.09) taki odczyt potrafi wejsc w
  /// nieprzerywalne I/O i nie wrocic - a czyta stad `isMounted`, czyli czujka
  /// `backup-health` ORAZ petla odswiezania GUI chodzaca co 10 sekund.
  /// Zawieszenie wieszalo wiec i podglad, i nadzor, na tej samej awarii,
  /// ktora oba maja wykryc.
  ///
  /// Nalozenie limitu czasu (jak w `TimeMachineStatus.commandTimeout`)
  /// usuneloby zawieszenie, ale kazdy taki limit jest tu czystym kosztem:
  /// przy odswiezaniu co 10 s wywolania zaczelyby sie nakladac, a odpowiedz
  /// i tak by nie przyszla. `getmntinfo(MNT_NOWAIT)` usuwa problem u zrodla -
  /// czyta tablice montowan z pamieci jadra i NIE odpytuje zadnego systemu
  /// plikow (od tego jest `MNT_WAIT`, ktore wlasnie umialoby zawisnac).
  /// Nie ma tu procesu, potoku ani wejscia/wyjscia, wiec nie ma czego
  /// ograniczac limitem. Zmierzone na tej maszynie: 19 montowan w 0,0002 s.
  ///
  /// Przy okazji znika parsowanie tekstu: `f_mntonname` to sciezka wprost,
  /// zamiast szukania `" on <sciezka> "` w wydruku.
  public static func mountPoints() -> [String]? {
    var raw: UnsafeMutablePointer<statfs>?
    let count = getmntinfo(&raw, MNT_NOWAIT)
    guard count > 0, let raw else { return nil }
    return (0..<Int(count)).map { index in
      withUnsafePointer(to: raw[index].f_mntonname) {
        $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { String(cString: $0) }
      }
    }
  }

  /// Czy bufor jest zamontowany. `nil` = NIE WIADOMO.
  ///
  /// Rozroznienie jest tu istotne, bo na tej odpowiedzi stoi decyzja o
  /// podpieciu i o utworzeniu obrazu - a "nie wiem" udajace "nie zamontowane"
  /// to ten sam rodzaj cichej awarii, ktory w tym pliku zamyka juz
  /// `UploadState.queueUnknown` po stronie kolejki.
  public static func mountedState() -> Bool? {
    guard let points = mountPoints() else { return nil }
    // Tablica montowan jest zrodlem prawdy - samo istnienie katalogu nic nie
    // znaczy, bo punkt montowania zostaje na dysku po odmontowaniu.
    return points.contains(mountPoint.path)
  }

  /// Skrot dla miejsc, w ktorych brak odczytu i "nie zamontowane" znacza to
  /// samo - czyli tam, gdzie i tak czekamy na montowanie albo tylko je
  /// wypisujemy. Wszedzie, gdzie z odpowiedzi wynika DECYZJA, uzywaj
  /// `mountedState()`.
  public static var isMounted: Bool { mountedState() ?? false }

  // MARK: - Uruchomienie

  /// Argumenty `rclone mount`. Wydzielone, zeby dalo sie je sprawdzic testem
  /// bez uruchamiania czegokolwiek.
  public static func mountArguments() -> [String] {
    [
      "mount", "\(remoteName):\(remotePath)", mountPoint.path,
      "--vfs-cache-mode", "full",
      "--vfs-cache-max-size", cacheSize,
      // Cache nie moze wyrzucac danych, ktore czekaja na wyslanie - stad
      // wysoki wiek. Rozmiarem rzadzi --vfs-cache-max-size.
      "--vfs-cache-max-age", "9999h",
      "--vfs-write-back", "\(writeBackSeconds)s",
      "--vfs-cache-poll-interval", "1m",
      "--cache-dir", cacheDir.path,
      "--dir-cache-time", "5m",
      "--attr-timeout", "5m",
      "--transfers", "8",
      // Rozmiar kawalka dopasowany do rozmiaru pasma obrazu.
      "--drive-chunk-size", "32M",
      // Bez tego skasowane pasma ida do kosza Dysku i dalej licza sie
      // do limitu pojemnosci.
      "--drive-use-trash=false",
      // Po przekroczeniu dobowego limitu 750 GB rclone ma stanac, a nie
      // kreci sie w 403 do konca swiata.
      "--drive-stop-on-upload-limit",
      "--volname", remoteName,
      "--rc", "--rc-addr", rcAddress, "--rc-no-auth",
      "--log-file", logFile.path,
      "--log-level", "INFO",
    ]
  }

  /// Przygotowuje otoczenie i oddaje argumenty do uruchomienia. Nie uruchamia
  /// rclone sam - robi to `cloudmachine-agent mount-drive`, ktore musi zostac
  /// na pierwszym planie pod launchd.
  public static func prepare() throws -> [String] {
    try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    rotateLogIfLarge()
    return mountArguments()
  }

  private static func rotateLogIfLarge() {
    guard
      let attrs = try? FileManager.default.attributesOfItem(atPath: logFile.path),
      let size = attrs[.size] as? UInt64, size > logSizeLimit
    else { return }
    let rotated = logFile.appendingPathExtension("1")
    try? FileManager.default.removeItem(at: rotated)
    try? FileManager.default.moveItem(at: logFile, to: rotated)
  }

  /// Wyklucza katalog bufora z Time Machine. Bufor trzyma kopie danych
  /// backupu - gdyby Time Machine go objal, backupowalby wlasny backup i rosl
  /// bez konca. Wykluczenie zapisuje sie jako xattr na katalogu, wiec ginie
  /// razem z nim; dlatego odnawiamy je przy kazdym starcie, a nie raz w setupie.
  @discardableResult
  public static func excludeBufferFromTimeMachine() async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/tmutil", ["addexclusion", root.path], timeout: 30)
    return result?.succeeded == true
  }

  // MARK: - Kolejka wysylki

  public struct QueueStats {
    public var uploadsInProgress: Int
    public var uploadsQueued: Int
    public var files: Int
    public var erroredFiles: Int
    /// Rozmiar bufora wg samego rclone. Liczenie go wlasnym obchodem katalogu
    /// oznaczalo 6504 wywolania stat przy kazdym odswiezeniu interfejsu, co
    /// 10 sekund, na tym samym dysku, na ktory leci backup.
    public var bytesUsed: UInt64
    /// rclone nie ma juz gdzie odlozyc danych - nie zdazyl wyslac tego, co
    /// trzyma, wiec nie ma czego usunac. Mocniejszy sygnal niz jakikolwiek
    /// prog, bo pochodzi od tego, kto naprawde wie.
    public var outOfSpace: Bool

    /// rclone nic TERAZ nie robi. To warunek STABILNOSCI `hdiutil` na
    /// montowaniu FUSE-T (patrz `retryingFlakyMount`) i nic wiecej - w
    /// szczegolnosci NIE jest dowodem, ze kopia doleciala na Dysk.
    public var isIdle: Bool { uploadsInProgress == 0 && uploadsQueued == 0 }

    /// Nic nie czeka I nic nie zostalo po drodze porzucone.
    ///
    /// Do 23 wrzesnia 2026 to pytanie mialo tylko jedna odpowiedz - te, ktora
    /// dzis nazywa sie `isIdle` - i to ona szla do komunikatu odpiecia oraz do
    /// `safeToRebootNow()`. Pasmo, ktore rclone porzucil, wypada z kolejki
    /// dokladnie tak samo jak pasmo wyslane: `uploadsQueued` wraca do zera,
    /// a slad zostaje wylacznie w `erroredFiles`. Skutek: "Odpiete, wszystko
    /// wyslane na Google Drive" i "Restart bez pytania: TAK" przy danych
    /// istniejacych tylko lokalnie - podczas gdy `UploadState` z tych samych
    /// licznikow wyprowadzal juz `.failedFiles(...)` i "WYMAGA REAKCJI".
    public var isQuiet: Bool { isIdle && erroredFiles == 0 }

    /// Ile pozycji CZEKA na wyslanie: kolejka plus to, co wlasnie leci.
    ///
    /// To jest ta wielkosc, z ktorej dozorca bufora wyprowadza swoja miare
    /// (patrz `BufferGuardService.backlogGB`) - a NIE `bytesUsed`. Rozmiar
    /// cache'a przy `--vfs-cache-max-size 100G` i `--vfs-cache-max-age 9999h`
    /// stoi pod limitem stale (w dzienniku 281 pomiarow, minimum 99 GB), bo
    /// rclone trzyma tam takze to, co dawno wyslal. Zaleglosc niewyslana jest
    /// jedyna z tych dwoch liczb, ktora odpowiada na pytanie "czy wysylka
    /// nadaza".
    ///
    /// `uploadsInProgress` wchodzi do sumy, bo pozycja w trakcie wysylki tez
    /// jeszcze nie jest na Dysku i tez zajmuje bufor. Przy `--transfers 8` to
    /// najwyzej osiem pozycji, ale pusta kolejka z osmioma transferami w toku
    /// nie jest zerowa zaleglosci.
    public var unsentItems: Int { uploadsQueued + uploadsInProgress }
  }

  /// Odczytuje stan kolejki przez interfejs sterujacy rclone.
  ///
  /// UWAGA: `--rc-no-auth` to flaga SERWERA. Klient `rclone rc` jej nie
  /// przyjmuje i konczy sie bledem "unknown flag" - kosztowalo to juz jedno
  /// ciche zepsucie podgladu stanu.
  ///
  /// Limit czasu 60 s, a nie 30 s: 23.09.2026 to samo wywolanie trwalo
  /// **36,7 s** przy zapchanym buforze (kolejne 0,03 s - wiec sporadycznie, pod
  /// obciazeniem). Przy 30 s konczylo sie `nil`, a `nil` szedl dalej jako
  /// komplet zer i interfejs oglaszal "Wszystko wyslane" przy 386 pasmach w
  /// kolejce. Samo podniesienie limitu tego nie naprawia - od tego jest
  /// `UploadState.queueUnknown` - ale sprawia, ze pytanie zwykle dostaje
  /// odpowiedz.
  ///
  /// Wyzej nie warto. Petla odswiezania interfejsu chodzi co 10 s i czeka na
  /// ten odczyt, a `drive-status` pyta dwa razy (drugi raz przez
  /// `safeToRebootNow`). Przy martwym rclone kazda sekunda limitu to sekunda
  /// zamrozonego okna, a odpowiedz i tak nie przyjdzie.
  public static func queueStats() async -> QueueStats? {
    guard
      let result = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/stats"], timeout: 60),
      result.succeeded
    else { return nil }
    return parseQueueStats(result.stdout)
  }

  /// Czysta wersja parsowania odpowiedzi `vfs/stats`. `nil` znaczy "nie wiem",
  /// nigdy "same zera".
  ///
  /// Wydzielone, zeby dalo sie to sprawdzic testem - dotad parsowanie siedzialo
  /// w funkcji async wolajacej rclone i nie bylo do niego dostepu z zadnej
  /// strony poza uruchomieniem calego bufora.
  ///
  /// Dwie rzeczy, ktore tu byly i musialy zniknac:
  ///
  /// 1. `(json["diskCache"] as? [String: Any]) ?? json` - odpowiedz BEZ sekcji
  ///    `diskCache` (rclone zbudowane bez cache dysku, inna wersja interfejsu,
  ///    obcieta odpowiedz) wpadala na `json`, gdzie zadnego z licznikow nie ma.
  /// 2. `number(_:in:)` oddajace 0 dla brakujacego klucza.
  ///
  /// Razem dawaly `QueueStats` z samymi zerami zamiast `nil`, czyli
  /// `queueKnown == true` i znow plansza "Wszystko wyslane na Google Drive".
  /// To ten sam wzorzec, ktory naprawiono wyzej przez `UploadState.queueUnknown`,
  /// tyle ze przesuniety o jeden krok - do parsowania.
  static func parseQueueStats(_ raw: String) -> QueueStats? {
    guard
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      // vfs/stats zwraca liczniki zagniezdzone w sekcji "diskCache". Jej brak
      // to brak odpowiedzi na zadane pytanie, a nie odpowiedz "zero".
      let disk = json["diskCache"] as? [String: Any]
    else { return nil }

    func number(_ key: String) -> Int? {
      if let v = disk[key] as? Int { return v }
      if let v = disk[key] as? NSNumber { return v.intValue }
      return nil
    }

    guard
      let inProgress = number("uploadsInProgress"),
      let queued = number("uploadsQueued"),
      let files = number("files"),
      let errored = number("erroredFiles"),
      let bytesUsed = number("bytesUsed")
    else { return nil }

    return QueueStats(
      uploadsInProgress: inProgress,
      uploadsQueued: queued,
      files: files,
      erroredFiles: errored,
      bytesUsed: UInt64(max(0, bytesUsed)),
      // Jedyne pole, ktorego brak wolno nadrobic domyslna wartoscia: to flaga,
      // a nie licznik - starsze rclone jej nie wystawia, a jej brak nie da sie
      // pomylic z "bufor pelny".
      outOfSpace: (disk["outOfSpace"] as? Bool) ?? false
    )
  }

  /// Pojemnosc konta Google Drive, prosto od rclone.
  ///
  /// NIKT tego dotad nie sprawdzal. `machines.json` ma pola `drive_total_gb`
  /// i `limit_gb`, ale nie uzywa ich ani jedna linia kodu poza samym modelem -
  /// to byl budzet na papierze. Tymczasem wyczerpanie miejsca na Dysku jest dla
  /// rclone bledem FATALNYM (`--drive-stop-on-upload-limit` +
  /// `storageQuotaExceeded`): montowanie znika, a Time Machine traci cel.
  /// Przy przyroscie rzedu 600 MB na cykl godzinowy to nie jest problem
  /// odlegly, tylko kwestia daty.
  public static func remoteQuota() async -> (used: UInt64, total: UInt64, free: UInt64)? {
    guard
      let result = try? await CMTooling.runRclone(
        ["about", "--json", "\(remoteName):"], timeout: 120),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    func bytes(_ key: String) -> UInt64? {
      if let v = json[key] as? NSNumber, v.int64Value >= 0 { return UInt64(v.int64Value) }
      return nil
    }
    // `total` bywa nieobecne (konta bez limitu) - wtedy nie ma czego pilnowac.
    guard let total = bytes("total"), total > 0 else { return nil }
    let used = bytes("used") ?? 0
    let free = bytes("free") ?? (total > used ? total - used : 0)
    return (used, total, free)
  }

  /// Czeka, az rclone przestanie cokolwiek wysylac. Operacje `hdiutil` na
  /// montowaniu FUSE-T sa stabilne tylko przy pustej kolejce - patrz
  /// `BackupImageService.retryingFlakyMount`.
  ///
  /// Warunkiem jest `isIdle`, a NIE `isQuiet`: pasma porzucone przez rclone
  /// zostaja w `erroredFiles` do konca zycia procesu, wiec czekanie na
  /// `isQuiet` nigdy by sie nie doczekalo i kazde podpiecie placilo by pelny
  /// limit czasu za nic.
  ///
  /// Zwraca odczyt kolejki z chwili uciszenia - `nil`, gdy nie ucichla w czasie
  /// albo gdy rclone nie odpowiedzial. Wolajacy dostaje go po to, zeby moc
  /// sprawdzic `erroredFiles` bez zadawania rclone tego samego pytania drugi
  /// raz (kosztuje do 60 s - patrz `queueStats`).
  @discardableResult
  public static func statsWhenIdle(timeout: TimeInterval = 180) async -> QueueStats? {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if let stats = await queueStats(), stats.isIdle { return stats }
      try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
    return nil
  }

  /// Jak `statsWhenIdle`, gdy wolajacego interesuje wylacznie "doczekalem sie".
  @discardableResult
  public static func waitUntilIdle(timeout: TimeInterval = 180) async -> Bool {
    await statsWhenIdle(timeout: timeout) != nil
  }

  /// Przesuwa termin wysylki wszystkich czekajacych pozycji na "teraz".
  ///
  /// Potrzebne przy KAZDYM wygaszaniu. Pozycja trafia do kolejki zaraz po
  /// zapisie - widac ja w `vfs/queue` od razu - ale z terminem wymagalnosci
  /// `writeBackSeconds` w przod. Bez przesuniecia odpiecie czekaloby cale te
  /// dziesiec minut, a `prepare-shutdown` przed restartem Maca stalby sie nie
  /// do zniesienia. To nie jest kosmetyka: uzytkownik, ktory nie chce czekac,
  /// wylaczy Maca bez `prepare-shutdown`, a to juz raz zostawilo Time Machine
  /// bez celu na cala noc.
  ///
  /// Wolac PO tym, jak zapisy z odpiecia zdazyly trafic do kolejki - pozycje
  /// dolozone pozniej nie zostana ruszone.
  ///
  /// Zwraca liczbe pozycji, ktorym przesunieto termin, albo `nil`, gdy rclone
  /// nie odpowiedzial na pytanie o kolejke.
  ///
  /// `nil` i `0` to DWIE ROZNE RZECZY i dlatego typ jest opcjonalny. Do 23
  /// wrzesnia 2026 obie sytuacje - "kolejka byla pusta" i "nie dostalismy
  /// odpowiedzi" - wychodzily stad jako `0`, wiec `detach` milczal w logu
  /// dokladnie w tym przypadku, w ktorym terminow NIE przesunieto i drenaz
  /// mogl potrwac cale `writeBackSeconds` (dziesiec minut) zamiast chwili.
  ///
  /// Limit na samo listowanie kolejki podniesiony z 30 s do 60 s: ten sam plik
  /// dokumentuje pomiar **36,7 s** dla LZEJSZEGO `vfs/stats` przy zapchanym
  /// buforze (patrz `queueStats`), a `vfs/queue` wypisuje wtedy setki pozycji.
  /// Przy 30 s odpowiedz nie zdazala przyjsc dokladnie wtedy, gdy przesuniecie
  /// terminow bylo najbardziej potrzebne.
  ///
  /// Limit pojedynczego `queue-set-expiry` zostaje na 30 s CELOWO: tamto jedno
  /// wywolanie decyduje o calej funkcji, a to jest jedno z setek i jego strata
  /// kosztuje jedna pozycje. Przy kilkuset pozycjach sufit 60 s na sztuke
  /// zamienilby odpiecie w operacje bez gornego ograniczenia czasu.
  @discardableResult
  public static func expireQueuedUploads() async -> Int? {
    guard
      let result = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/queue"], timeout: 60),
      result.succeeded,
      let ids = parseQueueIDs(result.stdout)
    else { return nil }

    var moved = 0
    for id in ids {
      // Duza liczba ujemna zamiast zera - tak opisuje to samo rclone.
      let response = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/queue-set-expiry", "id=\(id)", "expiry=-1000000000"],
        timeout: 30)
      if response?.succeeded == true { moved += 1 }
    }
    return moved
  }

  /// Czysta wersja: numery pozycji z odpowiedzi `vfs/queue`, ktorym da sie
  /// przesunac termin. `nil` = odpowiedzi nie da sie odczytac, `[]` = kolejka
  /// jest pusta. Wydzielone, zeby to rozroznienie dalo sie sprawdzic testem.
  static func parseQueueIDs(_ raw: String) -> [Int]? {
    guard
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let queue = json["queue"] as? [[String: Any]]
    else { return nil }

    return queue.compactMap { item in
      // Pozycji juz wysylanej nie da sie przyspieszyc - rclone to ignoruje,
      // wiec nie marnujemy na nia wywolania.
      if (item["uploading"] as? Bool) == true { return nil }
      return (item["id"] as? NSNumber)?.intValue
    }
  }

  /// MIEJSCE ZAJETE NA DYSKU przez katalog bufora. `nil` = NIE ZMIERZONO.
  ///
  /// Normalnie rozmiar cache'a podaje samo rclone (`QueueStats.bytesUsed`):
  /// obchod katalogu to 6504 wywolania stat, a przy odswiezaniu co 10 sekund
  /// niepotrzebne obciazenie dysku, na ktory akurat leci backup.
  ///
  /// UWAGA: to NIE jest zapas dla miary, na ktorej dozorca podejmuje decyzje,
  /// i nie wolno go tam podstawiac. Dwa powody, oba zmierzone:
  ///
  /// 1. Ta funkcja liczy MIEJSCE ZAJETE NA DYSKU (`totalFileAllocatedSize`),
  ///    czyli wielkosc NIEPOROWNYWALNA z limitem `--vfs-cache-max-size` -
  ///    potrafi go przekroczyc. Stad "bufor 155 GB" przy limicie 100 GB
  ///    w jedynej linii PAUZA w calym dzienniku (23.09.2026 03:34). Godzine
  ///    pozniej czujka zapisala "Interfejs sterujacy rclone nie odpowiada":
  ///    brak odpowiedzi zamieniono na liczbe z INNEJ miary, i ta liczba
  ///    uruchomila nieodwracalna pauze.
  /// 2. Gdy obchod padnie (odmowa praw, znikniete `~/.cloudmachine`), wynik
  ///    `0` wyglada jak PUSTY bufor, czyli jak spelniony warunek wznowienia
  ///    Time Machine wstrzymanego dlatego, ze bufor byl pelny. Dokladnie ten
  ///    wzorzec zamknal `BufferGuardService.freeGB()` dla `statfs` - stad
  ///    tutaj `nil`, a nie zero.
  ///
  /// Zostaje wiec do JEDNEGO: powiedzenia czlowiekowi, ile miejsca na dysku
  /// zajmuje cache. Zadna decyzja tego nie czyta.
  public static func cacheSizeBytesByWalk() -> UInt64? {
    guard
      let enumerator = FileManager.default.enumerator(
        at: cacheDir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
        options: [.skipsHiddenFiles])
    else { return nil }
    var total: UInt64 = 0
    for case let url as URL in enumerator {
      let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
      total += UInt64(values?.totalFileAllocatedSize ?? 0)
    }
    return total
  }

  /// Czy rclone stanal na dobowym limicie Google Drive (750 GB/dobe).
  ///
  /// Rozpoznajemy to po ZACHOWANIU rclone, nie po tresci bledu. Powod jest
  /// konkretny: `403 userRateLimitExceeded` to chwilowe dlawienie tempa, ktore
  /// rclone ponawia sam ("will retry in 1m0s"), ale opisuje je komunikatem
  /// "Received upload limit error" - nie do odroznienia po samym tekscie od
  /// limitu dobowego. Pierwsza wersja tej funkcji lapala wlasnie to i
  /// wstrzymala backup po 109 GiB wyslanych, czyli przy siodmej czesci limitu.
  ///
  /// Prawdziwy limit jest dla rclone fatalny (`--drive-stop-on-upload-limit`
  /// dziala dokladnie dla `storageQuotaExceeded` i `teamDriveFileLimitExceeded`),
  /// wiec proces konczy prace i montowanie znika.
  ///
  /// UWAGA: NIE wolno dokladac tu warunku "tylko gdy montowanie lezy". Taka
  /// wersja tu byla i byla martwa: agent `gdrive-buffer` ma `KeepAlive`
  /// z `ThrottleInterval` 30 s, wiec launchd podnosi rclone z powrotem szybciej,
  /// niz dozorca bufora zdazy tyknac (co 30 s). Okno, w ktorym montowania
  /// faktycznie nie ma, jest krotsze od okresu odpytywania - wykrycie limitu
  /// bylo rzutem moneta, a w praktyce nie zdarzalo sie wcale. Rozpoznanie po
  /// SWIEZYM wpisie w logu dziala niezaleznie od tego, czy launchd zdazyl juz
  /// wskrzesic montowanie.
  ///
  /// Chwilowa przepustnica (`userRateLimitExceeded`) nadal NIE jest tu lapana -
  /// patrz `logMentionsUploadLimit`. To ona kiedys wstrzymala backup po
  /// 109 GiB i to jej dotyczyla ostroznosc, nie stanu montowania.
  ///
  /// `nil` = LOGU NIE DA SIE PRZECZYTAC, co jest czyms innym niz "nie ma
  /// sladu limitu". Wczesniej oba przypadki wychodzily stad jako `false`,
  /// czyli jako odpowiedz "nie ma problemu" na pytanie, na ktore nie bylo
  /// odpowiedzi - a dozorca nie wstrzymuje wtedy backupu na brak miejsca na
  /// Dysku. To nie jest teoretyczne: log rclone ma prawa `-rw-r-----`,
  /// a przy starcie jest przenoszony na `.1` (patrz `rotateLogIfLarge`).
  public static func hitStorageQuotaState(logFile: URL? = nil) -> Bool? {
    guard let text = recentLog(bytes: 256 * 1024, from: logFile ?? Self.logFile) else {
      return nil
    }
    return logMentionsUploadLimit(text, now: Date(), within: 30)
  }

  /// Wersja DO POKAZANIA CZLOWIEKOWI, gdzie trzeciego stanu nie ma gdzie
  /// wstawic (`BufferStatus.driveFull`, `UploadState.from`).
  ///
  /// ZADNA DECYZJA nie ma prawa jej uzywac: `?? false` to dokladnie to
  /// podstawienie, ktore opisuje komentarz wyzej. Dozorca bufora czyta
  /// `hitStorageQuotaState()` i sam rozstrzyga, co zrobic z "nie wiem".
  /// Trzeci stan w interfejsie wymaga zmiany `BufferStatus` i
  /// `CloudMachineController` - to osobna zmiana, poza ta galezia.
  public static func hitStorageQuota() -> Bool { hitStorageQuotaState() ?? false }

  /// Czy wysylka faktycznie STOI - rozpoznane po zachowaniu, nie po tresci.
  ///
  /// Dobowy limit uploadu Google (750 GB) zglasza sie jako `403
  /// userRateLimitExceeded`, czyli DOKLADNIE tym samym kodem, co zwykle
  /// chwilowe dlawienie tempa. Po tekscie rozroznic sie ich nie da i nie
  /// nalezy probowac - pierwsza wersja `logMentionsUploadLimit` probowala
  /// i wstrzymala backup po 109 GiB z 750 GB.
  ///
  /// Rozroznia je natomiast STOSUNEK sukcesow do bledow w oknie czasowym.
  /// Zmierzone na wlasnym logu:
  ///   - dlawienie:  11 wrz 14h -> 4833, 12 wrz 09h -> 1,07, 15 wrz 08h -> 2,39
  ///   - realny zator: 12 wrz 10-12h -> 0,002-0,011, 15 wrz 09h -> 0,003
  /// Miedzy jednym a drugim leza DWA RZEDY WIELKOSCI, wiec prog 0,1 ma zapas
  /// w obie strony.
  ///
  /// `minErrors` chroni przed cisza: w oknie bez ruchu jest zero bledow
  /// i zero sukcesow, a to nie jest zator.
  ///
  /// `nil` = LOGU NIE DA SIE PRZECZYTAC. Rozroznienie jest tu grozniejsze niz
  /// przy samym pomiarze: `false` szedl dalej do `reportUploadStall`, ktore
  /// USUWALO znacznik zatoru i zapisywalo "Wysylka na Google Drive ruszyla
  /// z powrotem" - twierdzenie o zdarzeniu, ktorego nikt nie sprawdzil, na
  /// podstawie pliku, ktorego nikt nie przeczytal.
  public static func uploadStalledState(logFile: URL? = nil) -> Bool? {
    // Wieksze okno niz przy tescie tekstowym: w trakcie zatoru log rosnie
    // o okolo 90 KB na minute, wiec 256 KB pokazaloby tylko ostatnie trzy
    // minuty i stosunek liczylby sie z probki bez ani jednego sukcesu.
    guard let text = recentLog(bytes: 4 * 1024 * 1024, from: logFile ?? Self.logFile) else {
      return nil
    }
    return logShowsUploadStalled(text, now: Date(), within: 30)
  }

  /// Wersja do pokazania czlowiekowi - patrz `hitStorageQuota()`, ten sam
  /// powod i to samo ostrzezenie: zadna decyzja nie czyta tej wersji.
  public static func uploadStalled() -> Bool { uploadStalledState() ?? false }

  /// Zbiorcza odpowiedz "wysylka na Dysk nie idzie" - do pokazania
  /// uzytkownikowi. Dozorca bufora NIE uzywa tej funkcji, bo dla niego roznica
  /// miedzy jednym a drugim jest zasadnicza: brak miejsca nie minie sam,
  /// a limit dobowy mija w kilka godzin.
  public static func hitDailyQuota() -> Bool {
    hitStorageQuota() || uploadStalled()
  }

  /// Ogon logu rclone jako tekst. `nil` = pliku NIE DA SIE PRZECZYTAC: nie ma
  /// go, nie ma do niego prawa albo odczyt padl.
  ///
  /// Wolajacy MUSI oddac to `nil` dalej jako "nie wiem". Brak wpisow o limicie
  /// i brak dostepu do logu to dwie rozne rzeczy, a tylko pierwsza znaczy "nie
  /// ma problemu". Plik bierzemy z parametru, zeby oba pytania zadawane temu
  /// logowi dalo sie sprawdzic testem na wlasnym pliku - bez `~/.cloudmachine`
  /// i bez zgadywania praw.
  private static func recentLog(bytes: UInt64, from file: URL) -> String? {
    guard let handle = try? FileHandle(forReadingFrom: file) else { return nil }
    defer { try? handle.close() }
    let size = (try? handle.seekToEnd()) ?? 0
    try? handle.seek(toOffset: size > bytes ? size - bytes : 0)
    guard let data = try? handle.readToEnd() else { return nil }
    // Ogon prawie zawsze zaczyna sie w polowie znaku wielobajtowego, wiec
    // dekodujemy stratnie - inaczej caly odczyt przepadalby przez jeden bajt.
    return String(decoding: data, as: UTF8.self)
  }

  /// Czysta wersja rozpoznania zatoru - liczy sukcesy i bledy w oknie.
  ///
  /// Sukcesem jest linia `... : Copied (...)`, bledem `Received upload limit
  /// error`. Oba pochodza z tego samego logu i tego samego zdarzenia, wiec
  /// stosunek nie wymaga zadnej kalibracji miedzy maszynami.
  public static func logShowsUploadStalled(
    _ text: String, now: Date, within minutes: Int,
    minErrors: Int = 300, maxSuccessRatio: Double = 0.1
  ) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    let cutoff = now.addingTimeInterval(-Double(minutes) * 60)

    var errors = 0
    var successes = 0
    for line in text.components(separatedBy: .newlines).reversed() {
      guard line.count > 19, let stamp = formatter.date(from: String(line.prefix(19))) else {
        continue
      }
      // Log jest chronologiczny, wiec pierwsza linia starsza od okna konczy
      // liczenie - dalej sa juz same starsze.
      if stamp < cutoff { break }
      let lower = line.lowercased()
      if lower.contains("received upload limit error") {
        errors += 1
      } else if lower.contains(": copied (") {
        successes += 1
      }
    }

    guard errors >= minErrors else { return false }
    return Double(successes) < maxSuccessRatio * Double(errors)
  }

  /// Szuka sladu limitu tylko w swiezych wpisach. Bez ograniczenia czasowego
  /// raz zapalony alarm nigdy by nie zgasl, bo wpis zostaje w logu na zawsze -
  /// backup wpadlby w cykl pauza-wznowienie-pauza.
  ///
  /// Czysta wersja, zeby dalo sie ja sprawdzic testem bez pliku i bez zegara.
  public static func logMentionsUploadLimit(_ text: String, now: Date, within minutes: Int) -> Bool
  {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    let cutoff = now.addingTimeInterval(-Double(minutes) * 60)

    for line in text.components(separatedBy: .newlines).reversed() {
      guard line.count > 19, let stamp = formatter.date(from: String(line.prefix(19))) else {
        continue
      }
      if stamp < cutoff { return false }
      let lower = line.lowercased()
      // userRateLimitExceeded celowo POMINIETE - to zwykla przepustnica, ktora
      // rclone ponawia sam. Lapanie jej wstrzymalo backup przy 109 GiB z 750 GB.
      if lower.contains("storagequotaexceeded") || lower.contains("teamdrivefilelimitexceeded") {
        return true
      }
    }
    return false
  }
}
