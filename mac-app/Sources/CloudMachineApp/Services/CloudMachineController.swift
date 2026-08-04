import AppKit
import CloudMachineCore
import Foundation

@MainActor
final class CloudMachineController: ObservableObject {
  @Published var config: MachinesConfig
  @Published var status = AppStatus()

  /// Chroni przed lawina nakladajacych sie subprocessow - `MenuBarContentView`
  /// odpala `refreshAll()` w `.task` przy KAZDYM otwarciu popupu paska menu,
  /// wiec bez tego szybkie, powtarzane klikanie ikonki multiplikowaloby te
  /// wywolania bez sensu.
  private var lastRefreshAllAt: Date?
  private let refreshAllMinInterval: TimeInterval = 5

  /// Ostatnia znana probka (bajty, znacznik czasu) do liczenia predkosci
  /// transferu miedzy dwoma odswiezeniami - `tmutil` nie podaje tego sam.
  private var lastProgressSample: (bytes: Double, date: Date)?

  init() {
    let (loaded, corruption) = ConfigStore.loadOrInitialize()
    config = loaded
    if let corruption {
      status.errorMessage =
        "Plik konfiguracyjny (machines.json) jest uszkodzony i nie zostal wczytany - pokazuje pusta konfiguracje, ZEBY NIE NADPISAC oryginalu (kopia zapasowa zapisana obok). Blad: \(corruption.localizedDescription)"
    }
    Task {
      status.currentMachineKey = await MachineIdentity.currentKey()
    }
  }

  // MARK: - Config

  func saveConfig() {
    do {
      try ConfigStore.save(config)
    } catch {
      fail("Nie udalo sie zapisac konfiguracji: \(error.localizedDescription)")
    }
  }

  func currentMachineKey() async -> String {
    await MachineIdentity.currentKey()
  }

  // MARK: - Logging i bledy widoczne w UI

  /// Wszystkie akcje wywolywane z UI powinny zaczynac od `clearError()`, a przy
  /// niepowodzeniu wolac `fail(...)` - inaczej blad trafia tylko do pliku logu
  /// i uzytkownik widzi tylko "kliknalem i nic sie nie stalo".
  func clearError() {
    status.errorMessage = nil
  }

  func fail(_ message: String) {
    status.errorMessage = message
    appendLog("BLAD: \(message)")
  }

  func appendLog(_ line: String) {
    let stamp = ISO8601DateFormatter().string(from: Date())
    status.logTail += "[\(stamp)] \(line)\n"
    if status.logTail.count > 20_000 {
      status.logTail = String(status.logTail.suffix(20_000))
    }
  }

  func refreshLogTail() {
    guard let data = try? String(contentsOf: CMPaths.combinedLogFile, encoding: .utf8) else {
      return
    }
    status.logTail = String(data.suffix(20_000))
  }

  // MARK: - Zaleznosci (rclone) - potrzebne dla warstwy archiwizacji w chmurze

  func checkDependencies() async {
    status.dependencyState = .checking
    let missing = await DependencyInstaller.missingTools()
    status.dependencyState = missing.isEmpty ? .ready : .missing(missing)
  }

  private func homebrewPrefix() async -> String {
    let arch = (try? await ProcessRunner.run("/usr/bin/uname", ["-m"]))?
      .stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return arch == "arm64" ? "/opt/homebrew" : "/usr/local"
  }

  func installDependencies() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    defer { status.isBusy = false }

