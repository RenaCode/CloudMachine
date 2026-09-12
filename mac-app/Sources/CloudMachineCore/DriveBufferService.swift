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

  /// Adres interfejsu sterujacego rclone. Slucha tylko na petli zwrotnej, ale
  /// kazdy lokalny proces moze przez niego sterowac montowaniem - jesli kiedys
  /// uznamy to za zbyt luzne, trzeba dolozyc `--rc-user`/`--rc-pass`.
  public static let rcAddress = "127.0.0.1:5572"

  /// Powyzej tego rozmiaru log rclone jest przycinany przy starcie. rclone nie
  /// rotuje wlasnego logu, a ten projekt stracil juz raz 3.3 GiB na logu,
  /// ktory rosl bez ograniczen.
  private static let logSizeLimit: UInt64 = 100 * 1024 * 1024

  // MARK: - Stan

  public static var isMounted: Bool {
    // `mount` jest zrodlem prawdy - samo istnienie katalogu nic nie znaczy,
    // bo punkt montowania zostaje na dysku po odmontowaniu.
    guard let out = try? shellMountTable() else { return false }
    return out.contains(" on \(mountPoint.path) ")
  }

  private static func shellMountTable() throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/sbin/mount")
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return String(data: data, encoding: .utf8) ?? ""
  }

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
      "--vfs-write-back", "30s",
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
    public var isQuiet: Bool { uploadsInProgress == 0 && uploadsQueued == 0 }
  }

  /// Odczytuje stan kolejki przez interfejs sterujacy rclone.
  ///
  /// UWAGA: `--rc-no-auth` to flaga SERWERA. Klient `rclone rc` jej nie
  /// przyjmuje i konczy sie bledem "unknown flag" - kosztowalo to juz jedno
  /// ciche zepsucie podgladu stanu.
  public static func queueStats() async -> QueueStats? {
    guard
      let result = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/stats"], timeout: 30),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    func number(_ key: String, in dict: [String: Any]) -> Int {
      if let v = dict[key] as? Int { return v }
      if let v = dict[key] as? NSNumber { return v.intValue }
      return 0
    }

    // vfs/stats zwraca liczniki zagniezdzone w sekcji "diskCache".
    let disk = (json["diskCache"] as? [String: Any]) ?? json
    return QueueStats(
      uploadsInProgress: number("uploadsInProgress", in: disk),
      uploadsQueued: number("uploadsQueued", in: disk),
      files: number("files", in: disk),
      erroredFiles: number("erroredFiles", in: disk),
      bytesUsed: UInt64(max(0, number("bytesUsed", in: disk))),
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

  /// Czeka, az wysylka ucichnie. Operacje `hdiutil` na montowaniu FUSE-T sa
  /// stabilne tylko przy pustej kolejce - patrz `BackupImageService`.
  @discardableResult
  public static func waitUntilQuiet(timeout: TimeInterval = 180) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if let stats = await queueStats(), stats.isQuiet { return true }
      try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
    return false
  }

  /// Rozmiar bufora w bajtach - z obchodu katalogu.
  ///
  /// Uzywane TYLKO awaryjnie, gdy interfejs sterujacy rclone nie odpowiada.
  /// Normalnie liczbe podaje samo rclone (`QueueStats.bytesUsed`): obchod
  /// katalogu to 6504 wywolania stat, a przy odswiezaniu co 10 sekund
  /// niepotrzebne obciazenie dysku, na ktory akurat leci backup.
  public static func cacheSizeBytesByWalk() -> UInt64 {
    guard
      let enumerator = FileManager.default.enumerator(
        at: cacheDir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
        options: [.skipsHiddenFiles])
    else { return 0 }
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
  public static func hitDailyQuota() -> Bool {
    recentLogMentionsUploadLimit()
  }

  private static func recentLogMentionsUploadLimit(within minutes: Int = 30) -> Bool {
    guard let handle = try? FileHandle(forReadingFrom: logFile) else { return false }
    defer { try? handle.close() }
    let size = (try? handle.seekToEnd()) ?? 0
    let window: UInt64 = 256 * 1024
    try? handle.seek(toOffset: size > window ? size - window : 0)
    guard let data = try? handle.readToEnd(),
      let text = String(data: data, encoding: .utf8)
    else { return false }
    return logMentionsUploadLimit(text, now: Date(), within: minutes)
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
