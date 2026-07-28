import Foundation

/// Port `mount.sh` - montuje folder tej maszyny z Google Drive jako lokalny
/// wolumin (przez `rclone nfsmount`, wbudowany serwer NFS rclone - Homebrew'owy
/// rclone na macOS jest budowany bez wsparcia FUSE), gotowy do wskazania jako
/// cel Time Machine.
public enum MountService {
  private static let rcloneTransfers = "32"
  private static let rcloneCheckers = "32"
  private static let rcloneTpsLimit = "50"
  private static let rcloneVfsWriteBack = "5s"

  /// Wczesniej sztywne "40G" - zbyt male, gdy pojedynczy "goracy" band
  /// (dziennik/metadane APFS dopisywane bez przerwy przez caly czas trwania
  /// backupu) nigdy nie dostaje 5-sekundowego okna ciszy potrzebnego do
  /// uploadu (patrz `MountHealth.detectStuckBand`) i rosnie w lokalnym cache
  /// bez konca - zaobserwowane realnie: cache przekroczyl skonfigurowany
  /// max. Rclone i tak nie wymusza twardego limitu (eviction jest leniwe, nie
  /// blokujace - patrz rclone docs), ale hojniejszy margines zmniejsza szanse
  /// na sytuacje, w ktorej cache jest pod ciagla presja zamiast miec zapas.
  /// Ograniczone do [40, 200] GB i do 1/4 faktycznie wolnego miejsca, zeby
  /// nie obiecywac wiecej niz lokalny dysk realnie ma.
  private static func vfsCacheMaxSize() -> String {
    let freeGB = localFreeDiskGB() ?? 160
    let capped = min(max(freeGB / 4, 40), 200)
    return "\(capped)G"
  }

  private static func localFreeDiskGB() -> Int? {
    guard
      let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(
        forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
      let bytes = values.volumeAvailableCapacityForImportantUsage
    else { return nil }
    return Int(bytes / 1_073_741_824)
  }

  /// Zwraca `true`, jesli po zakonczeniu wolumin NFS jest zamontowany
  /// (sparsebundle moglo sie nie udac oddzielnie - to nie jest fatalne, patrz
  /// `mountSparsebundle`).
  @discardableResult
  public static func mount(config: MachinesConfig, machineKey: String) async -> Bool {
    let result = await withCMLock(deviceLockName(machineKey: machineKey)) {
      await mountLocked(config: config, machineKey: machineKey)
    }
    guard let result else {
      CMLogger.log(
        "Inna operacja na tym urzadzeniu juz trwa (mount/unmount/naprawa/przycinanie/weryfikacja), pomijam ten przebieg."
      )
      return await MountHealth.isMounted(CMPaths.localMachineMountDir(machineKey: machineKey).path)
    }
    return result
  }

  /// Bez `private` (celowo) - `MountWatchdogService` wola to bezposrednio
  /// przy remoncie po wykryciu utknietego bandu, gdy JUZ trzyma blokade
  /// urzadzenia z zewnatrz (`deviceLockName`) - ponowne wejscie przez
  /// publiczne `mount()` (ktore samo probuje ja wziac) zaklinowaloby sie na
  /// wlasnej blokadzie, bo `CMLock` nie jest rekurencyjny.
  static func mountLocked(config: MachinesConfig, machineKey: String) async -> Bool {
    let remotePath = config.remotePath(forMachineKey: machineKey)
    let localDir = CMPaths.localMachineMountDir(machineKey: machineKey)
    let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)

    try? FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)

    let nfsMounted = await MountHealth.isMounted(localDir.path)
    let spMounted = await MountHealth.isMounted(spMount.path)

    if nfsMounted && spMounted {
      CMLogger.log("Zarowno wolumin NFS jak i wirtualny dysk sparsebundle sa juz zamontowane.")
      return true
    }

