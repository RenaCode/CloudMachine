import Foundation

/// Port `unmount.sh` - odmontowuje wolumin CloudMachine i sparsebundle.
public enum UnmountService {
  /// Wczesniej ta funkcja nie brala ZADNEJ blokady - klikniecie "Odmontuj" w
  /// GUI moglo wystartowac rownolegle z naprawa mount-watchdoga (albo z
  /// przycinaniem quoty czy weryfikacja checksumow), bo wszystkie one dotykaly
  /// tego samego hdiutil/rclone bez wzajemnego wykluczenia. Patrz
  /// `deviceLockName` w CMLock.swift.
  @discardableResult
  public static func unmount(config: MachinesConfig, machineKey: String) async -> Bool {
    let result = await withCMLock(deviceLockName(machineKey: machineKey)) {
      await unmountLocked(config: config, machineKey: machineKey, userInitiated: true)
    }
    guard let result else {
      CMLogger.log(
        "Inna operacja na tym urzadzeniu juz trwa (mount/naprawa/przycinanie/weryfikacja) - pomijam odmontowanie w tym przebiegu."
      )
      return false
    }
    return result
  }

  /// Bez `private` (celowo) - patrz analogiczny komentarz przy
  /// `MountService.mountLocked`: `MountWatchdogService` wola to bezposrednio
  /// gdy juz trzyma blokade urzadzenia z zewnatrz.
  ///
  /// `userInitiated`: `true` z publicznego `unmount()` (uzytkownik naprawde
  /// chce odmontowac). `false`, gdy wywolujacym jest wewnetrzna operacja
  /// utrzymaniowa (np. `MountWatchdogService.checkForStuckBandAndRemount`,
  /// ktory odmontowuje TYLKO po to, zeby zaraz z powrotem zamontowac) - w
  /// tym przypadku NIE zmieniamy `mountDesired`. WAZNE: zmiana tego flaga
  /// bylo wczesniej bezwarunkowe, wiec kazdy wewnetrzny remont ustawial
  /// `mountDesired=false`, a `mountLocked` przywraca `true` TYLKO przy pelnym
  /// sukcesie - kazda przejsciowa porazka w trakcie remontu (np. chwilowy
  /// blad API Google Drive) trwale gasila cala automatyczna naprawe do konca
  /// sesji, bo kazdy kolejny watchdog zaczyna od `guard mountDesired else
  /// { return }` (zaobserwowane jako realne ryzyko w audycie).
  /// Zwraca `true`, jesli odmontowanie faktycznie sie odbylo (albo nie bylo
  /// czego odmontowywac), `false` jesli zostalo PRZERWANE, bo Time Machine
  /// nie potwierdzilo zatrzymania - w tym przypadku wolumin ZOSTAJE
  /// zamontowany tak jak byl (nic nie zostalo wymuszone).
  @discardableResult
  static func unmountLocked(
    config: MachinesConfig, machineKey: String, userInitiated: Bool
  ) async -> Bool {
    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey)
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
    let remotePath = config.remotePath(forMachineKey: machineKey)

    if userInitiated {
      // Zapisujemy PRZED faktycznym odmontowaniem, zeby mount-watchdog (ktory
      // moze odpalic sie w dowolnej chwili w tle) od razu przestal traktowac
      // ten wolumin jako "powinien byc zamontowany".
      RuntimeState.setMountDesired(false)
      RuntimeState.stopCaffeinate()
    }

    // Jesli Time Machine akurat aktywnie pisze na ten wolumin, zatrzymujemy
    // backup i CZEKAMY az faktycznie stanie, ZANIM odmontujemy - wymuszone
    // odmontowanie w trakcie aktywnego zapisu potrafi uszkodzic metadane
    // sparsebundle. Jesli TM NIE potwierdzi zatrzymania, PRZERYWAMY - nie
    // wolno kontynuowac wymuszonego demontazu (dokladnie ten mechanizm
    // realnie uszkodzil kontener APFS przy "goracych" bandach metadanych,
    // ktore sa dotykane zbyt czesto, zeby kiedykolwiek dostac okno ciszy
    // podczas gdy TM wciaz aktywnie pisze).
    guard await MountHealth.stopTimeMachineIfRunning() else {
      if userInitiated {
        // Cofamy zmiane stanu z gory funkcji - wolumin ZOSTAJE zamontowany,
        // wiec "zamiar" powinien nadal odzwierciedlac rzeczywistosc.
        RuntimeState.setMountDesired(true)
        await RuntimeState.startCaffeinate()
      }
      return false
    }

    if await MountHealth.isMounted(spMount.path) {
      CMLogger.log("Odmontowuje sparsebundle: \(spMount.path)")
      // Timeout/fallback na wypadek zawieszonego NFS-a (kliknięcie "Odmontuj"
      // w GUI mogloby inaczej zawiesic sie na zawsze) jest scentralizowany w
      // `detachSparsebundle` (patrz komentarz przy jej definicji w MountHealth).
      _ = await MountHealth.detachSparsebundle(spMount.path, force: false)
    }

    if !(await MountHealth.isMounted(localDir.path)) {
      CMLogger.log("Nic do odmontowania pod \(localDir.path).")
      await MountHealth.killRcloneForRemote(remotePath)
      return true
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
    return true
  }
}
