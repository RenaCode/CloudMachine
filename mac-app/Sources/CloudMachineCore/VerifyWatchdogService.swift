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
    await withCMLock("verify-watchdog") { await runLocked(config: config, machineKey: machineKey) }
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
        "/usr/bin/tmutil", ["listbackups", "-d", spMount.path]),
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
    let result = try? await ProcessRunner.runTmutilUnattended([
      "verifychecksums", String(latestBackup),
    ])
    if result?.succeeded == true {
      CMLogger.log("[verify-watchdog] OK: sumy kontrolne sie zgadzaja.")
    } else if result?.isSudoAuthFailure == true {
      // Brak reguly sudoers to problem konfiguracji, NIE dowod na
      // uszkodzony backup - nie strasz uzytkownika notyfikacja sugerujaca
      // realna niespojnosc danych za cos, co jest tylko brakiem uprawnien.
      CMLogger.log(
        "[verify-watchdog] BLAD: brak reguly sudoers dla 'tmutil verifychecksums' - skonfiguruj automatyczne przycinanie w GUI (albo dopisz regule recznie w /etc/sudoers.d/cloudmachine), zeby weryfikacja mogla dzialac bez nadzoru."
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
