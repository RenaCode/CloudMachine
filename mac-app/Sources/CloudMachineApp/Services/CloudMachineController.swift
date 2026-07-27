import AppKit
import CloudMachineCore
import Foundation

@MainActor
final class CloudMachineController: ObservableObject {
  @Published var config: MachinesConfig
  @Published var status = AppStatus()

  /// Chroni przed lawina nakladajacych sie subprocessow (rclone size/about,
  /// tmutil, launchctl...) - `MenuBarContentView` odpala `refreshAll()` w
  /// `.task` przy KAZDYM otwarciu popupu paska menu, wiec bez tego szybkie,
  /// powtarzane klikanie ikonki multiplikowaloby te wywolania bez sensu.
  private var lastRefreshAllAt: Date?
  private let refreshAllMinInterval: TimeInterval = 5

  init() {
    let (loaded, corruption) = ConfigStore.loadOrInitialize()
    config = loaded
    if let corruption {
      // NIE zapisujemy tu nic na dysk - `ConfigStore.loadOrInitialize()`
      // juz zrobil kopie zapasowa uszkodzonego pliku i NIE nadpisal go.
      // Czerwony baner ma powstrzymac uzytkownika od dotkniecia zakladki
      // Maszyny (co odpalyloby auto-zapis pustej konfiguracji) zanim
      // przejrzy, co poszlo nie tak.
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
    // Karta "Wykorzystanie limitu" w Statusie czyta `status.quota.limitGB`,
    // ktore normalnie odswieza tylko `refreshQuota()` (siecowe zapytanie
    // `rclone size`, wywolywane przy starcie / recznym "Odswiez status") -
    // bez tego edycja limitu w zakladce Maszyny byla widoczna na dysku,
    // ale w Statusie pokazywal sie stary limit, dopoki ktos nie odswiezyl
    // recznie. Limit to czysto lokalna wartosc z configu (w
    // przeciwienstwie do usedGB), wiec synchronizujemy ja od razu, bez
    // czekania na siec.
    if let machine = config.machines.first(where: { $0.key == status.currentMachineKey }) {
      status.quota.limitGB = machine.limitGB
    }
  }

  func currentMachineKey() async -> String {
    await MachineIdentity.currentKey()
  }

  var currentMachine: MachineEntry? {
    get async {
      let key = await currentMachineKey()
      return config.machines.first { $0.key == key }
    }
  }

  func ensureMachineRegistered(displayName: String, limitGB: Int) async {
    let key = await currentMachineKey()
    if let idx = config.machines.firstIndex(where: { $0.key == key }) {
      config.machines[idx].displayName = displayName
      config.machines[idx].limitGB = limitGB
    } else {
      config.machines.append(MachineEntry(key: key, displayName: displayName, limitGB: limitGB))
    }
    saveConfig()
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

  // MARK: - Zaleznosci (rclone)

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

  /// Instaluje wszystko od zera, bez zadnych zalozen o stanie maszyny:
  /// jesli brakuje Homebrew, instaluje najpierw jego (jeden dialog autoryzacji
  /// administratora zamiast interaktywnego sudo, ktorego nie ma jak pokazac z
  /// procesu bez terminala), a potem rclone (przez `DependencyInstaller`,
  /// wspoldzielony z CLI).
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
        // Wlasciciel katalogu prefiksu musi byc biezacym uzytkownikiem, zeby
        // oficjalny installer Homebrew mogl dzialac dalej BEZ wlasnego sudo
        // (ktorego i tak nie pokazalby bez terminala) - i zeby nie odmowil
        // startu, bo Homebrew celowo nie pozwala uruchamiac siebie jako root.
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

  // MARK: - Polaczenie z Google Drive

  func remoteConfigured() async -> Bool {
    await RemoteConfigurer.isConfigured(remoteName: config.remoteName)
  }

  /// Uruchamia `rclone authorize "drive"`, ktore samo otwiera przegladarke do
  /// logowania Google (przez `RemoteConfigurer`, wspoldzielony z CLI).
  func connectGoogleDrive() async {
    guard !status.isBusy else { return }
    clearError()
    guard status.dependencyState == .ready else {
      fail("Najpierw zainstaluj zaleznosci (krok 1 kreatora) - rclone nie jest jeszcze dostepne.")
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

  // MARK: - Montowanie

  func refreshMountState() async {
    let key = await currentMachineKey()
    let localDir = CMPaths.localMachineMountDir(machineKey: key).path
    let sparsebundleDir = CMPaths.sparsebundleMountDir(machineKey: key).path
    let nfsMounted = await MountHealth.isMounted(localDir)
    let spMounted = await MountHealth.isMounted(sparsebundleDir)
    status.mountState =
      (nfsMounted && spMounted) ? .mounted : (nfsMounted ? .mounting : .notMounted)
  }

  func mountNow() async {
    // Bez tej straznicy, klikniecie przycisku kilka razy z rzedu (np. z
    // kreatora, gdzie ten przycisk nie zawsze byl blokowany w trakcie
    // isBusy) odpalaloby kilka rownoleglych Task { await mountNow() } -
    // `MountService.mount` ma wlasna blokade PID-owa, ale i tak nie ma
    // sensu tego robic z poziomu UI.
    guard !status.isBusy else { return }
    clearError()
    guard status.dependencyState == .ready else {
      fail("rclone nie jest zainstalowane - wykonaj krok 1 w Kreatorze.")
      return
    }
    guard status.remoteConfigured else {
      fail("Google Drive nie jest jeszcze polaczony - wykonaj krok 2 w Kreatorze.")
      return
    }
    status.isBusy = true
    status.busyLabel = "Montuje Google Drive..."
    defer { status.isBusy = false }

    let key = await currentMachineKey()
    let ok = await MountService.mount(config: config, machineKey: key)

    await refreshMountState()
    if !ok || status.mountState != .mounted {
      fail("Montowanie nie powiodlo sie - sprawdz zakladke Logi.")
    }
  }

  func unmountNow() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Odmontowuje..."
    defer { status.isBusy = false }
    let key = await currentMachineKey()
    await UnmountService.unmount(config: config, machineKey: key)
    await refreshMountState()
    if status.mountState == .mounted {
      fail("Odmontowanie nie powiodlo sie - wolumin nadal jest zamontowany. Sprawdz zakladke Logi.")
    }
  }

  // MARK: - Time Machine

  func refreshTimeMachineState() async {
    let key = await currentMachineKey()
    let registered = await TimeMachineSetup.isRegistered(machineKey: key)
    status.timeMachineState = registered ? .registered : .notRegistered
  }

  func registerTimeMachineDestination() async {
    guard !status.isBusy else { return }
    clearError()
    guard status.mountState == .mounted else {
      fail("Zamontuj najpierw wolumin, zanim zarejestrujesz go w Time Machine.")
      return
    }
    let key = await currentMachineKey()
    let sparsebundleDir = CMPaths.sparsebundleMountDir(machineKey: key).path
    status.isBusy = true
    status.busyLabel = "Rejestruje cel Time Machine..."
    defer { status.isBusy = false }
    do {
      let result = try await runTmutilPrivileged(["setdestination", "-a", sparsebundleDir])
      if !result.succeeded {
        fail(
          "Blad rejestracji celu Time Machine: \(result.stderr.isEmpty ? result.stdout : result.stderr)"
        )
        return
      }
      await refreshTimeMachineState()
    } catch {
      fail("Blad rejestracji celu Time Machine: \(error.localizedDescription)")
    }
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

  /// `tmutil stopbackup` NIE wymaga sudo (w przeciwienstwie do startbackup) -
  /// patrz ten sam komentarz w `UnmountService`. Bezpieczne wywolac nawet
  /// gdy akurat nic nie kopiuje (tmutil po prostu nic wtedy nie robi).
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
    let key = await currentMachineKey()
    let sparsebundleDir = CMPaths.sparsebundleMountDir(machineKey: key).path

    guard let latest = await BackupVerifier.latestBackupPath(spMount: sparsebundleDir) else {
      status.lastVerify = LastRunResult(
        succeeded: false, message: "Brak backupow do zweryfikowania.", date: Date())
      fail("Brak backupow Time Machine do zweryfikowania pod \(sparsebundleDir).")
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

  /// Uruchamia uprzywilejowana podkomende `tmutil` (setdestination/startbackup/
  /// verifychecksums) przez `sudo` z regula NOPASSWD, NIE przez AppleScript
  /// `do shell script ... with administrator privileges`.
  ///
  /// Powod: `do shell script` z podniesionymi uprawnieniami uruchamia
  /// polecenie w oddzielnym procesie autoryzacyjnym, ktorego macOS NIE
  /// przypisuje poprawnie tej aplikacji do celow TCC / Pelnego dostepu do
  /// dysku - `tmutil` konczy sie wtedy bledem "setdestination requires Full
  /// Disk Access privileges" NAWET gdy CloudMachine ma FDA jawnie przyznane
  /// w Ustawieniach systemowych (potwierdzone bezposrednio w systemowej
  /// bazie TCC.db). `sudo` wywolane przez zwykly `Process`/`NSTask` jest
  /// natomiast BEZPOSREDNIM potomkiem tej aplikacji, wiec TCC poprawnie go
  /// rozpoznaje jako CloudMachine.
  ///
  /// Najpierw probuje bez pytania o haslo (`sudo -n`) - jesli regula
  /// sudoers jeszcze nie istnieje (pierwsze uzycie), dopisuje ja (jeden
  /// prompt autoryzacji administratora) i probuje ponownie.
  private func runTmutilPrivileged(_ args: [String]) async throws -> ProcessResult {
    if let result = try? await ProcessRunner.run(
      "/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300),
      result.succeeded
    {
      return result
    }
    try await ensureTmutilSudoersRule()
    return try await ProcessRunner.run(
      "/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300)
  }

  // MARK: - Quota

  func refreshQuota() async {
    let key = await currentMachineKey()
    guard let machine = config.machines.first(where: { $0.key == key }) else { return }
    let remotePath = config.remotePath(forMachineKey: key)
    guard let usedGB = await RcloneSize.usedGB(remotePath: remotePath) else { return }
    status.quota = QuotaStatus(usedGB: usedGB, limitGB: machine.limitGB, lastChecked: Date())
  }

  /// Realne zajecie calego konta Google Drive (`rclone about`) - to na tym,
  /// nie na recznie wpisanej liczbie, powinien opierac sie wybor limitu per
  /// Mac w zakladce Maszyny.
  func refreshDriveInfo() async {
    guard status.remoteConfigured else { return }
    guard
      let result = try? await ProcessRunner.runRclone(
        ["about", "\(config.remoteName):", "--json"], timeout: 30),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let total = json["total"] as? Double
    else {
      return
    }
    let used = (json["used"] as? Double) ?? 0
    let free = (json["free"] as? Double) ?? max(total - used, 0)
    status.driveInfo = DriveInfo(
      totalGB: total / 1_073_741_824,
      usedGB: used / 1_073_741_824,
      freeGB: free / 1_073_741_824,
      lastChecked: Date()
    )
    // Trzymamy config.driveTotalGB zsynchronizowany z prawdziwa pojemnoscia
    // konta, zeby wyliczenie bezpiecznego budzetu nie opieralo sie na
    // recznie zgadywanej liczbie.
    let realTotalGB = Int(total / 1_073_741_824)
    if realTotalGB > 0 && config.driveTotalGB != realTotalGB {
      config.driveTotalGB = realTotalGB
      saveConfig()
    }
  }

  // MARK: - Watchdog / launchd

  func refreshWatchdogInstalled() async {
    status.watchdogInstalled = await LaunchdInstaller.isInstalled(
      label: "com.renacode.cloudmachine.watchdog")
    status.mountWatchdogInstalled = await LaunchdInstaller.isInstalled(
      label: "com.renacode.cloudmachine.mount-watchdog")
  }

  func installLaunchdAgents() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Instaluje automatyzacje (launchd)..."
    defer { status.isBusy = false }
    let result = await LaunchdInstaller.install()
    appendLog(result.message)
    if !result.succeeded {
      fail(result.message)
    }
    await refreshWatchdogInstalled()
  }

  /// Dopisuje wpisy sudoers (NOPASSWD) dla wszystkich podkomend `tmutil`,
  /// ktorych ta appka potrzebuje bez interaktywnego hasla: `delete` (dla
  /// watchdoga limitu dzialajacego bez sesji GUI) oraz `setdestination` /
  /// `startbackup` / `verifychecksums` / `removedestination` (dla
  /// przyciskow w GUI - patrz komentarz przy `runTmutilPrivileged`,
  /// dlaczego to NIE jest przez AppleScript). Nadpisuje istniejacy plik za
  /// kazdym razem (idempotentne, bezpieczne tez gdy user ma juz starszy
  /// wpis sprzed tej zmiany).
  private func ensureTmutilSudoersRule() async throws {
    let user = NSUserName()
    let rules = [
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil delete -p *",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil setdestination -a *",
      // Spacja po "startbackup" (nie goly "startbackup*") celowo wymaga co
      // najmniej jednego argumentu odzielonego spacja (np. "--auto",
      // "-d <ID>") - odrobine ciasniejsze niz plaski wildcard, bez utraty
      // zadnego z realnie uzywanych wywolan.
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil startbackup *",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums *",
      "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil removedestination *",
    ]
    let writeCommands = rules.enumerated().map { index, line in
      "echo '\(line)' \(index == 0 ? ">" : ">>") /etc/sudoers.d/cloudmachine"
    }.joined(separator: " && ")
    let command =
      "\(writeCommands) && chmod 440 /etc/sudoers.d/cloudmachine && visudo -c -f /etc/sudoers.d/cloudmachine"
    _ = try await Shell.runPrivileged(command)
    appendLog(
      "Skonfigurowano uprawnienia sudoers dla tmutil (setdestination/startbackup/verifychecksums/delete)."
    )
  }

  func enableUnattendedPruning() async {
    guard !status.isBusy else { return }
    clearError()
    status.isBusy = true
    status.busyLabel = "Konfiguruje uprawnienia dla watchdoga (wymaga autoryzacji)..."
    defer { status.isBusy = false }
    do {
      try await ensureTmutilSudoersRule()
    } catch {
      fail("Blad konfiguracji sudoers: \(error.localizedDescription)")
    }
  }

  /// macOS nie ma publicznego API do wprost odpytania "czy ta appka ma Pelny
  /// dostep do dysku" (TCC.db jest prywatne) - jedyny wiarygodny sposob to
  /// probne odczytanie pliku, do ktorego dostep BEZ FDA jest zawsze
  /// zablokowany przez sandboxing systemowy, niezaleznie od zwyklych uprawnien
  /// unixowych. Safari Bookmarks.plist jest do tego standardowym wyborem
  /// (uzywanym tez przez inne narzedzia open-source w tym samym celu) -
  /// MigrationHistory.plist to fallback na wypadek, gdyby ktos usunal/nie mial
  /// jeszcze historii Safari.
  func checkFullDiskAccess() {
    let home = FileManager.default.homeDirectoryForCurrentUser
    let safariDir = home.appendingPathComponent("Library/Safari")
    let bookmarksPath = safariDir.appendingPathComponent("Bookmarks.plist")

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

  // MARK: - Aktywnosc watchdogow w tle

  /// Panel Status pokazywal dotad WYLACZNIE wyniki akcji klikanych recznie w
  /// GUI (`lastBackup`/`lastVerify`) - jesli watchdogi (mount-watchdog,
  /// backup-watchdog, verify-watchdog) naprawily/zweryfikowaly cos w tle przez
  /// launchd, GUI o tym nie wiedzialo. Skanujemy `cloudmachine.log` (wspolny
  /// log wszystkich serwisow, pisany przez `CMLogger`) w poszukiwaniu
  /// ostatniej linii kazdego watchdoga.
  func refreshBackgroundWatchdogActivity() {
    guard let data = try? String(contentsOf: CMPaths.combinedLogFile, encoding: .utf8) else {
      return
    }
    let lines = data.split(separator: "\n").map(String.init)
    status.backgroundActivity = BackgroundActivity(
      lastMountRepair: lines.last(where: {
        $0.contains("[mount-watchdog] Naprawa zakonczona powodzeniem")
      }),
      lastVerify: lines.last(where: {
        $0.contains("[verify-watchdog]") && ($0.contains("OK:") || $0.contains("UWAGA:"))
      }),
      lastBackupResume: lines.last(where: { $0.contains("[backup-watchdog] Wznowiono backup") })
    )
  }

  // MARK: - Odswiezenie calosci

  /// `force: false` (domyslne) pomija odswiezenie, jesli ostatnie wywolanie
  /// bylo mniej niz `refreshAllMinInterval` temu - patrz komentarz przy
  /// `lastRefreshAllAt`. Przyciski "Odswiez" klikniete recznie przez
  /// uzytkownika powinny uzywac `force: true`, zeby zawsze zadzialaly.
  func refreshAll(force: Bool = false) async {
    if !force, let last = lastRefreshAllAt, Date().timeIntervalSince(last) < refreshAllMinInterval {
      return
    }
    lastRefreshAllAt = Date()

    let key = await currentMachineKey()
    status.currentMachineKey = key
    await checkDependencies()
    status.remoteConfigured = await remoteConfigured()
    await refreshMountState()
    await refreshTimeMachineState()
    await refreshQuota()
    await refreshDriveInfo()
    await refreshWatchdogInstalled()
    checkFullDiskAccess()
    refreshLogTail()
    refreshBackgroundWatchdogActivity()
  }
}
