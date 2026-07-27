import Foundation

/// Port `unmount.sh` - odmontowuje wolumin CloudMachine i sparsebundle.
public enum UnmountService {
  public static func unmount(config: MachinesConfig, machineKey: String) async {
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
    // sparsebundle. `tmutil stopbackup` NIE wymaga sudo.
    if await TimeMachineStatus.isRunning() {
      CMLogger.log(
        "Time Machine aktywnie kopiuje - zatrzymuje backup przed odmontowaniem, zeby nie uszkodzic sparsebundle."
      )
      _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"])
      var waited = 0
      while waited < 30 {
        if !(await TimeMachineStatus.isRunning()) { break }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        waited += 2
      }
      if await TimeMachineStatus.isRunning() {
        CMLogger.log(
          "OSTRZEZENIE: Time Machine nie zatrzymalo sie po \(waited)s - odmontowuje mimo to, ryzyko uszkodzenia sparsebundle."
        )
      } else {
        CMLogger.log("Backup zatrzymany po \(waited)s.")
      }
    }

    if await MountHealth.isMounted(spMount.path) {
      CMLogger.log("Odmontowuje sparsebundle: \(spMount.path)")
      let detach = try? await ProcessRunner.run("/usr/bin/hdiutil", ["detach", spMount.path])
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
    let unmount = try? await ProcessRunner.run("/sbin/umount", [localDir.path])
    if unmount?.succeeded != true {
      let diskutilUnmount = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["unmount", localDir.path])
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
