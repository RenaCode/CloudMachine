import Foundation

/// Port `unmount.sh` - odmontowuje wolumin CloudMachine i sparsebundle.
public enum UnmountService {
  /// Wczesniej ta funkcja nie brala ZADNEJ blokady - klikniecie "Odmontuj" w
  /// GUI moglo wystartowac rownolegle z naprawa mount-watchdoga (albo z
  /// przycinaniem quoty czy weryfikacja checksumow), bo wszystkie one dotykaly
  /// tego samego hdiutil/rclone bez wzajemnego wykluczenia. Patrz
  /// `deviceLockName` w CMLock.swift.
  public static func unmount(config: MachinesConfig, machineKey: String) async {
    let didRun: Void? = await withCMLock(deviceLockName(machineKey: machineKey)) {
      await unmountLocked(config: config, machineKey: machineKey)
    }
    if didRun == nil {
      CMLogger.log(
        "Inna operacja na tym urzadzeniu juz trwa (mount/naprawa/przycinanie/weryfikacja) - pomijam odmontowanie w tym przebiegu."
      )
    }
  }

  /// Bez `private` (celowo) - patrz analogiczny komentarz przy
  /// `MountService.mountLocked`: `MountWatchdogService` wola to bezposrednio
  /// gdy juz trzyma blokade urzadzenia z zewnatrz.
  static func unmountLocked(config: MachinesConfig, machineKey: String) async {
    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey)
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
    let remotePath = config.remotePath(forMachineKey: machineKey)

    // Zapisujemy PRZED faktycznym odmontowaniem, zeby mount-watchdog (ktory
    // moze odpalic sie w dowolnej chwili w tle) od razu przestal traktowac
    // ten wolumin jako "powinien byc zamontowany".
    RuntimeState.setMountDesired(false)
    RuntimeState.stopCaffeinate()

    // Jesli Time Machine akurat aktywnie pisze na ten wolumin, zatrzymujemy
    // backup i CZEKAMY az faktycznie stanie, ZANIM odmontujemy - wymuszone
    // odmontowanie w trakcie aktywnego zapisu potrafi uszkodzic metadane
    // sparsebundle.
    await MountHealth.stopTimeMachineIfRunning()

    if await MountHealth.isMounted(spMount.path) {
      CMLogger.log("Odmontowuje sparsebundle: \(spMount.path)")
      // WAZNE: timeout tutaj jest konieczny - `hdiutil detach` na sparsebundle
      // nad NFS-em rclone potrafi utknac w jadrze w nieprzerywalnym
      // oczekiwaniu (zaobserwowane realnie na zywo, patrz komentarz przy
      // `ProcessRunner.run(timeout:)`). Bez tego kliknięcie "Odmontuj" w GUI
      // mogloby zawiesic sie na zawsze.
      let detach = try? await ProcessRunner.run(
        "/usr/bin/hdiutil", ["detach", spMount.path], timeout: 20)
      if detach?.succeeded != true {
        await MountHealth.forceUnmount(spMount.path, timeoutS: 10)
      }
    }

    if !(await MountHealth.isMounted(localDir.path)) {
      CMLogger.log("Nic do odmontowania pod \(localDir.path).")
      await MountHealth.killRcloneForRemote(remotePath)
      return
    }

    CMLogger.log("Odmontowuje \(localDir.path)")
    let unmount = try? await ProcessRunner.run("/sbin/umount", [localDir.path], timeout: 15)
    if unmount?.succeeded != true {
      let diskutilUnmount = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["unmount", localDir.path], timeout: 15)
      if diskutilUnmount?.succeeded != true {
        CMLogger.log("Zwykle odmontowanie nie powiodlo sie, probuje force unmount.")
        if !(await MountHealth.forceUnmount(localDir.path, timeoutS: 10)) {
          CMLogger.log(
            "OSTRZEZENIE: punkt montowania nadal widnieje w tabeli po probie wymuszonego odmontowania - proces diskutil moze zostac osierocony w tle."
          )
        }
      }
    }
    await MountHealth.killRcloneForRemote(remotePath)
    CMLogger.log("Odmontowano.")
  }
}
