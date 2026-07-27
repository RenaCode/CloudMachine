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
      kill(pid, 0) == 0
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
