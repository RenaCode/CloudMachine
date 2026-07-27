import Foundation

/// Port `backup-watchdog.sh` - pilnuje, zeby backup Time Machine na
/// CloudMachine wznawial sie SAM po nieudanej probie (znane ryzyko:
/// `BACKUP_FAILED_DISCONNECTED_DESTINATION`, mimo ze sam wolumin jest w danym
/// momencie realnie zdrowy), bez recznej interwencji.
public enum BackupWatchdogService {
  private static let cooldown: TimeInterval = 180
  private static var stateFile: URL {
    CMPaths.logDir.appendingPathComponent(".backup-watchdog-last-attempt")
  }

  public static func run(config: MachinesConfig, machineKey: String) async {
    await withCMLock("backup-watchdog") {
      await runWithDeviceLock(config: config, machineKey: machineKey)
    }
  }

  /// Patrz komentarz przy analogicznej funkcji w MountWatchdogService -
  /// blokada urzadzenia zapobiega wznowieniu backupu w trakcie np. naprawy
  /// mountu czy przycinania quoty na tym samym sparsebundle.
  private static func runWithDeviceLock(config: MachinesConfig, machineKey: String) async {
    guard
      await withCMLock(
        deviceLockName(machineKey: machineKey),
        { await runLocked(config: config, machineKey: machineKey) }
      ) != nil
    else {
      CMLogger.log(
        "[backup-watchdog] Inna operacja trwa na tym urzadzeniu (mount/unmount/naprawa/przycinanie/weryfikacja) - pomijam ten przebieg."
      )
      return
    }
  }

  private static func runLocked(config: MachinesConfig, machineKey: String) async {
    guard RuntimeState.mountDesired else { return }

    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey)
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)

    // Interweniujemy WYLACZNIE gdy nasz wlasny mount jest w tabeli `mount` -
    // jesli jest zepsuty/brakujacy, to zadanie mount-watchdog, nie nasze.
    let nfsReady = await MountHealth.isMounted(localDir.path)
    let spReady = await MountHealth.isMounted(spMount.path)
    let mountReady = nfsReady && spReady
    EdgeTriggeredLog.log(
      marker: CMPaths.logDir.appendingPathComponent(".backup-watchdog-mount-not-ready"),
      active: !mountReady,
      "[backup-watchdog] Mount CloudMachine nie jest gotowy - pomijam kolejne przebiegi w milczeniu, dopoki mount-watchdog go nie naprawi."
    )
    guard mountReady else { return }

    guard let destID = await TimeMachineStatus.destinationID(forMountPointContaining: spMount.path)
    else { return }

    // Jesli TM aktualnie cos aktywnie robi (do CloudMachine, czy do innego
    // celu uzytkownika) - nie przeszkadzamy.
    if await TimeMachineStatus.isRunning() { return }

    let lastEpoch = CooldownGate.parseStateFile(stateFile)
    guard !CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, cooldown: cooldown) else { return }
    CooldownGate.writeStateFile(stateFile)

    CMLogger.log(
      "[backup-watchdog] Time Machine jest bezczynne, mimo ze CloudMachine (\(destID)) powinno byc aktywne - wznawiam."
    )
    let result = try? await ProcessRunner.runTmutilUnattended(["startbackup", "-d", destID])
    if result?.succeeded == true {
      CMLogger.log("[backup-watchdog] Wznowiono backup.")
    } else if result?.isSudoAuthFailure == true {
      CMLogger.log(
        "[backup-watchdog] Nie udalo sie wznowic backupu - brak reguly sudoers dla 'tmutil startbackup'. Skonfiguruj automatyczne przycinanie w GUI (albo dopisz regule recznie w /etc/sudoers.d/cloudmachine)."
      )
    } else {
      CMLogger.log(
        "[backup-watchdog] Nie udalo sie wznowic backupu - tmutil zglosilo blad. Sprawdz Logi/Console.app."
      )
    }
  }
}