    if DependencyInstaller.resolvedBrewPath() == nil {
      let prefix = await homebrewPrefix()
      status.busyLabel =
        "Homebrew nie jest zainstalowany - przygotowuje \(prefix) (autoryzacja administratora)..."
      do {
        _ = try await Shell.runPrivileged(
          "mkdir -p '\(prefix)' && chown -R \(NSUserName()):admin '\(prefix)'")
      } catch {
        fail(
          "Nie udalo sie przygotowac katalogu \(prefix) dla Homebrew: \(error.localizedDescription)"
        )
        await checkDependencies()
        return
      }

      status.busyLabel = "Pobieram i instaluje Homebrew (moze potrwac kilka minut)..."
      let installCommand =
        "NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      guard
        let installResult = try? await ProcessRunner.run(
          "/bin/bash", ["-c", installCommand], timeout: 900)
      else {
        fail("Instalacja Homebrew nie powiodla sie (proces nie odpowiedzial).")
        await checkDependencies()
        return
      }
      appendLog(installResult.stdout)
      if DependencyInstaller.resolvedBrewPath() == nil {
        fail(
          "Instalacja Homebrew nie powiodla sie: \(installResult.stderr.isEmpty ? installResult.stdout : installResult.stderr)"
        )
        await checkDependencies()
        return
      }
      appendLog("Homebrew zainstalowany pomyslnie w \(prefix).")
    }

