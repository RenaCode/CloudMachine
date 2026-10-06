import Foundation

/// The buffer between Time Machine and Google Drive - a port of `gdrive/mount-drive.sh`.
///
/// Mounts Drive as a volume with a local write cache. A write completes the
/// moment it reaches the cache, the upload goes on in the background - which
/// is why a broken link pauses the drain instead of interrupting the backup.
///
/// The rclone process stays in the foreground; launchd manages its life cycle
/// (KeepAlive).
public enum DriveBufferService {

  // MARK: - Paths and settings

  public static var root: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var mountPoint: URL { root.appendingPathComponent("drive") }
  public static var cacheDir: URL { root.appendingPathComponent("cache") }
  public static var logFile: URL { root.appendingPathComponent("rclone.log") }

  public static let remoteName = "gdrive"
  public static let remotePath = "CloudMachine/mac-studio"
  /// Buffer size. Kept as a number, because the watchdog's thresholds are
  /// derived from it - otherwise changing one without the other gives
  /// thresholds that never fire or fire immediately.
  public static let cacheSizeGB = 100
  public static var cacheSize: String { "\(cacheSizeGB)G" }

  /// How long rclone waits after a band's last change before uploading it.
  ///
  /// This is NOT a caution setting, but a bumper against write amplification.
  /// Time Machine rewrites the same bands throughout a run, and with a short
  /// delay every touch is a full 32 MB uploaded again. Measured on our own log
  /// (56,533 intervals between consecutive uploads of THE SAME band): the median
  /// interval is 9.5 minutes, so 10 minutes merges about half of the repeats.
  /// Going longer pays off less and less (15 min -> 57%, 30 min -> 70%), while
  /// the window in which data exists ONLY locally grows.
  ///
  /// History: it was 30 s, and with that value the day of 14/15 September 2026
  /// pushed 823 GB to Drive for about 45 GB of real change - i.e. over Google's
  /// daily limit (750 GB), which blocked the upload for several hours.
  ///
  /// Every shutdown path MUST force the upload via `expireQueuedUploads()`,
  /// otherwise a detach would wait as long as this delay.
  public static let writeBackSeconds = 600

  /// Address of rclone's remote control interface. It listens on loopback only,
  /// but any local process can control the mount through it - if we ever decide
  /// that is too loose, `--rc-user`/`--rc-pass` have to be added.
  public static let rcAddress = "127.0.0.1:5572"

  /// Above this size the rclone log is trimmed at start-up. rclone does not
  /// rotate its own log, and this project has already lost 3.3 GiB once to a log
  /// that grew without limit.
  private static let logSizeLimit: UInt64 = 100 * 1024 * 1024

  // MARK: - State

  /// Mount points straight from the kernel table. `nil` = the table COULD NOT
  /// be read, which is something else than "nothing is mounted".
  ///
  /// WHY NOT `/sbin/mount`
  ///
  /// Until 23 September 2026 this ran `/sbin/mount` with
  /// `readDataToEndOfFile()` + `waitUntilExit()` WITHOUT a time limit. With a
  /// dead FUSE-T mount (the ENXIO incident of 22.09) such a read can enter
  /// uninterruptible I/O and never return - and `isMounted` reads from here,
  /// i.e. the `backup-health` monitor AND the GUI refresh loop running every 10
  /// seconds. The hang thus froze both the view and the supervision, on the very
  /// failure both are meant to detect.
  ///
  /// Adding a time limit (as in `TimeMachineStatus.commandTimeout`) would remove
  /// the hang, but any such limit is pure cost here: with a refresh every 10 s
  /// the calls would start to overlap, and the answer would not come anyway.
  /// `getmntinfo(MNT_NOWAIT)` removes the problem at the source - it reads the
  /// mount table from kernel memory and does NOT query any file system (that is
  /// what `MNT_WAIT` does, which is exactly what could hang). There is no
  /// process, pipe or I/O here, so there is nothing to put a limit on. Measured
  /// on this machine: 19 mounts in 0.0002 s.
  ///
  /// Text parsing goes away as a bonus: `f_mntonname` is the path itself,
  /// instead of searching for `" on <path> "` in the output.
  public static func mountPoints() -> [String]? {
    var raw: UnsafeMutablePointer<statfs>?
    let count = getmntinfo(&raw, MNT_NOWAIT)
    guard count > 0, let raw else { return nil }
    return (0..<Int(count)).map { index in
      withUnsafePointer(to: raw[index].f_mntonname) {
        $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { String(cString: $0) }
      }
    }
  }

