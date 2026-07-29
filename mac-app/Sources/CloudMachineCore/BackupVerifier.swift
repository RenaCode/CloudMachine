import Foundation

/// GLOWNE narzedzie do oceny, czy backup Time Machine na lokalnym wolumenie
/// APFS jest spojny. Wspoldzielone miedzy CLI (`verify-backup`, pelny raport
/// diagnostyczny) i GUI (przycisk "Weryfikuj sumy kontrolne" w Statusie,
/// ktory dodatkowo uzywa wlasnego mechanizmu autoryzacji AppleScript zamiast
/// `sudo -n` - stad `latestBackupPath` jest wydzielone jako osobny,
/// przywilej-agnostyczny krok, a `verifychecksums` samo GUI woła po swojemu).
public enum BackupVerifier {
  /// Najnowszy backup na danym wolumenie, albo `nil` jesli brak.
  public static func latestBackupPath(mountPoint: String) async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["listbackups", "-d", mountPoint])
    else {
      return nil
    }
    return result.stdout.split(separator: "\n").last.map(String.init)
  }

  /// Pelna sekwencja diagnostyczna (uzywana przez CLI): destinationinfo,
  /// listbackups, verifychecksums (przez `sudo -n`, wymaga skonfigurowanej
  /// reguly sudoers).
  ///
  /// WAZNE: nie ma tu kroku porownania z Google Drive - w tej architekturze
  /// lokalny wolumin APFS JEST zrodlem prawdy, a archiwizacja do chmury
  /// (`CloudArchiveService`, dzialajaca produkcyjnie) ma wlasny, osobny stan
  /// (`archived-backups.json`) i wlasny watchdog (`archive-watchdog`) -
  /// swiadomie POZA tym sprawdzeniem integralnosci lokalnego backupu, zeby
  /// nie mieszac "czy lokalny backup jest spojny" z "czy zdazyl juz trafic
  /// do chmury".
  public static func runFullCheck() async -> CMActionResult {
    let volume = await LocalBackupService.currentStatus()
    guard let mountPoint = volume.mountPoint, volume.exists else {
      return CMActionResult(
        succeeded: false, message: "Lokalny wolumin backupu jeszcze nie istnieje.")
    }

    CMLogger.log("=== 1/3: tmutil destinationinfo ===")
    if let info = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) {
      print(info.stdout)
    }

    CMLogger.log("=== 2/3: lista backupow (tmutil listbackups) ===")
    if let list = try? await ProcessRunner.run(
      "/usr/bin/tmutil", ["listbackups", "-d", mountPoint])
    {
      print(list.stdout)
    }

    guard let latestBackup = await latestBackupPath(mountPoint: mountPoint) else {
      return CMActionResult(
        succeeded: false,
        message:
          "Brak backupu do zweryfikowania. Odpal najpierw: sudo tmutil startbackup --auto --block")
    }

    CMLogger.log(
      "=== 3/3: weryfikacja sum kontrolnych najnowszego backupu: \(latestBackup) (moze potrwac dlugo) ==="
    )
    // Bez sztywnego limitu czasu - weryfikacja duzego backupu moze legalnie
    // trwac dlugo, timeout tutaj zabijalby prawidlowo dzialajacy proces.
    let verifyResult = try? await ProcessRunner.runTmutilUnattended(
      ["verifychecksums", latestBackup])
    guard let verifyResult else {
      return CMActionResult(
        succeeded: false,
        message: "verifychecksums nie odpowiedzialo (blad uruchomienia procesu).")
    }
    // WAZNE: brak reguly sudoers NOPASSWD dla 'tmutil verifychecksums' NIE
    // jest tym samym co uszkodzony backup - to zwykly blad konfiguracji.
    // Wczesniej oba przypadki zwracaly ten sam, alarmujacy komunikat
    // sugerujacy uszkodzenie/niewiarygodnosc backupu.
    guard !verifyResult.isSudoAuthFailure else {
      return CMActionResult(
        succeeded: false,
        message:
          "verifychecksums wymaga hasla sudo - to NIE oznacza uszkodzenia backupu, tylko brak reguly sudoers. Dopisz regule recznie w /etc/sudoers.d/cloudmachine (patrz README)."
      )
    }
    guard verifyResult.succeeded else {
      return CMActionResult(
        succeeded: false, message: "verifychecksums zglosilo problem z backupem.")
    }
    CMLogger.log("OK: sumy kontrolne sie zgadzaja.")

    return CMActionResult(
      succeeded: true, message: "Wszystkie testy przeszly. Backup wyglada na spojny.")
  }
}
