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
  public static let cacheSize = "100G"

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
      erroredFiles: number("erroredFiles", in: disk)
    )
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

  /// Rozmiar bufora na dysku w bajtach.
  public static func cacheSizeBytes() -> UInt64 {
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
  /// Prawdziwy limit dobowy jest dla rclone fatalny (`--drive-stop-on-upload-limit`),
  /// wiec proces konczy prace i montowanie znika. Dopoki montowanie stoi,
  /// rclone sobie radzi i nie ma czego wstrzymywac.
  public static func hitDailyQuota() -> Bool {
    if isMounted { return false }
    return recentLogMentionsUploadLimit()
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
