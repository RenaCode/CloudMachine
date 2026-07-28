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
    if let pidString = try? String(contentsOf: pidFile, encoding: .utf8),
      let pid = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines)),
      isProcessAlive(pid)
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

  private func isProcessAlive(_ pid: pid_t) -> Bool {
    guard kill(pid, 0) == 0 else { return false }

    // Synchronicznie pobierz stan procesu z `ps`.
    if let psState = processState(pid: pid) {
      // Stan 'U' (macOS uninterruptible NFS wait) lub 'D' (Linux disk sleep)
      // - oba oznaczaja zawieszenie w jadrze, z ktorego SIGKILL nie wybudza.
      if psState.uppercased().hasPrefix("U") || psState.uppercased().hasPrefix("D") {
        // Czy blokada czeka juz od ponad progu? mtime lock.d == czas przejecia.
        if isLockDirOlderThan(seconds: Self.stuckLockThreshold) {
          CMLogger.log(
            "[CMLock] OSTRZEZENIE: PID \(pid) trzymajacy blokade '\(lockDir.lastPathComponent)'"
              + " jest zawieszony w stanie U (NFS hang?) od ponad \(Int(Self.stuckLockThreshold/60)) min."
              + " Przejmuje blokade. SIGKILL na zawieszony proces (ignorowany przez jadro, ale"
              + " sprzatnie PID po odmontowaniu)."
          )
          kill(pid, SIGKILL)
          return false
        }
      }
    }
    return true
  }

  /// Synchroniczne uruchomienie `ps -p <pid> -o stat=` przez Process/Pipe.
  /// Bezpieczne blokujace uzycie `readDataToEndOfFile()` bo `ps` ZAWSZE szybko
  /// konczy i zamyka swoje FD - brak ryzyka wiecznego oczekiwania na EOF
  /// (ten problem dotyczy wylacznie demonow takich jak rclone --daemon,
  /// ktore forkuja dziecko dziedziczace FD i nigdy ich nie zamykaja).
  private func processState(pid: pid_t) -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/ps")
    proc.arguments = ["-p", "\(pid)", "-o", "stat="]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    proc.standardInput = FileHandle.nullDevice
    guard (try? proc.run()) != nil else { return nil }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    proc.waitUntilExit()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Zwraca `true` jesli katalog blokady (lock.d) ma mtime starszy niz `seconds`.
  /// mtime katalogu == czas przejecia blokady przez mkdir() - nie jest pozniej
  /// modyfikowany, dobrze sluzy jako znacznik czasu przejecia.
  private func isLockDirOlderThan(seconds: TimeInterval) -> Bool {
    guard
      let attrs = try? FileManager.default.attributesOfItem(atPath: lockDir.path),
      let mtime = attrs[.modificationDate] as? Date
    else { return false }
    return Date().timeIntervalSince(mtime) > seconds
  }

  private func writePid() {
    let pidFile = lockDir.appendingPathComponent("pid")
    try? "\(getpid())".write(to: pidFile, atomically: true, encoding: .utf8)
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

/// Nazwa wspolnej blokady per-urzadzenie (maszyna), trzymana przez KAZDA
/// operacje faktycznie mutujaca mount/sparsebundle - mount, unmount, naprawe
/// watchdoga montowania, wznowienie backupu, przycinanie quoty i weryfikacje
/// checksumow. Wczesniej kazda z tych piec operacji blokowala sie TYLKO przed
/// samym soba (osobna nazwa na watchdog), co pozwalalo np. mount-watchdogowi
/// wymusic odmontowanie sparsebundle w trakcie godzinami trwajacej weryfikacji
/// (verify-watchdog) albo przycinania (quota-watchdog) - dokladnie ten sam typ
/// bledu, ktory TimeMachineStatus.isRunning() w MountWatchdogService juz
/// wczesniej naprawil, ale tylko wzgledem samego Time Machine, nie wzgledem
/// pozostalych trzech watchdogow.
public func deviceLockName(machineKey: String) -> String { "device-\(machineKey)" }

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
