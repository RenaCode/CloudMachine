import Foundation

/// Automatyzuje to, co README opisuje jako "wysoce zalecane, rob to
/// regularnie": weryfikacje sum kontrolnych najnowszego backupu. Realna
/// weryfikacja odpala sie co najwyzej raz na `intervalDays` dni (domyslnie 7) -
/// `tmutil verifychecksums` na duzym backupie moze trwac dlugo i mocno
/// obciazyc I/O. W architekturze lokalnego woluminu APFS nie ma juz
/// zawieszajacych sie montowan NFS/sparsebundle do pilnowania (patrz legacy
/// `MountHealth`/`RuntimeState` usuniete razem z ta zmiana) - jedyna ochrona
/// potrzebna tutaj to nie startowac drugiej weryfikacji rownolegle z inna.
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

  public static func run() async {
    await withCMLock("verify-watchdog") {
      await runLocked()
    }
  }

  private static func runLocked() async {
    let volume = await LocalBackupService.currentStatus()
    guard let mountPoint = volume.mountPoint, volume.exists else {
      // EdgeTriggeredLog zamiast zwyklego CMLogger.log - bez tego kazdy
      // codzienny cykl watchdoga (RunAtLoad+StartInterval, patrz plist) na
      // Maku bez jeszcze utworzonego woluminu zapisywalby identyczna linie
      // w kolko w nieskonczonosc, zasypujac wspolny log.
      EdgeTriggeredLog.log(
        marker: CMPaths.logDir.appendingPathComponent(".verify-watchdog-no-volume"),
        active: true,
        "[verify-watchdog] Brak lokalnego woluminu backupu, pomijam ten przebieg."
      )
      return
    }
    EdgeTriggeredLog.log(
      marker: CMPaths.logDir.appendingPathComponent(".verify-watchdog-no-volume"), active: false,
      "")

    // Nie przeszkadzamy aktywnemu backupowi.
    if await TimeMachineStatus.isRunning() { return }

    let lastEpoch = CooldownGate.parseStateFile(stateFile)
    guard
      !CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, cooldown: Double(intervalDays * 86400))
    else { return }

    guard
      let listResult = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["listbackups", "-d", mountPoint], timeout: 60),
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
    let result = try? await ProcessRunner.runTmutilUnattended(
      ["verifychecksums", String(latestBackup)], timeout: 1800)
    if result?.succeeded == true {
      CMLogger.log("[verify-watchdog] OK: sumy kontrolne sie zgadzaja.")
    } else if result?.isSudoAuthFailure == true {
      // Brak reguly sudoers to problem konfiguracji, NIE dowod na
      // uszkodzony backup - nie strasz uzytkownika notyfikacja sugerujaca
      // realna niespojnosc danych za cos, co jest tylko brakiem uprawnien.
      CMLogger.log(
        "[verify-watchdog] BLAD: brak reguly sudoers dla 'tmutil verifychecksums' - dopisz regule recznie w /etc/sudoers.d/cloudmachine (patrz README), zeby weryfikacja mogla dzialac bez nadzoru."
      )
    } else if result == nil {
      // WAZNE: `result == nil` oznacza, ze proces w ogole nie zwrocil
      // wyniku (timeout powyzej, blad uruchomienia) - to problem
      // OPERACYJNY, NIE dowod na uszkodzone sumy kontrolne.
      CMLogger.log(
        "[verify-watchdog] BLAD: verifychecksums nie zakonczylo sie poprawnie (timeout lub blad uruchomienia) - to problem operacyjny, nie potwierdzenie uszkodzonych danych. Sprobuje ponownie przy nastepnym cyklu."
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
