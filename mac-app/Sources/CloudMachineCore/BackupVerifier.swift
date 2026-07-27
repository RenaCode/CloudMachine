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
    guard
      let verifyResult = try? await ProcessRunner.runTmutilUnattended([
        "verifychecksums", latestBackup,
      ]), verifyResult.succeeded
    else {
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
