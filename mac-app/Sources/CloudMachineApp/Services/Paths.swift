import Foundation

/// Rozwiazuje sciezki do bundlowanych skryptow shell oraz do lokalizacji
/// zapisywalnych przez uzytkownika (config, logi), niezaleznie od tego, czy
/// appka dziala jako spakowany .app (Resources sa read-only), czy jest
/// uruchomiona dewelopersko przez `swift run` z drzewa zrodel.
enum Paths {
    /// Folder ze skryptami bash (mount.sh, quota-watchdog.sh, itd.).
    static var scriptsDir: URL? {
        if let bundled = Bundle.main.resourceURL?.appendingPathComponent("scripts"),
           FileManager.default.fileExists(atPath: bundled.appendingPathComponent("common.sh").path) {
            return bundled
        }
        // Fallback dla `swift run` w drzewie repo: Sources/CloudMachineApp/Services -> mac-app -> CloudMachine/scripts
        let devPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Services
            .deletingLastPathComponent() // CloudMachineApp
            .deletingLastPathComponent() // Sources
            .deletingLastPathComponent() // mac-app
            .appendingPathComponent("scripts")
        if FileManager.default.fileExists(atPath: devPath.appendingPathComponent("common.sh").path) {
            return devPath
        }
        return nil
    }

    static var launchdTemplatesDir: URL? {
        scriptsDir?.deletingLastPathComponent().appendingPathComponent("launchd")
    }

    static var appSupportDir: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("CloudMachine")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var configPath: URL { appSupportDir.appendingPathComponent("machines.json") }

    static var logDir: URL {
        let base = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Logs/CloudMachine")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var combinedLogFile: URL { logDir.appendingPathComponent("cloudmachine.log") }
}
