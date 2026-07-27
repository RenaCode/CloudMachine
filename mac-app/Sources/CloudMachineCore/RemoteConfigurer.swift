import Foundation

/// Port `configure-remote.sh` (+ scalone z dawnym `CloudMachineController.
/// connectGoogleDrive()` w GUI) - laczy z Google Drive przez `rclone
/// authorize` (nieinteraktywny OAuth w przegladarce), zamiast starszego,
/// interaktywnego kreatora `rclone config`. CLI i GUI uzywaja teraz
/// DOKLADNIE tej samej sciezki logowania.
public enum RemoteConfigurer {
    public static func isConfigured(remoteName: String) async -> Bool {
        guard let result = try? await ProcessRunner.runRclone(["listremotes"]) else { return false }
        return result.stdout.contains("\(remoteName):")
    }

    public static func extractToken(from output: String) -> String? {
        guard let startRange = output.range(of: "--->"),
              let endRange = output.range(of: "<---") else { return nil }
        let token = output[startRange.upperBound..<endRange.lowerBound]
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @discardableResult
    public static func connect(config: MachinesConfig, machineKey: String) async -> CMActionResult {
        guard let authResult = try? await ProcessRunner.runRclone(["authorize", "drive"], timeout: 300), authResult.succeeded else {
            return CMActionResult(succeeded: false, message: "rclone authorize nie powiodlo sie.")
        }
        guard let token = extractToken(from: authResult.stdout) else {
            return CMActionResult(succeeded: false, message: "Nie udalo sie odczytac tokenu z wyniku rclone authorize.")
        }
        let createResult = try? await ProcessRunner.runRclone(["config", "create", config.remoteName, "drive", "token=\(token)"])
        guard createResult?.succeeded == true else {
            return CMActionResult(succeeded: false, message: "rclone config create nie powiodlo sie.")
        }
        _ = try? await ProcessRunner.runRclone(["mkdir", config.remotePath(forMachineKey: machineKey)])
        return CMActionResult(succeeded: true, message: "Polaczono z Google Drive jako remote '\(config.remoteName)'.")
    }
}
