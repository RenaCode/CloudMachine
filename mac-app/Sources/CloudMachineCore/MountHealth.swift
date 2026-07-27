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
            lock.lock(); defer { lock.unlock() }
            return _finished
        }
        func markFinished() {
            lock.lock(); _finished = true; lock.unlock()
        }
    }

    /// Odpala proces w tle i NIGDY na niego nie czeka synchronicznie -
    /// `terminationHandler` moze odpalic sie znacznie po uplywie `timeoutS`
    /// (albo wcale, jesli proces utknal w jadrze na dobre) - to jest w pelni
    /// zamierzone i bezpieczne, dokladnie jak `& disown` w bashu.
    private static func runDetachedAndPoll(executable: String, args: [String], timeoutS: Int) async -> Bool {
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
        await runDetachedAndPoll(executable: "/usr/bin/stat", args: ["-f", "%N", dir], timeoutS: timeoutS)
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
        process.arguments = ["-c", "diskutil unmount force '\(mountPoint)' >/dev/null 2>&1 || umount -f '\(mountPoint)' >/dev/null 2>&1"]
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

    public static func isMounted(_ path: String) async -> Bool {
        guard let result = try? await ProcessRunner.run("/sbin/mount", []) else { return false }
        return result.stdout.contains(path)
    }

    /// Ubija istniejace procesy `rclone nfsmount` dla danego remote - najpierw
    /// TERM (grzecznie), potem KILL po 5s jesli nadal zyje.
    public static func killRcloneForRemote(_ remotePath: String) async {
        let pattern = "rclone nfsmount \(remotePath) "
        guard let pgrep = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]), pgrep.succeeded else {
            return
        }
        CMLogger.log("Ubijam istniejace procesy 'rclone nfsmount' dla \(remotePath)...")
        _ = try? await ProcessRunner.run("/usr/bin/pkill", ["-TERM", "-f", pattern])
        for _ in 0..<5 {
            if let check = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]), !check.succeeded {
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
    public static func rcloneIsBusyDraining(_ remotePath: String, quietThreshold: TimeInterval = 45) async -> Bool {
        let pattern = "rclone nfsmount \(remotePath) "
        guard let pgrep = try? await ProcessRunner.run("/usr/bin/pgrep", ["-f", pattern]), pgrep.succeeded else {
            return false
        }
        guard let content = try? String(contentsOf: CMPaths.rcloneMountLogFile, encoding: .utf8) else {
            return false
        }
        let recentLines = content.split(separator: "\n").suffix(500)
        guard let lastActivityLine = recentLines.last(where: {
            $0.contains("Copied (") || $0.contains("upload succeeded") || $0.contains("queuing for upload")
        }) else {
            return false
        }
        // Rclone: "2026/07/25 02:18:09 INFO  : ..."
        let parts = lastActivityLine.split(separator: " ", maxSplits: 2)
        guard parts.count >= 2 else { return false }
        let timestampString = "\(parts[0]) \(parts[1])"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        guard let lastActivity = formatter.date(from: timestampString) else { return false }
        return Date().timeIntervalSince(lastActivity) < quietThreshold
    }
}
