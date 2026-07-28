import Foundation

/// Prymitywy do bezpiecznego sprawdzania/naprawiania zawieszonych montowan NFS -
/// port `cm_probe_responsive`/`cm_force_unmount`/`cm_rclone_busy_draining`/
/// `cm_kill_rclone_for_remote` z common.sh. To NAJBARDZIEJ krytyczna czesc tego
/// projektu do przeniesienia poprawnie: zawieszony `stat()`/`diskutil` na
/// martwym backendzie NFS blokuje sie w jadrze W NIEPRZERYWALNYM oczekiwaniu -
/// zaden timeout na poziomie userspace go nie odblokuje. Jedyna bezpieczna
/// strategia (identyczna z bash: `& disown`) to odpalic operacje w tle i
/// PRZESTAC na nia czekac po timeout, zamiast probowac ja przerwac - proces
/// zostaje osierocony (nieszkodliwie) i kiedys sam dokonczy, gdy jadro w koncu
/// dostanie odpowiedz albo mount zostanie wymuszony do odmontowania z innej strony.
public enum MountHealth {
  /// Prosty box do przekazania wyniku z `terminationHandler` (dziala w tle,
  /// niezaleznie od tego czy dalej czekamy) do petli odpytujacej.
  private final class ResultBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _finished = false
    var finished: Bool {
      lock.lock()
      defer { lock.unlock() }
      return _finished
    }
    func markFinished() {
      lock.lock()
      _finished = true
      lock.unlock()
    }
  }

  /// Odpala proces w tle i NIGDY na niego nie czeka synchronicznie -
  /// `terminationHandler` moze odpalic sie znacznie po uplywie `timeoutS`
  /// (albo wcale, jesli proces utknal w jadrze na dobre) - to jest w pelni
  /// zamierzone i bezpieczne, dokladnie jak `& disown` w bashu.
  private static func runDetachedAndPoll(executable: String, args: [String], timeoutS: Int) async
    -> Bool
  {
    let box = ResultBox()
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    process.terminationHandler = { _ in box.markFinished() }
    guard (try? process.run()) != nil else { return false }

    var waited = 0
    while waited < timeoutS {
      if box.finished { return true }
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      waited += 1
    }
    return box.finished
  }

  /// Sprawdza, czy katalog faktycznie ODPOWIADA (a nie tylko figuruje w
  /// tabeli `mount`) - uzywa `stat` na SAMYM katalogu (getattr), NIE
  /// readdir na jego zawartosci (patrz uzasadnienie w oryginalnym common.sh:
  /// readdir na zimnym cache VFS tworzy samonapedzajaca sie petle falszywych
  /// "zawieszen"). Domyslny timeout 6s.
  public static func probeResponsive(_ dir: String, timeoutS: Int = 6) async -> Bool {
    await runDetachedAndPoll(
      executable: "/usr/bin/stat", args: ["-f", "%N", dir], timeoutS: timeoutS)
  }

  /// Wymusza odmontowanie w tle, NIGDY nie czeka na `diskutil`/`umount`
  /// synchronicznie. Zwraca `true`, jesli punkt montowania zniknal z tabeli
  /// `mount` w ciagu `timeoutS`, `false` w przeciwnym razie (proces
  /// pozostaje osierocony w tle - patrz komentarz na gorze pliku).
  @discardableResult
  public static func forceUnmount(_ mountPoint: String, timeoutS: Int = 10) async -> Bool {
    guard await isMounted(mountPoint) else { return true }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = [
      "-c",
      "diskutil unmount force '\(mountPoint)' >/dev/null 2>&1 || umount -f '\(mountPoint)' >/dev/null 2>&1",
    ]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    guard (try? process.run()) != nil else { return false }

    var waited = 0
    while waited < timeoutS {
      if !(await isMounted(mountPoint)) { return true }
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      waited += 1
    }
    return !(await isMounted(mountPoint))
  }

  /// Odmontowuje sparsebundle (`hdiutil detach`), z bezpiecznym, ograniczonym
  /// timeoutem - JEDYNY punkt w calym module, przez ktory powinno przechodzic
  /// kazde wywolanie `hdiutil detach`, zeby ten timeout (i fallback na
  /// `forceUnmount` ponizej) nie musial byc kopiowany osobno przy kazdym
  /// nowym wywolujacym (dokladnie ten sam powod centralizacji, co przy
  /// `killRcloneForRemote`/`waitForRcloneUploadsToDrain` powyzej). `hdiutil
  /// detach` nad sparsebundle osadzonym w NFS-ie rclone potrafi utknac w
  /// jadrze w nieprzerywalnym oczekiwaniu - `ProcessRunner.run(timeout:)` ma
  /// juz wbudowana twarda granice czasu na taki wypadek (patrz komentarz w
  /// ProcessRunner.swift), wiec to wywolanie nigdy nie zawiesi sie na stale.
  /// Zwraca `true`, jesli punkt montowania faktycznie zniknal.
  @discardableResult
  public static func detachSparsebundle(_ mountPoint: String, force: Bool, timeoutS: Int = 20)
    async -> Bool
  {
    guard await isMounted(mountPoint) else { return true }
    var args = ["detach"]
    if force { args.append("-force") }
    args.append(mountPoint)
    let result = try? await ProcessRunner.run(
      "/usr/bin/hdiutil", args, timeout: TimeInterval(timeoutS))
    if result?.succeeded == true, !(await isMounted(mountPoint)) {
      return true
    }
    // `hdiutil detach` nie zadzialalo (timeout, blad, albo zglosilo sukces,
    // ale punkt montowania jednak nadal widnieje) - ostatnia deska ratunku,
    // ten sam fallback co przy zwyklym NFS unmount.
    return await forceUnmount(mountPoint, timeoutS: 10)
  }

  /// Czysta logika dopasowania - wydzielona z `isMounted(_:)` zeby dalo sie
  /// ja przetestowac bez shellowania do `/sbin/mount` (patrz
  /// CloudMachineCoreTests). Dopasowuje `path` jako PELNY punkt montowania w
  /// linii `mount` (otoczony " on " i " (" - dokladnie ten format, w jakim
  /// `/sbin/mount` go drukuje), nie zwyklym "zawieraniem podciagu" - ten
  /// drugi dawal falszywy pozytyw, gdy jeden klucz maszyny byl prefiksem
  /// innego (np. "imac" bylby "zamontowany" tylko dlatego, ze "imac-2"
  /// faktycznie jest).
  public static func isMountedIn(_ mountOutput: String, path: String) -> Bool {
    let marker = " on \(path) ("
    return mountOutput.split(separator: "\n").contains { $0.contains(marker) }
  }

  public static func isMounted(_ path: String) async -> Bool {
    guard let result = try? await ProcessRunner.run("/sbin/mount", []) else { return false }
    return isMountedIn(result.stdout, path: path)
  }

  /// Czysta logika wykrywania "utknietego bandu" - wydzielona z `stuckBand`
  /// zeby dalo sie ja przetestowac na goto tekscie logu bez shellowania.
  /// Rclone kolejkuje plik do uploadu dopiero po `--vfs-write-back` (domyslnie
  /// 5s) OD OSTATNIEGO zapisu - kazdy kolejny zapis w tym oknie resetuje
  /// timer (udokumentowane zachowanie, patrz rclone#4763 "file has changed"/
  /// #6857 "stuck in a failed upload loop"). Band, ktory jest modyfikowany
  /// czesciej niz raz na 5s (np. dziennik/metadane APFS zywe przez caly czas
  /// backupu) NIGDY nie dostaje szansy na upload i moze tak zostac w
  /// nieskonczonosc - zaobserwowane realnie: setki powtorzen "queuing for
  /// upload" dla TEGO SAMEGO bandu bez ani jednego zakonczonego uploadu, przy
  /// jednoczesnym spadku ogolnej przepustowosci backupu o rzad wielkosci.
  /// Zwraca nazwe pierwszego bandu spelniajacego ten wzorzec, `nil` w
  /// przeciwnym razie.
  public static func detectStuckBand(logLines: [Substring], minQueueEvents: Int = 200) -> String? {
    var queueCounts: [String: Int] = [:]
    var completed: Set<String> = []
    for line in logLines {
      guard let bandsRange = line.range(of: "bands/") else { continue }
      let afterBands = line[bandsRange.upperBound...]
      guard let colonRange = afterBands.range(of: ":") else { continue }
      let band = String(afterBands[afterBands.startIndex..<colonRange.lowerBound])
      guard !band.isEmpty else { continue }
      if line.contains("queuing for upload") {
        queueCounts[band, default: 0] += 1
      } else if line.contains("Copied (") || line.contains("upload succeeded") {
        completed.insert(band)
      }
    }
    return queueCounts.first(where: { $0.value >= minQueueEvents && !completed.contains($0.key) })?
      .key
  }

  /// Zwraca nazwe utknietego bandu (patrz `detectStuckBand`) dla danego
  /// remote, jesli proces rclone dla niego zyje - `nil`, jesli nic nie zyje,
  /// log nie istnieje, albo zaden band nie pasuje do wzorca zawieszenia.
  public static func stuckBand(
    remotePath: String, tailLines: Int = 3000, minQueueEvents: Int = 200
  ) async -> String? {
    let pattern = "rclone nfsmount \(remotePath) "
    guard let pgrep = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]),
      pgrep.succeeded
    else {
      return nil
    }
    guard let content = try? String(contentsOf: CMPaths.rcloneMountLogFile, encoding: .utf8)
    else {
      return nil
    }
    let recentLines = content.split(separator: "\n").suffix(tailLines)
    return detectStuckBand(logLines: Array(recentLines), minQueueEvents: minQueueEvents)
  }

  /// Jesli Time Machine akurat aktywnie pisze na wolumin obslugiwany przez
  /// `rclone nfsmount`, zatrzymuje backup i CZEKA az faktycznie stanie, ZANIM
  /// funkcja wroci - wymuszone odmontowanie/zabicie rclone w trakcie
  /// aktywnego zapisu potrafi uszkodzic metadane sparsebundle (przy nastepnym
  /// mouncie wyglada to jak "zniknal z chmury" i cala historia backupu
  /// zaczyna sie od zera - zaobserwowane realnie: `MountService.mount()`
  /// zabijal rclone w ten sposob bez tego zabezpieczenia i skasowal w ten
  /// sposob ~49GB juz przeslanego backupu w trakcie stall-retry). KAZDY
  /// wywolujacy kod, ktory moze zabic/wymusic odmontowanie rclone dla tego
  /// remote, powinien wywolac to NAJPIERW. `tmutil stopbackup` NIE wymaga sudo.
  /// `logPrefix` pozwala wywolujacemu zachowac wlasna konwencje logow (np.
  /// mount-watchdog prefiksuje kazda linie "[mount-watchdog] ") - bez tego
  /// te linie wypadaly z atrybucji przy grepowaniu logu per-watchdog.
  /// Zwraca `true`, jesli bezpiecznie mozna kontynuowac (TM potwierdzone
  /// zatrzymane albo nigdy nie bylo aktywne), `false` jesli TM NIE
  /// potwierdzilo zatrzymania w ciagu 30s - w tym przypadku WYWOLUJACY MUSI
  /// przerwac operacje (NIE kontynuowac force-unmount/kill), a nie tylko
  /// zalogowac ostrzezenie i przejsc dalej. WCZESNIEJ ta funkcja nie
  /// zwracala niczego i kazdy wywolujacy kontynuowal bezwarunkowo mimo
  /// ostrzezenia - zaobserwowane realnie na zywo: `tmutil stopbackup` nie
  /// zdazylo zatrzymac zapisu do "goracego" bandu (band z metadanymi APFS,
  /// dotykany dziesiatki razy na sekunde przy aktywnym backupie - zaden
  /// rozsadny `--vfs-write-back` nigdy mu nie da okna ciszy, dopoki TM
  /// faktycznie nie przestanie pisac), a kod i tak wymusil odmontowanie.
  @discardableResult
  public static func stopTimeMachineIfRunning(logPrefix: String = "") async -> Bool {
    // WAZNE: CELOWO bez wczesniejszego `guard isRunning() else { return }`.
    // `TimeMachineStatus.isRunning()` zwraca `false` NIE TYLKO gdy TM
    // faktycznie jest bezczynne, ale TEZ przy jakimkolwiek bledzie `tmutil
    // status` (rzucony `try?`, niespodziewany format wyjscia) - a to jest
    // dokladnie ta sama ochrona przed uszkodzeniem sparsebundle, ktora ta
    // funkcja ma zagwarantowac. Przy przejsciowym bledzie odczytu statusu
    // wczesniejszy kod cicho POMIJAL cala ta ochrone i pozwalal wywolujacemu
    // przejsc prosto do wymuszonego odmontowania/killa - w najgorszym razie
    // dokladnie w trakcie aktywnego zapisu (zaobserwowane jako realne ryzyko
    // w audycie). `tmutil stopbackup` jest bezpiecznym no-opem, gdy TM i tak
    // nic nie robi, wiec wywolanie go BEZWARUNKOWO nie ma wad, a zamyka luke.
    //
    // WAZNE tresc komunikatu: celowo "przed wymuszonym odmontowaniem/
    // zabiciem rclone", NIE "przed montowaniem" - ta funkcja jest wywolywana
    // zarowno przed mountowaniem (MountService), jak i przed czystym
    // odmontowaniem (UnmountService) - wczesniejsza tresc mowila zawsze o
    // "montowaniu", co bylo faktycznie mylace podczas odmontowania.
    CMLogger.log(
      "\(logPrefix)Zatrzymuje ewentualny aktywny backup Time Machine przed wymuszonym odmontowaniem/zabiciem rclone, zeby nie uszkodzic sparsebundle."
    )
    _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 20)
    var waited = 0
    var stopped = false
    while waited < 30 {
      if !(await TimeMachineStatus.isRunning()) {
        stopped = true
        break
      }
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      waited += 2
    }
    if stopped {
      CMLogger.log("\(logPrefix)Backup zatrzymany po \(waited)s.")
    } else {
      CMLogger.log(
        "\(logPrefix)OSTRZEZENIE: Time Machine nie zatrzymalo sie po \(waited)s - przerywam ta operacje, zeby nie uszkodzic sparsebundle. Sprobuje ponownie przy nastepnym cyklu."
      )
    }
    return stopped
  }

  /// Czeka, az kolejka wyslania rclone (`--vfs-write-back`) faktycznie sie
  /// oproznila, PRZED jakimkolwiek unmount/kill. BEZ TEGO dane wciaz
  /// czekajace na upload sa bezpowrotnie tracone przy zabiciu rclone -
  /// zaobserwowane realnie WIELOKROTNIE: seria wymuszonych remontow ("stuck
  /// band") zabijala rclone w trakcie draina, co ostatecznie doprowadzilo do
  /// uszkodzenia kontenera APFS w sparsebundle (checksum verify failures,
  /// "no mountable file systems").
  ///
  /// WAZNE: pierwsza wersja tej funkcji sprawdzala realna kolejke uploadow
  /// przez `rclone rc vfs/stats` (lokalny `--rc`) - dokladniejsze niz to,
  /// co ponizej. Zostalo wycofane: `--rc` koliduje z `--daemon` w tej
  /// wersji rclone (patrz komentarz w `MountService.startRcloneDaemon`), wiec
  /// TA funkcja w praktyce ZAWSZE natychmiast "nie znajdywala" dzialajacego
  /// `--rc` i zwracala `true` bez ŻADNEGO realnego czekania - cicha,
  /// NIEDZIALAJACA ochrona (potwierdzone: kontener uszkodzil sie ponownie
  /// mimo tej "ochrony" w miejscu). Zamiast tego uzywamy dwuetapowego
  /// podejscia bez `--rc`:
  /// 1. Stale okno `MountService.rcloneVfsWriteBackSeconds` - daje
  ///    write-back timerowi rclone szanse w ogole ZAKOLEJKOWAC swiezo
  ///    dotkniete bandy (rclone kolejkuje dopiero po oknie ciszy OD
  ///    OSTATNIEGO zapisu do pliku).
  /// 2. Potem odpytujemy `rcloneIsBusyDraining` (log rclone-mount.log, juz
  ///    uzywane gdzie indziej w tym pliku i sprawdzone na zywo) w petli, az
  ///    przestanie widziec swieza aktywnosc uploadu - czyli kolejka faktycznie
  ///    sie oprozniła, a nie tylko "minal jakis czas".
  /// Zwraca `true`, jesli kolejka wyglada na pusta, `false` jesli minal
  /// timeout z wciaz widoczna aktywnoscia.
  @discardableResult
  public static func waitForRcloneUploadsToDrain(remotePath: String, timeoutS: Int = 90) async
    -> Bool
  {
    try? await Task.sleep(
      nanoseconds: UInt64(MountService.rcloneVfsWriteBackSeconds) * 1_000_000_000)
    let deadline = Date().addingTimeInterval(TimeInterval(timeoutS))
    while await rcloneIsBusyDraining(remotePath) {
      guard Date() < deadline else {
        CMLogger.log(
          "OSTRZEZENIE: rclone wciaz wyglada na aktywne (upload w toku) po \(timeoutS)s oczekiwania na oproznienie kolejki - kontynuuje mimo to, ryzyko utraty danych czekajacych na wyslanie."
        )
        return false
      }
      try? await Task.sleep(nanoseconds: 5_000_000_000)
    }
    return true
  }

  /// Zwalnia port `--rc` PRZED odpaleniem nowego demona rclone. WAZNE: rclone
  /// traktuje niepowodzenie zbindowania `--rc-addr` jako blad KRYTYCZNY -
  /// caly demon (WLACZNIE z montowaniem NFS) konczy sie porazka, nie tylko
  /// samo RC (zaobserwowane realnie: druga proba montowania w tej samej
  /// petli retry startowala zanim system zdazyl zwolnic port po zabiciu
  /// pierwszego demona, co psulo OBIE proby montowania na okraglo). Ten sam
  /// staly port jest uzywany dla kazdego mountu tej maszyny (patrz
  /// `MountService.rcloneRCPort`), wiec przed KAZDYM startem demona
  /// upewniamy sie, ze nic go nie trzyma.
  public static func freeRCPortIfStuck() async {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/sbin/lsof", ["-ti", ":\(MountService.rcloneRCPort)"], timeout: 5),
      result.succeeded,
      !result.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      return
    }
    for pidString in result.stdout.split(separator: "\n") {
      if let pid = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines)) {
        kill(pid, SIGKILL)
      }
    }
    // Krotka pauza, zeby jadro faktycznie zwolnilo port przed kolejna proba
    // bindowania - `kill()` jest asynchroniczny wzgledem zwolnienia zasobow.
    try? await Task.sleep(nanoseconds: 500_000_000)
  }

  /// Ubija istniejace procesy `rclone nfsmount` dla danego remote. NAJPIERW
  /// czeka, az kolejka uploadow sie oprozni (patrz `waitForRcloneUploadsToDrain`
  /// powyzej - to JEDYNY punkt, przez ktory przechodzi kazdy kill/unmount w
  /// tym module, wiec ochrona przed utrata danych jest tu, a nie rozproszona
  /// po kazdym wywolujacym), potem TERM (grzecznie), potem KILL po 5s jesli
  /// nadal zyje.
  public static func killRcloneForRemote(_ remotePath: String) async {
    let pattern = "rclone nfsmount \(remotePath) "
    guard let pgrep = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]),
      pgrep.succeeded
    else {
      return
    }
    _ = await waitForRcloneUploadsToDrain(remotePath: remotePath)
    CMLogger.log("Ubijam istniejace procesy 'rclone nfsmount' dla \(remotePath)...")
    _ = try? await ProcessRunner.run("/usr/bin/pkill", ["-TERM", "-f", pattern])
    for _ in 0..<5 {
      if let check = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]),
        !check.succeeded
      {
        return
      }
      try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    CMLogger.log("Proces nie zareagowal na TERM w 5s, wysylam KILL.")
    _ = try? await ProcessRunner.run("/usr/bin/pkill", ["-KILL", "-f", pattern])
  }

  /// Zwraca `true`, jesli proces rclone nfsmount dla danego remote ZYJE i
  /// jego log rosl w ciagu ostatnich `quietThreshold` sekund - czyli realnie
  /// COS ROBI (dogania zalegla kolejke uploadow), mimo ze NFS jeszcze sie nie
  /// pojawil w tabeli `mount`. Patrz szerokie uzasadnienie w oryginalnym
  /// `cm_rclone_busy_draining` (common.sh) - watchdog NIE MOZE zabic takiego
  /// procesu, bo kazdy restart zaczyna liczenie zaleglej kolejki od zera.
  public static func rcloneIsBusyDraining(_ remotePath: String, quietThreshold: TimeInterval = 45)
    async -> Bool
  {
    let pattern = "rclone nfsmount \(remotePath) "
    guard let pgrep = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]),
      pgrep.succeeded
    else {
      return false
    }
    guard let content = try? String(contentsOf: CMPaths.rcloneMountLogFile, encoding: .utf8) else {
      return false
    }
    let recentLines = content.split(separator: "\n").suffix(500)
    guard
      let lastActivityLine = recentLines.last(where: {
        $0.contains("Copied (") || $0.contains("upload succeeded")
          || $0.contains("queuing for upload")
      })
    else {
      return false
    }
    // Rclone: "2026/07/25 02:18:09 INFO  : ..."
    let parts = lastActivityLine.split(separator: " ", maxSplits: 2)
    guard parts.count >= 2 else { return false }
    let timestampString = "\(parts[0]) \(parts[1])"
    let formatter = DateFormatter()
    // WAZNE: bez wymuszonego locale/strefy, parsowanie ciszej niepowodzenie
    // (`date(from:) == nil`) na systemie z innymi ustawieniami regionalnymi
    // powodowaloby, ze ta funkcja ZAWSZE zwracalaby `false` ("nie dogania
    // kolejki") - a to jest dokladnie sytuacja, w ktorej watchdog NIE MOZE
    // zabic procesu rclone (patrz komentarz nad funkcja), wiec cichy blad
    // parsowania bylby najgorszym mozliwym defaultem.
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    guard let lastActivity = formatter.date(from: timestampString) else { return false }
    return Date().timeIntervalSince(lastActivity) < quietThreshold
  }
}
