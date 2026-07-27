import Foundation

/// Port `quota-watchdog.sh` - pilnuje, zeby backup tej maszyny na Google Drive
/// nie przekroczyl przydzielonego jej limitu, kasujac najstarsze backupy Time
/// Machine gdy trzeba (ale NIGDY ostatniego pozostalego).
public enum QuotaWatchdogService {
  /// Zabezpieczenie przed literowka w konfiguracji (limit <=0 sprawilby, ze
  /// prog przycinania tez jest <=0 - watchdog uznalby, ze ZAWSZE jest nad
  /// limitem i zaczalby aktywnie kasowac WSZYSTKIE backupy). Ta sama granica
  /// co w GUI (`MachinesConfigView.minimumMachineLimitGB`), ale niezalezna -
  /// to jest ostatnia linia obrony dla instalacji CLI-only bez GUI.
  public static let minSaneLimitGB = 10

  /// Czyste funkcje (bez efektow ubocznych), wydzielone zeby dalo sie je
  /// przetestowac bez shellowania do rclone/tmutil - patrz
  /// CloudMachineCoreTests.
  public static func isLimitSane(_ limitGB: Int) -> Bool { limitGB >= minSaneLimitGB }

  /// Sprawdzaj przy 90% limitu, zeby zdazyc przyciac zanim TM sam zablokuje zapis.
  public static func triggerGB(forLimitGB limitGB: Int) -> Int { Int(Double(limitGB) * 0.9) }

  public static func run(config: MachinesConfig, machineKey: String) async {
    await withCMLock("quota-watchdog") { await runLocked(config: config, machineKey: machineKey) }
  }

  private static func runLocked(config: MachinesConfig, machineKey: String) async {
    CMLogger.rotateIfLarge(CMPaths.combinedLogFile, maxBytes: 10 * 1024 * 1024, keepLines: 3000)

    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
    let remotePath = config.remotePath(forMachineKey: machineKey)

    guard let limitGB = config.limitGB(forMachineKey: machineKey) else {
      CMLogger.log("BLAD: maszyna '\(machineKey)' nie jest zdefiniowana w konfiguracji.")
      return
    }
    guard isLimitSane(limitGB) else {
      CMLogger.log(
        "BLAD: limit skonfigurowany dla '\(machineKey)' (\(limitGB) GB) jest podejrzanie niski (<\(minSaneLimitGB) GB) - to prawie na pewno pomylka w konfiguracji, nie zamierzona wartosc. Przerywam, ZEBY NIE SKASOWAC wszystkich backupow. Popraw limit recznie."
      )
      return
    }

    let triggerGB = Self.triggerGB(forLimitGB: limitGB)
    CMLogger.log(
      "Sprawdzam wykorzystanie \(remotePath) (limit \(limitGB) GB, prog przycinania \(triggerGB) GB)"
    )

    guard var usedGB = await RcloneSize.usedGB(remotePath: remotePath, timeout: 180) else {
      CMLogger.log("BLAD: 'rclone size' nie powiodlo sie. Przerywam ten przebieg.")
      return
    }
    CMLogger.log("Aktualne wykorzystanie: \(String(format: "%.1f", usedGB)) GB / \(limitGB) GB")

    guard Int(usedGB) >= triggerGB else {
      CMLogger.log("Ponizej progu, nic do zrobienia.")
      return
    }

    guard await MountHealth.isMounted(spMount.path) else {
      CMLogger.log(
        "BLAD: przekroczono prog, ale wirtualny dysk sparsebundle pod \(spMount.path) nie jest zamontowany - nie moge wylistowac backupow TM do przyciecia."
      )
      return
    }

    CMLogger.log(
      "Przekroczono prog przycinania. Szukam najstarszych backupow Time Machine do usuniecia.")

    guard
      let listResult = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["listbackups", "-d", spMount.path])
    else {
      return
    }
    // tmutil listbackups zwraca sciezki posortowane od najstarszego do najnowszego.
    let backups = listResult.stdout.split(separator: "\n").map(String.init)

    guard backups.count > 1 else {
      CMLogger.log(
        "UWAGA: zostal juz tylko \(backups.count) backup(ow) - nie usuwam, zeby nie zostac bez kopii zapasowej. Rozwaz podniesienie limitu."
      )
      return
    }

    var deleted = 0
    for backupPath in backups {
      guard backups.count > deleted + 1 else { break }
      CMLogger.log("Usuwam najstarszy backup: \(backupPath)")
      let deleteResult = try? await ProcessRunner.run(
        "/usr/bin/sudo", ["-n", "/usr/bin/tmutil", "delete", "-p", backupPath])
      guard deleteResult?.succeeded == true else {
        CMLogger.log("BLAD przy usuwaniu \(backupPath) (sudo bez hasla niedostepne lub inny blad).")
        break
      }
      deleted += 1

      guard let refreshed = await RcloneSize.usedGB(remotePath: remotePath, timeout: 180) else {
        break
      }
      usedGB = refreshed
      CMLogger.log("Po usunieciu: \(String(format: "%.1f", usedGB)) GB / \(limitGB) GB")
      if Int(usedGB) < triggerGB { break }
    }

    CMLogger.log("Zakonczono. Usunieto \(deleted) backup(ow).")
    if deleted > 0 {
      _ = try? await ProcessRunner.run(
        "/usr/bin/osascript",
        [
          "-e",
          "display notification \"Usunieto \(deleted) najstarszych backupow, zeby zmiescic sie w limicie \(limitGB) GB\" with title \"CloudMachine\"",
        ])
    }
  }
}
