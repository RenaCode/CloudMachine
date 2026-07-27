import Foundation

/// Parsowanie tekstowego wyjscia `tmutil status`/`tmutil destinationinfo` -
/// oba to wlasciwie "plist-jak" tekst, nie prawdziwy JSON/plist, wiec
/// najprosciej i najbezpieczniej parsowac linia po linii, tak jak robily to
/// oryginalne `awk` w bash.
public enum TimeMachineStatus {
    public static func isRunning() async -> Bool {
        guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["status"]) else { return false }
        for line in result.stdout.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("Running") {
                return trimmed.contains("= 1")
            }
        }
        return false
    }

    /// Odpowiednik `tmutil destinationinfo | awk ... -v mp="$SP_MOUNT"` - szuka
    /// bloku, ktorego "Mount Point" zawiera `mountPoint`, i zwraca jego ID.
    public static func destinationID(forMountPointContaining mountPoint: String) async -> String? {
        guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) else { return nil }
        var found = false
        for rawLine in result.stdout.split(separator: "\n") {
            let line = String(rawLine)
            if line.hasPrefix("Mount Point") {
                found = line.contains(mountPoint)
                continue
            }
            if found, line.hasPrefix("ID") {
                let parts = line.split(separator: ":", maxSplits: 1)
                guard parts.count == 2 else { continue }
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    public static func destinationInfoContains(_ needle: String) async -> Bool {
        guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) else { return false }
        return result.stdout.contains(needle)
    }
}
