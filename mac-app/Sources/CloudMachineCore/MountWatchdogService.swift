import Foundation

/// Wynik decyzji watchdoga - czysta wartosc, bez efektow ubocznych, zeby
/// `decide()` (ponizej) dalo sie testowac bez dotykania systemu plikow/
/// procesow (patrz CloudMachineCoreTests).
public enum MountWatchdogDecision: Equatable {
  case healthy
  case waitingForConfirmation(streak: Int)
  case waitingForRcloneDraining
  case needsRepair
}

/// Port `mount-watchdog.sh` - pilnuje, zeby montowanie (NFS + sparsebundle)
/// dzialalo NIEPRZERWANIE, tak dlugo jak uzytkownik chce miec je zamontowane.
public enum MountWatchdogService {
  public static let slowStreakThreshold = 3

  /// Czysta logika decyzyjna - jeden pojedynczy wolny probe NIE powinien od
  /// razu wywalac zdrowego mountu (pierwszy `stat` po swiezym zamontowaniu,
  /// zanim vfs-cache sie rozgrzeje, albo chwilowy skok latencji Google Drive
  /// API) - naprawiamy dopiero po `slowStreakThreshold` kolejnych nieudanych
  /// cyklach pod rzad.
  public static func decide(
    nfsListed: Bool, isResponsive: Bool, isBusyDraining: Bool, currentStreak: Int
  ) -> (decision: MountWatchdogDecision, newStreak: Int) {
    if nfsListed {
      if isResponsive {
        return (.healthy, 0)
      }
      let streak = currentStreak + 1
      if streak >= slowStreakThreshold {
        return (.needsRepair, 0)
      }
      return (.waitingForConfirmation(streak: streak), streak)
    } else {
      if isBusyDraining {
        return (.waitingForRcloneDraining, 0)
      }
      return (.needsRepair, 0)
    }
  }

  private static var streakFile: URL {
    CMPaths.logDir.appendingPathComponent(".mount-watchdog-slow-streak")
  }

  private static func readStreak() -> Int {
    guard let s = try? String(contentsOf: streakFile, encoding: .utf8) else { return 0 }
    return Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
  }

  private static func writeStreak(_ value: Int) {
    try? "\(value)".write(to: streakFile, atomically: true, encoding: .utf8)
  }

  private static func clearStreak() {
    try? FileManager.default.removeItem(at: streakFile)
  }

  public static func run(config: MachinesConfig, machineKey: String) async {
    guard
      await withCMLock(
        "mount-watchdog", { await runLocked(config: config, machineKey: machineKey) }) != nil
    else {
      return
    }
  }

  private static func runLocked(config: MachinesConfig, machineKey: String) async {
    guard RuntimeState.mountDesired else { return }

    await RuntimeState.startCaffeinate()
    CMLogger.rotateIfLarge(CMPaths.rcloneMountLogFile, maxBytes: 200 * 1024 * 1024, keepLines: 5000)

    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey)
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
    let remotePath = config.remotePath(forMachineKey: machineKey)

    let nfsListed = await MountHealth.isMounted(localDir.path)
    let isResponsive =
      nfsListed ? await MountHealth.probeResponsive(localDir.path, timeoutS: 20) : false
    let isBusyDraining =
      nfsListed ? false : await MountHealth.rcloneIsBusyDraining(remotePath, quietThreshold: 45)
    let currentStreak = readStreak()

    let (decision, _) = Self.decide(
      nfsListed: nfsListed, isResponsive: isResponsive, isBusyDraining: isBusyDraining,
      currentStreak: currentStreak
    )

