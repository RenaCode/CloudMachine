import Foundation
import AppKit

struct ShellResult {
    var stdout: String
    var stderr: String
    var exitCode: Int32
    var succeeded: Bool { exitCode == 0 }
}

enum ShellError: LocalizedError {
    case launchFailed(String)
    case privilegedFailed(String)

    var errorDescription: String? {
        switch self {
        case .launchFailed(let msg): return msg
        case .privilegedFailed(let msg): return msg
        }
    }
}

/// Cienka warstwa nad Process/NSAppleScript do uruchamiania skryptow bash
/// tego projektu, z i bez podniesionych uprawnien.
enum Shell {
    /// Standardowe (nieuprzywilejowane) uruchomienie polecenia.
    static func run(_ executable: String, _ args: [String], env: [String: String] = [:], timeout: TimeInterval? = nil) async throws -> ShellResult {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = args

            var fullEnv = ProcessInfo.processInfo.environment
            // Homebrew na Apple Silicon instaluje do /opt/homebrew/bin - dorzucamy na wszelki wypadek.
            fullEnv["PATH"] = "/opt/homebrew/bin:/usr/local/bin:" + (fullEnv["PATH"] ?? "/usr/bin:/bin")
            for (k, v) in env { fullEnv[k] = v }
            process.environment = fullEnv

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            process.standardInput = FileHandle.nullDevice

            let queue = DispatchQueue(label: "com.renacode.cloudmachine.shell-pipe")
            var stdoutData = Data()
            var stderrData = Data()

            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    queue.async {
                        stdoutData.append(data)
                    }
                }
            }

            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    queue.async {
                        stderrData.append(data)
                    }
                }
            }

            process.terminationHandler = { proc in
                stdoutPipe.fileHandleForReading.readabilityHandler = nil
                stderrPipe.fileHandleForReading.readabilityHandler = nil
                
                let remainingOut = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let remainingErr = stderrPipe.fileHandleForReading.readDataToEndOfFile()

                queue.sync {
                    stdoutData.append(remainingOut)
                    stderrData.append(remainingErr)

                    let result = ShellResult(
                        stdout: String(data: stdoutData, encoding: .utf8) ?? "",
                        stderr: String(data: stderrData, encoding: .utf8) ?? "",
                        exitCode: proc.terminationStatus
                    )
                    continuation.resume(returning: result)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: ShellError.launchFailed("Nie mozna uruchomic \(executable): \(error.localizedDescription)"))
                return
            }

            if let timeout {
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                    if process.isRunning {
                        process.terminate()
                    }
                }
            }
        }
    }

    /// Uruchamia `rclone` przez `/usr/bin/env`, zeby dzialalo niezaleznie od tego,
    /// czy Homebrew zainstalowal je do /opt/homebrew/bin (Apple Silicon) czy
    /// /usr/local/bin (Intel) - oba katalogi sa w PATH ustawionym w `run`.
    static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws -> ShellResult {
        try await run("/usr/bin/env", ["rclone"] + args, timeout: timeout)
    }

    /// Uruchamia skrypt bash z Resources/scripts, z ustawionymi CM_CONFIG / CM_LOG_DIR
    /// wskazujacymi na Application Support / Library/Logs (patrz Paths.swift).
    static func runScript(_ name: String, _ args: [String] = [], extraEnv: [String: String] = [:], timeout: TimeInterval? = nil) async throws -> ShellResult {
        guard let scriptsDir = Paths.scriptsDir else {
            throw ShellError.launchFailed("Nie znaleziono folderu ze skryptami (scripts/) w bundlu aplikacji.")
        }
        let scriptPath = scriptsDir.appendingPathComponent(name).path
        var env: [String: String] = [
            "CM_CONFIG": Paths.configPath.path,
            "CM_LOG_DIR": Paths.logDir.path
        ]
        for (k, v) in extraEnv { env[k] = v }
        return try await run("/bin/bash", [scriptPath] + args, env: env, timeout: timeout)
    }

    /// Uruchamia polecenie z podniesionymi uprawnieniami przez natywny dialog
    /// autoryzacji macOS (Touch ID / haslo administratora) - bez potrzeby
    /// wczesniejszej konfiguracji sudoers. Uzywane do jednorazowych akcji
    /// wykonywanych z poziomu GUI, gdy uzytkownik jest przy komputerze.
    static func runPrivileged(_ shellCommand: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let escaped = shellCommand
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                let source = "do shell script \"\(escaped)\" with administrator privileges"
                guard let script = NSAppleScript(source: source) else {
                    continuation.resume(throwing: ShellError.privilegedFailed("Nie udalo sie przygotowac AppleScript."))
                    return
                }
                var errorDict: NSDictionary?
                let output = script.executeAndReturnError(&errorDict)
                if let errorDict {
                    let message = errorDict[NSAppleScript.errorMessage] as? String ?? "Nieznany blad autoryzacji."
                    continuation.resume(throwing: ShellError.privilegedFailed(message))
                    return
                }
                continuation.resume(returning: output.stringValue ?? "")
            }
        }
    }
}
