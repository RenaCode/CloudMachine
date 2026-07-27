import Foundation

public struct ProcessResult {
  public var stdout: String
  public var stderr: String
  public var exitCode: Int32
  public var succeeded: Bool { exitCode == 0 }
}

public enum ProcessRunnerError: LocalizedError {
  case launchFailed(String)

  public var errorDescription: String? {
    switch self {
    case .launchFailed(let msg): return msg
    }
  }
}

/// Cienka warstwa nad `Process` do uruchamiania zewnetrznych narzedzi
/// (rclone, tmutil, hdiutil, diskutil...) - dzielona przez GUI i CLI. Wczesniej
/// zyla wylacznie w GUI jako `Shell.run`; przeniesiona tu, zeby watchdogi CLI
/// mialy dokladnie te sama, juz sprawdzona semantyke timeoutu.
public enum ProcessRunner {
  public static func run(
    _ executable: String, _ args: [String], env: [String: String] = [:],
    timeout: TimeInterval? = nil
  ) async throws -> ProcessResult {
    try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      process.executableURL = URL(fileURLWithPath: executable)
      process.arguments = args

      var fullEnv = ProcessInfo.processInfo.environment
      // Homebrew na Apple Silicon instaluje do /opt/homebrew/bin - dorzucamy na wszelki wypadek.
      fullEnv["PATH"] =
        "/opt/homebrew/bin:/usr/local/bin:" + (fullEnv["PATH"] ?? "/usr/bin:/bin:/usr/sbin:/sbin")
      for (k, v) in env { fullEnv[k] = v }
      process.environment = fullEnv

      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()
      process.standardOutput = stdoutPipe
      process.standardError = stderrPipe
      process.standardInput = FileHandle.nullDevice

      let queue = DispatchQueue(label: "com.renacode.cloudmachine.process-pipe")
      var stdoutData = Data()
      var stderrData = Data()

      stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          queue.async { stdoutData.append(data) }
        }
      }
      stderrPipe.fileHandleForReading.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          queue.async { stderrData.append(data) }
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

          let result = ProcessResult(
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
        continuation.resume(
          throwing: ProcessRunnerError.launchFailed(
            "Nie mozna uruchomic \(executable): \(error.localizedDescription)"))
        return
      }

      if let timeout {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
          if process.isRunning {
            process.terminate()
          }
        }
        // Eskalacja do SIGKILL, jesli proces zignoruje SIGTERM - patrz
        // uzasadnienie przy tym samym mechanizmie w dawnym Shell.swift
        // (zawieszony potomny diskutil/umount ignoruje SIGTERM bez konca).
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 5) {
          if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
          }
        }
      }
    }
  }

  /// Uruchamia `rclone` przez `/usr/bin/env`, zeby dzialalo niezaleznie od
  /// tego, czy Homebrew zainstalowal je do /opt/homebrew/bin czy /usr/local/bin.
  public static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws
    -> ProcessResult
  {
    try await run("/usr/bin/env", ["rclone"] + args, timeout: timeout)
  }

  /// Uruchamia `tmutil` przez `sudo -n` (bez pytania o haslo) - wymaga
  /// wczesniej skonfigurowanej reguly NOPASSWD w /etc/sudoers.d/cloudmachine
  /// (patrz LaunchdInstaller/DependencyInstaller). Uzywane przez watchdogi
  /// dzialajace bez sesji GUI (nie moga pokazac dialogu autoryzacji).
  public static func runTmutilUnattended(_ args: [String], timeout: TimeInterval? = nil)
    async throws -> ProcessResult
  {
    try await run("/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: timeout)
  }

  public static func isProcessRunning(pid: pid_t) -> Bool {
    kill(pid, 0) == 0
  }
}
