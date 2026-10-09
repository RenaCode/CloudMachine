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

/// Reads one pipe of a child process. Lives on the serial queue it is given -
/// every method must be called on that queue, which is what makes the final
/// `finish()` see every byte read before it.
///
/// A dispatch read source instead of `FileHandle.readabilityHandler`: the
/// handler runs on a Foundation queue of its own, so "read, then hand over"
/// could not be ordered against the process exit.
final class PipeReader: @unchecked Sendable {
  private let pipe: Pipe
  private let fd: Int32
  private let source: DispatchSourceRead
  private var data = Data()
  private var discarding = false
  private var finished = false
  private var closed = false

  init(_ pipe: Pipe, queue: DispatchQueue) {
    self.pipe = pipe
    fd = pipe.fileHandleForReading.fileDescriptor
    // Non-blocking, so that reading "everything there is" stops at an empty
    // pipe instead of waiting for EOF - see `terminationHandler`.
    _ = fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK)
    source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
    // A strong reference on purpose: the reader has to outlive the call while
    // a `--daemon` child still writes into the pipe, and an uncancelled source
    // whose handler did nothing would fire on the unread data without end.
    // The cycle ends at `cancel()` (EOF), when dispatch drops the handler.
    source.setEventHandler { self.drain() }
    // The pipe (and with it the descriptor) stays alive until the source is
    // cancelled - closing it earlier would leave the source watching a number
    // that the next `open` may reuse.
    source.setCancelHandler { [pipe] in _ = pipe }
    source.resume()
  }

  /// Reads whatever is in the pipe right now.
  private func drain() {
    var buffer = [UInt8](repeating: 0, count: 65536)
    while !closed {
      let count = read(fd, &buffer, buffer.count)
      if count > 0 {
        if !discarding { data.append(buffer, count: count) }
      } else if count == 0 {
        // EOF: every holder of the write end has closed it.
        closed = true
        source.cancel()
      } else if errno == EINTR {
        continue
      } else {
        // EAGAIN - nothing more for now; anything else - nothing more ever.
        if errno != EAGAIN {
          closed = true
          source.cancel()
        }
        return
      }
    }
  }

  /// The final read after the process has exited, and everything collected.
  /// Stops reading only when EOF came: otherwise a child that inherited the
  /// pipe (`--daemon`) still writes into it, and with nobody reading, a full
  /// pipe would block it on `write()`. What it writes from now on is dropped.
  func finish() -> Data {
    if !finished {
      finished = true
      drain()
      discarding = true
    }
    return data
  }

  /// The result will not be read (timed out) - keep the pipe empty only.
  func discardFromNowOn() {
    discarding = true
    data = Data()
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

      // Everything that touches the collected output runs on this ONE serial
      // queue: the reads as data arrives, the final drain and building the
      // result. Until 09.10.2026 the reads ran in `readabilityHandler` on a
      // queue of their own and only the append came here; `terminationHandler`
      // removed the handlers and built the result at once. What was still in
      // the pipe, or read but not yet appended, was lost - an EMPTY stdout with
      // exit code 0 (measured: 2 in 5000 calls at rest, 970 in 4000 with eight
      // at a time). Callers took "" for an answer: `destinationinfo` -> "the
      // destination is not registered", `listremotes` -> "there is no remote".
      let queue = DispatchQueue(label: "com.renacode.cloudmachine.process-pipe")
      let stdoutReader = PipeReader(stdoutPipe, queue: queue)
      let stderrReader = PipeReader(stderrPipe, queue: queue)
      let resumeGuard = ContinuationGuard()

      process.terminationHandler = { proc in
        // IMPORTANT: readDataToEndOfFile() must NOT be called here - it blocks
        // until the write end of the pipe is closed by ALL of its holders.
        // Processes started with "--daemon" (e.g. `rclone nfsmount --daemon`)
        // fork a child that inherits the same stdout/stderr FDs and NEVER
        // closes them - the terminationHandler of the immediate parent process
        // fires normally, but readDataToEndOfFile() then hangs forever,
        // because EOF never arrives (observed for real: a watchdog stuck for
        // >10 min after every fresh rclone start).
        //
        // The final drain is a NON-BLOCKING read instead: the process has
        // exited, so everything it wrote is already in the pipe, and the read
        // stops at "nothing more right now" rather than at EOF.
        queue.async {
          let result = ProcessResult(
            stdout: String(data: stdoutReader.finish(), encoding: .utf8) ?? "",
            stderr: String(data: stderrReader.finish(), encoding: .utf8) ?? "",
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
            // IMPORTANT: we do NOT stop reading - that leaves the pipe with NO
            // reader at all. If the process survived even SIGKILL (stuck in the
            // kernel in uninterruptible I/O - see the comment above) and does
            // resume some day, it may still write to stdout/stderr; without a
            // reader, a full pipe buffer would block it on `write()` FOREVER,
            // turning "a harmless orphaned process" into a permanently stuck
            // zombie that never gets cleaned up. So the readers keep draining
            // and discard the data - the result will not be read anyway (the
            // continuation below resumes with the timeout error), but the
            // orphaned process can freely finish writing and exit on its own.
            queue.async {
              stdoutReader.discardFromNowOn()
              stderrReader.discardFromNowOn()
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
