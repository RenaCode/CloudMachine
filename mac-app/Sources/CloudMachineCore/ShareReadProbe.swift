import Foundation

/// Reads one byte through the share's own path in the machine:
/// `/srv/tm-local/<image>/bands/0`, which after `vm-prepare-bundle` is the
/// bind of punchfs over the rclone mount - the chain every band Time Machine
/// writes goes through.
///
/// Why a read and not the services: every link of that chain can be
/// `systemctl is-active` while a read through it fails or never returns. A
/// hung FUSE daemon is still a live process; punchfs keeps the DEAD mount of
/// an rclone that systemd restarted under it (`Restart=always` restarts
/// rclone alone); after `vm-prepare-bundle` an inactive `tm-bands-bind`
/// passes as fine, and the bands land on the machine's local disk. In the
/// disk-image layout the same blind spot (the mount table still listing a
/// dead device) let the panel say "everything uploaded" while Time Machine
/// got ENXIO (22.09.2026). `stat` is not a read either: it is answered from
/// the attribute cache (`--attr-timeout 5m`), only reading data proves the
/// path.
///
/// Band `0` holds the start of the image (the partition map, the APFS
/// container superblock): it exists in every image Time Machine has
/// formatted, and it is read on every mount, so rclone has it in its cache -
/// the probe costs a local read, not a download from Drive.
///
/// HOW IT STAYS BOUNDED: a read on a hung FUSE mount sits in uninterruptible
/// sleep (`D`); neither `timeout` nor SIGKILL brings it back, and a script
/// that waits for it hangs the whole `limactl shell` call - and with it the
/// panel, `vm-status` and the watchdog. So the read runs DETACHED, the script
/// polls for its result for at most `timeoutSeconds` and then reports "hung"
/// with the age of the read. A lock directory lets only one read exist: a
/// stuck one is reported at once by every later run, instead of leaving one
/// more stuck process per panel refresh.
///
/// The reader ignores SIGHUP/SIGINT/SIGTERM: `sudo` with `use_pty` (Ubuntu's
/// default) runs the script in its own process group on a pty, and that group
/// is hung up when bash exits or when the Mac kills `limactl` - a reader dying
/// of it would leave its lock behind. It removes the lock itself; a lock whose
/// reader is gone (SIGKILL, no pid and older than `staleLockSeconds`) is
/// taken over. `/run` is a tmpfs, so a reboot clears it too.
///
/// It only reads: `head -c1` opens the band read-only, nothing is written to
/// the image.
public enum ShareReadProbe {

  public enum Verdict: Equatable, Sendable {
    /// One byte read through the share's path.
    case readable
    /// No image in the machine yet - Time Machine has not created it.
    case noImage
    /// The read failed with a device-level error (EIO, ENOTCONN, ENXIO,
    /// ENODEV, ESTALE) or the first band is missing (ENOENT). Restarting the
    /// share's stack (punchfs, the bind, smbd) is the likely fix - by a
    /// person for now; doing it by itself is a separate decision.
    case dead(reason: String)
    /// Another read error (EACCES...) - not fixed by a restart, not fine either.
    case failed(reason: String)
    /// The read did not return within the limit (`hungSeconds` = how long the
    /// read has been running), or the machine printed no verdict at all
    /// (`nil`). NOT a failure to act on - a hung read can be a write still
    /// going - and never "fine".
    case noAnswer(hungSeconds: Int?)

    /// Only these two let the panel show green.
    public var isConfirmed: Bool {
      switch self {
      case .readable, .noImage: return true
      case .dead, .failed, .noAnswer: return false
      }
    }
  }

  /// How long one run waits for the read. A cached band reads in
  /// milliseconds; an uncached one is a ranged download, a few seconds over a
  /// slow network. Counted into `VMStatus.reportTimeout`.
  public static let timeoutSeconds = 10

  /// A lock without its reader's pid older than this is a reader that died
  /// before writing it; no read waits this long for its pid.
  static let staleLockSeconds = 60

  /// Where the lock and the last result live in the machine.
  static let stateDir = "/run/cloudmachine-share-probe"

  /// Sets `f` to the first band of the image the share serves; empty `f` = no
  /// image (yet).
  ///
  /// A prepared image is named in `bundle.env`, and its band is read
  /// unconditionally: its bands are the FUSE chain, and a missing band 0 is
  /// exactly what the probe must report. Before `vm-prepare-bundle` the image
  /// is on the machine's own disk, and Time Machine creating it writes the
  /// directory a moment before band 0 - there `[ -e ]` is a safe local check,
  /// and an image without its band yet is "no image yet", not a dead share.
  static func locateFirstBand(bundleEnv: String, localRoot: String) -> String {
    let env = VMLayout.shellQuoted(bundleEnv)
    let root = VMLayout.shellQuoted(localRoot)
    return "B=$(sed -n 's/^CM_BUNDLE=//p' \(env) 2>/dev/null | tr -d '\"'); f=; "
      + "if [ -n \"$B\" ]; then f=\(root)/\"$B\"/bands/0; else "
      + "B=$(cd \(root) 2>/dev/null && ls -d *.sparsebundle 2>/dev/null | head -1); "
      + "if [ -n \"$B\" ] && [ -e \(root)/\"$B\"/bands/0 ]; then f=\(root)/\"$B\"/bands/0; fi; "
      + "fi"
  }