  /// Whether the buffer is mounted. `nil` = UNKNOWN.
  ///
  /// The distinction matters here, because the decision to attach and to create
  /// the image rests on this answer - and "I do not know" posing as "not
  /// mounted" is the same kind of silent failure that `UploadState.queueUnknown`
  /// already closes on the queue side.
  public static func mountedState() -> Bool? {
    guard let points = mountPoints() else { return nil }
    // The mount table is the source of truth - the directory merely existing
    // means nothing, because the mount point stays on disk after unmounting.
    return points.contains(mountPoint.path)
  }

  /// Shortcut for places where a failed read and "not mounted" mean the same
  /// thing - i.e. where we wait for the mount anyway or only print it.
  /// Wherever a DECISION follows from the answer, use `mountedState()`.
  public static var isMounted: Bool { mountedState() ?? false }

  // MARK: - Start-up

  /// Arguments for `rclone mount`. Split out so that they can be tested without
  /// running anything.
  public static func mountArguments() -> [String] {
    [
      "mount", "\(remoteName):\(remotePath)", mountPoint.path,
      "--vfs-cache-mode", "full",
      "--vfs-cache-max-size", cacheSize,
      // The cache must not evict data waiting to be uploaded - hence the high
      // age. Size is governed by --vfs-cache-max-size.
      "--vfs-cache-max-age", "9999h",
      "--vfs-write-back", "\(writeBackSeconds)s",
      "--vfs-cache-poll-interval", "1m",
      "--cache-dir", cacheDir.path,
      // ONLY this Mac writes to this folder, so change notifications from Drive
      // carry only our own uploads - and each one invalidates the `bands`
      // directory (18,853 files on 02.10.2026). The next `stat` reloaded it from
      // Google in pages of 1000, HOLDING the directory lock: for ~42 s out of every
      // minute every Getattr from FUSE (Time Machine, hdiutil), every `vfs/stats`
      // and every upload completion stood still. That is where the hung
      // `hdiutil attach`, `validateMountPoint timed out` in Time Machine and the red
      // panel came from. Without notifications and with a long cache the directory
      // loads once after start-up; rclone adds its own writes to it by itself.
      "--poll-interval", "0",
      "--dir-cache-time", "9999h",
      "--attr-timeout", "5m",
      "--transfers", "8",
      // Chunk size matched to the image's band size.
      "--drive-chunk-size", "32M",
      // Without this, deleted bands go to Drive's trash and keep counting
      // towards the storage limit.
      "--drive-use-trash=false",
      // After exceeding the daily 750 GB limit rclone is to stop, not spin in
      // 403s until the end of the world.
      "--drive-stop-on-upload-limit",
      "--volname", remoteName,
      "--rc", "--rc-addr", rcAddress, "--rc-no-auth",
      "--log-file", logFile.path,
      "--log-level", "INFO",
    ]
  }

  /// Prepares the environment and returns the arguments to run with. Does not
  /// start rclone itself - `cloudmachine-agent mount-drive` does that, and it
  /// has to stay in the foreground under launchd.
  public static func prepare() throws -> [String] {
    try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    rotateLogIfLarge()
    return mountArguments()
  }

  private static func rotateLogIfLarge() {
    guard
      let attrs = try? FileManager.default.attributesOfItem(atPath: logFile.path),
      let size = attrs[.size] as? UInt64, size > logSizeLimit
    else { return }
    let rotated = logFile.appendingPathExtension("1")
    try? FileManager.default.removeItem(at: rotated)
    try? FileManager.default.moveItem(at: logFile, to: rotated)
  }

