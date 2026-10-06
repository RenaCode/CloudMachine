import Foundation

public struct ProcessResult {
  public var stdout: String
  public var stderr: String
  public var exitCode: Int32
  public var succeeded: Bool { exitCode == 0 }

  /// `true` if this failure is `sudo -n` refusing immediately because of a
  /// missing NOPASSWD rule in sudoers (and NOT a real failure of a command
  /// that sudo actually managed to run) - tells "the rule has to be added and
  /// the action retried" apart from "the command will fail identically on a
  /// retry anyway", so there is no point asking the user for the administrator
  /// password or scaring them in the log/notification with a fictitious data
  /// problem.
  public var isSudoAuthFailure: Bool {
    let text = (stderr + stdout).lowercased()
    return text.contains("a password is required") || text.contains("no tty present")
  }
}

public enum ProcessRunnerError: LocalizedError {
  case launchFailed(String)
  case timedOut(String)

  public var errorDescription: String? {
    switch self {
    case .launchFailed(let msg): return msg
    case .timedOut(let executable):
      return L10n.tr(
        "%@ did not respond within the allotted time (the process was left orphaned in the background).",
        executable)
    }
  }
}

/// Protects `continuation` against being resumed twice - needed ever since
/// `run(timeout:)` can "give up" and return an error BEFORE the process has
/// actually ended (see the comment on `timeout` below). If terminationHandler
/// still fires later, it MUST do nothing instead of causing a fatal error with
/// a second `continuation.resume`.
///
/// Internal rather than private: since 26.09.2026 `ImageProbe` gives up on a
/// deadline in exactly the same way (a probe stuck in the kernel may answer
/// later or never), so both paths must share the same, proven semantics of
/// "whoever was first resumes".
final class ContinuationGuard: @unchecked Sendable {
  private let lock = NSLock()
  private var done = false

  /// Returns `true` only the FIRST time - i.e. "you are the one entitled to
  /// resume the continuation"; every subsequent call gets `false`.
  func claim() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    if done { return false }
    done = true
    return true
  }
}

/// A thin layer over `Process` for running external tools (rclone, tmutil,
/// hdiutil, diskutil...) - shared by the GUI and the CLI. Previously it lived
/// only in the GUI as `Shell.run`; moved here so that the CLI watchdogs have
/// exactly the same, already proven timeout semantics.
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
      // Homebrew on Apple Silicon installs to /opt/homebrew/bin - added just in case.
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
      let resumeGuard = ContinuationGuard()

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

        // IMPORTANT: readDataToEndOfFile() must NOT be called here - it blocks
        // until the write end of the pipe is closed by ALL of its holders.
        // Processes started with "--daemon" (e.g. `rclone nfsmount --daemon`)
        // fork a child that inherits the same stdout/stderr FDs and NEVER
        // closes them - the terminationHandler of the immediate parent process
        // fires normally, but readDataToEndOfFile() then hangs forever,
        // because EOF never arrives (observed for real: a watchdog stuck for
        // >10 min after every fresh rclone start). `readabilityHandler` already
        // collects everything as the data arrives - no extra, blocking final
        // read is needed.
        queue.async {
          let result = ProcessResult(
            stdout: String(data: stdoutData, encoding: .utf8) ?? "",
            stderr: String(data: stderrData, encoding: .utf8) ?? "",
            exitCode: proc.terminationStatus
          )
          if resumeGuard.claim() {
            continuation.resume(returning: result)
          }
        }
      }

      do {
        try process.run()
      } catch {
        if resumeGuard.claim() {
          continuation.resume(
            throwing: ProcessRunnerError.launchFailed(
              L10n.tr("Cannot launch %@: %@", executable, error.localizedDescription)))
        }
        return
      }

      if let timeout {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
          if process.isRunning {
            process.terminate()
          }
        }
        // Escalation to SIGKILL if the process ignores SIGTERM - see the
        // rationale for the same mechanism in the old Shell.swift (a hung
        // child diskutil/umount ignores SIGTERM indefinitely).
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 5) {
          if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
          }
        }
        // IMPORTANT: SIGKILL does NOT work on a process stuck in the kernel in
        // an uninterruptible wait (state "U" in `ps`, e.g. hdiutil/
        // diskimages-helper waiting for I/O over a dead/slow NFS - observed
        // for real, live). Without this final limit `timeout` would NOT be a
        // real upper bound on the waiting time, contrary to what the parameter
        // suggests - `continuation` would wait forever for a
        // `terminationHandler` that would never fire. Here we give up and
        // return an error instead of hanging; the process is left orphaned in
        // the background (harmlessly - it will finish by itself some day, when
        // the kernel finally gets an answer, and `resumeGuard` prevents a
        // double resume if `terminationHandler` fires later).
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 10) {
          if resumeGuard.claim() {
            // IMPORTANT: we do NOT reset the handler to `nil` - that leaves the
            // pipe with NO reader at all. If the process survived even SIGKILL
            // (stuck in the kernel in uninterruptible I/O - see the comment
            // above) and does resume some day, it may still write to
            // stdout/stderr; without a reader, a full pipe buffer would block
            // it on `write()` FOREVER, turning "a harmless orphaned process"
            // into a permanently stuck zombie that never gets cleaned up. So we
            // replace the handler with one that keeps draining and discarding
            // the data - the result will not be read anyway (the continuation
            // below resumes with the timeout error), but the orphaned process
            // can freely finish writing and exit on its own.
            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
              _ = handle.availableData
            }
            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
              _ = handle.availableData
            }
            continuation.resume(throwing: ProcessRunnerError.timedOut(executable))
          }
        }
      }
    }
  }

  /// Runs `rclone` via `/usr/bin/env`, so that it works regardless of whether
  /// Homebrew installed it to /opt/homebrew/bin or /usr/local/bin.
  public static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws
    -> ProcessResult
  {
    try await run("/usr/bin/env", ["rclone"] + args, timeout: timeout)
  }

  /// Runs `tmutil` via `sudo -n` (without asking for a password) - requires a
  /// NOPASSWD rule configured beforehand in /etc/sudoers.d/cloudmachine (see
  /// LaunchdInstaller/DependencyInstaller). Used by watchdogs running without
  /// a GUI session (they cannot show an authorization dialog).
  public static func runTmutilUnattended(_ args: [String], timeout: TimeInterval? = nil)
    async throws -> ProcessResult
  {
    try await run("/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: timeout)
  }

  public static func isProcessRunning(pid: pid_t) -> Bool {
    kill(pid, 0) == 0
  }
}
