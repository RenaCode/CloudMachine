import Foundation

/// Blokada oparta na atomowym `mkdir` (nie `flock`, ktorego macOS nie ma
/// domyslnie), z wykrywaniem osierocenia po PID-zie zapisanym w blokadzie
/// (nie po wieku katalogu - ta sama motywacja co w bash-owym `cm_acquire_lock`:
/// operacja pod blokada moze legalnie trwac dlugo, np. dogananie zaleglej
/// kolejki uploadow, wiec staly prog czasowy falszywie oznaczalby zywy proces
/// jako osierocony).
public final class CMLock {
  private let lockDir: URL
  private var acquired = false

  public init(name: String) {
    lockDir = CMPaths.logDir.appendingPathComponent("\(name).lock.d")
  }

  /// Probuje przejac blokade. Zwraca `false`, jesli inny zywy proces juz ja trzyma.
  public func acquire() -> Bool {
    if (try? FileManager.default.createDirectory(at: lockDir, withIntermediateDirectories: false))
      != nil
    {
      writePid()
      acquired = true
      return true
    }
    // Katalog juz istnieje - sprawdzamy, czy wlasciciel wciaz zyje.
    let pidFile = lockDir.appendingPathComponent("pid")
    if let content = try? String(contentsOf: pidFile, encoding: .utf8),
      let pid = Self.parsePid(from: content),
      isProcessAlive(pid, recordedStartTime: Self.parseStartTime(from: content))
    {
      return false
    }
    // Proces-wlasciciel juz nie zyje (lub blokada przerwana zanim zdazyl
    // zapisac PID) - osierocona, przejmujemy.
    try? FileManager.default.removeItem(at: lockDir)
    guard
      (try? FileManager.default.createDirectory(at: lockDir, withIntermediateDirectories: false))
        != nil
    else {
      return false
    }
    writePid()
    // WAZNE: `removeItem` + `createDirectory` powyzej NIE jest atomowe -
    // dwa procesy przejmujace ta sama osierocona blokade w nakladajacym
    // sie oknie moga obie odczytac "martwy PID", obie usunac i utworzyc
    // katalog na nowo, obie zapisac swoj PID - i obie zwrocic `true`.
    // Odczytujemy wlasnie zapisany plik z powrotem: jesli inny proces
    // zdazyl go nadpisac swoim PID-em pomiedzy naszym `writePid()` a tym
    // odczytem, wiemy, ze przegralismy wyscig, i wycofujemy sie zamiast
    // dzialac w falszywym przekonaniu o wylacznosci. Nie eliminuje to
    // calkowicie okna (obie strony moga jeszcze przejsciowo "wygrac" tuz
    // przed ta weryfikacja), ale gwarantuje, ze co najmniej jedna z nich
    // to wykryje i cofnie.
    guard
      let verifyContent = try? String(contentsOf: pidFile, encoding: .utf8),
      Self.parsePid(from: verifyContent) == getpid()
    else {
      return false
    }
    acquired = true
    return true
  }

  /// Sprawdza, czy proces z podanym PID wciaz zyje I nie jest zawieszony na
  /// stale w nieprzerywalnym oczekiwaniu kernela (stan 'U' z `ps`).
  /// Uzywa synchronicznego `popen("ps -p <pid> -o stat=")` bo `acquire()`
  /// jest sync - nie mozemy tu czekac na async ProcessRunner.
  ///
  /// Proces w stanie U przechodzi `kill(pid, 0) == 0`, ale nigdy sam nie
  /// zwolni blokady (SIGKILL go nie budzi z NFS/I-O wait w jadrze). Traktujemy
  /// go jako "martwy dla celow blokady" po `stuckThreshold` minutach - prog
  /// wystarczajaco duzy, zeby nie konfliktowac z legalnymi dlugimi operacjami
  /// (dogananie kolejki uploadow, weryfikacja checksumow mogace trwac godziny).
  private static let stuckLockThreshold: TimeInterval = 15 * 60  // 15 minut

