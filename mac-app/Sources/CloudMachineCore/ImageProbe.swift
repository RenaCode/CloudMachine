import Foundation

/// Whether the attached image REALLY returns data - and does not merely appear
/// in the mount table.
///
/// WHY THIS EXISTS
///
/// On 22 Sep 2026 at 00:17 rclone got HTTP 401 from Google while listing the
/// bands, passed an I/O error to FUSE-T, and the image driver considered the
/// device disconnected. From that moment every read of a file under
/// `/Volumes/CloudMachine` ended with `errno 6 ENXIO` ("Device not
/// configured") and Time Machine failed every run with
/// `BACKUP_FAILED_DISCONNECTED_DESTINATION`.
///
/// Meanwhile `mount` still showed the volume, `hdiutil info` still showed the
/// image, `ls` of the directory worked (from the kernel cache), and `statfs`
/// returned free space. Everything `isAttached` was built on said "OK". The
/// result: `drive-status` said "Image attached: OK", the GUI "Everything
/// uploaded", and the `gdrive-attach` agent reported "Already attached" every
/// 15 minutes and did NOT reattach. For 15 hours the only thing that cried out
/// was `backup-health` - after the fact, from the age of the last backup.
///
/// Measured on the dead device: `open()` of the directory - OK, `listdir` -
/// OK, `statvfs` - OK, `fsync` - OK, **`open`+`read` of 1 byte of a regular
/// file - ENXIO**. That is why the probe reads a byte. Nothing weaker tells a
/// live device from a dead one.
public enum ImageProbe {

  public enum Verdict: Equatable, Sendable {
    /// The read succeeded.
    case readable
    /// The device does not return data. `errno` from the failed read.
    case dead(errno: Int32)
    /// There is no regular file in the root directory that could be read -
    /// that is what a fresh volume looks like before the first backup. A
    /// failure cannot be established, so we do NOT report one.
    case nothingToProbe
    /// The probe DID NOT ANSWER within the allotted time.
    ///
    /// This is NOT `.dead`, and merging the two cases would be dangerous:
    /// `.dead` triggers a FORCED detach in `attach-image` of an image on which
    /// unsent data is still waiting, while here we do not even know whether
    /// the device is dead. A lack of knowledge must HOLD BACK an irreversible
    /// operation, not trigger it - that is why this verdict maps to
    /// `BackupImageService.Attachment.unknown`, which already blocks `attach`
    /// and `create`.
    case timedOut
  }

  /// Errors that mean "the device is gone", not "the file is odd".
  ///
  /// EACCES or EISDIR are a property of the file, not of the volume - we skip
  /// such a file and try the next one. ENXIO/EIO/ENODEV/ENOTCONN are the
  /// volume.
  static let deviceErrors: Set<Int32> = [ENXIO, EIO, ENODEV, ENOTCONN]

  /// Pure version: listing and reading are injected, so that a test can
  /// substitute ENXIO without breaking a real device.
  ///
  /// - `regularFiles`: regular files in the volume's root directory.
  /// - `readFirstByte`: returns the `errno` when the read fails.
  public static func probe(
    regularFiles: () throws -> [URL],
    readFirstByte: (URL) -> Int32?
  ) -> Verdict {
    let files: [URL]
    do {
      files = try regularFiles()
    } catch {
      // Listing can also fail on a dead device - and that is the case `try?`
      // used to swallow. `--dir-cache-time` is 5 minutes: while the cache is
      // fresh, `contentsOfDirectory` runs from kernel memory and works even
      // after ENXIO (hence the statement above that listing "is not a test").
      // Once the cache expires, the same listing goes to rclone for data and
      // fails with the same ENXIO as the read. Until 23 September 2026 the
      // probe then said `.nothingToProbe`, `BackupImageService.attachment`
      // mapped that to `.attached`, and the `gdrive-attach` agent reported
      // "Already attached" every 15 minutes - i.e. exactly the failure this
      // probe was created for came back through the back door after the
      // fifth minute.
      if let code = deviceErrno(of: error), deviceErrors.contains(code) {
        return .dead(errno: code)
      }
      // An error without a recognized device errno proves nothing about the volume.
      return .nothingToProbe
    }
    guard !files.isEmpty else { return .nothingToProbe }
    for file in files {
      guard let errno = readFirstByte(file) else { return .readable }
      if deviceErrors.contains(errno) { return .dead(errno: errno) }
      // An error specific to the file - try another one.
    }
    return .nothingToProbe
  }