    switch decision {
    case .healthy:
      clearStreak()
      if !(await MountHealth.isMounted(spMount.path)) {
        CMLogger.log(
          "[mount-watchdog] NFS zdrowy, ale wirtualny dysk sparsebundle nie jest zamontowany pod \(spMount.path) - montuje."
        )
        let sparsebundlePath = localDir.appendingPathComponent("backup.sparsebundle").path
        // WAZNE: timeout tutaj jest konieczny - bez niego zawieszony hdiutil
        // (zaobserwowane realnie: hdiutil attach nad NFS-em rclone potrafi
        // utknac w jadrze na wiele minut) blokowalby CALY ten przebieg
        // watchdoga w nieskonczonosc, co - poniewaz StartInterval launchd
        // nie odpala nowej instancji, dopoki poprzednia zyje - skutecznie
        // WYLACZALOBY samo-naprawe montowania do konca sesji.
        let result = try? await ProcessRunner.run(
          "/usr/bin/hdiutil",
          [
            "attach", "-noverify", "-noautoopen", "-nobrowse", "-mountpoint", spMount.path,
            sparsebundlePath,
          ], timeout: 180)
        if result?.succeeded != true {
          CMLogger.log(
            "[mount-watchdog] Nie udalo sie zamontowac sparsebundle w tym przebiegu, sprobuje ponownie w nastepnym cyklu."
          )
        }
      }
      return

    case .waitingForConfirmation(let streak):
      writeStreak(streak)
      CMLogger.log(
        "[mount-watchdog] \(localDir.path) nie odpowiedzialo w 20s (proba \(streak)/\(slowStreakThreshold)) - czekam na potwierdzenie w kolejnym cyklu przed naprawa."
      )
      return

    case .waitingForRcloneDraining:
      CMLogger.log(
        "[mount-watchdog] \(localDir.path) jeszcze nie zamontowane, ale rclone wciaz aktywnie pracuje (prawdopodobnie doganiam zalegle wysylki po przerwanym backupie) - czekam, nie przerywam."
      )
      return

    case .needsRepair:
      clearStreak()
      if nfsListed {
        CMLogger.log(
          "[mount-watchdog] \(localDir.path) nie odpowiada od \(slowStreakThreshold) kolejnych sprawdzen - traktuje jako zawieszone."
        )
      } else {
        CMLogger.log("[mount-watchdog] \(localDir.path) nie jest zamontowane, mimo ze powinno byc.")
      }
    }

    CMLogger.log("[mount-watchdog] Wykryto niezdrowe/zawieszone montowanie. Naprawiam...")

    // WAZNE: agresywny demontaz + kill odpalamy TYLKO gdy NFS naprawde
    // widnieje w tabeli mount, ale nie odpowiada. Jesli nic jeszcze nie
    // jest zamontowane, NIE wolno tu z wyprzedzeniem zabijac rclone -
    // moglibysmy trafic w sam srodek juz trwajacego, zdrowego montowania.
    if nfsListed {
      if await MountHealth.isMounted(spMount.path) {
        // WAZNE: jesli Time Machine akurat aktywnie pisze na ten wolumin,
        // `hdiutil detach -force` w trakcie zapisu potrafi uszkodzic
        // metadane sparsebundle - wtedy przy nastepnym mouncie wyglada to
        // jak "zniknal z chmury" i cala historia backupu zaczyna sie od
        // zera. Dajemy Time Machine szanse grzecznie sie zatrzymac, tak
        // jak robi to rowniez `UnmountService` przy recznym odmontowaniu.
        if await TimeMachineStatus.isRunning() {
          CMLogger.log(
            "[mount-watchdog] Time Machine aktywnie kopiuje - zatrzymuje backup przed wymuszonym odmontowaniem, zeby nie uszkodzic sparsebundle."
          )
          _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 20)
          var waited = 0
          while waited < 30 {
            if !(await TimeMachineStatus.isRunning()) { break }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            waited += 2
          }
          if await TimeMachineStatus.isRunning() {
            CMLogger.log(
              "[mount-watchdog] OSTRZEZENIE: Time Machine nie zatrzymalo sie po \(waited)s - odmontowuje mimo to, ryzyko uszkodzenia sparsebundle."
            )
          } else {
            CMLogger.log("[mount-watchdog] Backup zatrzymany po \(waited)s.")
          }
        }
        _ = try? await ProcessRunner.run("/usr/bin/hdiutil", ["detach", "-force", spMount.path])
        await MountHealth.forceUnmount(spMount.path, timeoutS: 10)
      }
      await MountHealth.forceUnmount(localDir.path, timeoutS: 10)
      await MountHealth.killRcloneForRemote(remotePath)
      if await MountHealth.isMounted(localDir.path) {
        CMLogger.log(
          "[mount-watchdog] Punkt montowania nadal widnieje w tabeli po probie wymuszonego odmontowania - mount przeniesie go na bok i utworzy nowy."
        )
      }
    }

    CMLogger.log("[mount-watchdog] Probuje zamontowac ponownie.")
    let success = await MountService.mount(config: config, machineKey: machineKey)
    if success {
      CMLogger.log("[mount-watchdog] Naprawa zakonczona powodzeniem.")
      _ = try? await ProcessRunner.run(
        "/usr/bin/osascript",
        [
          "-e",
          "display notification \"Wykryto zawieszone montowanie dysku Google i naprawiono je automatycznie.\" with title \"CloudMachine\"",
        ])
    } else {
      CMLogger.log(
        "[mount-watchdog] Naprawa nie powiodla sie w tym przebiegu, sprobuje ponownie przy nastepnym cyklu watchdoga."
      )
    }
  }
}