  /// Znacznik "od kiedy nieprzerwanie widzimy ten proces w stanie U/D" -
  /// CELOWO osobny od mtime `lockDir` (czasu PRZEJECIA blokady). Legalna
  /// dlugotrwala operacja (weryfikacja checksumow trwajaca godziny) moze
  /// trzymac te sama blokade dlugo PRZED tym, jak w ogole wpadnie w U/D -
  /// liczenie progu od czasu przejecia blokady (jak robil wczesniejszy kod)
  /// zabija taki legalny, dlugo dzialajacy proces przy pierwszej probce w
  /// U/D po uplywie progu, co jest dokladnie tym, przed czym ostrzega
  /// komentarz w naglowku tego pliku (orphan detection PO PID, NIE po
  /// wieku). Ten znacznik zapisujemy przy PIERWSZYM zaobserwowanym U/D i
  /// kasujemy, gdy proces wroci do normalnego stanu - wiec mierzy faktyczny,
  /// NIEPRZERWANY czas trwania zawieszenia.
  private var stuckSinceFile: URL { lockDir.appendingPathComponent("stuck-since") }

  /// `recordedStartTime` to czas startu procesu-wlasciciela ZAPISANY w pliku
  /// blokady w momencie jej przejecia (`writePid()`) - pozwala odroznic
  /// "ten sam proces wciaz zyje" od "PID zostal juz ponownie uzyty przez
  /// zupelnie inny, nowszy proces" (`kill(pid, 0) == 0` samo w sobie tego
  /// nie odroznia - widzi TYLKO, ze COS zyje pod tym numerem PID). Ryzyko
  /// jest bardzo niskie w praktyce (przestrzen PID jest duza, watchdogi
  /// odpalaja sie rzadko), ale kosztuje niewiele do sprawdzenia. `nil` (plik
  /// blokady zapisany przed wprowadzeniem tego pola, albo `ps` chwilowo nie
  /// odpowiedzialo przy zapisie) pomija te dodatkowa weryfikacje zamiast
  /// falszywie zaklada osierocenie.
  private func isProcessAlive(_ pid: pid_t, recordedStartTime: String?) -> Bool {
    guard kill(pid, 0) == 0 else { return false }

    if let recordedStartTime, !recordedStartTime.isEmpty,
      let currentStartTime = Self.processStartTime(pid: pid),
      currentStartTime != recordedStartTime
    {
      return false
    }

    // Synchronicznie pobierz stan procesu z `ps`.
    // Stan 'U' (macOS uninterruptible NFS wait) lub 'D' (Linux disk sleep)
    // - oba oznaczaja zawieszenie w jadrze, z ktorego SIGKILL nie wybudza.
    guard let psState = processState(pid: pid),
      psState.uppercased().hasPrefix("U") || psState.uppercased().hasPrefix("D")
    else {
      // Proces dziala normalnie (albo `ps` chwilowo nie odpowiedzialo) -
      // kasujemy znacznik, gdyby proces przejsciowo wpadl w U/D i wrocil.
      try? FileManager.default.removeItem(at: stuckSinceFile)
      return true
    }

    if let stuckSinceString = try? String(contentsOf: stuckSinceFile, encoding: .utf8),
      let stuckSinceEpoch = TimeInterval(
        stuckSinceString.trimmingCharacters(in: .whitespacesAndNewlines))
    {
      let stuckDuration = Date().timeIntervalSince1970 - stuckSinceEpoch
      guard stuckDuration > Self.stuckLockThreshold else { return true }
      CMLogger.log(
        "[CMLock] OSTRZEZENIE: PID \(pid) trzymajacy blokade '\(lockDir.lastPathComponent)'"
          + " jest NIEPRZERWANIE zawieszony w stanie U/D (NFS hang?) od ponad"
          + " \(Int(Self.stuckLockThreshold/60)) min. Przejmuje blokade. SIGKILL na zawieszony"
          + " proces (ignorowany przez jadro, ale sprzatnie PID po odmontowaniu)."
      )
      kill(pid, SIGKILL)
      try? FileManager.default.removeItem(at: stuckSinceFile)
      return false
    }
    // Pierwsza probka w stanie U/D - zapisujemy poczatek okna i czekamy na
    // kolejne probki, zanim uznamy proces za utkniety.
    try? "\(Date().timeIntervalSince1970)".write(
      to: stuckSinceFile, atomically: true, encoding: .utf8)
    return true
  }

