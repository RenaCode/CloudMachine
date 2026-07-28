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

  /// Tworzy lokalny wolumin (jesli jeszcze nie istnieje) i rejestruje go jako
  /// cel Time Machine, w jednym kroku - odpowiednik dawnego "Zamontuj".
  func createLocalVolumeAndRegister(quotaGB: Int) async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    defer { status.isBusy = false }

    if !status.localVolume.exists {
      status.busyLabel = "Tworze lokalny wolumin backupu (\(quotaGB)GB)..."
      let createResult = await LocalBackupService.createVolume(quotaGB: quotaGB)
      appendLog(createResult.message)
      if !createResult.succeeded {
        fail(createResult.message)
        return
      }
    }

    status.busyLabel = "Rejestruje wolumin jako cel Time Machine..."
    var destResult = await LocalBackupService.setAsDestination()
    if destResult.isSudoAuthFailure {
      // Pierwsza uprzywilejowana operacja na swiezej instalacji - reguly
      // sudoers jeszcze nie istnieja (patrz `ensureTmutilSudoersRule`,
      // wczesniej wywolywana tylko z `runTmutilPrivileged`, ktorego ta
      // sciezka wcale nie uzywala - `setAsDestination()` bez tego zawsze
      // konczylo sie martwym koncem na czystym Maku). Ustawiamy reguly
      // (jeden dialog autoryzacji administratora) i probujemy ponownie.
      do {
        try await ensureTmutilSudoersRule()
        destResult = await LocalBackupService.setAsDestination()
      } catch {
        fail("Nie udalo sie skonfigurowac uprawnien sudo: \(error.localizedDescription)")
        return
      }
    }
    appendLog(destResult.message)
    if !destResult.succeeded {
      fail(destResult.message)
    }
    await refreshLocalVolume()
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

  func startBackupNow() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Uruchamiam backup Time Machine..."
    defer { status.isBusy = false }
    do {
      let result = try await runTmutilPrivileged(["startbackup", "--auto"])
      if result.succeeded {
        status.lastBackup = LastRunResult(
          succeeded: true,
          message:
            "Backup uruchomiony w tle, sledz postep w Ustawieniach systemowych -> Time Machine.",
          date: Date())
      } else {
        let message = result.stderr.isEmpty ? result.stdout : result.stderr
        status.lastBackup = LastRunResult(succeeded: false, message: message, date: Date())
        fail("Blad uruchamiania backupu: \(message)")
      }
    } catch {
      status.lastBackup = LastRunResult(
        succeeded: false, message: error.localizedDescription, date: Date())
      fail("Blad uruchamiania backupu: \(error.localizedDescription)")
    }
  }

  /// `tmutil stopbackup` NIE wymaga sudo (w przeciwienstwie do startbackup).
  /// Bezpieczne wywolac nawet gdy akurat nic nie kopiuje.
  func stopBackupNow() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Zatrzymuje backup Time Machine..."
    defer { status.isBusy = false }
    do {
      let result = try await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 30)
      if result.succeeded {
        appendLog("Zatrzymano backup Time Machine.")
      } else {
        fail(
          "Zatrzymanie backupu nie powiodlo sie: \(result.stderr.isEmpty ? result.stdout : result.stderr)"
        )
      }
    } catch {
      fail("Blad zatrzymania backupu: \(error.localizedDescription)")
    }
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

  /// Dopisuje wpisy sudoers (NOPASSWD) dla podkomend `tmutil` potrzebnych bez
  /// interaktywnego hasla. `setdestination`/`verifychecksums` sa zawezone do
  /// lokalnego wolumnu CloudMachine (glob na sciezce). `startbackup` i
  /// `removedestination` NIE dadza sie tak zawezic wprost z ksztaltu ich
  /// argumentow: `startbackup` nie przyjmuje celu, a `removedestination`
  /// operuje na UUID celu (nie na sciezce - potrzebne w petli czyszczacej
  /// stare cele w `LocalBackupService.setAsDestination()`) - zostaja
  /// szerokim `*`, realny kompromis wynikajacy z API tmutil, nie przeoczenie.
  /// (Wykluczenia folderow z backupu sa celowo POZA CloudMachine - uzytkownik
  /// zarzadza nimi wprost w Ustawieniach systemowych -> Time Machine, wiec
  /// nie ma tu reguly dla `addexclusion`/`removeexclusion`.)
  private func ensureTmutilSudoersRule() async throws {
    let user = NSUserName()
    let cmGlob = "/Volumes/\(LocalBackupService.defaultVolumeName)*"
    let rules = [
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil setdestination -a \(cmGlob)",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil startbackup *",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums \(cmGlob)*",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil removedestination *",
    ]
    let tmpPath = "/etc/sudoers.d/.cloudmachine.tmp.$$"
    let writeBody = rules.map { "echo '\($0)'" }.joined(separator: "; ")
    let command = """
      { \(writeBody); } > \(tmpPath) && chmod 440 \(tmpPath) && visudo -c -f \(tmpPath) \
      && mv -f \(tmpPath) /etc/sudoers.d/cloudmachine || { rm -f \(tmpPath); exit 1; }
      """
    _ = try await Shell.runPrivileged(command)
    appendLog("Skonfigurowano uprawnienia sudoers dla tmutil, zawezone do lokalnego wolumnu CloudMachine.")
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
    checkFullDiskAccess()
    refreshLogTail()
  }
}
