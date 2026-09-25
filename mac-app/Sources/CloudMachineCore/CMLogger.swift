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
    emitToStandardOutput(line)
    append(line, to: CMPaths.combinedLogFile)
    // WAZNE: `rotateIfLarge` istnialo wczesniej w kodzie, ale nigdzie nie
    // bylo wywolywane - `cloudmachine.log` rosl bez ograniczen (dokladnie
    // ten scenariusz, ktory ta funkcja miala zapobiegac, patrz komentarz
    // przy niej). Sprawdzenie rozmiaru pliku to tani `stat`, wiec robimy to
    // przy kazdym wpisie zamiast polegac na pamieci, zeby to gdzies wywolac.
    rotateIfLarge(CMPaths.combinedLogFile)
  }

  /// Wypisuje tekst na stdout i NATYCHMIAST oproznia bufor stdio.
  ///
  /// Bez `fflush` linia zostawala w buforze biblioteki C, dopoki nie uzbieralo
  /// sie 16 KiB. Pod launchd stdout jest PLIKIEM
  /// (`StandardOutPath: __CM_LOG_DIR__/launchd-*.out.log`), a dla pliku stdio
  /// wybiera buforowanie BLOKOWE - inaczej niz dla terminala, gdzie buforuje
  /// liniami i problem nie istnieje. Dlatego nie dalo sie tego zobaczyc,
  /// uruchamiajac to samo polecenie z reki.
  ///
  /// Zmierzone 25.09.2026: `~/Library/Logs/CloudMachine/launchd-buffer-guard.out.log`
  /// mial DOKLADNIE 16384 bajty, date 2026-09-20 i ostatnia linie urwana w pol
  /// slowa, podczas gdy proces `buffer-guard` zyl od 2026-09-25 i normalnie
  /// logowal do `cloudmachine.log`. Plik, do ktorego czlowiek zaglada NAJPIERW
  /// (bo tak go kieruje nazwa), byl o piec dni z tylu i konczyl sie w polowie
  /// zdania - czyli wygladal jak proces, ktory umarl piatego dnia.
  ///
  /// Gryzie to wylacznie procesy DLUGOWIECZNE i dlatego tak dlugo zostawalo
  /// niewidoczne: `buffer-guard` to `while true` + `KeepAlive`, wiec nigdy nie
  /// dochodzi do oproznienia bufora przy wyjsciu. Krotkie podkomendy
  /// (`attach-image`, `backup-health`) koncza sie po kazdym tiku, a `exit(3)`
  /// oproznia bufor za nie - dlatego `launchd-backup-health.out.log` byl
  /// aktualny tego samego dnia, w ktorym `launchd-buffer-guard.out.log` stal
  /// od pieciu.
  ///
  /// Dlaczego `fflush` tutaj, a nie `setvbuf(stdout, nil, _IOLBF, 0)` przy
  /// starcie agenta:
  ///
  /// - `setvbuf` trzeba zawolac w KAZDYM punkcie wejscia (agent CLI, GUI,
  ///   harnessy POC) i przed pierwszym zapisem na stdout. Zapomniany w jednym
  ///   z nich daje dokladnie te awarie z powrotem, a jej objawem znow jest
  ///   plik, ktory wyglada na kompletny. Gwarancja nalezy do ZAPISU, nie do
  ///   konfiguracji, ktora ktos musi pamietac wlaczyc.
  /// - `setvbuf` po pierwszym I/O na strumieniu jest nieokreslony, wiec
  ///   "ustawimy to gdzies na starcie" jest w praktyce warunkiem na kolejnosc
  ///   inicjalizacji - a to sie cicho psuje przy przestawianiu kodu.
  /// - Koszt jest zaniedbywalny: dziennik ma wpisy w tempie zdarzen (sekundy,
  ///   nie mikrosekundy), a ten sam wpis i tak leci juz `write(2)` do
  ///   `cloudmachine.log` obok.
  ///
  /// To NIE zalatwia buforowania zwyklych `print(...)` z podkomend CLI - te
  /// pisza wprost. Zalatwia dziennik, czyli to, co pod launchd jest jedynym
  /// sladem po dzialaniu agenta.
  static func emitToStandardOutput(_ text: String) {
    print(text, terminator: "")
    fflush(stdout)
  }

  private static func append(_ text: String, to url: URL) {
    lock.lock()
    defer { lock.unlock() }
    appendLocked(text, to: url)
  }

  /// Zaklada, ze `lock` jest juz przejety przez wywolujacego - wydzielone z
  /// `append(_:to:)`, zeby `rotateIfLargeLocked` mogl dopisac swoj wlasny
  /// komunikat bez ponownego (rekurencyjnego) `lock.lock()`.
  private static func appendLocked(_ text: String, to url: URL) {
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
  ///
  /// WAZNE: chroniona tym samym `lock` co `append()` (wczesniej NIE byla) -
  /// bez tego dwa watki w tym samym procesie logujace dokladnie w momencie
  /// przekroczenia `maxBytes` moglyby rownolegle odczytac-przyciac-zapisac
  /// ten sam plik bez koordynacji, gubiac swiezo dopisane linie.
  @discardableResult
  public static func rotateIfLarge(
    _ url: URL, maxBytes: Int = 200 * 1024 * 1024, keepLines: Int = 5000
  ) -> Bool {
    lock.lock()
    defer { lock.unlock() }
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
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let notice =
        "[\(formatter.string(from: Date()))] Przycieto \(url.lastPathComponent)"
        + " (bylo \(size) bajtow, zachowano ostatnie \(keepLines) linii).\n"
      emitToStandardOutput(notice)
      appendLocked(notice, to: url)
      return true
    } catch {
      return false
    }
  }
}