    status.busyLabel = "Instaluje rclone przez Homebrew..."
    let result = await DependencyInstaller.installRclone()
    appendLog(result.message)
    if !result.succeeded {
      fail(result.message)
    }
    await checkDependencies()
  }

  // MARK: - Polaczenie z Google Drive (dla warstwy archiwizacji w chmurze)

  func remoteConfigured() async -> Bool {
    await RemoteConfigurer.isConfigured(remoteName: config.remoteName)
  }

  func connectGoogleDrive() async {
    guard !status.isBusy else { return }
    clearError()
    guard status.dependencyState == .ready else {
      fail("Najpierw zainstaluj zaleznosci - rclone nie jest jeszcze dostepne.")
      return
    }
    status.isBusy = true
    status.busyLabel = "Czekam na logowanie do Google w przegladarce..."
    defer { status.isBusy = false }

    let key = await currentMachineKey()
    let result = await RemoteConfigurer.connect(config: config, machineKey: key)
    if result.succeeded {
      appendLog(result.message)
      status.remoteConfigured = true
    } else {
      fail(result.message)
    }
  }

  // MARK: - Lokalny wolumin backupu

  /// CZYTA tylko aktualny stan lokalnego celu Time Machine - tworzenie
  /// woluminu i rejestrowanie go jako cel TM to teraz krok wykonywany przez
  /// uzytkownika samodzielnie (System Settings -> Time Machine), nie logika
  /// tej apki (patrz `LocalBackupService`).
  func refreshLocalVolume() async {
    let volumeStatus = await LocalBackupService.currentStatus()
    status.localVolume = LocalVolumeStatus(
      exists: volumeStatus.exists,
      mountPoint: volumeStatus.mountPoint,
      totalGB: volumeStatus.totalGB,
      usedGB: volumeStatus.usedGB,
      freeContainerGB: volumeStatus.freeContainerGB
    )
    status.timeMachineState = volumeStatus.destinationID != nil ? .registered : .notRegistered
  }

  // MARK: - Time Machine

  /// Odswieza zywy postep aktualnie trwajacego backupu (procent, bajty,
  /// pozostaly czas) - `nil`, gdy nic sie akurat nie kopiuje. Predkosc
  /// transferu liczymy sami z delty bajtow wzgledem poprzedniego odswiezenia,
  /// bo `tmutil status` samo w sobie tego nie podaje.
  func refreshBackupProgress() async {
    guard let progress = await TimeMachineStatus.currentProgress() else {
      status.backupProgress = nil
      lastProgressSample = nil
      return
    }

    var transferRateMBs: Double?
    if let bytes = progress.bytes {
      if let last = lastProgressSample {
        let elapsed = Date().timeIntervalSince(last.date)
        let deltaBytes = bytes - last.bytes
        if elapsed > 1, deltaBytes >= 0 {
          transferRateMBs = (deltaBytes / elapsed) / 1_048_576
        }
      }
      lastProgressSample = (bytes: bytes, date: Date())
    }

    status.backupProgress = BackupProgressInfo(
      phase: progress.phase,
      percent: progress.percent,
      bytesDone: progress.bytes,
      bytesTotal: progress.totalBytes,
      filesDone: progress.files,
      filesTotal: progress.totalFiles,
      timeRemainingSeconds: progress.timeRemainingSeconds,
      transferRateMBs: transferRateMBs
    )
  }

  // MARK: - Udostepnienie sieciowe (SMB)

  func refreshNetworkShare() async {
    status.networkShare = NetworkShareStatus(
      candidateDisks: await NetworkShareService.candidateDisks(),
      fileSharingEnabled: await NetworkShareService.isFileSharingEnabled()
    )
  }

  /// Wlacza File Sharing (jesli jeszcze wylaczony) i dodaje `disk.mountPoint`
  /// jako zwykly udzial SMB o nazwie `shareName`, bez dostepu goscia (host
  /// backupu wymaga zalogowania sie kontem uzytkownika tego Maca). Oznaczenie
  /// TEGO udzialu jako cel "Time Machine backup destination" jest swiadomie
  /// POZOSTAWIONE uzytkownikowi jako ostatni, reczny krok w System Settings
  /// -> General -> Sharing - patrz doc-comment `NetworkShareService`.
  func shareDiskOverNetwork(disk: DiskCandidate, shareName: String) async {
    guard !status.isBusy else { return }
    guard !shareName.trimmingCharacters(in: .whitespaces).isEmpty else {
      fail("Podaj nazwe udzialu sieciowego.")
      return
    }
    clearError()
    status.isBusy = true
    status.busyLabel = "Udostepniam \(disk.name) w sieci..."
    defer { status.isBusy = false }

    let path = shellSingleQuoteEscaped(disk.mountPoint)
    let name = shellSingleQuoteEscaped(shareName)
    let enablePrefix =
      status.networkShare.fileSharingEnabled
      ? ""
      : "launchctl enable system/com.apple.smbd && launchctl kickstart -k system/com.apple.smbd && "
    let command = "\(enablePrefix)/usr/sbin/sharing -a '\(path)' -S '\(name)' -s 001 -g 000"

    do {
      let output = try await Shell.runPrivileged(command)
      let message =
        output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Udostepniono \"\(disk.name)\" w sieci jako \"\(shareName)\"."
        : output
      status.lastNetworkShare = LastRunResult(succeeded: true, message: message, date: Date())
      appendLog("Udostepniono \(disk.mountPoint) w sieci jako \"\(shareName)\".")
    } catch {
      status.lastNetworkShare = LastRunResult(
        succeeded: false, message: error.localizedDescription, date: Date())
      fail("Nie udalo sie udostepnic dysku w sieci: \(error.localizedDescription)")
    }
    await refreshNetworkShare()
  }

  // MARK: - Weryfikacja

  func verifyNow() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Weryfikuje spojnosc backupu (moze potrwac dlugo)..."
    defer { status.isBusy = false }
    guard let mountPoint = status.localVolume.mountPoint else {
      fail("Wolumin lokalny nie jest jeszcze utworzony.")
      return
    }

    guard let latest = await BackupVerifier.latestBackupPath(mountPoint: mountPoint) else {
      status.lastVerify = LastRunResult(
        succeeded: false, message: "Brak backupow do zweryfikowania.", date: Date())
      fail("Brak backupow Time Machine do zweryfikowania pod \(mountPoint).")
      return
    }

    do {
      let result = try await runTmutilPrivileged(["verifychecksums", latest])
      if result.succeeded {
        status.lastVerify = LastRunResult(
          succeeded: true, message: "Sumy kontrolne OK dla \(latest)", date: Date())
        appendLog("Weryfikacja OK: \(latest)")
      } else {
        let message = result.stderr.isEmpty ? result.stdout : result.stderr
        status.lastVerify = LastRunResult(succeeded: false, message: message, date: Date())
        fail("Weryfikacja nieudana: \(message)")
      }
    } catch {
      status.lastVerify = LastRunResult(
        succeeded: false, message: "Blad weryfikacji: \(error.localizedDescription)", date: Date())
      fail("Weryfikacja nieudana: \(error.localizedDescription)")
    }
  }

  // MARK: - Archiwizacja w chmurze

  func refreshCloudArchive() async {
    let key = await currentMachineKey()
    let archiveStatus = await CloudArchiveService.currentStatus(config: config, machineKey: key)
    status.cloudArchive = CloudArchiveStatusInfo(
      lastArchivedBackup: archiveStatus.lastArchivedBackup,
      lastArchivedDate: archiveStatus.lastArchivedDate,
      archivedCount: archiveStatus.archivedCount,
      pendingCount: archiveStatus.pendingCount
    )
  }

  func archiveNow() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Archiwizuje ukonczone backupy na Google Drive (moze potrwac dlugo)..."
    defer { status.isBusy = false }

    let key = await currentMachineKey()
    let result = await CloudArchiveService.archivePending(config: config, machineKey: key)
    status.lastArchive = LastRunResult(
      succeeded: result.succeeded, message: result.message, date: Date())
    if result.succeeded {
      appendLog(result.message)
    } else {
      fail(result.message)
    }
    await refreshCloudArchive()
  }

  /// Uruchamia uprzywilejowana podkomende `tmutil` przez `sudo` z regula
  /// NOPASSWD, NIE przez AppleScript `do shell script ... with administrator
  /// privileges` - `do shell script` z podniesionymi uprawnieniami uruchamia
  /// polecenie w oddzielnym procesie autoryzacyjnym, ktorego macOS NIE
  /// przypisuje poprawnie tej aplikacji do celow TCC / Pelnego dostepu do
  /// dysku. `sudo` wywolane przez zwykly `Process` jest natomiast
  /// BEZPOSREDNIM potomkiem tej aplikacji, wiec TCC poprawnie go rozpoznaje.
  private func runTmutilPrivileged(_ args: [String]) async throws -> ProcessResult {
    if let result = try? await ProcessRunner.run(
      "/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300)
    {
      if result.succeeded || !result.isSudoAuthFailure {
        return result
      }
    }
    try await ensureTmutilSudoersRule()
    return try await ProcessRunner.run(
      "/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300)
  }

  /// Bezpiecznie osadza `value` wewnatrz pojedynczego `echo '...'` w
  /// `command` w `ensureTmutilSudoersRule()` ponizej: zamyka biezacy
  /// cudzyslow, wstawia znak `'` jako osobny, zescape'owany literal (`\'`),
  /// po czym otwiera cudzyslow na nowo. Konieczne, bo `volumeMountPoint`/
  /// `user` pochodza w koncu z nazwy dysku/konta, ktora uzytkownik moze
  /// dowolnie zmienic (np. na "Mac Studio's Backup") - bez tego escape'owania
  /// apostrof w tej nazwie wyrywalby sie z cudzyslowu w komendzie wykonywanej
  /// przez `do shell script ... with administrator privileges` (patrz
  /// `Shell.runPrivileged`, ktory escape'uje TYLKO `\` i `"` na potrzeby
  /// samego AppleScriptu, nie pojedynczy cudzyslow uzywany tutaj przez
  /// powloke) - realne ryzyko wykonania dowolnej komendy jako root z tresci
  /// nazwy dysku.
  private func shellSingleQuoteEscaped(_ value: String) -> String {
    value.replacingOccurrences(of: "'", with: "'\\''")
  }

  /// Dopisuje wpis sudoers (NOPASSWD) dla `tmutil verifychecksums`, zawezony
  /// do lokalnego wolumnu CloudMachine (glob na sciezce) - jedyna
  /// uprzywilejowana podkomenda `tmutil`, ktorej ta apka jeszcze sama uzywa
  /// (`verifyNow()`/`VerifyWatchdogService`). Rejestrowanie celu TM
  /// (`setdestination`) i uruchamianie/zatrzymywanie backupu
  /// (`startbackup`/`stopbackup`/`removedestination`) to teraz krok
  /// wykonywany przez uzytkownika samodzielnie w Ustawieniach systemowych,
  /// wiec te reguly zostaly usuniete - mniej uprawnien nadanych bez hasla,
  /// tym lepiej. (Wykluczenia folderow z backupu sa tak samo celowo POZA
  /// CloudMachine - uzytkownik zarzadza nimi wprost w Ustawieniach
  /// systemowych -> Time Machine.)
  ///
  /// WAZNE: sciezka glob musi odzwierciedlac RZECZYWISTY wolumin, nie
  /// zakladana z gory nazwe - `LocalBackupService.currentStatus()` juz
  /// prawidlowo wykrywa rzeczywisty zarejestrowany cel Time Machine (albo,
  /// jesli jeszcze nic nie zarejestrowano, zgaduje po domyslnej nazwie na
  /// czas pierwszej konfiguracji). Wczesniej ta funkcja uzywala WYLACZNIE
  /// twardo zakodowanej `LocalBackupService.defaultVolumeName` - dzialalo to
  /// tylko dopoki uzytkownik nie nazwal/nie zmienil nazwy woluminu inaczej
  /// (zaobserwowane na zywo: po recznej zmianie nazwy na "TimeMachine" ta
  /// reguła nie pasowalaby juz do prawdziwej sciezki, cicho psujac
  /// bezobslugowe wywolania tmutil).
  private func ensureTmutilSudoersRule() async throws {
    let user = shellSingleQuoteEscaped(NSUserName())
    let volumeMountPoint = shellSingleQuoteEscaped(
      await LocalBackupService.currentStatus().mountPoint
        ?? "/Volumes/\(LocalBackupService.defaultVolumeName)")
    let cmGlob = "\(volumeMountPoint)*"
    let rules = [
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums \(cmGlob)*"
    ]
    let tmpPath = "/etc/sudoers.d/.cloudmachine.tmp.$$"
    let writeBody = rules.map { "echo '\($0)'" }.joined(separator: "; ")
    let command = """
      { \(writeBody); } > \(tmpPath) && chmod 440 \(tmpPath) && visudo -c -f \(tmpPath) \
      && mv -f \(tmpPath) /etc/sudoers.d/cloudmachine || { rm -f \(tmpPath); exit 1; }
      """
    _ = try await Shell.runPrivileged(command)
    appendLog(
      "Skonfigurowano uprawnienia sudoers dla tmutil, zawezone do lokalnego wolumnu CloudMachine."
    )
  }

  /// macOS nie ma publicznego API do wprost odpytania "czy ta appka ma Pelny
  /// dostep do dysku" (TCC.db jest prywatne) - jedyny wiarygodny sposob to
  /// probne odczytanie pliku, do ktorego dostep BEZ FDA jest zawsze
  /// zablokowany przez sandboxing systemowy.
  func checkFullDiskAccess() {
    let home = FileManager.default.homeDirectoryForCurrentUser
    let bookmarksPath = home.appendingPathComponent("Library/Safari/Bookmarks.plist")

    do {
      _ = try Data(contentsOf: bookmarksPath)
      status.hasFullDiskAccess = true
    } catch {
      let migrationPath = URL(
        fileURLWithPath: "/Library/SystemMigration/History/MigrationHistory.plist")
      do {
        _ = try Data(contentsOf: migrationPath)
        status.hasFullDiskAccess = true
      } catch {
        status.hasFullDiskAccess = false
      }
    }
  }

  func openFullDiskAccessSettings() {
    if let url = URL(
      string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
    {
      NSWorkspace.shared.open(url)
    }
  }

  // MARK: - Odswiezenie calosci

  /// `force: false` (domyslne) pomija odswiezenie, jesli ostatnie wywolanie
  /// bylo mniej niz `refreshAllMinInterval` temu. Przyciski "Odswiez"
  /// klikniete recznie przez uzytkownika powinny uzywac `force: true`.
  func refreshAll(force: Bool = false) async {
    if !force, let last = lastRefreshAllAt, Date().timeIntervalSince(last) < refreshAllMinInterval {
      return
    }
    lastRefreshAllAt = Date()

    let key = await currentMachineKey()
    status.currentMachineKey = key
    await checkDependencies()
    status.remoteConfigured = await remoteConfigured()
    await refreshLocalVolume()
    await refreshBackupProgress()
    await refreshCloudArchive()
    await refreshNetworkShare()
    checkFullDiskAccess()
    refreshLogTail()
  }
}
