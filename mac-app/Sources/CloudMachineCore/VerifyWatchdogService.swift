import Foundation

/// Automatyzuje to, co README opisuje jako "wysoce zalecane, rob to
/// regularnie": weryfikacje sum kontrolnych najnowszego backupu. Realna
/// weryfikacja odpala sie co najwyzej raz na `intervalDays` dni (domyslnie 7) -
/// `tmutil verifychecksums` na duzym backupie moze trwac dlugo i mocno
/// obciazyc I/O.
public enum VerifyWatchdogService {
  public static var intervalDays: Int {
    if let env = ProcessInfo.processInfo.environment["CM_VERIFY_INTERVAL_DAYS"],
      let value = Int(env)
    {
      return value
    }
    return 7
  }

  private static var stateFile: URL {
    CMPaths.logDir.appendingPathComponent(".verify-watchdog-last-run")
  }

  public static func run(config: MachinesConfig, machineKey: String) async {
    await withCMLock("verify-watchdog") {
      await runWithDeviceLock(config: config, machineKey: machineKey)
    }
  }

  /// Patrz komentarz przy analogicznej funkcji w MountWatchdogService -
  /// blokada urzadzenia zapobiega temu, zeby wielogodzinna weryfikacja
  /// checksumow ruszyla w trakcie np. naprawy mountu czy przycinania quoty
  /// na tym samym sparsebundle (i odwrotnie).
  private static func runWithDeviceLock(config: MachinesConfig, machineKey: String) async {
    guard
      await withCMLock(
        deviceLockName(machineKey: machineKey),
        { await runLocked(config: config, machineKey: machineKey) }
      ) != nil
    else {
      CMLogger.log(
        "[verify-watchdog] Inna operacja trwa na tym urzadzeniu (mount/unmount/naprawa/przycinanie) - pomijam ten przebieg."
      )
      return
    }
  }

  private static func runLocked(config: MachinesConfig, machineKey: String) async {
    guard RuntimeState.mountDesired else { return }

    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
    let spReady = await MountHealth.isMounted(spMount.path)
    EdgeTriggeredLog.log(
      marker: CMPaths.logDir.appendingPathComponent(".verify-watchdog-mount-not-ready"),
      active: !spReady,
      "[verify-watchdog] Mount CloudMachine nie jest gotowy - pomijam kolejne przebiegi w milczeniu, dopoki mount-watchdog go nie naprawi."
    )
    guard spReady else { return }

    // Nie przeszkadzamy aktywnemu backupowi.
    if await TimeMachineStatus.isRunning() { return }

    let lastEpoch = CooldownGate.parseStateFile(stateFile)
    guard
      !CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, cooldown: Double(intervalDays * 86400))
    else { return }

    guard
      let listResult = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["listbackups", "-d", spMount.path], timeout: 60),
      let latestBackup = listResult.stdout.split(separator: "\n").last
    else {
      CMLogger.log("[verify-watchdog] Brak backupow do zweryfikowania, pomijam ten przebieg.")
      return
    }

    // Zapisujemy PRZED faktyczna weryfikacja (nie po) - dluga weryfikacja
    // (potencjalnie godziny) nie powinna sama siebie wywolywac ponownie w
    // kolko, jesli nastepny cykl watchdoga trafi w trakcie jej trwania.
    CooldownGate.writeStateFile(stateFile)

    CMLogger.log(
      "[verify-watchdog] Weryfikuje sumy kontrolne najnowszego backupu: \(latestBackup) (moze potrwac dlugo)."
    )
    // WAZNE: timeout (patrz analogiczny komentarz w BackupVerifier) - bez
    // niego zawieszony NFS moze zablokowac ten proces (i blokade urzadzenia,
    // ktora trzyma) na stale, wylaczajac backup/quota/mount-watchdog na czas
    // nieokreslony (zamiast na max. 15 min do przejecia blokady przez CMLock).
    let result = try? await ProcessRunner.runTmutilUnattended(
      ["verifychecksums", String(latestBackup)], timeout: 1800)
    if result?.succeeded == true {
      CMLogger.log("[verify-watchdog] OK: sumy kontrolne sie zgadzaja.")
    } else if result?.isSudoAuthFailure == true {
      // Brak reguly sudoers to problem konfiguracji, NIE dowod na
      // uszkodzony backup - nie strasz uzytkownika notyfikacja sugerujaca
      // realna niespojnosc danych za cos, co jest tylko brakiem uprawnien.
      CMLogger.log(
        "[verify-watchdog] BLAD: brak reguly sudoers dla 'tmutil verifychecksums' - skonfiguruj automatyczne przycinanie w GUI (albo dopisz regule recznie w /etc/sudoers.d/cloudmachine), zeby weryfikacja mogla dzialac bez nadzoru."
      )
    } else if result == nil {
      // WAZNE: `result == nil` oznacza, ze proces w ogole nie zwrocil
      // wyniku (timeout powyzej, mount odpadl w trakcie weryfikacji, blad
      // uruchomienia) - to problem OPERACYJNY, NIE dowod na uszkodzone sumy
      // kontrolne. Wczesniej ten przypadek wpadal w ta sama galaz co
      // faktyczne niezgodnosci sum, wiec zwykly zanik mountu w trakcie
      // wielogodzinnej weryfikacji strasyl uzytkownika falszywym alarmem o
      // uszkodzonym backupie.
      CMLogger.log(
        "[verify-watchdog] BLAD: verifychecksums nie zakonczylo sie poprawnie (timeout lub mount odpadl w trakcie weryfikacji) - to problem operacyjny, nie potwierdzenie uszkodzonych danych. Sprobuje ponownie przy nastepnym cyklu."
      )
    } else {
      CMLogger.log(
        "[verify-watchdog] UWAGA: verifychecksums wykryto realny problem z sumami kontrolnymi backupu."
      )
      _ = try? await ProcessRunner.run(
        "/usr/bin/osascript",
        [
          "-e",
          "display notification \"Weryfikacja sum kontrolnych najnowszego backupu wykazala problem - sprawdz Logi.\" with title \"CloudMachine\"",
        ])
    }
  }
}
