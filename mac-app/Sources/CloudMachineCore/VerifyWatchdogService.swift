import Foundation

/// Automatyzuje to, co README opisuje jako "wysoce zalecane, rob to
/// regularnie": weryfikacje sum kontrolnych najnowszego backupu. Realna
/// weryfikacja odpala sie co najwyzej raz na `intervalDays` dni (domyslnie 7) -
/// `tmutil verifychecksums` na duzym backupie moze trwac dlugo i mocno
/// obciazyc I/O.
public enum VerifyWatchdogService {
    public static var intervalDays: Int {
        if let env = ProcessInfo.processInfo.environment["CM_VERIFY_INTERVAL_DAYS"], let value = Int(env) {
            return value
        }
        return 7
    }

    private static var stateFile: URL { CMPaths.logDir.appendingPathComponent(".verify-watchdog-last-run") }

    public static func run(config: MachinesConfig, machineKey: String) async {
        await withCMLock("verify-watchdog") { await runLocked(config: config, machineKey: machineKey) }
    }

    private static func runLocked(config: MachinesConfig, machineKey: String) async {
        guard RuntimeState.mountDesired else { return }

        let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey)
        guard await MountHealth.isMounted(spMount.path) else { return }

        // Nie przeszkadzamy aktywnemu backupowi.
        if await TimeMachineStatus.isRunning() { return }

        let now = Date()
        if let last = try? String(contentsOf: stateFile, encoding: .utf8),
           let lastEpoch = Double(last.trimmingCharacters(in: .whitespacesAndNewlines)) {
            if now.timeIntervalSince1970 - lastEpoch < Double(intervalDays * 86400) { return }
        }

        guard let listResult = try? await ProcessRunner.run("/usr/bin/tmutil", ["listbackups", "-d", spMount.path]),
              let latestBackup = listResult.stdout.split(separator: "\n").last else {
            CMLogger.log("[verify-watchdog] Brak backupow do zweryfikowania, pomijam ten przebieg.")
            return
        }

        // Zapisujemy PRZED faktyczna weryfikacja (nie po) - dluga weryfikacja
        // (potencjalnie godziny) nie powinna sama siebie wywolywac ponownie w
        // kolko, jesli nastepny cykl watchdoga trafi w trakcie jej trwania.
        try? "\(Int(now.timeIntervalSince1970))".write(to: stateFile, atomically: true, encoding: .utf8)

        CMLogger.log("[verify-watchdog] Weryfikuje sumy kontrolne najnowszego backupu: \(latestBackup) (moze potrwac dlugo).")
        let result = try? await ProcessRunner.runTmutilUnattended(["verifychecksums", String(latestBackup)])
        if result?.succeeded == true {
            CMLogger.log("[verify-watchdog] OK: sumy kontrolne sie zgadzaja.")
        } else {
            CMLogger.log("[verify-watchdog] UWAGA: verifychecksums zglosilo problem (albo sudo bez hasla niedostepne). Rozwaz uruchomienie weryfikacji recznie.")
            _ = try? await ProcessRunner.run("/usr/bin/osascript", [
                "-e", "display notification \"Weryfikacja sum kontrolnych najnowszego backupu wykazala problem - sprawdz Logi.\" with title \"CloudMachine\""
            ])
        }
    }
}
