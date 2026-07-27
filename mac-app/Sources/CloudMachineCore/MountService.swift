import Foundation

/// Port `mount.sh` - montuje folder tej maszyny z Google Drive jako lokalny
/// wolumin (przez `rclone nfsmount`, wbudowany serwer NFS rclone - Homebrew'owy
/// rclone na macOS jest budowany bez wsparcia FUSE), gotowy do wskazania jako
/// cel Time Machine.
public enum MountService {
    private static let vfsCacheMaxSize = "40G"
    private static let rcloneTransfers = "32"
    private static let rcloneCheckers = "32"
    private static let rcloneTpsLimit = "50"
    private static let rcloneVfsWriteBack = "5s"

    /// Zwraca `true`, jesli po zakonczeniu wolumin NFS jest zamontowany
    /// (sparsebundle moglo sie nie udac oddzielnie - to nie jest fatalne, patrz
    /// `mountSparsebundle`).
    @discardableResult
    public static func mount(config: MachinesConfig, machineKey: String) async -> Bool {
        let result = await withCMLock("mount-\(machineKey)") {
            await mountLocked(config: config, machineKey: machineKey)
        }
        guard let result else {
            CMLogger.log("Inna instancja mount dla tej maszyny juz dziala, pomijam ten przebieg.")
            return await MountHealth.isMounted(CMPaths.localMachineMountDir(machineKey: machineKey).path)
        }
        return result
    }

    private static func mountLocked(config: MachinesConfig, machineKey: String) async -> Bool {
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
        let sparsebundleExists = listResult?.succeeded == true

        if !sparsebundleExists {
            guard let limitGB = config.limitGB(forMachineKey: machineKey) else {
                CMLogger.log("BLAD: maszyna '\(machineKey)' nie jest zdefiniowana w konfiguracji.")
                return false
            }
            CMLogger.log("Brak sparsebundle w chmurze. Tworze i przesylam nowy wirtualny dysk (limit \(limitGB) GB)...")
            let tmpSp = "/tmp/cm-temp-\(machineKey).sparsebundle"
            try? FileManager.default.removeItem(atPath: tmpSp)
            let createResult = try? await ProcessRunner.run("/usr/bin/hdiutil", [
                "create", "-size", "\(limitGB)g", "-fs", "APFS",
                "-volname", "CloudMachine-Backup-\(machineKey)", "-type", "SPARSEBUNDLE", tmpSp
            ])
            guard createResult?.succeeded == true else {
                CMLogger.log("BLAD: nie udalo sie utworzyc lokalnego sparsebundle.")
                return false
            }
            CMLogger.log("Przesylam sparsebundle bezposrednio na Dysk Google (bypassing NFS)...")
            let copyResult = try? await ProcessRunner.runRclone(["copy", tmpSp, sparsebundlePath])
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
                CMLogger.log("Istniejacy proces rclone dla tego remote wciaz aktywnie pracuje (prawdopodobnie dogania zalegla kolejke) - NIE ubijam, czekam na niego zamiast startowac nowy.")
                alreadyRunning = true
            } else {
                await MountHealth.killRcloneForRemote(remotePath)
                await MountHealth.forceUnmount(localDir.path, timeoutS: 10)
            }

            CMLogger.log("Montuje \(remotePath) -> \(localDir.path) (vfs-cache-mode=full, cache max=\(vfsCacheMaxSize))")

            for attempt in 1...2 {
                var started = alreadyRunning
                if !alreadyRunning {
                    started = await startRcloneDaemon(remotePath: remotePath, localDir: localDir)
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
                                CMLogger.log("Proba \(attempt): rclone przestal robic postepy (brak aktywnosci w logu >45s) po \(waited)s oczekiwania - przerywam ta probe.")
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
                    await MountHealth.forceUnmount(localDir.path, timeoutS: 10)
                    await MountHealth.killRcloneForRemote(remotePath)
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if !(await MountHealth.isMounted(localDir.path)) {
                        let stuckDir = localDir.deletingLastPathComponent()
                            .appendingPathComponent("\(localDir.lastPathComponent)-zaklinowany-\(Int(Date().timeIntervalSince1970))")
                        try? FileManager.default.moveItem(at: localDir, to: stuckDir)
                        try? FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)
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
            RuntimeState.startCaffeinate()
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
        guard let pathsResult = try? await ProcessRunner.runRclone(["config", "paths"]), pathsResult.succeeded else { return }
        guard let cacheDirLine = pathsResult.stdout.split(separator: "\n").first(where: { $0.contains("Cache dir") }) else { return }
        let parts = cacheDirLine.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return }
        let cacheDir = parts[1].trimmingCharacters(in: .whitespaces)
        guard !cacheDir.isEmpty else { return }

        let relativePath = "\(config.remoteName)/\(config.remoteRootFolder)/\(machineKey)/backup.sparsebundle"
        for subdir in ["vfs", "vfsMeta"] {
            try? FileManager.default.removeItem(atPath: "\(cacheDir)/\(subdir)/\(relativePath)")
        }
    }

    private static func startRcloneDaemon(remotePath: String, localDir: URL) async -> Bool {
        let args = [
            "nfsmount", remotePath, localDir.path,
            "--volname", "CloudMachine-\(localDir.lastPathComponent)",
            "--vfs-cache-mode", "full",
            "--vfs-cache-max-size", vfsCacheMaxSize,
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
            "--daemon"
        ]
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
            let result = try? await ProcessRunner.run("/usr/bin/hdiutil", [
                "attach", "-noverify", "-noautoopen", "-nobrowse",
                "-mountpoint", spMount.path, sparsebundlePath
            ])
            if result?.succeeded == true { return }
            if attempt < 3 {
                CMLogger.log("Proba \(attempt) montowania sparsebundle nie powiodla sie, ponawiam za 3s...")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
}
