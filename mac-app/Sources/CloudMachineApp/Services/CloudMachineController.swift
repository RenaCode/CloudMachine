import Foundation
import AppKit

@MainActor
final class CloudMachineController: ObservableObject {
    @Published var config: MachinesConfig
    @Published var status = AppStatus()

    private let requiredTools = ["rclone", "jq"]

    init() {
        // mount.sh/quota-watchdog.sh wymagaja istniejacego pliku configu - bez tego
        // pierwsze klikniecie "Zamontuj" (zanim ktokolwiek dotknie zakladki Maszyny)
        // konczy sie cichym bledem "brak pliku konfiguracyjnego" widocznym tylko w logu.
        if !ConfigStore.exists {
            try? ConfigStore.save(.empty)
        }
        config = ConfigStore.load()
        Task {
            let key = await currentMachineKey()
            status.currentMachineKey = key
        }
    }

    // MARK: - Config

    func reloadConfig() {
        config = ConfigStore.load()
    }

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

    /// Znormalizowany klucz tej maszyny, taki sam jak `cm_machine_key` w common.sh.
    func currentMachineKey() async -> String {
        guard let result = try? await Shell.run("/usr/sbin/scutil", ["--get", "ComputerName"]) else {
            return "this-mac"
        }
        let raw = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = raw.lowercased().replacingOccurrences(of: " ", with: "-")
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
        return String(lowered.unicodeScalars.filter { allowed.contains($0) })
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
        guard let data = try? String(contentsOf: Paths.combinedLogFile, encoding: .utf8) else { return }
        status.logTail = String(data.suffix(20_000))
    }

    // MARK: - Zaleznosci (rclone, jq)

    func checkDependencies() async {
        status.dependencyState = .checking
        var missing: [String] = []
        for tool in requiredTools {
            let result = try? await Shell.run("/usr/bin/which", [tool])
            if result == nil || !(result!.succeeded) {
                missing.append(tool)
            }
        }
        status.dependencyState = missing.isEmpty ? .ready : .missing(missing)
    }

    /// Sciezka do binarki brew, jesli Homebrew jest juz zainstalowany (Apple
    /// Silicon: /opt/homebrew, Intel: /usr/local) - sprawdzamy oba wprost,
    /// bo swiezo zainstalowany brew moze nie byc jeszcze w PATH tego procesu.
    private func resolvedBrewPath() -> String? {
        ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    private func homebrewPrefix() async -> String {
        let arch = (try? await Shell.run("/usr/bin/uname", ["-m"]))?
            .stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return arch == "arm64" ? "/opt/homebrew" : "/usr/local"
    }

    /// Instaluje wszystko od zera, bez zadnych zalozen o stanie maszyny:
    /// jesli brakuje Homebrew, instaluje najpierw jego (jeden dialog autoryzacji
    /// administratora zamiast interaktywnego sudo, ktorego nie ma jak pokazac z
    /// procesu bez terminala), a potem rclone i jq.
    func installDependencies() async {
        guard !status.isBusy else { return }
        clearError()
        status.isBusy = true
        defer { status.isBusy = false }

        if resolvedBrewPath() == nil {
            let prefix = await homebrewPrefix()
            status.busyLabel = "Homebrew nie jest zainstalowany - przygotowuje \(prefix) (autoryzacja administratora)..."
            do {
                // Wlasciciel katalogu prefiksu musi byc biezacym uzytkownikiem, zeby
                // oficjalny installer Homebrew mogl dzialac dalej BEZ wlasnego sudo
                // (ktorego i tak nie pokazalby bez terminala) - i zeby nie odmowil
                // startu, bo Homebrew celowo nie pozwala uruchamiac siebie jako root.
                _ = try await Shell.runPrivileged("mkdir -p '\(prefix)' && chown -R \(NSUserName()):admin '\(prefix)'")
            } catch {
                fail("Nie udalo sie przygotowac katalogu \(prefix) dla Homebrew: \(error.localizedDescription)")
                await checkDependencies()
                return
            }

            status.busyLabel = "Pobieram i instaluje Homebrew (moze potrwac kilka minut)..."
            let installCommand = "NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            guard let installResult = try? await Shell.run("/bin/bash", ["-c", installCommand], timeout: 900) else {
                fail("Instalacja Homebrew nie powiodla sie (proces nie odpowiedzial).")
                await checkDependencies()
                return
            }
            appendLog(installResult.stdout)
            if resolvedBrewPath() == nil {
                fail("Instalacja Homebrew nie powiodla sie: \(installResult.stderr.isEmpty ? installResult.stdout : installResult.stderr)")
                await checkDependencies()
                return
            }
            appendLog("Homebrew zainstalowany pomyslnie w \(prefix).")
        }

        guard let brewPath = resolvedBrewPath() else {
            fail("Nie udalo sie zlokalizowac Homebrew po instalacji.")
            await checkDependencies()
            return
        }

        status.busyLabel = "Instaluje rclone i jq przez Homebrew..."
        do {
            let result = try await Shell.run(brewPath, ["install", "rclone", "jq"], timeout: 600)
            appendLog(result.stdout)
            if !result.succeeded {
                fail("Instalacja rclone/jq nie powiodla sie: \(result.stderr.isEmpty ? result.stdout : result.stderr)")
            }
        } catch {
            fail("Blad instalacji rclone/jq: \(error.localizedDescription)")
        }
        await checkDependencies()
    }