  /// Excludes the buffer directory from Time Machine. The buffer holds a copy of
  /// the backup data - if Time Machine covered it, it would back up its own
  /// backup and grow forever. The exclusion is stored as an xattr on the
  /// directory, so it disappears together with it; that is why we renew it on
  /// every start-up, not once in setup.
  @discardableResult
  public static func excludeBufferFromTimeMachine() async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/tmutil", ["addexclusion", root.path], timeout: 30)
    return result?.succeeded == true
  }

  // MARK: - Upload queue

  public struct QueueStats {
    public var uploadsInProgress: Int
    public var uploadsQueued: Int
    public var files: Int
    public var erroredFiles: Int
    /// Buffer size according to rclone itself. Computing it with our own walk of
    /// the directory meant 6504 stat calls on every interface refresh, every 10
    /// seconds, on the same disk the backup is going to.
    public var bytesUsed: UInt64
    /// rclone has nowhere left to put data - it has not managed to upload what
    /// it holds, so there is nothing to evict. A stronger signal than any
    /// threshold, because it comes from the one who really knows.
    public var outOfSpace: Bool

    /// rclone is doing nothing RIGHT NOW. This is a STABILITY condition for
    /// `hdiutil` on a FUSE-T mount (see `retryingFlakyMount`) and nothing more -
    /// in particular it is NOT proof that the backup has reached Drive.
    public var isIdle: Bool { uploadsInProgress == 0 && uploadsQueued == 0 }

    /// Nothing is waiting AND nothing was abandoned along the way.
    ///
    /// Until 23 September 2026 this question had only one answer - the one now
    /// called `isIdle` - and it went into the detach message and into
    /// `safeToRebootNow()`. A band that rclone abandoned drops out of the queue
    /// exactly like an uploaded band: `uploadsQueued` returns to zero, and the
    /// only trace is left in `erroredFiles`. Result: "Detached, everything
    /// uploaded to Google Drive" and "Restart without asking: YES" with data
    /// existing only locally - while `UploadState`, from the same counters,
    /// already derived `.failedFiles(...)` and "ACTION NEEDED".
    public var isQuiet: Bool { isIdle && erroredFiles == 0 }

    /// How many items are WAITING to be uploaded: the queue plus what is
    /// uploading right now.
    ///
    /// This is the quantity from which the buffer watchdog derives its measure
    /// (see `BufferGuardService.backlogGB`) - and NOT `bytesUsed`. The cache size
    /// with `--vfs-cache-max-size 100G` and `--vfs-cache-max-age 9999h` sits at
    /// the limit permanently (281 measurements in the journal, minimum 99 GB),
    /// because rclone also keeps there what it uploaded long ago. The unsent
    /// backlog is the only one of these two numbers that answers the question
    /// "is the upload keeping up".
    ///
    /// `uploadsInProgress` is part of the sum, because an item being uploaded is
    /// not on Drive yet either and also takes up the buffer. With `--transfers 8`
    /// that is at most eight items, but an empty queue with eight transfers in
    /// progress is not a zero backlog.
    public var unsentItems: Int { uploadsQueued + uploadsInProgress }
  }

  /// Reads the queue state through rclone's remote control interface.
  ///
  /// NOTE: `--rc-no-auth` is a SERVER flag. The `rclone rc` client does not
  /// accept it and ends with an "unknown flag" error - this has already cost one
  /// silent breakage of the status view.
  ///
  /// Time limit 60 s, not 30 s: on 23.09.2026 the same call took **36.7 s** with
  /// a clogged buffer (the next one 0.03 s - so sporadic, under load). With 30 s
  /// it ended with `nil`, and `nil` went on as a set of zeros and the interface
  /// announced "Everything uploaded" with 386 bands in the queue. Raising the
  /// limit alone does not fix that - that is what `UploadState.queueUnknown` is
  /// for - but it means the question usually gets an answer.
  ///
  /// Higher is not worth it. The interface refresh loop runs every 10 s and
  /// waits for this read, and `drive-status` asks twice (the second time via
  /// `safeToRebootNow`). With a dead rclone every second of the limit is a
  /// second of a frozen window, and the answer will not come anyway.
  public static func queueStats() async -> QueueStats? {
    guard
      let result = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/stats"], timeout: 60),
      result.succeeded
    else { return nil }
    return parseQueueStats(result.stdout)
  }

  /// Pure version of parsing the `vfs/stats` response. `nil` means "I do not
  /// know", never "all zeros".
  ///
  /// Split out so that it can be tested - until now the parsing sat in an async
  /// function calling rclone and there was no way to reach it other than
  /// running the whole buffer.
  ///
  /// Two things that were here and had to go:
  ///
  /// 1. `(json["diskCache"] as? [String: Any]) ?? json` - a response WITHOUT the
  ///    `diskCache` section (rclone built without the disk cache, a different
  ///    interface version, a truncated response) fell through to `json`, where
  ///    none of the counters are.
  /// 2. `number(_:in:)` returning 0 for a missing key.
  ///
  /// Together they gave `QueueStats` with all zeros instead of `nil`, i.e.
  /// `queueKnown == true` and again the "Everything uploaded to Google Drive"
  /// screen. It is the same pattern that was fixed above by
  /// `UploadState.queueUnknown`, just moved one step - into the parsing.
  static func parseQueueStats(_ raw: String) -> QueueStats? {
    guard
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      // vfs/stats returns the counters nested in the "diskCache" section. Its
      // absence is no answer to the question asked, not the answer "zero".
      let disk = json["diskCache"] as? [String: Any]
    else { return nil }

    func number(_ key: String) -> Int? {
      if let v = disk[key] as? Int { return v }
      if let v = disk[key] as? NSNumber { return v.intValue }
      return nil
    }

    guard
      let inProgress = number("uploadsInProgress"),
      let queued = number("uploadsQueued"),
      let files = number("files"),
      let errored = number("erroredFiles"),
      let bytesUsed = number("bytesUsed")
    else { return nil }

    return QueueStats(
      uploadsInProgress: inProgress,
      uploadsQueued: queued,
      files: files,
      erroredFiles: errored,
      bytesUsed: UInt64(max(0, bytesUsed)),
      // The only field whose absence may be made up with a default: it is a
      // flag, not a counter - older rclone does not expose it, and its absence
      // cannot be mistaken for "buffer full".
      outOfSpace: (disk["outOfSpace"] as? Bool) ?? false
    )
  }

  /// Google Drive account capacity, straight from rclone.
  ///
  /// NOBODY checked this until now. `machines.json` has the fields
  /// `drive_total_gb` and `limit_gb`, but not a single line of code outside the
  /// model itself uses them - it was a budget on paper. Meanwhile running out of
  /// space on Drive is a FATAL error for rclone (`--drive-stop-on-upload-limit` +
  /// `storageQuotaExceeded`): the mount disappears and Time Machine loses its
  /// destination. With growth of around 600 MB per hourly cycle this is not a
  /// distant problem, only a matter of the date.
  public static func remoteQuota() async -> (used: UInt64, total: UInt64, free: UInt64)? {
    guard
      let result = try? await CMTooling.runRclone(
        ["about", "--json", "\(remoteName):"], timeout: 120),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    func bytes(_ key: String) -> UInt64? {
      if let v = json[key] as? NSNumber, v.int64Value >= 0 { return UInt64(v.int64Value) }
      return nil
    }
    // `total` is sometimes absent (accounts without a limit) - then there is nothing to watch.
    guard let total = bytes("total"), total > 0 else { return nil }
    let used = bytes("used") ?? 0
    let free = bytes("free") ?? (total > used ? total - used : 0)
    return (used, total, free)
  }

  /// Waits until rclone stops uploading anything. `hdiutil` operations on a
  /// FUSE-T mount are stable only with an empty queue - see
  /// `BackupImageService.retryingFlakyMount`.
  ///
  /// The condition is `isIdle`, NOT `isQuiet`: bands abandoned by rclone stay in
  /// `erroredFiles` until the process ends, so waiting for `isQuiet` would never
  /// finish and every attach would pay the full time limit for nothing.
  ///
  /// Returns the queue reading from the moment it went quiet - `nil` when it did
  /// not go quiet in time or rclone did not answer. The caller gets it so that it
  /// can check `erroredFiles` without asking rclone the same question a second
  /// time (costs up to 60 s - see `queueStats`).
  @discardableResult
  public static func statsWhenIdle(timeout: TimeInterval = 180) async -> QueueStats? {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if let stats = await queueStats(), stats.isIdle { return stats }
      try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
    return nil
  }

  /// Like `statsWhenIdle`, when the caller only cares about "it got there".
  @discardableResult
  public static func waitUntilIdle(timeout: TimeInterval = 180) async -> Bool {
    await statsWhenIdle(timeout: timeout) != nil
  }

  /// Moves the upload deadline of all waiting items to "now".
  ///
  /// Needed on EVERY shutdown. An item enters the queue right after the write -
  /// it is visible in `vfs/queue` immediately - but with a due date
  /// `writeBackSeconds` ahead. Without moving it a detach would wait those whole
  /// ten minutes, and `prepare-shutdown` before a Mac restart would become
  /// unbearable. This is not cosmetic: a user who does not want to wait will
  /// shut down the Mac without `prepare-shutdown`, and that has already once left
  /// Time Machine without a destination for a whole night.
  ///
  /// Call AFTER the writes from the detach have had time to reach the queue -
  /// items added later will not be touched.
  ///
  /// Returns `ExpiryOutcome` - how many items we FOUND and for how many the
  /// deadline was moved - or `nil` when rclone did not answer the question about
  /// the queue.
  ///
  /// `nil` and `0` are TWO DIFFERENT THINGS, and that is why the type is
  /// optional. Until 23 September 2026 both situations - "the queue was empty"
  /// and "we got no answer" - came out of here as `0`, so `detach` stayed silent
  /// in the log in exactly the case where the deadlines were NOT moved and the
  /// drain could take the whole `writeBackSeconds` (ten minutes) instead of a
  /// moment.
  ///
  /// The number of moved items alone is not enough, because a THIRD case looks
  /// like the first: when the queue has items but every `vfs/queue-set-expiry`
  /// fails, "moved 0" was indistinguishable from "there was nothing to move".
  /// That is why `queued` and `moved` are separate - see
  /// `BackupImageService.expiryLogLine`.
  ///
  /// The limit for listing the queue itself raised from 30 s to 60 s: this same
  /// file documents a measurement of **36.7 s** for the LIGHTER `vfs/stats` with
  /// a clogged buffer (see `queueStats`), and `vfs/queue` lists hundreds of items
  /// at such times. With 30 s the answer failed to arrive exactly when moving
  /// the deadlines was needed most.
  ///
  /// The limit for a single `queue-set-expiry` stays at 30 s ON PURPOSE: that
  /// one call decides the whole function, while this is one of hundreds and
  /// losing it costs one item. With several hundred items a 60 s ceiling per
  /// item would turn the detach into an operation without an upper time bound.
  /// How many items to speed up were in the queue and for how many the deadline
  /// was ACTUALLY moved. Two fields, not one, because "zero" means something
  /// different depending on how many attempts there were - see
  /// `expireQueuedUploads`.
  public struct ExpiryOutcome: Sendable, Equatable {
    /// Items found in the queue that could be sped up (without those already
    /// uploading - see `parseQueueIDs`).
    public var queued: Int
    /// How many of them rclone confirmed.
    public var moved: Int

    public init(queued: Int, moved: Int) {
      self.queued = queued
      self.moved = moved
    }
  }

  @discardableResult
  public static func expireQueuedUploads() async -> ExpiryOutcome? {
    guard
      let result = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/queue"], timeout: 60),
      result.succeeded,
      let ids = parseQueueIDs(result.stdout)
    else { return nil }

    var moved = 0
    for id in ids {
      // A large negative number instead of zero - that is how rclone itself describes it.
      let response = try? await CMTooling.runRclone(
        ["rc", "--url", rcAddress, "vfs/queue-set-expiry", "id=\(id)", "expiry=-1000000000"],
        timeout: 30)
      if response?.succeeded == true { moved += 1 }
    }
    return ExpiryOutcome(queued: ids.count, moved: moved)
  }

  /// Pure version: IDs of items from the `vfs/queue` response whose deadline can
  /// be moved. `nil` = the response cannot be read, `[]` = the queue is empty.
  /// Split out so that this distinction can be tested.
  static func parseQueueIDs(_ raw: String) -> [Int]? {
    guard
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let queue = json["queue"] as? [[String: Any]]
    else { return nil }

    return queue.compactMap { item in
      // An item already uploading cannot be sped up - rclone ignores it, so we
      // do not waste a call on it.
      if (item["uploading"] as? Bool) == true { return nil }
      return (item["id"] as? NSNumber)?.intValue
    }
  }

  /// DISK SPACE TAKEN by the buffer directory. `nil` = NOT MEASURED.
  ///
  /// Normally rclone itself reports the cache size (`QueueStats.bytesUsed`):
  /// walking the directory is 6504 stat calls, and with a refresh every 10
  /// seconds needless load on the disk the backup is going to.
  ///
  /// NOTE: this is NOT a fallback for the measure the watchdog makes decisions
  /// on, and must not be substituted there. Two reasons, both measured:
  ///
  /// 1. This function counts DISK SPACE TAKEN (`totalFileAllocatedSize`), a
  ///    quantity NOT COMPARABLE with the `--vfs-cache-max-size` limit - it can
  ///    exceed it. Hence "buffer 155 GB" with a 100 GB limit in the only PAUSE
  ///    line in the whole journal (23.09.2026 03:34). An hour later the monitor
  ///    wrote "rclone remote control is not answering": a missing answer was
  ///    replaced with a number from a DIFFERENT measure, and that number
  ///    triggered an irreversible pause.
  /// 2. When the walk fails (permission denied, `~/.cloudmachine` gone), the
  ///    result `0` looks like an EMPTY buffer, i.e. like a met condition for
  ///    resuming a Time Machine that was paused because the buffer was full.
  ///    Exactly this pattern was closed by `BufferGuardService.freeGB()` for
  ///    `statfs` - hence `nil` here, not zero.
  ///
  /// So it is left for ONE thing: telling a person how much disk space the
  /// cache takes. No decision reads it.
  public static func cacheSizeBytesByWalk() -> UInt64? {
    guard
      let enumerator = FileManager.default.enumerator(
        at: cacheDir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey],
        options: [.skipsHiddenFiles])
    else { return nil }
    var total: UInt64 = 0
    for case let url as URL in enumerator {
      let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
      total += UInt64(values?.totalFileAllocatedSize ?? 0)
    }
    return total
  }

  /// Whether rclone stopped on the Google Drive daily limit (750 GB/day).
  ///
  /// We recognise it by rclone's BEHAVIOUR, not by the error text. The reason is
  /// concrete: `403 userRateLimitExceeded` is a momentary rate throttle that
  /// rclone retries by itself ("will retry in 1m0s"), but it describes it with
  /// the message "Received upload limit error" - indistinguishable by text alone
  /// from the daily limit. The first version of this function caught exactly
  /// that and paused the backup after 109 GiB uploaded, i.e. at a seventh of the
  /// limit.
  ///
  /// The real limit is fatal for rclone (`--drive-stop-on-upload-limit` acts
  /// exactly on `storageQuotaExceeded` and `teamDriveFileLimitExceeded`), so the
  /// process exits and the mount disappears.
  ///
  /// NOTE: do NOT add a condition "only when the mount is down" here. Such a
  /// version was here and it was dead: the `gdrive-buffer` agent has `KeepAlive`
  /// with a `ThrottleInterval` of 30 s, so launchd brings rclone back faster than
  /// the buffer watchdog manages to tick (every 30 s). The window in which the
  /// mount is actually gone is shorter than the polling period - detecting the
  /// limit was a coin toss, and in practice never happened at all. Recognising
  /// it by a FRESH log entry works regardless of whether launchd has already
  /// resurrected the mount.
  ///
  /// The momentary throttle (`userRateLimitExceeded`) is still NOT caught here -
  /// see `logMentionsUploadLimit`. That is what once paused the backup after
  /// 109 GiB, and that is what the caution was about, not the mount state.
  ///
  /// `nil` = THE LOG CANNOT BE READ, which is something else than "no trace of
  /// the limit". Previously both cases came out of here as `false`, i.e. as the
  /// answer "no problem" to a question that had no answer - and the watchdog
  /// then does not pause the backup for lack of space on Drive. This is not
  /// theoretical: the rclone log has `-rw-r-----` permissions, and at start-up
  /// it is moved to `.1` (see `rotateLogIfLarge`).
  public static func hitStorageQuotaState(logFile: URL? = nil) -> Bool? {
    guard let text = recentLog(bytes: 256 * 1024, from: logFile ?? Self.logFile) else {
      return nil
    }
    return logMentionsUploadLimit(text, now: Date(), within: 30)
  }

  /// Version FOR SHOWING TO A PERSON, where there is no place to put a third
  /// state (`BufferStatus.driveFull`, `UploadState.from`).
  ///
  /// NO DECISION may use it: `?? false` is exactly the substitution described in
  /// the comment above. The buffer watchdog reads `hitStorageQuotaState()` and
  /// decides itself what to do with "I do not know". A third state in the
  /// interface requires changing `BufferStatus` and `CloudMachineController` -
  /// that is a separate change, outside this branch.
  public static func hitStorageQuota() -> Bool { hitStorageQuotaState() ?? false }

  /// Whether the upload is actually STALLED - recognised by behaviour, not by
  /// text.
  ///
  /// Google's daily upload limit (750 GB) reports itself as `403
  /// userRateLimitExceeded`, i.e. with EXACTLY the same code as an ordinary
  /// momentary rate throttle. They cannot be told apart by text and one should
  /// not try - the first version of `logMentionsUploadLimit` tried and paused the
  /// backup after 109 GiB of 750 GB.
  ///
  /// What does tell them apart is the RATIO of successes to errors in a time
  /// window. Measured on our own log:
  ///   - throttling:  11 Sep 14h -> 4833, 12 Sep 09h -> 1.07, 15 Sep 08h -> 2.39
  ///   - real jam: 12 Sep 10-12h -> 0.002-0.011, 15 Sep 09h -> 0.003
  /// TWO ORDERS OF MAGNITUDE lie between one and the other, so the 0.1 threshold
  /// has margin both ways.
  ///
  /// `minErrors` protects against silence: a window without traffic has zero
  /// errors and zero successes, and that is not a jam.
  ///
  /// `nil` = THE LOG CANNOT BE READ. The distinction is more dangerous here than
  /// for the measurement itself: `false` went on to `reportUploadStall`, which
  /// REMOVED the jam marker and wrote "Upload to Google Drive has resumed" - a
  /// claim about an event nobody checked, based on a file nobody read.
  public static func uploadStalledState(logFile: URL? = nil) -> Bool? {
    // A bigger window than for the text test: during a jam the log grows by
    // about 90 KB per minute, so 256 KB would show only the last three minutes
    // and the ratio would be computed from a sample without a single success.
    guard let text = recentLog(bytes: 4 * 1024 * 1024, from: logFile ?? Self.logFile) else {
      return nil
    }
    return logShowsUploadStalled(text, now: Date(), within: 30)
  }

  /// Version for showing to a person - see `hitStorageQuota()`, same reason and
  /// same warning: no decision reads this version.
  public static func uploadStalled() -> Bool { uploadStalledState() ?? false }

  /// Combined answer "the upload to Drive is not going" - for showing to the
  /// user. The buffer watchdog does NOT use this function, because for it the
  /// difference between the two is fundamental: lack of space will not pass by
  /// itself, while the daily limit passes within a few hours.
  public static func hitDailyQuota() -> Bool {
    hitStorageQuota() || uploadStalled()
  }

  /// Tail of the rclone log as text. `nil` = the file CANNOT BE READ: it does not
  /// exist, there is no permission for it, or the read failed.
  ///
  /// The caller MUST pass that `nil` on as "I do not know". No limit entries and
  /// no access to the log are two different things, and only the first means "no
  /// problem". The file is taken from a parameter so that both questions asked of
  /// this log can be tested on our own file - without `~/.cloudmachine` and
  /// without guessing permissions.
  private static func recentLog(bytes: UInt64, from file: URL) -> String? {
    guard let handle = try? FileHandle(forReadingFrom: file) else { return nil }
    defer { try? handle.close() }
    let size = (try? handle.seekToEnd()) ?? 0
    try? handle.seek(toOffset: size > bytes ? size - bytes : 0)
    guard let data = try? handle.readToEnd() else { return nil }
    // The tail almost always starts in the middle of a multi-byte character, so
    // we decode lossily - otherwise the whole read would be lost to one byte.
    return String(decoding: data, as: UTF8.self)
  }

  /// The locale we read rclone log timestamps with.
  ///
  /// `en_US_POSIX`, NOT `Locale.current`. A `DateFormatter` with a fixed
  /// `dateFormat` and the default locale takes the calendar from that locale: on
  /// a machine with the Buddhist calendar (`th_TH`) "2026" means the Buddhist
  /// year, i.e. Gregorian 1483, and with the Persian or Hijri calendar yet
  /// another date comes out. The timestamp then parses WITHOUT AN ERROR and lands
  /// 543 years too early, so `stamp < cutoff` ends the loop on the first line,
  /// `errors` stays zero and `uploadStalled()` reports "no jam" exactly when the
  /// jam is going on - and on that basis the buffer watchdog does not pause Time
  /// Machine.
  ///
  /// The same class of bug as `LC_ALL=C` forced in `CMLock` (see the description
  /// of the real incident there): machine text is read with the machine's
  /// settings, not the person's.
  public static let rcloneLogLocale = Locale(identifier: "en_US_POSIX")

  /// Pure version of jam detection - counts successes and errors in the window.
  ///
  /// A success is a `... : Copied (...)` line, an error `Received upload limit
  /// error`. Both come from the same log and the same event, so the ratio needs
  /// no calibration between machines.
  ///
  /// `locale` exists only so that a test can inject a KNOWN BAD calendar - see
  /// `rcloneLogLocale`. Production code does not pass it.
  public static func logShowsUploadStalled(
    _ text: String, now: Date, within minutes: Int,
    minErrors: Int = 300, maxSuccessRatio: Double = 0.1,
    locale: Locale = DriveBufferService.rcloneLogLocale
  ) -> Bool {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    let cutoff = now.addingTimeInterval(-Double(minutes) * 60)

    var errors = 0
    var successes = 0
    for line in text.components(separatedBy: .newlines).reversed() {
      guard line.count > 19, let stamp = formatter.date(from: String(line.prefix(19))) else {
        continue
      }
      // The log is chronological, so the first line older than the window ends
      // the counting - everything further back is older still.
      if stamp < cutoff { break }
      let lower = line.lowercased()
      if lower.contains("received upload limit error") {
        errors += 1
      } else if lower.contains(": copied (") {
        successes += 1
      }
    }

    guard errors >= minErrors else { return false }
    return Double(successes) < maxSuccessRatio * Double(errors)
  }

  /// Looks for a trace of the limit only in fresh entries. Without a time bound
  /// an alarm once raised would never go out, because the entry stays in the log
  /// forever - the backup would fall into a pause-resume-pause cycle.
  ///
  /// A pure version, so that it can be tested without a file and without a clock.
  ///
  /// `locale` as in `logShowsUploadStalled` - for tests only.
  public static func logMentionsUploadLimit(
    _ text: String, now: Date, within minutes: Int,
    locale: Locale = DriveBufferService.rcloneLogLocale
  ) -> Bool {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    let cutoff = now.addingTimeInterval(-Double(minutes) * 60)

    for line in text.components(separatedBy: .newlines).reversed() {
      guard line.count > 19, let stamp = formatter.date(from: String(line.prefix(19))) else {
        continue
      }
      if stamp < cutoff { return false }
      let lower = line.lowercased()
      // userRateLimitExceeded deliberately SKIPPED - it is an ordinary throttle
      // that rclone retries by itself. Catching it paused the backup at 109 GiB of
      // 750 GB.
      if lower.contains("storagequotaexceeded") || lower.contains("teamdrivefilelimitexceeded") {
        return true
      }
    }
    return false
  }
}
