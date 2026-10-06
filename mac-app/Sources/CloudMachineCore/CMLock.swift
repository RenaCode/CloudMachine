import Foundation

/// A lock based on an atomic `mkdir` (not `flock`, which macOS does not have
/// by default), with orphan detection by the PID stored in the lock (not by
/// the directory's age - the same motivation as in the bash `cm_acquire_lock`:
/// an operation under the lock can legitimately take long, e.g. catching up
/// with a backlog of uploads, so a fixed time threshold would falsely mark a
/// live process as orphaned).
public final class CMLock {
  private let lockDir: URL
  private var acquired = false

  public init(name: String) {
    lockDir = CMPaths.logDir.appendingPathComponent("\(name).lock.d")
  }

  /// For tests only: a lock in a directory the test cleans up itself. Without
  /// this, every lock test would leave directories in the real `~/Library/Logs/
  /// CloudMachine`, i.e. where the running installation keeps its production
  /// locks - a test could block the agent.
  init(directory: URL) {
    lockDir = directory
  }

  /// Tries to take the lock. Returns `false` if another live process already holds it.
  public func acquire() -> Bool {
    if (try? FileManager.default.createDirectory(at: lockDir, withIntermediateDirectories: false))
      != nil
    {
      // Verification by reading back is needed here for EXACTLY the same
      // reason as on the takeover path below - until 23 September 2026 it was
      // only there. `writePid()` swallows a write error (`try?`), and a
      // process killed between `createDirectory` and the write leaves the
      // lock directory WITHOUT a `pid` file. A competitor then reads an empty
      // directory, finds no PID, considers the lock orphaned and takes it over
      // - while we have already returned `true` and are acting in the belief
      // that we have exclusivity. Two owners of the same "image" lock means a
      // parallel `detach` and `attach` on the same image, i.e. exactly what
      // the lock is meant to protect against.
      guard writeAndVerifyPid() else {
        try? FileManager.default.removeItem(at: lockDir)
        return false
      }
      acquired = true
      return true
    }
    // The directory already exists - check whether the owner is still alive.
    let pidFile = lockDir.appendingPathComponent("pid")
    if let content = try? String(contentsOf: pidFile, encoding: .utf8),
      let pid = Self.parsePid(from: content),
      isProcessAlive(pid, recordedStartTime: Self.parseStartTime(from: content))
    {
      return false
    }
    // The owner process is no longer alive (or the lock was interrupted before
    // it managed to write its PID) - orphaned, we take it over.
    try? FileManager.default.removeItem(at: lockDir)
    guard
      (try? FileManager.default.createDirectory(at: lockDir, withIntermediateDirectories: false))
        != nil
    else {
      return false
    }
    guard writeAndVerifyPid() else { return false }
    acquired = true
    return true
  }

  /// Writes our own PID and CONFIRMS it by reading it back. `false` means "I
  /// cannot prove the lock is mine" - and that must end in giving up, not in
  /// optimism.
  ///
  /// IMPORTANT: `removeItem` + `createDirectory` on the takeover path is NOT
  /// atomic - two processes taking over the same orphaned lock in an
  /// overlapping window can both read "dead PID", both remove and recreate the
  /// directory, both write their PID - and both return `true`. We read the
  /// file we just wrote back: if another process managed to overwrite it with
  /// its PID between the write and this read, we know we lost the race, and
  /// we back off instead of acting in the false belief of exclusivity. This
  /// does not eliminate the window completely (both sides can still
  /// transiently "win" just before this verification), but it guarantees that
  /// at least one of them will detect it and back off.
  private func writeAndVerifyPid() -> Bool {
    writePid()
    guard
      let verifyContent = try? String(
        contentsOf: lockDir.appendingPathComponent("pid"), encoding: .utf8),
      Self.parsePid(from: verifyContent) == getpid()
    else {
      return false
    }
    return true
  }