  /// The part of the status script that prints the `PROBE` line.
  public static let guestScript = script(
    locate: locateFirstBand(
      bundleEnv: VMLayout.Guest.bundleEnv, localRoot: VMLayout.Guest.localRoot),
    stateDir: stateDir, timeout: timeoutSeconds)

  /// The probe as a bash script. `locate` assigns the file to read to `f`.
  /// Separate from `guestScript` so a test can run it on a real file, a
  /// missing one and a FIFO (which blocks like a hung mount).
  ///
  /// Output: `PROBE ok`, `PROBE none`, `PROBE error <message>` or
  /// `PROBE hung <seconds>`.
  static func script(locate: String, stateDir: String, timeout: Int) -> String {
    let d = VMLayout.shellQuoted(stateDir)
    return "{ "
      + "\(locate); "
      + "if [ -z \"$f\" ]; then echo PROBE none; else "
      + "mkdir -p \(d); "
      // A lock whose reader is gone is taken over. Two runs doing it at once
      // can start two readers; both still write one result, so that costs one
      // extra read, never a wrong verdict.
      + "if [ -d \(d)/lock ]; then p=$(cat \(d)/lock/pid 2>/dev/null); s=$(cat \(d)/lock/start 2>/dev/null); "
      + "if [ -n \"$p\" ]; then kill -0 \"$p\" 2>/dev/null || rm -rf \(d)/lock; "
      + "elif [ -n \"$s\" ] && [ $(( $(date +%s) - s )) -gt \(staleLockSeconds) ]; then rm -rf \(d)/lock; fi; fi; "
      // The one who creates the lock starts the read. The reader writes the
      // result BEFORE it removes the lock, so whoever sees the lock gone sees
      // that result. `sh -c 'echo $PPID'` is the reader's own pid (bash 3.2,
      // which the tests run, has no BASHPID).
      + "if mkdir \(d)/lock 2>/dev/null; then "
      + "date +%s > \(d)/lock/start; "
      + "( trap '' HUP INT TERM; sh -c 'echo $PPID' > \(d)/lock/pid; "
      + "LC_ALL=C head -c1 -- \"$f\" >/dev/null 2>\(d)/err.tmp; echo $? > \(d)/rc.tmp; "
      + "mv -f \(d)/err.tmp \(d)/err; mv -f \(d)/rc.tmp \(d)/rc; rm -rf \(d)/lock ) "
      + "</dev/null >/dev/null 2>&1 & "
      + "fi; "
      // Wait while the read runs and is younger than the limit; the counter
      // caps the wait even if `start` is missing.
      + "i=0; while [ -d \(d)/lock ] && [ $i -le \(timeout) ]; do "
      + "s=$(cat \(d)/lock/start 2>/dev/null); "
      + "if [ -n \"$s\" ]; then [ $(( $(date +%s) - s )) -lt \(timeout) ] || break; fi; "
      + "sleep 1; i=$((i+1)); done; "
      + "if [ -d \(d)/lock ]; then s=$(cat \(d)/lock/start 2>/dev/null); "
      + "echo PROBE hung $(( $(date +%s) - ${s:-$(date +%s)} )); "
      + "elif [ \"$(cat \(d)/rc 2>/dev/null)\" = 0 ]; then echo PROBE ok; "
      + "else echo \"PROBE error $(head -1 \(d)/err 2>/dev/null)\"; fi; "
      + "fi; }"
  }

  // MARK: - Reading the verdict (pure)

  /// The verdict from the status script's output. No `PROBE` line, or one
  /// that is not understood, is `.noAnswer(nil)` - never `.readable`.
  public static func verdict(scriptOutput: String) -> Verdict {
    for line in scriptOutput.split(separator: "\n") where line.hasPrefix("PROBE ") {
      let rest = String(line.dropFirst("PROBE ".count))
      if rest == "ok" { return .readable }
      if rest == "none" { return .noImage }
      if rest.hasPrefix("hung "), let seconds = Int(rest.dropFirst("hung ".count)) {
        return .noAnswer(hungSeconds: max(0, seconds))
      }
      if rest == "error" || rest.hasPrefix("error ") {
        return verdict(errorText: String(rest.dropFirst("error".count)))
      }
    }
    return .noAnswer(hungSeconds: nil)
  }

  /// Error messages (C locale; GNU coreutils in the machine, BSD in the
  /// tests) and the errno they stand for. Longer first: "No such device"
  /// is a prefix of "No such device or address".
  static let deviceErrors: [(text: String, name: String)] = [
    ("No such device or address", "ENXIO"),
    ("Input/output error", "EIO"),
    ("Transport endpoint is not connected", "ENOTCONN"),
    ("Socket is not connected", "ENOTCONN"),
    ("Stale NFS file handle", "ESTALE"),
    ("Stale file handle", "ESTALE"),
    ("No such device", "ENODEV"),
    ("Operation not supported by device", "ENODEV"),
    ("No such file or directory", "ENOENT"),
  ]

  static func verdict(errorText: String) -> Verdict {
    // `head: <file>: <message>` or `head: cannot open '<file>' ...: <message>`.
    let message =
      errorText.components(separatedBy: ": ").last?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    for known in deviceErrors where message.hasPrefix(known.text) {
      return .dead(reason: known.name)
    }
    return .failed(reason: message.isEmpty ? "no message" : message)
  }
}