  /// Extracts the raw `errno` from an error thrown by the directory listing.
  ///
  /// Foundation does not hand it over directly: `contentsOfDirectory` wraps
  /// the POSIX error in `NSCocoaErrorDomain` (e.g. 256
  /// `NSFileReadUnknownError`), and hides the original `errno` under
  /// `NSUnderlyingErrorKey` as `NSPOSIXErrorDomain`. We check three forms,
  /// because each comes from a different layer: `POSIXError` from code calling
  /// libc directly, `NSPOSIXErrorDomain` from a thin wrapper, and only then the
  /// nested one.
  static func deviceErrno(of error: Error) -> Int32? {
    if let posix = error as? POSIXError { return posix.code.rawValue }
    let ns = error as NSError
    if ns.domain == NSPOSIXErrorDomain { return Int32(ns.code) }
    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError,
      underlying.domain == NSPOSIXErrorDomain
    {
      return Int32(underlying.code)
    }
    return nil
  }

  // MARK: - Time limit
  //
  // WHY A THREAD SEPARATED BY A DEADLINE, AND NOT `ProcessRunner.run(timeout:)`
  //
  // The probe is a `readdir` plus `open`/`read` on a volume living on FUSE-T.
  // When rclone stops responding, these calls enter an UNINTERRUPTIBLE wait in
  // the kernel (state "U" in `ps`). Such a thread can be neither cancelled
  // nor killed: `Task.cancel()` is cooperative and `read()` in the kernel does
  // not cooperate with it, and SIGKILL does not work either - the same
  // limitation `ProcessRunner` already describes for its "final limit". Since
  // the probe cannot be INTERRUPTED, the only thing that can be guaranteed is
  // that its hang does not hang the CALLER. So the probe gets its own thread,
  // and the caller gets a deadline and the `.timedOut` verdict.
  //
  // That is also why there is not (and cannot be) a synchronous
  // `probe(volume:)` here - there was one until 26.09.2026 and it was exactly
  // what froze the panel on `@MainActor` and silenced the `backup-health`
  // watchdog permanently. The only entry point onto a live volume is `async`,
  // so that the caller waits without blocking a thread.
  //
  // Considered and REJECTED:
  //
  // - A probe in a SUBPROCESS via `ProcessRunner.run(..., timeout:)` - the
  //   pattern that saves `tmutil` in this repo. Here it buys exactly as much
  //   as a thread (a hang does not stop the caller), and costs much more: a
  //   new agent subcommand, finding the binary in three layouts (GUI bundle,
  //   `.build/` when working from the terminal, `/Applications` under
  //   launchd), a `fork`+`exec` every 10 s in the panel's refresh loop and -
  //   just like here - an orphaned process stuck in the kernel that nobody
  //   will kill. Three new places where the probe can silently stop working,
  //   for a gain limited to the stuck thread belonging to another process.
  //
  // - `open(..., O_NONBLOCK)`. On a REGULAR FILE O_NONBLOCK does not make
  //   `read()` non-blocking - it applies to FIFOs, sockets and character
  //   devices, not to waiting for file I/O; `readdir` does not even have such
  //   a variant. The probe would thus lose code clarity without gaining a
  //   guarantee, and would incidentally stop measuring what it exists for: the
  //   device HANDING OVER a byte.
  //
  // - A race between two `Task`s with `Task.sleep` and `cancel()` on the loser
  //   - see above, cancellation has no way to reach `read()` in the kernel. A
  //   thread from the `DispatchQueue.global()` pool is out for the same
  //   reason, only worse: a stuck thread stays occupied forever, and the pool
  //   has ~64 slots and is shared with the whole rest of the process.

  /// How long we wait for a verdict before declaring `.timedOut`.
  ///
  /// On a live volume the probe takes microseconds - one `readdir` and a read
  /// of one byte. So these 15 s are not a budget for work but a limit of
  /// patience. The lower bound is set by a LIVE but slow FUSE-T (a band being
  /// downloaded from the Drive during the read), which must not be taken for
  /// an unknown; the upper one - by what this limit exists for: on 25.09.2026
  /// `drive-status` hung for over 25 s and had to be killed by hand, and the
  /// `backup-health` watchdog runs every 1800 s, so the full 15 s will not come
  /// anywhere near its window anyway.
  public static let probeTimeout: TimeInterval = 15

  /// Verdict passed from the probing thread to the caller.
  ///
  /// Both sides must survive the absence of the other: the caller may give up
  /// on the deadline and never collect the verdict, and the thread may never
  /// reach `finish`, because it got stuck in the kernel.
  private final class ProbeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var verdict: Verdict?
    private var handler: ((Verdict) -> Void)?

