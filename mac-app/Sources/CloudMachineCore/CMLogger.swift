import Foundation

/// Odpowiednik `cm_log`/`cm_rotate_log_if_large` z bash-owego common.sh -
/// timestampowany zapis do wspolnego logu (`cloudmachine.log`) plus rotacja
/// "copytruncate", zeby logi nie rosly bez ograniczen (zaobserwowany na zywo
/// przypadek: rclone-mount.log urosl do 3.3 GiB bez zadnej rotacji).
public enum CMLogger {
  private static let lock = NSLock()

  /// Dopisuje linie do `cloudmachine.log` (z timestampem) i do stdout -
  /// odpowiednik `cm_log` (ktory uzywal `tee -a`).
  public static func log(_ message: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = "[\(formatter.string(from: Date()))] \(message)\n"
    print(line, terminator: "")
    append(line, to: CMPaths.combinedLogFile)
    // WAZNE: `rotateIfLarge` istnialo wczesniej w kodzie, ale nigdzie nie
    // bylo wywolywane - `cloudmachine.log` rosl bez ograniczen (dokladnie
    // ten scenariusz, ktory ta funkcja miala zapobiegac, patrz komentarz
    // przy niej). Sprawdzenie rozmiaru pliku to tani `stat`, wiec robimy to
    // przy kazdym wpisie zamiast polegac na pamieci, zeby to gdzies wywolac.
    rotateIfLarge(CMPaths.combinedLogFile)
  }

  private static func append(_ text: String, to url: URL) {
    lock.lock()
    defer { lock.unlock() }
    guard let data = text.data(using: .utf8) else { return }
    if FileManager.default.fileExists(atPath: url.path) {
      if let handle = try? FileHandle(forWritingTo: url) {
        defer { try? handle.close() }
        handle.seekToEndOfFile()
        handle.write(data)
        return
      }
    }
    try? data.write(to: url)
  }

  /// Przycina plik logu metoda "copytruncate", jesli przekroczyl `maxBytes` -
  /// zachowuje ostatnie `keepLines` linii, POTEM obcina oryginal do 0
  /// bajtow. Bezpieczne dla procesu (np. rclone), ktory trzyma ten sam plik
  /// otwarty do dopisywania (O_APPEND) - po obcieciu jadro samo przesuwa
  /// nastepny zapis na nowy, mniejszy koniec pliku, wiec NIE trzeba
  /// restartowac tego procesu, zeby rotacja zadziala.
  @discardableResult
  public static func rotateIfLarge(
    _ url: URL, maxBytes: Int = 200 * 1024 * 1024, keepLines: Int = 5000
  ) -> Bool {
    guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
      let size = attrs[.size] as? Int, size > maxBytes
    else {
      return false
    }
    guard let content = try? String(contentsOf: url, encoding: .utf8) else { return false }
    let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
    let tail = lines.suffix(keepLines).joined(separator: "\n")
    do {
      try tail.write(to: url, atomically: false, encoding: .utf8)
      log(
        "Przycieto \(url.lastPathComponent) (bylo \(size) bajtow, zachowano ostatnie \(keepLines) linii)."
      )
      return true
    } catch {
      return false
    }
  }
}