    // 1. Sprawdzamy, czy sparsebundle istnieje na Google Drive (PRZED
    // montowaniem NFS, zeby uniknac problemow z cache i zapisu plikow
    // konfiguracyjnych bezposrednio przez NFS).
    let sparsebundlePath = "\(remotePath)/backup.sparsebundle"
    let listResult = try? await ProcessRunner.runRclone(["lsf", sparsebundlePath])
    // WAZNE: `try?`/`succeeded != true` NIE ROZROZNIA "sprawdzenie sie nie
    // udalo" (blad sieci, przejsciowy 429 z Google Drive API, timeout) od
    // "potwierdzone, ze pusto/nie istnieje". Traktowanie porazki sprawdzenia
    // jako "nie istnieje" jest niebezpieczne - ponizej kod TWORZY nowy pusty
    // sparsebundle i `rclone copy` go NA WIERZCH istniejacej sciezki, co przy
    // prawdziwym, w pelni przeslanym backupie nadpisuje/kasuje jego dane.
    // Dlatego przerywamy montowanie zamiast zgadywac, gdy samo sprawdzenie
    // zawiodlo - "nie wiem" nie moze pociagac za soba destrukcyjnej akcji.
    guard let listResult else {
      CMLogger.log(
        "BLAD: nie udalo sie sprawdzic czy sparsebundle istnieje w chmurze (blad polaczenia z rclone) - przerywam, zeby nie ryzykowac nadpisania istniejacego backupu."
      )
      return false
    }
    guard listResult.succeeded else {
      CMLogger.log(
        "BLAD: 'rclone lsf' zakonczylo sie bledem podczas sprawdzania sparsebundle w chmurze - przerywam, zeby nie ryzykowac nadpisania istniejacego backupu. Sprobuje ponownie przy nastepnym cyklu."
      )
      return false
    }
    // `rclone lsf` zwraca exit 0 z PUSTYM stdout gdy folder istnieje, ale
    // jest pusty (np. po `rclone delete` ktory zostawia katalog bez plikow).
    // Pusty folder != istniejacy sparsebundle - trzeba sprawdzic czy lsf zwrocil
    // jakikolwiek content (poprawny sparsebundle ZAWSZE ma co najmniej Info.plist).
    // Bez tego warunku MountService pomijal tworzenie nowego sparsebundle i probowal
    // zamontowac pusty folder -> "hdiutil: image not recognized" w nieskonczonosc.
    let sparsebundleExists =
      !listResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    if !sparsebundleExists {
      guard let limitGB = config.limitGB(forMachineKey: machineKey) else {
        CMLogger.log("BLAD: maszyna '\(machineKey)' nie jest zdefiniowana w konfiguracji.")
        return false
      }
      CMLogger.log(
        "Brak sparsebundle w chmurze. Tworze i przesylam nowy wirtualny dysk (limit \(limitGB) GB)..."
      )
      let tmpSp = "/tmp/cm-temp-\(machineKey).sparsebundle"
      try? FileManager.default.removeItem(atPath: tmpSp)
      let createResult = try? await ProcessRunner.run(
        "/usr/bin/hdiutil",
        [
          "create", "-size", "\(limitGB)g", "-fs", "APFS",
          "-volname", "CloudMachine-Backup-\(machineKey)", "-type", "SPARSEBUNDLE",
          // WAZNE: domyslny band-size hdiutil to ~8MB. Wszystkie bandy
          // sparsebundle musza usiedziec w JEDNYM katalogu, a macOS/APFS
          // zaczyna zawodzic w okolicy ~100 000 plikow w katalogu - przy
          // 8MB bandach to zaledwie ~800GB (100 000 x 8MB), duzo ponizej
          // typowych limitow maszyn (np. 3500GB tutaj), wiec sparsebundle
          // mial realna szanse trafic w ta sciane dlugo przed zapelnieniem
          // limitu. 128MB bandy (sprawdzony w spolecznosci rozmiar dla
          // Time Machine po sieci, patrz "sparse-band-size=262144" =
          // 262144 sektorow x 512B = 128MB) dają margines do ~12-13TB
          // przy tym samym limicie plikow, ORAZ - jako efekt uboczny -
          // duzo mniej plikow do zsynchronizowania przez rclone/NFS, co
          // bylo tez zrodlem spowolnien przy duzej liczbie malych plikow.
          "-imagekey", "sparse-band-size=262144",
          tmpSp,
        ])
      guard createResult?.succeeded == true else {
        CMLogger.log("BLAD: nie udalo sie utworzyc lokalnego sparsebundle.")
        return false
      }
      CMLogger.log("Przesylam sparsebundle bezposrednio na Dysk Google (bypassing NFS)...")
      var copyArgs = ["copy", tmpSp, sparsebundlePath]
      if let bwLimit = bwLimitArg(mbps: config.bwLimitMbps) {
        copyArgs.append(contentsOf: ["--bwlimit", bwLimit])
      }
      let copyResult = try? await ProcessRunner.runRclone(copyArgs)
      try? FileManager.default.removeItem(atPath: tmpSp)
      guard copyResult?.succeeded == true else {
        CMLogger.log("BLAD: nie udalo sie przeslac nowego sparsebundle na Google Drive.")
        return false
      }
      CMLogger.log("Wirtualny dysk zostal przeslany do chmury.")
      await cleanStaleVFSCache(config: config, machineKey: machineKey)
    }