    // MARK: - Polaczenie z Google Drive

    func remoteConfigured() async -> Bool {
        guard let result = try? await Shell.runRclone(["listremotes"]) else { return false }
        return result.stdout.contains("\(config.remoteName):")
    }

    /// Uruchamia `rclone authorize "drive"`, ktore samo otwiera przegladarke do
    /// logowania Google, po czym zapisuje zwrocony token jako nowy remote -
    /// bez potrzeby przechodzenia przez interaktywny kreator `rclone config`.
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

        do {
            let authResult = try await Shell.runRclone(["authorize", "drive"], timeout: 300)
            guard authResult.succeeded else {
                fail("rclone authorize nie powiodlo sie: \(authResult.stderr)")
                return
            }
            guard let token = extractToken(from: authResult.stdout) else {
                fail("Nie udalo sie odczytac tokenu z wyniku rclone authorize.")
                return
            }

            let createResult = try await Shell.runRclone(
                ["config", "create", config.remoteName, "drive", "token=\(token)"]
            )
            guard createResult.succeeded else {
                fail("rclone config create nie powiodlo sie: \(createResult.stderr)")
                return
            }
            appendLog("Polaczono z Google Drive jako remote '\(config.remoteName)'.")
            status.remoteConfigured = true

            let key = await currentMachineKey()
            _ = try? await Shell.runRclone(["mkdir", "\(config.remoteName):\(config.remoteRootFolder)/\(key)"])
        } catch {
            fail("Blad polaczenia z Google Drive: \(error.localizedDescription)")
        }
    }

    private func extractToken(from output: String) -> String? {
        guard let startRange = output.range(of: "--->"),
              let endRange = output.range(of: "<---") else { return nil }
        let token = output[startRange.upperBound..<endRange.lowerBound]
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Montowanie

    func refreshMountState() async {
        let key = await currentMachineKey()
        let localDir = "\(NSHomeDirectory())/CloudMachine-Mount/\(key)"
        let sparsebundleDir = "/Volumes/CloudMachine-Backup-\(key)"
        guard let result = try? await Shell.run("/sbin/mount", []) else {
            status.mountState = .unknown
            return
        }
        let nfsMounted = result.stdout.contains(localDir)
        let spMounted = result.stdout.contains(sparsebundleDir)
        status.mountState = (nfsMounted && spMounted) ? .mounted : (nfsMounted ? .mounting : .notMounted)
    }

    func mountNow() async {
        // Bez tej straznicy, klikniecie przycisku kilka razy z rzedu (np. z
        // kreatora, gdzie ten przycisk nie zawsze byl blokowany w trakcie
        // isBusy) odpalalo kilka rownoleglych Task { await mountNow() } -
        // kazdy wywolywal osobne mount.sh, co obserwowalismy jako kilka
        // nakladajacych sie montowan na tej samej sciezce naraz.
        guard !status.isBusy else { return }
        clearError()
        guard status.dependencyState == .ready else {
            fail("rclone/jq nie sa zainstalowane - wykonaj krok 1 w Kreatorze.")
            return
        }
        guard status.remoteConfigured else {
            fail("Google Drive nie jest jeszcze polaczony - wykonaj krok 2 w Kreatorze.")
            return
        }
        status.isBusy = true
        status.busyLabel = "Montuje Google Drive..."
        defer { status.isBusy = false }

        // mount.sh moze zrobic 2 proby (sprzatanie + retry przy "Resource busy"),
        // wiec potrzebuje wiecej czasu niz pojedyncza proba montowania.
        var result: ShellResult?
        do {
            result = try await Shell.runScript("mount.sh", timeout: 180)
        } catch {
            fail("Blad montowania: \(error.localizedDescription)")
        }

        // "Resource busy" na tym etapie oznacza wewnetrznie zawieszony punkt
        // montowania (np. po nieczystym zamknieciu appki/Maca w trakcie
        // montowania) - zwykle nie da sie tego posprzatac bez uprawnien roota,
        // wiec probujemy raz wymuszonego odmontowania przez natywny dialog
        // autoryzacji, po czym powtarzamy mount.sh.
        let output = (result?.stderr ?? "") + (result?.stdout ?? "")
        let looksBusy = result?.succeeded == false && output.localizedCaseInsensitiveContains("resource busy")
        if looksBusy {
            status.busyLabel = "Wykryto zawieszony punkt montowania - probuje wymuszonego odmontowania (autoryzacja administratora)..."
            let key = await currentMachineKey()
            let localDir = "\(NSHomeDirectory())/CloudMachine-Mount/\(key)"
            if (try? await Shell.runPrivileged("umount -f '\(localDir)' 2>/dev/null; exit 0")) != nil {
                appendLog("Wymuszono odmontowanie zawieszonego punktu, probuje zamontowac ponownie.")
                status.busyLabel = "Montuje ponownie po naprawie..."
                result = try? await Shell.runScript("mount.sh", timeout: 180)
            }
        }

        if let finalResult = result, !finalResult.succeeded {
            fail("Montowanie nie powiodlo sie: \(finalResult.stderr.isEmpty ? finalResult.stdout : finalResult.stderr)")
        }

        await refreshMountState()
        if status.mountState != .mounted && status.errorMessage == nil {
            fail("Montowanie zakonczylo sie bez bledu, ale wolumin nadal nie jest widoczny - sprawdz zakladke Logi.")
        }
    }

    func unmountNow() async {
        guard !status.isBusy else { return }
        clearError()
        status.isBusy = true
        status.busyLabel = "Odmontowuje..."
        defer { status.isBusy = false }
        do {
            let result = try await Shell.runScript("unmount.sh", timeout: 30)
            if !result.succeeded {
                fail("Odmontowanie nie powiodlo sie: \(result.stderr.isEmpty ? result.stdout : result.stderr)")
            }
        } catch {
            fail("Blad odmontowania: \(error.localizedDescription)")
        }
        await refreshMountState()
    }

    // MARK: - Time Machine

    func refreshTimeMachineState() async {
        guard let result = try? await Shell.run("/usr/bin/tmutil", ["destinationinfo"]) else {
            status.timeMachineState = .unknown
            return
        }
        let key = await currentMachineKey()
        status.timeMachineState = result.stdout.contains("CloudMachine-Backup-\(key)") ? .registered : .notRegistered
    }

    func registerTimeMachineDestination() async {
        guard !status.isBusy else { return }
        clearError()
        guard status.mountState == .mounted else {
            fail("Zamontuj najpierw wolumin, zanim zarejestrujesz go w Time Machine.")
            return
        }
        let key = await currentMachineKey()
        let sparsebundleDir = "/Volumes/CloudMachine-Backup-\(key)"
        status.isBusy = true
        status.busyLabel = "Rejestruje cel Time Machine..."
        defer { status.isBusy = false }
        do {
            let result = try await runTmutilPrivileged(["setdestination", "-a", sparsebundleDir])
            if !result.succeeded {
                fail("Blad rejestracji celu Time Machine: \(result.stderr.isEmpty ? result.stdout : result.stderr)")
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
                status.lastBackup = LastRunResult(succeeded: true, message: "Backup uruchomiony w tle, sledz postep w Ustawieniach systemowych -> Time Machine.", date: Date())
            } else {
                let message = result.stderr.isEmpty ? result.stdout : result.stderr
                status.lastBackup = LastRunResult(succeeded: false, message: message, date: Date())
                fail("Blad uruchamiania backupu: \(message)")
            }
        } catch {
            status.lastBackup = LastRunResult(succeeded: false, message: error.localizedDescription, date: Date())
            fail("Blad uruchamiania backupu: \(error.localizedDescription)")
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
        let sparsebundleDir = "/Volumes/CloudMachine-Backup-\(key)"

        guard let listResult = try? await Shell.run("/usr/bin/tmutil", ["listbackups", "-d", sparsebundleDir]),
              let latest = listResult.stdout.split(separator: "\n").last else {
            status.lastVerify = LastRunResult(succeeded: false, message: "Brak backupow do zweryfikowania.", date: Date())
            fail("Brak backupow Time Machine do zweryfikowania pod \(sparsebundleDir).")
            return
        }

        do {
            let result = try await runTmutilPrivileged(["verifychecksums", String(latest)])
            if result.succeeded {
                status.lastVerify = LastRunResult(succeeded: true, message: "Sumy kontrolne OK dla \(latest)", date: Date())
                appendLog("Weryfikacja OK: \(latest)")
            } else {
                let message = result.stderr.isEmpty ? result.stdout : result.stderr
                status.lastVerify = LastRunResult(succeeded: false, message: message, date: Date())
                fail("Weryfikacja nieudana: \(message)")
            }
        } catch {
            status.lastVerify = LastRunResult(succeeded: false, message: "Blad weryfikacji: \(error.localizedDescription)", date: Date())
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
    private func runTmutilPrivileged(_ args: [String]) async throws -> ShellResult {
        if let result = try? await Shell.run("/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300),
           result.succeeded {
            return result
        }
        try await ensureTmutilSudoersRule()
        return try await Shell.run("/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: 300)
    }

    // MARK: - Quota

    func refreshQuota() async {
        let key = await currentMachineKey()
        guard let machine = config.machines.first(where: { $0.key == key }) else { return }
        let remotePath = "\(config.remoteName):\(config.remoteRootFolder)/\(key)"
        guard let result = try? await Shell.runRclone(["size", remotePath, "--json"], timeout: 60),
              result.succeeded,
              let data = result.stdout.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bytes = json["bytes"] as? Double else {
            return
        }
        status.quota = QuotaStatus(usedGB: bytes / 1_073_741_824, limitGB: machine.limitGB, lastChecked: Date())
    }

    /// Realne zajecie calego konta Google Drive (`rclone about`) - to na tym,
    /// nie na recznie wpisanej liczbie, powinien opierac sie wybor limitu per
    /// Mac w zakladce Maszyny.
    func refreshDriveInfo() async {
        guard status.remoteConfigured else { return }
        guard let result = try? await Shell.runRclone(["about", "\(config.remoteName):", "--json"], timeout: 30),
              result.succeeded,
              let data = result.stdout.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let total = json["total"] as? Double else {
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
        guard let result = try? await Shell.run("/bin/launchctl", ["list"]) else { return }
        status.watchdogInstalled = result.stdout.contains("com.renacode.cloudmachine.watchdog")
        status.mountWatchdogInstalled = result.stdout.contains("com.renacode.cloudmachine.mount-watchdog")
    }

    func installLaunchdAgents() async {
        guard !status.isBusy else { return }
        clearError()
        status.isBusy = true
        status.busyLabel = "Instaluje automatyzacje (launchd)..."
        defer { status.isBusy = false }
        do {
            let result = try await Shell.runScript("install-launchd.sh", timeout: 30)
            appendLog(result.stdout)
            if !result.succeeded {
                fail("Instalacja automatyzacji nie powiodla sie: \(result.stderr.isEmpty ? result.stdout : result.stderr)")
            }
        } catch {
            fail("Blad instalacji launchd: \(error.localizedDescription)")
        }
        await refreshWatchdogInstalled()
    }

    /// Dopisuje wpisy sudoers (NOPASSWD) dla wszystkich podkomend `tmutil`,
    /// ktorych ta appka potrzebuje bez interaktywnego hasla: `delete` (dla
    /// watchdoga limitu dzialajacego bez sesji GUI) oraz `setdestination` /
    /// `startbackup` / `verifychecksums` (dla przyciskow w GUI - patrz
    /// komentarz przy `runTmutilPrivileged`, dlaczego to NIE jest przez
    /// AppleScript). Nadpisuje istniejacy plik za kazdym razem (idempotentne,
    /// bezpieczne tez gdy user ma juz starszy wpis tylko dla `delete`
    /// sprzed tej zmiany).
    private func ensureTmutilSudoersRule() async throws {
        let user = NSUserName()
        let rules = [
            "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil delete -p *",
            "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil setdestination -a *",
            "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil startbackup*",
            "\(user) ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums *"
        ]
        let writeCommands = rules.enumerated().map { index, line in
            "echo '\(line)' \(index == 0 ? ">" : ">>") /etc/sudoers.d/cloudmachine"
        }.joined(separator: " && ")
        let command = "\(writeCommands) && chmod 440 /etc/sudoers.d/cloudmachine && visudo -c -f /etc/sudoers.d/cloudmachine"
        _ = try await Shell.runPrivileged(command)
        appendLog("Skonfigurowano uprawnienia sudoers dla tmutil (setdestination/startbackup/verifychecksums/delete).")
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

    func checkFullDiskAccess() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let safariDir = home.appendingPathComponent("Library/Safari")
        let bookmarksPath = safariDir.appendingPathComponent("Bookmarks.plist")
        
        do {
            _ = try Data(contentsOf: bookmarksPath)
            status.hasFullDiskAccess = true
        } catch {
            let migrationPath = URL(fileURLWithPath: "/Library/SystemMigration/History/MigrationHistory.plist")
            do {
                _ = try Data(contentsOf: migrationPath)
                status.hasFullDiskAccess = true
            } catch {
                status.hasFullDiskAccess = false
            }
        }
    }

    func openFullDiskAccessSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Odswiezenie calosci

    func refreshAll() async {
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
    }
}