  /// Synchroniczne uruchomienie `ps -p <pid> -o <format>` przez Process/Pipe -
  /// wspoldzielone przez `processState` (`stat=`) i `processStartTime`
  /// (`lstart=`). Bezpieczne blokujace uzycie `readDataToEndOfFile()` bo `ps`
  /// ZAWSZE szybko konczy i zamyka swoje FD - brak ryzyka wiecznego
  /// oczekiwania na EOF (ten problem dotyczy wylacznie demonow takich jak
  /// rclone --daemon, ktore forkuja dziecko dziedziczace FD i nigdy ich nie
  /// zamykaja).
  private static func runPS(pid: pid_t, format: String) -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/ps")
    proc.arguments = ["-p", "\(pid)", "-o", format]
    // WAZNE: `ps` formatuje daty (np. `lstart=`) wedlug LC_TIME/LANG procesu,
    // ktory go wywoluje - NIE tego, ktorego PID sprawdzamy. Bez wymuszenia
    // stalego locale ten sam, zywy proces dostawal RUZNY tekst czasu startu
    // w zaleznosci od tego, kto go sprawdzal (np. "sr. 29 lip 10:01:01 2026"
    // z powloki uzytkownika z LANG=pl_PL.UTF-8, ale "Wed Jul 29 10:01:01
    // 2026" z watchdoga odpalonego przez launchd z innym/domyslnym locale) -
    // co `isProcessAlive` mylnie odczytywalo jako "PID zostal ponownie
    // uzyty przez inny proces" i pozwalalo ukrasc blokade dalej zywemu
    // procesowi. Zaobserwowane na zywo: dwa rownolegle `rclone copy` na ten
    // sam cel. `LC_ALL=C` gwarantuje ten sam tekst niezaleznie od tego, kto pyta.
    proc.environment = ["LC_ALL": "C"]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    proc.standardInput = FileHandle.nullDevice
    guard (try? proc.run()) != nil else { return nil }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    proc.waitUntilExit()
    let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return (text?.isEmpty == false) ? text : nil
  }

  private func processState(pid: pid_t) -> String? {
    Self.runPS(pid: pid, format: "stat=")
  }

  /// Czas startu procesu (np. "Wed Jul 29 09:07:59 2026") - unikalny "odcisk
  /// palca" konkretnej instancji procesu pod danym PID-em, uzywany do
  /// wykrywania ponownego uzycia PID-u (patrz `isProcessAlive`).
  private static func processStartTime(pid: pid_t) -> String? {
    runPS(pid: pid, format: "lstart=")
  }

  private func writePid() {
    let pidFile = lockDir.appendingPathComponent("pid")
    let pid = getpid()
    let startTime = Self.processStartTime(pid: pid) ?? ""
    try? "\(pid)\n\(startTime)".write(to: pidFile, atomically: true, encoding: .utf8)
  }

  private static func parsePid(from content: String) -> pid_t? {
    guard let firstLine = content.split(separator: "\n", maxSplits: 1).first else { return nil }
    return pid_t(firstLine.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  /// `nil` dla plikow blokady zapisanych przed wprowadzeniem tego pola
  /// (tylko jedna linia z PID-em) - `isProcessAlive` traktuje to jako brak
  /// dodatkowej informacji, nie jako dowod ponownego uzycia PID-u.
  private static func parseStartTime(from content: String) -> String? {
    let lines = content.split(separator: "\n", maxSplits: 1)
    guard lines.count == 2 else { return nil }
    let trimmed = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  public func release() {
    guard acquired else { return }
    try? FileManager.default.removeItem(at: lockDir)
    acquired = false
  }

  deinit {
    if acquired {
      try? FileManager.default.removeItem(at: lockDir)
    }
  }
}

/// Wykonuje `body` pod blokada `name`, zwalniajac ja automatycznie na wyjsciu
/// (rowniez przy rzuconym bledzie) - odpowiednik `cm_acquire_lock` + `trap EXIT`.
/// Zwraca `nil` bez wywolania `body`, jesli inna zywa instancja juz trzyma blokade.
@discardableResult
public func withCMLock<T>(_ name: String, _ body: () throws -> T) rethrows -> T? {
  let lock = CMLock(name: name)
  guard lock.acquire() else { return nil }
  defer { lock.release() }
  return try body()
}

@discardableResult
public func withCMLock<T>(_ name: String, _ body: () async throws -> T) async rethrows -> T? {
  let lock = CMLock(name: name)
  guard lock.acquire() else { return nil }
  defer { lock.release() }
  return try await body()
}