    // 2. Montujemy NFS, jesli jeszcze nie jest.
    var mountOK = nfsMounted
    if !nfsMounted {
      var alreadyRunning = false
      if await MountHealth.rcloneIsBusyDraining(remotePath) {
        CMLogger.log(
          "Istniejacy proces rclone dla tego remote wciaz aktywnie pracuje (prawdopodobnie dogania zalegla kolejke) - NIE ubijam, czekam na niego zamiast startowac nowy."
        )
        alreadyRunning = true
      } else {
        await MountHealth.stopTimeMachineIfRunning()
        await MountHealth.killRcloneForRemote(remotePath)
        await MountHealth.forceUnmount(localDir.path, timeoutS: 10)
      }

      CMLogger.log(
        "Montuje \(remotePath) -> \(localDir.path) (vfs-cache-mode=full, cache max=\(vfsCacheMaxSize()))"
      )

      for attempt in 1...2 {
        var started = alreadyRunning
        if !alreadyRunning {
          started = await startRcloneDaemon(
            remotePath: remotePath, localDir: localDir, bwLimitMbps: config.bwLimitMbps)
        }
        if started {
          var waited = 0
          while true {
            if await MountHealth.isMounted(localDir.path) {
              mountOK = true
              break
            }
            if waited >= 10 {
              let stillDraining = await MountHealth.rcloneIsBusyDraining(remotePath)
              if !stillDraining {
                CMLogger.log(
                  "Proba \(attempt): rclone przestal robic postepy (brak aktywnosci w logu >45s) po \(waited)s oczekiwania - przerywam ta probe."
                )
                break
              }
            }
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            waited += 5
          }
        }
        if mountOK { break }
        alreadyRunning = false
        if attempt == 1 {
          CMLogger.log("Proba \(attempt) nie powiodla sie, sprzatam i probuje ponownie...")
          await MountHealth.stopTimeMachineIfRunning()
          await MountHealth.forceUnmount(localDir.path, timeoutS: 10)
          await MountHealth.killRcloneForRemote(remotePath)
          try? await Task.sleep(nanoseconds: 1_000_000_000)
          if !(await MountHealth.isMounted(localDir.path)) {
            cleanupOldStuckDirs(localDir: localDir, keepNewest: 2)
            let stuckDir = localDir.deletingLastPathComponent()
              .appendingPathComponent(
                "\(localDir.lastPathComponent)-zaklinowany-\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.moveItem(at: localDir, to: stuckDir)
            try? FileManager.default.createDirectory(
              at: localDir, withIntermediateDirectories: true)
          }
          try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
      }
    }

    if mountOK {
      CMLogger.log("NFS gotowy, montuje wirtualny dysk...")
      await mountSparsebundle(localDir: localDir, spMount: spMount)
      CMLogger.log("Narzedzie CloudMachine gotowe do pracy.")
      RuntimeState.setMountDesired(true)
      await RuntimeState.startCaffeinate()
      return true
    } else {
      CMLogger.log("BLAD: montowanie nie powiodlo sie po 2 probach.")
      if let content = try? String(contentsOf: CMPaths.rcloneMountLogFile, encoding: .utf8) {
        for line in content.split(separator: "\n").suffix(10) {
          CMLogger.log("  \(line)")
        }
      }
      return false
    }
  }

  /// Kazda nieudana proba mountowania odklada zawieszony katalog na bok
  /// (`<klucz>-zaklinowany-<epoch>`) zamiast go kasowac, na wypadek gdyby
  /// przydal sie do diagnozy - ale bez sprzatania te katalogi rosly bez
  /// ograniczen przy powtarzajacych sie awariach mountu. Trzymamy tylko
  /// `keepNewest` najswiezszych, reszte usuwamy.
  private static func cleanupOldStuckDirs(localDir: URL, keepNewest: Int) {
    let parent = localDir.deletingLastPathComponent()
    let prefix = "\(localDir.lastPathComponent)-zaklinowany-"
    guard
      let entries = try? FileManager.default.contentsOfDirectory(
        at: parent, includingPropertiesForKeys: nil)
    else { return }
    let stuckDirs =
      entries
      .filter { $0.lastPathComponent.hasPrefix(prefix) }
      .sorted { $0.lastPathComponent > $1.lastPathComponent }  // najnowszy (najwiekszy epoch) pierwszy
    guard stuckDirs.count > keepNewest else { return }
    for old in stuckDirs.dropFirst(keepNewest) {
      try? FileManager.default.removeItem(at: old)
    }
  }

  /// Czysci lokalny cache VFS rclone dla SWIEZO utworzonego sparsebundle -
  /// jesli backup.sparsebundle pod ta sama sciezka kiedys juz istnial (np.
  /// zostal usuniety i tworzymy go tutaj od nowa), stary cache nadal zawiera
  /// "stare" wersje Info.plist/bandow. Kiedy potem hdiutil czyta ten obszar
  /// przez NFS, rclone w trakcie odczytu wykrywa niezgodnosc ("remote is
  /// different") i podmienia zawartosc w locie - hdiutil dostaje wtedy
  /// niespojne dane w polowie odczytu i konczy sie to "no mountable file
  /// systems", mimo ze swiezo przeslany plik jest calkowicie poprawny.
  /// Bezpieczne WYLACZNIE tutaj (zaraz po tym, jak SAMI dopiero co
  /// utworzylismy i przeslalismy nowy sparsebundle) - nigdzie indziej, bo w
  /// cache moglyby wtedy lezec realne, jeszcze nie przeslane fragmenty
  /// aktywnego backupu.
  private static func cleanStaleVFSCache(config: MachinesConfig, machineKey: String) async {
    guard let pathsResult = try? await ProcessRunner.runRclone(["config", "paths"]),
      pathsResult.succeeded
    else { return }
    guard
      let cacheDirLine = pathsResult.stdout.split(separator: "\n").first(where: {
        $0.contains("Cache dir")
      })
    else { return }
    let parts = cacheDirLine.split(separator: ":", maxSplits: 1)
    guard parts.count == 2 else { return }
    let cacheDir = parts[1].trimmingCharacters(in: .whitespaces)
    guard !cacheDir.isEmpty else { return }

    let relativePath =
      "\(config.remoteName)/\(config.remoteRootFolder)/\(machineKey)/backup.sparsebundle"
    for subdir in ["vfs", "vfsMeta"] {
      try? FileManager.default.removeItem(atPath: "\(cacheDir)/\(subdir)/\(relativePath)")
    }
  }

  /// Konwertuje Mbps (megabity/s dziesietnie - jednostka, w ktorej dostawcy
  /// internetu podaja predkosc lacza, 1 Mbps = 1_000_000 b/s) na argument
  /// `--bwlimit` rclone w BAJTACH/s (liczba bez sufiksu). WAZNE: rclone
  /// interpretuje sufiksy "M"/"k"/"G" binarnie (1024^n), NIE dziesietnie -
  /// gdyby przekazac np. "12.50M" dla 100 Mbps, rclone odczytalby to jako
  /// 12.5 MiB/s (~13.1 MB/s), czyli limit ~4.9% wyzszy niz oczekiwany.
  /// Podanie surowej liczby bajtow/s omija te niejednoznacznosc calkowicie
  /// i jest przy tym dokladne (mbps * 125_000 to zawsze liczba calkowita).
  /// `nil`, gdy limit wylaczony (<=0) - dla symetrii z `Optional` zamiast
  /// magicznej wartosci w liscie argumentow.
  private static func bwLimitArg(mbps: Int) -> String? {
    guard mbps > 0 else { return nil }
    let bytesPerSecond = mbps * 125_000
    return String(bytesPerSecond)
  }

  private static func startRcloneDaemon(remotePath: String, localDir: URL, bwLimitMbps: Int)
    async -> Bool
  {
    var args = [
      "nfsmount", remotePath, localDir.path,
      "--volname", "CloudMachine-\(localDir.lastPathComponent)",
      "--vfs-cache-mode", "full",
      "--vfs-cache-max-size", vfsCacheMaxSize(),
      "--vfs-cache-max-age", "72h",
      "--vfs-write-back", rcloneVfsWriteBack,
      "--dir-cache-time", "1h",
      "--poll-interval", "0",
      "--tpslimit", rcloneTpsLimit,
      "--transfers", rcloneTransfers,
      "--checkers", rcloneCheckers,
      "--log-level", "INFO",
      "--log-file", CMPaths.rcloneMountLogFile.path,
      "-o", "nolocks,locallocks",
      "--daemon",
    ]
    if let bwLimit = bwLimitArg(mbps: bwLimitMbps) {
      args.append(contentsOf: ["--bwlimit", bwLimit])
    }
    let result = try? await ProcessRunner.runRclone(args, timeout: 30)
    return result?.succeeded == true
  }

  /// Montuje wirtualny dysk sparsebundle pod `spMount`. Proba pierwsza moze
  /// dostac "No such file or directory" mimo ze plik na pewno tam jest (zimny
  /// dir-cache VFS zaraz po swiezym zamontowaniu NFS) - stad 3 proby co 3s.
  private static func mountSparsebundle(localDir: URL, spMount: URL) async {
    if await MountHealth.isMounted(spMount.path) { return }
    CMLogger.log("Montuje wirtualny dysk sparsebundle pod \(spMount.path)...")
    let sparsebundlePath = localDir.appendingPathComponent("backup.sparsebundle").path
    for attempt in 1...3 {
      do {
        let result = try await ProcessRunner.run(
          "/usr/bin/hdiutil",
          [
            "attach", "-noverify", "-noautoopen", "-nobrowse",
            "-mountpoint", spMount.path, sparsebundlePath,
          ], timeout: 180)
        if result.succeeded { return }
      } catch {
        if case ProcessRunnerError.timedOut = error {
          // WAZNE: hdiutil attach nad NFS-em rclone bywa legalnie bardzo
          // wolny (zaobserwowane na zywo: >7 min po dogonieniu duzej
          // zaleglej kolejki uploadow po przerwanym backupie). Po timeout
          // NIE probujemy od razu drugi raz - dwa rownolegle hdiutil attach
          // na ten sam mountpoint tylko namieszaja (osierocony pierwszy
          // moze wciaz skonczyc sie sam w tle). Kolejny cykl watchdoga (60s
          // pozniej) sam sprawdzi przez `isMounted`, czy sie jednak udalo.
          CMLogger.log(
            "Proba \(attempt) montowania sparsebundle nie zdazyla w 180s - moze jeszcze dokonczyc sie w tle, sprawdze przy nastepnej okazji zamiast probowac rownolegle."
          )
          return
        }
      }
      if attempt < 3 {
        CMLogger.log("Proba \(attempt) montowania sparsebundle nie powiodla sie, ponawiam za 3s...")
        try? await Task.sleep(nanoseconds: 3_000_000_000)
      }
    }
  }
}
