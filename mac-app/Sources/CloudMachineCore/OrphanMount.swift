import Foundation

/// The way out of a Drive mount whose rclone is gone.
///
/// 25 Oct 2026 00:02 and 27 Oct 2026 00:19, both during a backup: rclone
/// logged "Mount failed" / "CRITICAL: Fatal error: failed to umount FUSE fs"
/// and quit, but the FUSE-T NFS mount stayed in the mount table. From then on
/// every `stat` of the mount (Time Machine, `tmutil`, Xcode, our own agents)
/// hung, and nothing brought rclone back: `mount-drive` read the mount table,
/// saw the mount and said "Already mounted". On 27.10 that lasted 8 h, until
/// the owner restarted the Mac. On 25.10 `umount -f` of the mount point by
/// hand was enough - the agent brought rclone up 30 s later.
///
/// So the remedy is that `umount -f`, done by the agents, when the mount is
/// listed and no live rclone holds it. Everything here avoids the file
/// system: the mount table is read with `MNT_NOWAIT`, the process table with
/// `pgrep`/`ps`, so a dead mount cannot hang the check that looks for it.
///
/// Two callers:
/// - `buffer-guard` runs `watch()` in its own task, beside its main loop, so
///   a probe of that loop hanging on the dead mount cannot hold it up. It
///   waits `grace` before acting - the normal restart of rclone by launchd
///   also has a moment with the mount listed and no rclone yet.
/// - `mount-drive`, at start-up. launchd starts it only once the previous
///   rclone has exited, so a listed mount with no rclone is an orphan.
public enum OrphanMount {

  /// Whether an rclone holding our mount is alive.
  public enum RcloneState: Equatable {
    case running
    /// No such process, or only ones on their way out (`ps` state `E`/`Z`).
    case gone
    /// The process table could not be read - never a reason to unmount.
    case unknown
  }

  public static let grace: TimeInterval = 60
  public static let checkInterval: TimeInterval = 30
  static let unmountTimeout: TimeInterval = 60

  /// Since when the mount has been seen orphaned; `nil` = it is not.
  public static func orphanedSince(
    _ previous: TimeInterval?, mounted: Bool?, rclone: RcloneState, now: TimeInterval
  ) -> TimeInterval? {
    // Only a sure "mounted" and a sure "gone" make an orphan; any doubt
    // resets the clock rather than counting towards an unmount.
    guard mounted == true, rclone == .gone else { return nil }
    return previous ?? now
  }

  /// Whether the orphan has lasted long enough to unmount it.
  public static func shouldUnmount(orphanedSince: TimeInterval?, now: TimeInterval) -> Bool {
    guard let orphanedSince else { return false }
    return now - orphanedSince >= grace
  }

  /// `ps -o stat=` lines -> whether any of them is a process still running.
  /// `E` = trying to exit, `Z` = zombie: neither serves the mount any more.
  static func anyAlive(psStates: String) -> Bool {
    psStates.split(whereSeparator: \.isNewline).contains { line in
      let state = line.trimmingCharacters(in: .whitespaces)
      return !state.isEmpty && !state.contains("E") && !state.contains("Z")
    }
  }

  /// Our rclone, by the path it runs from and the `mount` subcommand.
  static var rclonePattern: String {
    NSRegularExpression.escapedPattern(for: CMTooling.managedRclonePath.path) + " mount "
  }

  public static func rcloneState() async -> RcloneState {
    guard
      let found = try? await ProcessRunner.run(
        "/usr/bin/pgrep", ["-f", rclonePattern], timeout: 15)
    else { return .unknown }
    switch found.exitCode {
    case 1: return .gone
    case 0: break
    default: return .unknown
    }
    let pids = found.stdout.split(whereSeparator: \.isWhitespace).map(String.init)
    guard !pids.isEmpty,
      let states = try? await ProcessRunner.run(
        "/bin/ps", ["-o", "stat=", "-p", pids.joined(separator: ",")], timeout: 15)
    else { return .unknown }
    // `ps` exits 1 when the processes have gone in the meantime.
    if !states.succeeded, states.stdout.isEmpty { return .gone }
    return anyAlive(psStates: states.stdout) ? .running : .gone
  }

  /// `umount -f` of the mount point; `true` once it has left the mount table.
  @discardableResult
  public static func forceUnmount() async -> Bool {
    let path = DriveBufferService.mountPoint.path
    CMLogger.log("Orphaned Drive mount (no rclone holds it) - umount -f \(path)")
    let result = try? await ProcessRunner.run(
      "/sbin/umount", ["-f", path], timeout: unmountTimeout)
    let gone = DriveBufferService.mountedState() == false
    CMLogger.log(
      gone
        ? "Orphaned Drive mount removed"
        : "Orphaned Drive mount NOT removed (umount -f: \(result.map { "exit code \($0.exitCode) \($0.stderr)" } ?? "no answer"))"
    )
    return gone
  }

  /// `mount-drive`'s check: unmount at once, no grace (see the type comment).
  public static func clearBeforeMount() async {
    guard DriveBufferService.mountedState() == true, await rcloneState() == .gone else { return }
    await forceUnmount()
  }

  /// `buffer-guard`'s watch, forever.
  public static func watch() async {
    var since: TimeInterval?
    while true {
      try? await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
      let mounted = DriveBufferService.mountedState()
      let rclone = mounted == true ? await rcloneState() : .unknown
      let now = Date().timeIntervalSince1970
      since = orphanedSince(since, mounted: mounted, rclone: rclone, now: now)
      guard shouldUnmount(orphanedSince: since, now: now) else { continue }
      since = nil
      guard await forceUnmount() else { continue }
      // launchd starts `mount-drive` again by itself once rclone has exited;
      // a kickstart without `-k` only covers a job that is not running.
      _ = try? await ProcessRunner.run(
        "/bin/launchctl",
        ["kickstart", "gui/\(getuid())/\(AgentRepair.prefix)\(MountRestart.mountAgent)"],
        timeout: 30)
    }
  }
}