    func finish(_ value: Verdict) {
      lock.lock()
      guard verdict == nil else {
        lock.unlock()
        return
      }
      verdict = value
      let waiting = handler
      handler = nil
      lock.unlock()
      waiting?(value)
    }

    /// Calls `handler` with the verdict - immediately if the probe managed to
    /// answer before the caller subscribed to the notification.
    func whenDone(_ handler: @escaping (Verdict) -> Void) {
      lock.lock()
      if let verdict {
        lock.unlock()
        handler(verdict)
        return
      }
      self.handler = handler
      lock.unlock()
    }
  }

  /// Which volumes currently have a probe in flight.
  private final class ProbeSlots: @unchecked Sendable {
    static let shared = ProbeSlots()
    private let lock = NSLock()
    private var busy: Set<String> = []

    /// `true` = the slot was free and from now on belongs to the caller.
    func claim(_ slot: String) -> Bool {
      lock.lock()
      defer { lock.unlock() }
      return busy.insert(slot).inserted
    }

    func release(_ slot: String) {
      lock.lock()
      busy.remove(slot)
      lock.unlock()
    }
  }

  /// Starts the probe on its OWN thread. `nil` = the probe for this slot is
  /// still running.
  ///
  /// One probe per slot is not an optimization. Without it, the GUI panel,
  /// which refreshes every 10 s, would leave one hanging thread per run on a
  /// permanently stuck volume - several hundred per hour, each with its own
  /// stack and none recoverable. A second thread would not learn anything new
  /// anyway: since the first one is stuck in the kernel, there is no answer,
  /// so the next caller gets `.timedOut` right away.
  private static func startProbe(
    slot: String,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32?
  ) -> ProbeBox? {
    guard ProbeSlots.shared.claim(slot) else { return nil }
    let box = ProbeBox()
    let thread = Thread {
      let verdict = probe(regularFiles: regularFiles, readFirstByte: readFirstByte)
      // Release the slot BEFORE handing over the verdict: otherwise a caller
      // woken by `finish` would see the slot as still occupied.
      ProbeSlots.shared.release(slot)
      box.finish(verdict)
    }
    thread.name = "com.renacode.cloudmachine.image-probe"
    thread.stackSize = 512 * 1024
    thread.start()
    return box
  }

  /// Probe on a live volume. After `timeout` it returns `.timedOut` and the
  /// caller moves on - the read itself may stay in the kernel forever and that
  /// is accepted, as long as it does not take the watchdog or the interface
  /// down with it.
  public static func probe(volume: URL, timeout: TimeInterval = probeTimeout) async -> Verdict {
    await probe(
      slot: volume.path, timeout: timeout,
      regularFiles: { try regularFiles(in: volume) },
      readFirstByte: { readFirstByteErrno(of: $0) })
  }

  /// As above, but with injected listing and reading - so that a test can
  /// substitute a probe that NEVER ANSWERS, without a dead volume at hand.
  /// `slot` is a separate parameter for the same reason: two tests must not
  /// occupy each other's slot.
  static func probe(
    slot: String,
    timeout: TimeInterval,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32?
  ) async -> Verdict {
    guard
      let box = startProbe(slot: slot, regularFiles: regularFiles, readFirstByte: readFirstByte)
    else { return .timedOut }
    return await withCheckedContinuation { (continuation: CheckedContinuation<Verdict, Never>) in
      let once = ContinuationGuard()
      box.whenDone { verdict in
        if once.claim() { continuation.resume(returning: verdict) }
      }
      DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
        if once.claim() { continuation.resume(returning: .timedOut) }
      }
    }
  }

  /// Regular files in the root directory. While the directory cache is fresh
  /// (`--dir-cache-time 5m`), listing runs from memory and works on a dead
  /// device too - that is why a successful listing alone is NOT proof of
  /// life, only a list of candidates for the test. Once the cache expires,
  /// the same listing fails with ENXIO and then it is proof of death - that
  /// is handled by `probe`, not by this function.
  static func regularFiles(in volume: URL) throws -> [URL] {
    try FileManager.default.contentsOfDirectory(
      at: volume, includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsSubdirectoryDescendants]
    )
    .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
  }

  /// `nil` = the read succeeded (an empty file too), otherwise `errno`.
  ///
  /// Via libc `open`/`read`, not via `Data(contentsOf:)`: Foundation reads the
  /// whole file, and we are interested in one byte and the raw errno.
  static func readFirstByteErrno(of file: URL) -> Int32? {
    let fd = open(file.path, O_RDONLY)
    guard fd >= 0 else { return errno }
    defer { close(fd) }
    var byte: UInt8 = 0
    let n = read(fd, &byte, 1)
    return n < 0 ? errno : nil
  }
}