  /// Checks whether the process with the given PID is still alive AND not
  /// permanently stuck in an uninterruptible kernel wait (state 'U' from
  /// `ps`). Uses a synchronous `popen("ps -p <pid> -o stat=")` because
  /// `acquire()` is sync - we cannot wait for the async ProcessRunner here.
  ///
  /// A process in state U passes `kill(pid, 0) == 0`, but will never release
  /// the lock by itself (SIGKILL does not wake it from an NFS/I-O wait in the
  /// kernel). We treat it as "dead for locking purposes" after
  /// `stuckThreshold` minutes - a threshold large enough not to conflict with
  /// legitimate long operations (catching up with the upload queue, checksum
  /// verification that can take hours).
  private static let stuckLockThreshold: TimeInterval = 15 * 60  // 15 minutes

  /// Marker "since when we have continuously seen this process in state U/D"
  /// - DELIBERATELY separate from the mtime of `lockDir` (the time the lock
  /// was TAKEN). A legitimate long-running operation (checksum verification
  /// lasting hours) can hold the same lock for a long time BEFORE it ever
  /// falls into U/D - counting the threshold from the time the lock was taken
  /// (as the earlier code did) kills such a legitimate, long-running process
  /// at the first U/D sample after the threshold has passed, which is exactly
  /// what the comment in this file's header warns against (orphan detection
  /// BY PID, NOT by age). We write this marker on the FIRST observed U/D and
  /// delete it when the process returns to a normal state - so it measures
  /// the actual, UNINTERRUPTED duration of the hang.
  private var stuckSinceFile: URL { lockDir.appendingPathComponent("stuck-since") }

  /// `recordedStartTime` is the owner process's start time WRITTEN to the
  /// lock file when the lock was taken (`writePid()`) - it allows telling
  /// "the same process is still alive" apart from "the PID has already been
  /// reused by a completely different, newer process" (`kill(pid, 0) == 0` on
  /// its own cannot tell these apart - it sees ONLY that SOMETHING is alive
  /// under that PID number). The risk is very low in practice (the PID space
  /// is large, watchdogs fire rarely), but it costs little to check. `nil` (a
  /// lock file written before this field was introduced, or `ps` briefly did
  /// not respond at write time) skips this extra verification instead of
  /// falsely assuming an orphan.
  private func isProcessAlive(_ pid: pid_t, recordedStartTime: String?) -> Bool {
    guard kill(pid, 0) == 0 else { return false }

    if let recordedStartTime, !recordedStartTime.isEmpty,
      let currentStartTime = Self.processStartTime(pid: pid),
      currentStartTime != recordedStartTime
    {
      return false
    }

    // Synchronously fetch the process state from `ps`.
    // State 'U' (macOS uninterruptible NFS wait) or 'D' (Linux disk sleep)
    // - both mean a hang in the kernel that SIGKILL does not wake from.
    guard let psState = processState(pid: pid),
      psState.uppercased().hasPrefix("U") || psState.uppercased().hasPrefix("D")
    else {
      // The process is running normally (or `ps` briefly did not respond) -
      // delete the marker, in case the process fell into U/D transiently and
      // came back.
      try? FileManager.default.removeItem(at: stuckSinceFile)
      return true
    }

    if let stuckSinceString = try? String(contentsOf: stuckSinceFile, encoding: .utf8),
      let stuckSinceEpoch = TimeInterval(
        stuckSinceString.trimmingCharacters(in: .whitespacesAndNewlines))
    {
      let stuckDuration = Date().timeIntervalSince1970 - stuckSinceEpoch
      guard stuckDuration > Self.stuckLockThreshold else { return true }
      CMLogger.log(
        "[CMLock] WARNING: PID \(pid) holding the lock '\(lockDir.lastPathComponent)'"
          + " has been CONTINUOUSLY stuck in state U/D (NFS hang?) for more than"
          + " \(Int(Self.stuckLockThreshold/60)) min. Taking over the lock. SIGKILL to the stuck"
          + " process (ignored by the kernel, but it will clean up the PID after unmounting)."
      )
      kill(pid, SIGKILL)
      try? FileManager.default.removeItem(at: stuckSinceFile)
      return false
    }
    // First sample in state U/D - record the start of the window and wait for
    // further samples before considering the process stuck.
    try? "\(Date().timeIntervalSince1970)".write(
      to: stuckSinceFile, atomically: true, encoding: .utf8)
    return true
  }

