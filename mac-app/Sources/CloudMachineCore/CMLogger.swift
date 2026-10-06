import Foundation

/// Counterpart of `cm_log`/`cm_rotate_log_if_large` from the bash common.sh -
/// timestamped writes to the shared log (`cloudmachine.log`) plus
/// "copytruncate" rotation, so that logs do not grow without bound (a case
/// observed live: rclone-mount.log grew to 3.3 GiB without any rotation).
public enum CMLogger {
  private static let lock = NSLock()

  /// Appends a line to `cloudmachine.log` (with a timestamp) and to stdout -
  /// the counterpart of `cm_log` (which used `tee -a`).
  public static func log(_ message: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = "[\(formatter.string(from: Date()))] \(message)\n"
    emitToStandardOutput(line)
    append(line, to: CMPaths.combinedLogFile)
    // IMPORTANT: `rotateIfLarge` existed in the code before, but was never
    // called anywhere - `cloudmachine.log` grew without bound (exactly the
    // scenario this function was meant to prevent, see the comment on it).
    // Checking the file size is a cheap `stat`, so we do it on every entry
    // instead of relying on someone remembering to call it somewhere.
    rotateIfLarge(CMPaths.combinedLogFile)
  }

  /// Writes text to stdout and IMMEDIATELY flushes the stdio buffer.
  ///
  /// Without `fflush` the line stayed in the C library buffer until 16 KiB had
  /// accumulated. Under launchd stdout is a FILE
  /// (`StandardOutPath: __CM_LOG_DIR__/launchd-*.out.log`), and for a file
  /// stdio chooses BLOCK buffering - unlike a terminal, where it buffers by
  /// line and the problem does not exist. That is why it could not be seen by
  /// running the same command by hand.
  ///
  /// Measured 25.09.2026: `~/Library/Logs/CloudMachine/launchd-buffer-guard.out.log`
  /// was EXACTLY 16384 bytes, dated 2026-09-20, with the last line cut off
  /// mid-word, while the `buffer-guard` process had been alive since
  /// 2026-09-25 and was logging normally to `cloudmachine.log`. The file a
  /// person looks at FIRST (because its name points them there) was five days
  /// behind and ended mid-sentence - i.e. it looked like a process that died
  /// on the fifth day.
  ///
  /// It bites only LONG-LIVED processes, which is why it stayed invisible for
  /// so long: `buffer-guard` is `while true` + `KeepAlive`, so it never gets to
  /// flush the buffer on exit. Short subcommands (`attach-image`,
  /// `backup-health`) end after every tick, and `exit(3)` flushes the buffer
  /// for them - that is why `launchd-backup-health.out.log` was current on the
  /// same day on which `launchd-buffer-guard.out.log` had been stuck for five.
  ///
  /// Why `fflush` here, and not `setvbuf(stdout, nil, _IOLBF, 0)` at agent
  /// startup:
  ///
  /// - `setvbuf` has to be called at EVERY entry point (CLI agent, GUI, POC
  ///   harnesses) and before the first write to stdout. Forgotten in one of
  ///   them, it brings exactly this failure back, and its symptom is again a
  ///   file that looks complete. The guarantee belongs to the WRITE, not to a
  ///   configuration someone has to remember to turn on.
  /// - `setvbuf` after the first I/O on the stream is undefined, so "we will
  ///   set it somewhere at startup" is in practice a condition on
  ///   initialization order - and that breaks silently when code is moved
  ///   around.
  /// - The cost is negligible: the log has entries at the pace of events
  ///   (seconds, not microseconds), and the same entry already goes via
  ///   `write(2)` to `cloudmachine.log` next to it anyway.
  ///
  /// This does NOT solve buffering of plain `print(...)` calls from CLI
  /// subcommands - those write directly. It solves the log, i.e. what is the
  /// only trace of the agent's activity under launchd.
  static func emitToStandardOutput(_ text: String) {
    print(text, terminator: "")
    fflush(stdout)
  }

  private static func append(_ text: String, to url: URL) {
    lock.lock()
    defer { lock.unlock() }
    appendLocked(text, to: url)
  }

  /// Assumes `lock` is already held by the caller - split out of
  /// `append(_:to:)` so that `rotateIfLargeLocked` can append its own message
  /// without a second (recursive) `lock.lock()`.
  private static func appendLocked(_ text: String, to url: URL) {
    guard let data = text.data(using: .utf8) else { return }
    if FileManager.default.fileExists(atPath: url.path) {
      if let handle = try? FileHandle(forWritingTo: url) {
        defer { try? handle.close() }
        handle.seekToEndOfFile()
        handle.write(data)
        return
      }
    }
    try? data.write(to: url)
  }

  /// Trims the log file using the "copytruncate" method if it has exceeded
  /// `maxBytes` - keeps the last `keepLines` lines, THEN truncates the
  /// original to 0 bytes. Safe for a process (e.g. rclone) that keeps the same
  /// file open for appending (O_APPEND) - after truncation the kernel itself
  /// moves the next write to the new, smaller end of the file, so that process
  /// does NOT have to be restarted for the rotation to work.
  ///
  /// IMPORTANT: guarded by the same `lock` as `append()` (previously it was
  /// NOT) - without that, two threads in the same process logging exactly at
  /// the moment `maxBytes` is exceeded could read-trim-write the same file in
  /// parallel without coordination, losing freshly appended lines.
  @discardableResult
  public static func rotateIfLarge(
    _ url: URL, maxBytes: Int = 200 * 1024 * 1024, keepLines: Int = 5000
  ) -> Bool {
    lock.lock()
    defer { lock.unlock() }
    guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
      let size = attrs[.size] as? Int, size > maxBytes
    else {
      return false
    }
    guard let content = try? String(contentsOf: url, encoding: .utf8) else { return false }
    let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
    let tail = lines.suffix(keepLines).joined(separator: "\n")
    do {
      try tail.write(to: url, atomically: false, encoding: .utf8)
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let notice =
        "[\(formatter.string(from: Date()))] Trimmed \(url.lastPathComponent)"
        + " (was \(size) bytes, kept the last \(keepLines) lines).\n"
      emitToStandardOutput(notice)
      appendLocked(notice, to: url)
      return true
    } catch {
      return false
    }
  }
}
