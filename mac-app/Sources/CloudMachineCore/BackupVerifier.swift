import Foundation

/// Port `verify-backup.sh` - GLOWNE narzedzie do oceny, czy backup Time
/// Machine na zamontowanym wolumenie CloudMachine jest spojny. Wspoldzielone
/// miedzy CLI (`verify-backup`, pelny raport diagnostyczny) i GUI (przycisk
/// "Weryfikuj sumy kontrolne" w Statusie, ktory dodatkowo uzywa wlasnego
/// mechanizmu autoryzacji AppleScript zamiast `sudo -n` - stad
/// `latestBackupPath`/`rcloneCheck` sa wydzielone jako osobne, przywilej-
/// agnostyczne kroki, a `verifychecksums` samo GUI woła po swojemu).
public enum BackupVerifier {
  /// Najnowszy backup na danym wolumenie sparsebundle, albo `nil` jesli brak.
  public static func latestBackupPath(spMount: String) async -> String? {
    guard
      let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["listbackups", "-d", spMount])
    else {
      return nil
    }
    return result.stdout.split(separator: "\n").last.map(String.init)
  }

  /// Porownuje lokalny cache VFS ze stanem na Google Drive - wykrywa
  /// rozjazdy po stronie transferu.
  public static func rcloneCheck(localDir: String, remotePath: String) async -> Bool {
    let result = try? await ProcessRunner.runRclone(["check", localDir, remotePath, "--one-way"])
    return result?.succeeded == true
  }

  /// Pelna sekwencja diagnostyczna (uzywana przez CLI): destinationinfo,
  /// listbackups, verifychecksums (przez `sudo -n`, wymaga skonfigurowanej
  /// reguly sudoers), rclone check.
  public static func runFullCheck(config: MachinesConfig, machineKey: String) async
    -> CMActionResult
  {
    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey).path
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey).path
    let remotePath = config.remotePath(forMachineKey: machineKey)

    guard await MountHealth.isMounted(spMount) else {
      return CMActionResult(
        succeeded: false,
        message: "Wirtualny dysk sparsebundle pod \(spMount) nie jest zamontowany.")
    }

    CMLogger.log("=== 1/3: tmutil destinationinfo ===")
    if let info = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) {
      print(info.stdout)
    }

    CMLogger.log("=== 2/3: lista backupow (tmutil listbackups) ===")
    if let list = try? await ProcessRunner.run("/usr/bin/tmutil", ["listbackups", "-d", spMount]) {
      print(list.stdout)
    }

    guard let latestBackup = await latestBackupPath(spMount: spMount) else {
      return CMActionResult(
        succeeded: false,
        message:
          "Brak backupu do zweryfikowania. Odpal najpierw: sudo tmutil startbackup --auto --block")
    }

    CMLogger.log(
      "=== 3/3: weryfikacja sum kontrolnych najnowszego backupu: \(latestBackup) (moze potrwac dlugo) ==="
    )
    // WAZNE: bez timeoutu - `tmutil verifychecksums` moze utknac w jadrze w
    // nieprzerywalnym oczekiwaniu na zawieszonym NFS-ie, tak samo jak
    // `hdiutil detach` gdzie indziej (patrz `ProcessRunner.run(timeout:)`).
    // Bez tego jedna weryfikacja moze zawiesic sie na zawsze, trzymajac
    // blokade urzadzenia i blokujac wszystkie pozostale watchdogi.
    let verifyResult = try? await ProcessRunner.runTmutilUnattended(
      ["verifychecksums", latestBackup], timeout: 1800)
    guard let verifyResult else {
      return CMActionResult(
        succeeded: false,
        message: "verifychecksums nie odpowiedzialo (timeout lub blad uruchomienia procesu).")
    }
    // WAZNE: brak reguly sudoers NOPASSWD dla 'tmutil verifychecksums' NIE
    // jest tym samym co uszkodzony backup - to zwykly blad konfiguracji
    // (README Krok 3 testu planu prosi o uruchomienie tego PRZED skonfiguro-
    // waniem sudoers w Kroku 5 Kreatora). Wczesniej oba przypadki zwracaly
    // ten sam, alarmujacy komunikat sugerujacy uszkodzenie/niewiarygodnosc
    // montowania - myla nowego uzytkownika dokladnie tam, gdzie README
    // najpierw go prowadzi.
    guard !verifyResult.isSudoAuthFailure else {
      return CMActionResult(
        succeeded: false,
        message:
          "verifychecksums wymaga hasla sudo - to NIE oznacza uszkodzenia backupu, tylko brak reguly sudoers. Skonfiguruj automatyczne przycinanie w GUI (Krok 5 Kreatora) albo dopisz regule recznie w /etc/sudoers.d/cloudmachine (patrz README)."
      )
    }
    guard verifyResult.succeeded else {
      return CMActionResult(
        succeeded: false,
        message:
          "verifychecksums zglosilo problem - montowanie przez rclone nfsmount moze nie byc wystarczajaco niezawodne dla Time Machine."
      )
    }
    CMLogger.log("OK: sumy kontrolne sie zgadzaja.")

    CMLogger.log("Dodatkowo: rclone check lokalnego cache vs. Google Drive...")
    guard await rcloneCheck(localDir: localDir, remotePath: remotePath) else {
      return CMActionResult(
        succeeded: false,
        message: "rclone check wykazalo roznice miedzy lokalnym widokiem a stanem na Google Drive.")
    }

    return CMActionResult(
      succeeded: true, message: "Wszystkie testy przeszly. Backup wyglada na spojny.")
  }
}