  /// Synchronous run of `ps -p <pid> -o <format>` via Process/Pipe - shared by
  /// `processState` (`stat=`) and `processStartTime` (`lstart=`). The blocking
  /// use of `readDataToEndOfFile()` is safe because `ps` ALWAYS finishes
  /// quickly and closes its FDs - no risk of waiting forever for EOF (that
  /// problem concerns only daemons such as rclone --daemon, which fork a child
  /// that inherits the FDs and never closes them).
  private static func runPS(pid: pid_t, format: String) -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/ps")
    proc.arguments = ["-p", "\(pid)", "-o", format]
    // IMPORTANT: `ps` formats dates (e.g. `lstart=`) according to the
    // LC_TIME/LANG of the process that CALLS it - NOT of the one whose PID we
    // check. Without forcing a fixed locale, the same live process got a
    // DIFFERENT start-time text depending on who was checking it (e.g. the
    // Polish "sr. 29 lip 10:01:01 2026" from the user's shell with
    // LANG=pl_PL.UTF-8, but "Wed Jul 29 10:01:01 2026" from a watchdog started
    // by launchd with another/default locale) - which `isProcessAlive`
    // misread as "the PID was reused by another process" and which allowed
    // the lock to be stolen from a still-living process. Observed live: two
    // parallel `rclone copy` runs to the same destination. `LC_ALL=C`
    // guarantees the same text regardless of who asks.
    proc.environment = ["LC_ALL": "C"]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    proc.standardInput = FileHandle.nullDevice
    guard (try? proc.run()) != nil else { return nil }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    proc.waitUntilExit()
    let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return (text?.isEmpty == false) ? text : nil
  }

  private func processState(pid: pid_t) -> String? {
    Self.runPS(pid: pid, format: "stat=")
  }

  /// The process start time (e.g. "Wed Jul 29 09:07:59 2026") - a unique
  /// "fingerprint" of a specific process instance under a given PID, used to
  /// detect PID reuse (see `isProcessAlive`).
  private static func processStartTime(pid: pid_t) -> String? {
    runPS(pid: pid, format: "lstart=")
  }

  private func writePid() {
    let pidFile = lockDir.appendingPathComponent("pid")
    let pid = getpid()
    let startTime = Self.processStartTime(pid: pid) ?? ""
    try? "\(pid)\n\(startTime)".write(to: pidFile, atomically: true, encoding: .utf8)
  }

  private static func parsePid(from content: String) -> pid_t? {
    guard let firstLine = content.split(separator: "\n", maxSplits: 1).first else { return nil }
    return pid_t(firstLine.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  /// `nil` for lock files written before this field was introduced (only one
  /// line with the PID) - `isProcessAlive` treats that as a lack of extra
  /// information, not as proof of PID reuse.
  private static func parseStartTime(from content: String) -> String? {
    let lines = content.split(separator: "\n", maxSplits: 1)
    guard lines.count == 2 else { return nil }
    let trimmed = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  public func release() {
    guard acquired else { return }
    try? FileManager.default.removeItem(at: lockDir)
    acquired = false
  }

  deinit {
    if acquired {
      try? FileManager.default.removeItem(at: lockDir)
    }
  }
}

/// Runs `body` under the lock `name`, releasing it automatically on exit
/// (also when an error is thrown) - the counterpart of `cm_acquire_lock` +
/// `trap EXIT`. Returns `nil` without calling `body` if another live instance
/// already holds the lock.
///
/// `nil` means **"nothing happened"** and the caller MUST tell it apart from
/// the result of `body`. Code such as `(await withCMLock("image") { ... }) ??
/// true` or `!= nil ? ... : ...` that turns not running into success is a bug:
/// an `attach` that did not happen would report "Attached", and a `detach`
/// that did not run - "everything uploaded".
@discardableResult
public func withCMLock<T>(_ name: String, _ body: () throws -> T) rethrows -> T? {
  let lock = CMLock(name: name)
  guard lock.acquire() else { return nil }
  defer { lock.release() }
  return try body()
}

@discardableResult
public func withCMLock<T>(_ name: String, _ body: () async throws -> T) async rethrows -> T? {
  let lock = CMLock(name: name)
  guard lock.acquire() else { return nil }
  defer { lock.release() }
  return try await body()
}
