import Foundation

/// Automatyzuje `CloudArchiveService.archivePending` - odpalane periodycznie
/// przez launchd (patrz `com.renacode.cloudmachine.archive-watchdog.plist.template`),
/// ale rzeczywista archiwizacja odpala sie co najwyzej raz na `intervalHours`
/// godzin, zeby nie kolidowac z toczacym sie backupem lokalnym ani nie
/// wysycac lacza w kolko bez potrzeby.
public enum ArchiveWatchdogService {
  public static var intervalHours: Int {
    if let env = ProcessInfo.processInfo.environment["CM_ARCHIVE_INTERVAL_HOURS"],
      let value = Int(env)
    {
      return value
    }
    return 6
  }

  private static var stateFile: URL {
    CMPaths.logDir.appendingPathComponent(".archive-watchdog-last-run")
  }

  /// Blokada TUTAJ ma inna nazwe niz ta w `CloudArchiveService.archivePending`
  /// (ktora chroni sam transfer przed rownoleglymi wywolaniami z GUI/CLI/
  /// watchdoga) - ta pilnuje wylacznie, zeby dwa nakladajace sie odpalenia
  /// TEGO watchdoga (np. launchd + reczne uruchomienie w tej samej chwili)
  /// nie sciegaly sie o plik stanu cooldownu. Gdyby uzyc tej samej nazwy,
  /// wewnetrzna blokada `archivePending` zawsze zawodzilaby (juz trzymana
  /// przez ten sam proces) i watchdog nigdy nie archiwizowalby niczego.
  public static func run(config: MachinesConfig, machineKey: String) async {
    await withCMLock("archive-watchdog-schedule") {
      await runLocked(config: config, machineKey: machineKey)
    }
  }

  private static func runLocked(config: MachinesConfig, machineKey: String) async {
    let lastEpoch = CooldownGate.parseStateFile(stateFile)
    guard
      !CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, cooldown: Double(intervalHours * 3600))
    else { return }

    CooldownGate.writeStateFile(stateFile)

    let result = await CloudArchiveService.archivePending(config: config, machineKey: machineKey)
    if result.succeeded {
      CMLogger.log("[archive-watchdog] \(result.message)")
    } else {
      CMLogger.log("[archive-watchdog] BLAD: \(result.message)")
    }
  }
}
