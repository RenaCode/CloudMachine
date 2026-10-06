import Foundation

/// Keeps the buffer from eating the disk - a port of `gdrive/buffer-guard.sh`.
///
/// Time Machine writes to the attached image at SSD speed (measured 267 MB/s),
/// while rclone uploads at link speed (~41 MB/s with a 332 Mb/s upload). The
/// difference lands in the buffer.
///
/// `--vfs-cache-max-size` is a SOFT limit: rclone evicts from the buffer only
/// data already uploaded, so when everything is waiting in the queue the
/// buffer keeps growing and can fill the disk. With a first backup measured in
/// terabytes this is not theory - the measured net growth at the start was
/// 32 MB/s.
///
/// The watchdog pauses Time Machine when the UNSENT BACKLOG exceeds a
/// threshold, and resumes it when the upload catches up. The backup becomes
/// slower, but it finishes instead of crashing the machine.
///
/// Three things you need to know here, because each was once done the other
/// way round and each cost the whole protection:
///
/// 1. We measure the BACKLOG, not the cache size. The cache size sits at the
///    limit permanently and does not answer whether the upload is keeping up
///    (see `backlogGB` and `Thresholds.init`).
/// 2. "I do not know" is neither a pause nor a resume. No answer from rclone
///    is not turned into a number, and an unreadable rclone log is not turned
///    into "no problem".
/// 3. A pause lasts as long as we keep it up. `tmutil stopbackup` cancels the
///    RUNNING backup and does not touch the schedule, so macOS starts another
///    one in its hourly cycle - which is why the pause is repeated on every
///    tick, not only on a state change (see `keepPaused`).
public actor BufferGuardService {

  public struct Thresholds: Sendable {
    /// Above this many GB of UNSENT BACKLOG we pause Time Machine.
    ///
    /// Backlog, not cache size - see `backlogGB` for the reason.
    public var highGB: Int
    /// Below this many GB of backlog we resume.
    public var lowGB: Int
    /// Below this many GB free on disk we pause regardless of the buffer.
    public var minFreeGB: Int
    /// Below this many GB free ON GOOGLE DRIVE a pause put in place because of
    /// lack of space on Drive must not be lifted.
    ///
    /// The same number that `BackupHealth` considers the warning threshold for
    /// Drive - one source of truth. With growth of around 600 MB per hourly
    /// cycle, 30 GB is about two weeks of headroom, i.e. enough for the resumed
    /// backup to have room, rather than hitting the wall again in the next hour.
    public var minDriveFreeGB: Int

    /// Thresholds derived from the buffer size, not typed in by hand - but
    /// computed ANEW since the watchdog measures the unsent backlog rather than
    /// the cache size. The old 1.5x and 0.4x of `cacheSizeGB` are not carried
    /// over, because they referred to a different quantity and mean nothing in
    /// this one.
    ///
    /// WHAT WAS WRONG
    ///
    /// The old pair (150 GB / 40 GB) referred to `bytesUsed`, i.e. the size of
    /// the WHOLE cache. With `--vfs-cache-max-size 100G` and
    /// `--vfs-cache-max-age 9999h` that sits at the limit permanently: 281
    /// measurements in the journal, minimum 99 GB. The 40 GB resume threshold
    /// was therefore UNREACHABLE, and the 150 GB pause threshold reachable only
    /// through the result of the directory walk, i.e. through a DIFFERENT
    /// measure. The log shows it plainly: ONE PAUSE line (23.09.2026 03:34,
    /// "buffer 155 GB") and ZERO RESUME lines.
    ///
    /// WHY THE THRESHOLDS ARE A FRACTION OF `cacheSizeGB`, BUT BELOW IT
    ///
    /// The unsent backlog is exactly the part of the cache that rclone CANNOT
    /// evict - it only evicts what it has already uploaded. As long as the
    /// backlog is smaller than `cacheSizeGB`, the cache has something to shrink
    /// from and the limit works. When the backlog reaches `cacheSizeGB`, there is
    /// no headroom and every further gigabyte written goes OVER the limit,
    /// straight into free disk space. So the pause threshold must lie BELOW the
    /// cache size - unlike the old 150 GB, which lay above it.
    ///
    /// `highGB` = half the buffer, 50 GB today:
    ///  - leaves 50 GB of evictable headroom, i.e. about 26 minutes at the
    ///    measured net growth of 32 MB/s - with margin for a tick every 30 s and
    ///    for `tmutil stopbackup` to take effect;
    ///  - lies more than three times above the highest backlog seen in normal
    ///    operation (462 items, i.e. about 15 GB), so neither an ordinary backup
    ///    nor a jam on Google's daily limit pauses the backups. The latter is
    ///    intended and described below in `step()`.
    ///
    /// `lowGB` = a tenth of the buffer, 10 GB today:
    ///  - must be REACHABLE, because that is what the previous version tripped
    ///    over. After a pause no new bands are created, the `writeBackSeconds`
    ///    delay passes and the queue drains at link speed (measured 23.09:
    ///    96 Mb/s, i.e. about 43 GB/h), so the way from 50 -> 10 GB is about an
    ///    hour;
    ///  - a 40 GB hysteresis is, at the measured speed difference (267 MB/s of
    ///    Time Machine writes, 41 MB/s of upload, 226 MB/s net), about three
    ///    minutes of work between consecutive pauses. A resume threshold close to
    ///    the pause threshold would give start/stop on almost every tick.
    ///
    /// Disk protection does NOT depend on these two numbers: `minFreeGB` and the
    /// `outOfSpace` reported by rclone work independently of the backlog and in
    /// EVERY watchdog state (see `step()`).
    public init(
      highGB: Int = DriveBufferService.cacheSizeGB / 2,
      lowGB: Int = DriveBufferService.cacheSizeGB / 10,
      minFreeGB: Int = 80,
      minDriveFreeGB: Int = BackupHealth.driveFreeWarningGB
    ) {
      self.highGB = highGB
      self.lowGB = lowGB
      self.minFreeGB = minFreeGB
      self.minDriveFreeGB = minDriveFreeGB
    }
  }

  public enum State: String, Sendable {
    /// We are supervising a running backup.
    case running
    case pausedForBuffer
    case pausedForQuota
    /// No backup running - we keep watch until the next one.
    ///
    /// The watchdog does NOT exit after a finished backup. It runs under
    /// launchd with KeepAlive, so exiting would mean an immediate restart, and
    /// with Time Machine not working - a tight restart loop limited only by
    /// ThrottleInterval.
    case idle
  }

  public struct Snapshot: Sendable {
    public var state: State
    /// Unsent backlog in GB. `nil` = rclone did not answer, i.e. UNKNOWN - and
    /// then the watchdog NEITHER pauses NOR resumes the backup.
    public var backlogGB: Int?
    /// `nil` = there was NO measurement (statfs failed), not "zero gigabytes".
    public var freeGB: Int?
    /// `nil` = tmutil did not answer, i.e. unknown.
    public var backupRunning: Bool?
    public var percent: Double
  }

  /// Sources of measurements and control.
  ///
  /// The defaults (`live`) read the real system. A test substitutes its own and
  /// thanks to that walks the WHOLE decision path of the watchdog - pause, state
  /// change, resume - without tmutil, rclone and a real backup. The same pattern
  /// as `preferencesFile` in `BackupHealth.currentReport`: there is no other way
  /// to inject a KNOWN BAD sample, and it is precisely in the watchdog's
  /// decisions (not in parsing) that the silent failures lived here.
  public struct Probes: Sendable {
    public var queueStats: @Sendable () async -> DriveBufferService.QueueStats?
    /// Cache size on disk - ONLY for one line in the log.
    ///
    /// A separate probe rather than a call in place, for two reasons. First:
    /// we call it only when reporting that rclone is not answering, because in
    /// the `live` version it is a walk of 6504 files on the disk the backup is
    /// going to. Second: the test must be able to show that this number takes
    /// part in NO decision - it feeds it the 155 GB from the production run of
    /// 23.09 and checks that the watchdog still does not pause Time Machine.
    public var cacheSizeGB: @Sendable (DriveBufferService.QueueStats?) -> Int?
    /// `nil` = not measured.
    public var freeGB: @Sendable () -> Int?
    /// `nil` = tmutil did not answer.
    public var backupRunning: @Sendable () async -> Bool?
    public var progressPercent: @Sendable () async -> Double
    /// Whether Google Drive has run out of space. `nil` = THE RCLONE LOG CANNOT
    /// BE READ, i.e. unknown - not "no problem".
    public var hitStorageQuota: @Sendable () -> Bool?
    /// Whether the upload is stuck on the daily limit. `nil` as above.
    public var uploadStalled: @Sendable () -> Bool?
    /// Free bytes on Google Drive. `nil` = UNKNOWN (rclone did not answer) -
    /// and that is not consent to resume.
    public var driveFreeBytes: @Sendable () async -> UInt64?
    /// `true` ONLY when tmutil confirmed that the command was carried out.
    public var stopBackup: @Sendable () async -> Bool
    public var startBackup: @Sendable () async -> Bool
    /// Reporting an upload jam. `nil` ("I do not know") HAS NO RIGHT to clear
    /// the jam marker - see `reportUploadStall`.
    public var reportStall: @Sendable (Bool?) async -> Void
    /// Split out so that a test does not append its made-up "PAUSE (threshold)"
    /// to the production `cloudmachine.log` - that log serves to diagnose real
    /// failures and must not contain events that did not happen.
    public var log: @Sendable (String) -> Void

    public init(
      queueStats: @escaping @Sendable () async -> DriveBufferService.QueueStats?,
      cacheSizeGB: @escaping @Sendable (DriveBufferService.QueueStats?) -> Int?,
      freeGB: @escaping @Sendable () -> Int?,
      backupRunning: @escaping @Sendable () async -> Bool?,
      progressPercent: @escaping @Sendable () async -> Double,
      hitStorageQuota: @escaping @Sendable () -> Bool?,
      uploadStalled: @escaping @Sendable () -> Bool?,
      driveFreeBytes: @escaping @Sendable () async -> UInt64?,
      stopBackup: @escaping @Sendable () async -> Bool,
      startBackup: @escaping @Sendable () async -> Bool,
      reportStall: @escaping @Sendable (Bool?) async -> Void,
      log: @escaping @Sendable (String) -> Void
    ) {
      self.queueStats = queueStats
      self.cacheSizeGB = cacheSizeGB
      self.freeGB = freeGB
      self.backupRunning = backupRunning
      self.progressPercent = progressPercent
      self.hitStorageQuota = hitStorageQuota
      self.uploadStalled = uploadStalled
      self.driveFreeBytes = driveFreeBytes
      self.stopBackup = stopBackup
      self.startBackup = startBackup
      self.reportStall = reportStall
      self.log = log
    }

    public static let live = Probes(
      queueStats: { await DriveBufferService.queueStats() },
      cacheSizeGB: { BufferGuardService.cacheSizeGB(stats: $0) },
      freeGB: { BufferGuardService.freeGB() },
      backupRunning: { await TimeMachineStatus.runningState() },
      progressPercent: { (await TimeMachineStatus.currentProgress())?.percent ?? 0 },
      // The `...State()` versions, not `hitStorageQuota()`/`uploadStalled()`:
      // the latter are for display and turn "I do not know" into `false`.
      hitStorageQuota: { DriveBufferService.hitStorageQuotaState() },
      uploadStalled: { DriveBufferService.uploadStalledState() },
      driveFreeBytes: { await DriveBufferService.remoteQuota()?.free },
      stopBackup: { await BufferGuardService.tmutil("stopbackup") },
      startBackup: { await BufferGuardService.tmutil("startbackup") },
      reportStall: { await BufferGuardService.reportUploadStall($0) },
      log: { CMLogger.log($0) })
  }

  private let thresholds: Thresholds
  private let probes: Probes
  private var state: State = .idle
  /// Whether since the last transition to idle we have seen a running backup -
  /// so that the end is reported once, not on every tick.
  private var sawBackupRunning = false
  /// Whether the previous step already reported a failed pause - so that with a
  /// failure lasting hours the log does not grow by a line every 30 seconds,
  /// but the event itself does NOT disappear (see `EdgeTriggeredLog`, same
  /// reason).
  private var reportedStopFailure = false
  /// The same for a missing free-space measurement.
  private var reportedFreeUnknown = false
  /// The same for no answer about the unsent backlog.
  private var reportedBacklogUnknown = false
  /// The same for an unreadable rclone log.
  private var reportedLogUnreadable = false
  /// The same for Time Machine starting during a pause.
  private var reportedRestop = false
  /// The same for a pause for lack of space on Drive held without proof.
  private var reportedQuotaHold = false

  public init(thresholds: Thresholds = Thresholds(), probes: Probes = .live) {
    self.thresholds = thresholds
    self.probes = probes
  }

  // MARK: - Measurements

  /// UNSENT BACKLOG in GB - the only measure on which the watchdog decides to
  /// pause and to resume. `nil` = rclone did not answer, i.e. WE DO NOT KNOW.
  ///
  /// WHY NOT THE CACHE SIZE
  ///
  /// Until 25.09.2026 the watchdog looked at `stats.bytesUsed`, i.e. the size of
  /// the whole rclone cache. With `--vfs-cache-max-size 100G` and
  /// `--vfs-cache-max-age 9999h` that number always sits at the limit - rclone
  /// also keeps in the cache what it uploaded long ago. So the watchdog measured
  /// an almost CONSTANT state and asked it about a CHANGING thing: whether the
  /// upload is keeping up with the writes. Result in the journal: 281
  /// measurements, minimum 99 GB, one pause and not a single resume. The unsent
  /// backlog is the same quantity that decides whether the cache can shrink at
  /// all - see `Thresholds.init`.
  ///
  /// WHY FROM THE ITEM COUNT, NOT FROM BYTES
  ///
  /// `vfs/stats` does not report the number of unsent BYTES: it has item
  /// counters (`uploadsQueued`, `uploadsInProgress`) and `bytesUsed` of the
  /// whole cache. Item sizes are exposed by `vfs/queue`, but that is a SECOND rc
  /// interface call on every tick, and `vfs/stats` alone was measured here at
  /// 36.7 s with a clogged buffer (see `DriveBufferService.queueStats`) -
  /// doubling that cost lengthens the reaction exactly when the backlog grows
  /// fastest. And it would give almost nothing: every item in this queue is a
  /// sparsebundle band of a FIXED size `BackupImageService.bandSectors`
  /// (32 MiB), so the sum of sizes is almost exactly the item count times
  /// 32 MiB. Check against real numbers: the 462 items of 23.09 give 14 GB from
  /// here, and the owner estimated "about 15 GB".
  ///
  /// THIS IS AN ESTIMATE, not a measurement - and it is described as such in the
  /// log (the "~" sign). The error goes ONE way: partial bands and small metadata
  /// files are SMALLER than 32 MiB, so the estimate overstates the backlog, and an
  /// overstated backlog pauses the backup earlier. For disk protection that is
  /// the right direction to err in.
  public static func backlogGB(stats: DriveBufferService.QueueStats?) -> Int? {
    guard let stats else { return nil }
    let bandBytes = UInt64(BackupImageService.bandSectors) * 512
    return Int(UInt64(max(0, stats.unsentItems)) * bandBytes / 1_073_741_824)
  }

  /// rclone cache size in GB - for THE VIEW AND THE LOG, never for decisions.
  /// `nil` = not measured either way.
  ///
  /// The two sources of this number are NOT EQUIVALENT, and that is why they
  /// must not be mixed in a decision: rclone reports the size of its own cache,
  /// while the directory walk reports DISK SPACE TAKEN, which can exceed the
  /// `--vfs-cache-max-size` limit (hence "155 GB" with a 100 GB limit). For a
  /// status line both are as good as any approximation; for pausing Time
  /// Machine neither is - see `DriveBufferService.cacheSizeBytesByWalk`.
  public static func cacheSizeGB(stats: DriveBufferService.QueueStats? = nil) -> Int? {
    if let bytes = stats?.bytesUsed, bytes > 0 { return Int(bytes / 1_073_741_824) }
    guard let walked = DriveBufferService.cacheSizeBytesByWalk() else { return nil }
    return Int(walked / 1_073_741_824)
  }

  /// Cache size for an interface that has nowhere to show "I do not know"
  /// (`BufferStatus.sizeGB`). Behaves exactly as the old `bufferGB` did -
  /// substituted zero included.
  ///
  /// NO DECISION may call this; the watchdog uses `backlogGB`. The zero for a
  /// missing measurement stays here until it is removed together with
  /// `BufferStatus` and `CloudMachineController`, which have to learn a third
  /// state - that is a separate change, outside this branch.
  public static func bufferGB(stats: DriveBufferService.QueueStats? = nil) -> Int {
    cacheSizeGB(stats: stats) ?? 0
  }

  /// Free space counted the way `df` counts it - i.e. PESSIMISTICALLY.
  ///
  /// It is tempting to use `volumeAvailableCapacityForImportantUsageKey`, but
  /// that is an optimistic measure: it includes space taken by local snapshots
  /// that the system only COULD free. On this machine it showed 1202 GB while
  /// `df` said 427 GB. The watchdog is supposed to pause the backup before the
  /// disk fills up, so it has to look at the space actually available now, not
  /// at a promise.
  ///
  /// `nil` means "NOT MEASURED", and that is not cosmetic. Previously a failed
  /// `statfs` returned `0`, i.e. a number - and then the pause condition
  /// (`free <= minFreeGB`) was met immediately, the resume condition
  /// (`free > minFreeGB`) NEVER, and the watchdog paused Time Machine forever.
  /// In parallel the monitor reported "The Mac's disk is running out of space
  /// (0 GB)" - an alarm about a state nobody measured. The same distinction that
  /// `BufferStatus.queueKnown` already introduced for the upload queue.
  public static func freeGB() -> Int? {
    var stats = statfs()
    guard statfs("/System/Volumes/Data", &stats) == 0 else { return nil }
    let available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
    return Int(available / 1_073_741_824)
  }

  /// Whether Time Machine may be resumed, looking ONLY at local measurements.
  ///
  /// A pure function - the decision can be tested without a disk and without
  /// tmutil. `free == nil` does not resume: a missing measurement is not proof
  /// that space is there. Resuming checks free space THE SAME WAY as pausing,
  /// because a pause protecting the disk must not be lifted by a condition that
  /// knows nothing about the disk.
  ///
  /// `backlog == nil` does not resume either, and that is the same rule applied
  /// to the second number. Previously no answer from rclone ended in a directory
  /// walk, and a failed walk - in zero; and zero meets the resume condition
  /// immediately, i.e. it LIFTED a pause put in place because the buffer was
  /// full.
  static func canResumeLocally(backlog: Int?, free: Int?, thresholds: Thresholds) -> Bool {
    guard let backlog, let free else { return false }
    return backlog <= thresholds.lowGB && free > thresholds.minFreeGB
  }

  /// Whether there is PROVEN room on Google Drive for further work.
  ///
  /// `nil` (rclone did not answer) is NOT consent - see `step()`.
  static func driveHasRoom(freeBytes: UInt64?, minGB: Int) -> Bool {
    guard let freeBytes else { return false }
    return freeBytes / 1_073_741_824 >= UInt64(max(0, minGB))
  }

  // MARK: - One step

  /// Performs one supervision step and returns the state. Split out of the loop
  /// so that decisions can be tested without waiting in real time.
  ///
  /// THE LAYOUT OF THIS FUNCTION IS PART OF THE FIX. Until 25.09.2026 the checks
  /// of `stats?.outOfSpace` and free space sat ONLY in the `.running` branch,
  /// and the `.pausedForBuffer` branch looked at nothing except the resume
  /// condition. After one pause the watchdog therefore stopped guarding the
  /// disk - i.e. the protection this process exists for switched off until the
  /// agent restarted. Measured: 53 hours in this state (pause 23.09.2026 03:34
  /// -> process restart 25.09.2026 08:46). That is why disk protection and
  /// `outOfSpace` NOW stand BEFORE `switch state`, and no path through this
  /// function can skip them.
  @discardableResult
  public func step() async -> Snapshot {
    let stats = await probes.queueStats()
    let backlog = Self.backlogGB(stats: stats)
    let free = probes.freeGB()
    let running = await probes.backupRunning()
    let percent = await probes.progressPercent()
    // Both questions go to the rclone log and both are three-state: an
    // unreadable file is "I do not know", not "no problem".
    let quota = probes.hitStorageQuota()
    let stalled = probes.uploadStalled()

    func snapshot() -> Snapshot {
      Snapshot(
        state: state, backlogGB: backlog, freeGB: free, backupRunning: running, percent: percent)
    }

    // A failed free-space measurement must NOT pass silently: the only
    // protection of the disk against filling up depends on this number, and
    // without it the watchdog will not pause Time Machine (and rightly so - it
    // does not guess). A person must learn about it from the log, not from a
    // full disk.
    if free == nil, !reportedFreeUnknown {
      probes.log(
        "WARNING: cannot measure free disk space (statfs failed) - the watchdog will not pause Time Machine because of the disk, as it has nothing to base the decision on."
      )
    }
    reportedFreeUnknown = (free == nil)

    // No answer from rclone must not pass silently either - but this time we do
    // NOT TURN it into a number. On 23.09.2026 in this situation the watchdog
    // fell back to the directory walk, got 155 GB (disk space taken - a measure
    // not comparable with the 100 GB limit), crossed the threshold with it and
    // paused Time Machine; an hour later the monitor wrote "rclone remote
    // control is not answering". So the pause rested on a number taken from the
    // fact that there was no measurement. We still print the cache size - but AS
    // SOMETHING ELSE, once per episode and with no effect on decisions.
    if backlog == nil, !reportedBacklogUnknown {
      let cache = probes.cacheSizeGB(stats)
      probes.log(
        "WARNING: rclone remote control is not answering - unknown how much is left to upload. The watchdog will NEITHER pause NOR resume Time Machine on that basis. The cache takes \(cache.map { "\($0) GB" } ?? "an unknown amount") on disk - that is DISK SPACE, not a backlog to upload, and it is no basis for a pause. Disk protection keeps working: free \(describe(free)), threshold \(thresholds.minFreeGB) GB."
      )
    }
    reportedBacklogUnknown = (backlog == nil)

    // An unreadable rclone log means "I do not know" for BOTH questions asked
    // of this file. Previously it meant "no problem", and that had two effects:
    // the watchdog did not pause the backup when Drive was out of space, and
    // `reportStall(false)` DELETED the jam marker and reported "Upload to Google
    // Drive has resumed" - a claim about an event nobody checked. The log has
    // `-rw-r-----` permissions, and at rclone start-up it is moved to `.1`, so
    // an unreadable log is an expected state, not a hypothesis.
    let logUnreadable = (quota == nil || stalled == nil)
    if logUnreadable, !reportedLogUnreadable {
      probes.log(
        "WARNING: cannot read the rclone log (\(DriveBufferService.logFile.path)) - the watchdog will recognise neither lack of space on Google Drive nor an upload jam. The jam marker stays unchanged, because 'I do not know' does not clear it."
      )
    }
    reportedLogUnreadable = logUnreadable

    // The daily upload limit is SOMETHING ELSE and deliberately does NOT pause
    // the backup.
    //
    // Measured on two episodes (12 and 15 September 2026): during a jam lasting
    // several hours the buffer did not budge - 99-103 GB, exactly as usual -
    // and the queue cleared by itself once the rolling 24 h window moved
    // forward. A pause would then have cost backups and given nothing in
    // return. The thresholds below protect against filling the disk, and they
    // work regardless of what causes the jam.
    //
    // We do, however, ALWAYS report it, because the jam of 12 September went
    // completely unnoticed - three hours without uploads and not a single trace
    // except the raw rclone log. `nil` is passed on as `nil`: the report itself
    // knows that "I do not know" clears nothing.
    await probes.reportStall(stalled)

    // Lack of SPACE on Drive takes precedence and will not pass by itself:
    // until the user deletes something, the upload will not move, and further
    // Time Machine work only pumps up the buffer. `nil` (unreadable log) does
    // NOT pause - no answer is not proof of a failure, just as it is not proof
    // of its absence; we reported it in the log above.
    if quota == true {
      if state == .pausedForQuota {
        await keepPaused(backupRunning: running)
      } else {
        await pause(
          reason:
            "PAUSE (no space on Google Drive): backlog \(describeBacklog(backlog)), free \(describe(free))",
          into: .pausedForQuota, backupRunning: running)
      }
      return snapshot()
    }

    // DISK PROTECTION - IN EVERY STATE, not only in `.running`.
    //
    // `outOfSpace` comes from rclone and means "I have nowhere left to put
    // data" - a harder fact than any threshold of ours, and it does not stop
    // being a fact because the watchdog happens to be paused.
    //
    // A missing free-space measurement (`free == nil`) does NOT pause the
    // backup. Previously a failed `statfs` gave zero, zero met the pause
    // condition and the watchdog paused Time Machine based on a number it
    // never measured - and then could not resume it, because the resume
    // condition never holds at zero.
    let lowDisk = free.map { $0 <= thresholds.minFreeGB } ?? false
    let bufferFull = stats?.outOfSpace == true
    if bufferFull || lowDisk {
      let why =
        bufferFull ? "rclone reports no space in the buffer" : "little free disk space"
      switch state {
      case .pausedForBuffer, .pausedForQuota:
        // Already paused, so there is nothing to announce - but Time Machine may
        // have started by itself in its hourly cycle, so we repeat the pause.
        // IMPORTANT: we do not go on to resuming from here. As long as the disk
        // is against the wall, no resume condition may lift the pause.
        await keepPaused(backupRunning: running)
      case .running, .idle:
        // Also from `.idle`: the disk fills up regardless of whether a backup
        // is running this second, and macOS starts another one every hour.
        // Entering the pause makes the next tick stop it.
        await pause(
          reason:
            "PAUSE (\(why)): backlog \(describeBacklog(backlog)), free \(describe(free)) - waiting for the upload",
          into: .pausedForBuffer, backupRunning: running)
      }
      return snapshot()
    }

    switch state {
    case .idle:
      // Only an EXPLICIT "yes". `nil` (tmutil did not answer) leaves the state
      // unchanged - we do not start supervising something we know nothing about.
      if running == true {
        probes.log("Backup started - supervising the upload backlog")
        sawBackupRunning = true
        state = .running
      }

    case .running:
      // `backlog == nil` does NOT pause: the same pattern as with `free`.
      // No answer from rclone is not a number and has no right to trigger an
      // irreversible pause.
      if let backlog, backlog >= thresholds.highGB {
        await pause(
          reason:
            "PAUSE (backlog threshold \(thresholds.highGB) GB): backlog \(describeBacklog(backlog)), free \(describe(free)) - waiting for the upload",
          into: .pausedForBuffer, backupRunning: running)
      } else if running == false {
        if sawBackupRunning {
          probes.log("Time Machine finished. Backlog \(describeBacklog(backlog))")
          sawBackupRunning = false
        }
        state = .idle
      }

    case .pausedForBuffer:
      // We resume only when the upload has actually caught up - otherwise we
      // would fall into start/stop oscillation at the threshold. Until it has
      // caught up, we KEEP UP the pause: the `tmutil stopbackup` from the moment
      // of pausing applied only to that one run.
      if Self.canResumeLocally(backlog: backlog, free: free, thresholds: thresholds) {
        await resume(backlogGB: backlog, freeGB: free)
      } else {
        await keepPaused(backupRunning: running)
      }

    case .pausedForQuota:
      // A pause for LACK OF SPACE on Drive needs POSITIVE proof that space is
      // there before it is lifted. This is not extra caution:
      //
      // `hitStorageQuota()` reads entries from the last 30 minutes of the rclone
      // log. After Time Machine is paused no new bands are created, rclone stops
      // trying to upload, the entries age and the function starts returning
      // `false` - even though Drive has as little space as before. With a quiet
      // buffer (and after a pause the buffer does empty) the shared resume
      // condition was then met immediately: the watchdog let Time Machine go, it
      // wrote more bands that cannot be uploaded, and the whole pause ended after
      // a few dozen minutes without anything changing on the Drive side.
      // `UploadState` says plainly that this state does NOT pass by itself.
      guard Self.canResumeLocally(backlog: backlog, free: free, thresholds: thresholds) else {
        await keepPaused(backupRunning: running)
        break
      }
      let driveFree = await probes.driveFreeBytes()
      guard Self.driveHasRoom(freeBytes: driveFree, minGB: thresholds.minDriveFreeGB) else {
        // No answer from rclone KEEPS the pause - "I do not know" is never
        // consent to resume something that fills up the disk.
        if !reportedQuotaHold {
          let amount =
            driveFree.map { "\($0 / 1_073_741_824) GB" } ?? "unknown (rclone did not answer)"
          probes.log(
            "PAUSE (no space on Drive) kept: free on Google Drive \(amount), required at least \(thresholds.minDriveFreeGB) GB."
          )
          reportedQuotaHold = true
        }
        await keepPaused(backupRunning: running)
        break
      }
      reportedQuotaHold = false
      await resume(backlogGB: backlog, freeGB: free)
    }

    return snapshot()
  }

  public func currentState() -> State { state }

  /// Free space for the log. A missing measurement MUST look different from
  /// zero, otherwise the log line lies just as the number itself used to.
  private func describe(_ freeGB: Int?) -> String {
    freeGB.map { "\($0) GB" } ?? "not measured"
  }

  /// Backlog for the log. The "~" sign is not decoration: this number is
  /// ESTIMATED from the number of items in the queue (see `backlogGB`), and a
  /// log that gives an estimate as a measurement lies about how solid the basis
  /// of the decision is.
  private func describeBacklog(_ gb: Int?) -> String {
    gb.map { "~\($0) GB" } ?? "unknown (rclone did not answer)"
  }

  // MARK: - Controlling Time Machine

  /// Pauses Time Machine and moves to `into` ONLY when that succeeded.
  ///
  /// THIS is the fix. Previously the result of `tmutil stopbackup` was thrown
  /// away (`_ = try? await ...`), and the state changed UNCONDITIONALLY. When
  /// the command failed - no permissions, time limit exceeded - the watchdog
  /// considered the pause done, and since `stopBackup()` was called only on a
  /// state CHANGE, it never retried. Time Machine kept writing, the watchdog
  /// waited for the drain, the disk filled up completely, and the log said
  /// "PAUSE ... waiting for the upload".
  ///
  /// On failure the state stays at `.running`, so the pause condition (still
  /// met) triggers another attempt on the next tick - i.e. in 30 seconds,
  /// without any extra retry mechanism.
  ///
  /// `backupRunning == false` (tmutil says EXPLICITLY that no backup is
  /// running) is a separate path: there is nothing to pause then, and calling
  /// `stopbackup` without a running backup can return an error - and the
  /// watchdog would then report "Time Machine KEEPS WRITING", i.e. a claim
  /// about an event nobody checked. `nil` ("tmutil did not answer") takes the
  /// strict path, because no answer is not proof of quiet.
  private func pause(reason: String, into paused: State, backupRunning: Bool?) async {
    probes.log(reason)
    if backupRunning == false {
      state = paused
      reportedStopFailure = false
      return
    }
    if await probes.stopBackup() {
      state = paused
      reportedStopFailure = false
      return
    }
    if !reportedStopFailure {
      probes.log(
        "FAILED to pause Time Machine (tmutil stopbackup). State stays at '\(state.rawValue)', retrying on every subsequent check. Time Machine KEEPS WRITING - the disk may fill up."
      )
      reportedStopFailure = true
    }
  }

  /// KEEPS UP the pause while in a paused state - on every tick.
  ///
  /// THIS is the fix. `stopBackup()` was called ONLY on a state change, and
  /// `tmutil stopbackup` cancels only the RUNNING backup and does not touch the
  /// schedule (`tmutil disable` does not appear in this repo even once). An
  /// hour after the pause macOS therefore started another backup: the watchdog
  /// neither stopped nor supervised it, because the `.pausedForBuffer` branch
  /// looked at nothing except the resume condition - and the log said "waiting
  /// for the upload". The pause held back writes for one run, even though the
  /// state itself lasted 53 hours. `pause` describes and fixes exactly this
  /// flaw for the FAILURE branch of `stopbackup`; for success it stayed
  /// untouched until 25.09.2026.
  ///
  /// We repeat only when tmutil does not say plainly "no backup running":
  /// "I do not know" (`nil`) counts here as "running", because no answer is not
  /// proof of quiet. With Time Machine idle this saves two processes (sudo +
  /// tmutil) every 30 seconds for the whole pause - in the 23.09 episode it
  /// would have been over 12 thousand of them.
  ///
  /// REJECTED ALTERNATIVE: `tmutil disable`. It turns the schedule off once and
  /// for good, so the pause would hold without repeating - but the watchdog
  /// keeps the pause state IN PROCESS MEMORY, and it runs under launchd with
  /// `KeepAlive`. After its death (or after a Mac restart) nobody would know
  /// that Time Machine had been disabled and has to be turned back on - a
  /// silent loss of backups forever instead of a slower backup. A repeated
  /// `stopbackup` is reversible by itself: when the watchdog stops working,
  /// Time Machine goes back to work in its hourly cycle.
  private func keepPaused(backupRunning: Bool?) async {
    guard backupRunning != false else {
      reportedRestop = false
      return
    }
    if !reportedRestop {
      probes.log(
        "Time Machine is running during a pause (state '\(state.rawValue)') - repeating the pause. `tmutil stopbackup` cancels only the running run, and macOS starts another one in its hourly cycle."
      )
      reportedRestop = true
    }
    if await probes.stopBackup() {
      reportedStopFailure = false
      return
    }
    if !reportedStopFailure {
      probes.log(
        "FAILED to repeat the Time Machine pause (tmutil stopbackup) in state '\(state.rawValue)'. Time Machine KEEPS WRITING to the buffer we are waiting to drain - the disk may fill up."
      )
      reportedStopFailure = true
    }
  }

  /// Resumes Time Machine.
  ///
  /// The asymmetry with `pause` is deliberate. A failed `stopbackup` risks
  /// filling the disk, so we must not pretend the pause happened. A failed
  /// `startbackup` risks nothing: Time Machine will start by itself in its
  /// hourly cycle anyway, and `startbackup` only speeds that up. If we stayed
  /// paused when it failed, the watchdog would be stuck in a state whose only
  /// exit is exactly what is not working.
  private func resume(backlogGB: Int?, freeGB: Int?) async {
    probes.log("RESUME: backlog \(describeBacklog(backlogGB)), free \(describe(freeGB))")
    reportedRestop = false
    if await probes.startBackup() == false {
      probes.log(
        "tmutil startbackup failed - Time Machine will start by itself in its hourly cycle.")
    }
    state = .running
  }

  /// What to do with the jam marker. A pure function, so that "I do not know"
  /// can be tested without a marker file, without a notification and without
  /// a log.
  ///
  /// `stalled == nil` is `.doNothing`, and that is the whole fix. Previously an
  /// unreadable rclone log came out of `uploadStalled()` as `false`, `false`
  /// meant "the jam is over" - so the marker was DELETED, and the log got
  /// "Upload to Google Drive has resumed". A claim about an event nobody
  /// checked, and the report cleared in exactly the case it exists for.
  enum StallAction: Equatable {
    case raise
    case clear
    case doNothing
  }

  static func stallAction(stalled: Bool?, markerExists: Bool) -> StallAction {
    guard let stalled else { return .doNothing }
    guard stalled != markerExists else { return .doNothing }
    return stalled ? .raise : .clear
  }

  /// Reports the start and end of an upload jam - once per state change.
  ///
  /// We keep the state in a file, not a field, because `buffer-guard` runs
  /// under launchd with `KeepAlive`: after every resurrection of the process the
  /// field would start from zero and the same jam would be reported anew every
  /// 30 seconds.
  ///
  /// `nil` = "I do not know", and then we touch NOTHING - see `stallAction`.
  static func reportUploadStall(_ stalled: Bool?) async {
    let marker = CMPaths.appSupportDir.appendingPathComponent(".upload-stalled")
    let reported = FileManager.default.fileExists(atPath: marker.path)
    let action = stallAction(stalled: stalled, markerExists: reported)
    guard action != .doNothing else { return }

    if action == .raise {
      CMLogger.log(
        "Upload to Google Drive is stalled - daily limit exhausted. Backups continue, the jam passes by itself within a few hours."
      )
      // The marker is created ONLY after the notification is delivered. Created
      // earlier, it closed the matter even when the notification did not get
      // through - i.e. it cleared the report in exactly the case it exists for
      // (the same bug as in `HealthAlert.report`, see the comment there).
      if await HealthAlert.notify(
        title: L10n.tr("CloudMachine: upload to Drive is stalled"),
        message: L10n.tr("Upload to Google Drive is stalled - daily limit exhausted."))
      {
        FileManager.default.createFile(atPath: marker.path, contents: nil)
      } else {
        CMLogger.log(
          "The upload jam notification was NOT delivered - will retry on the next check."
        )
      }
    } else {
      try? FileManager.default.removeItem(at: marker)
      CMLogger.log("Upload to Google Drive has resumed.")
    }
  }

  /// Calls `tmutil <command>` and says whether it REALLY succeeded.
  ///
  /// First via `sudo -n`: `tmutil stopbackup` and `startbackup` need root
  /// privileges, and the watchdog runs under launchd in the user session. The
  /// existing `runTmutilUnattended` was unused here, even though it was made
  /// exactly for this. The NOPASSWD rule in `/etc/sudoers.d/cloudmachine` is not
  /// set up by anything in this repo (checked: no installer writes it), so
  /// `sudo -n` refuses immediately today - and that is exactly why, on an
  /// AUTHORIZATION refusal, we still try without sudo instead of giving up.
  /// `isSudoAuthFailure` tells "sudo did not let us in" apart from "the command
  /// ran and returned an error".
  static func tmutil(_ command: String) async -> Bool {
    if let viaSudo = try? await ProcessRunner.runTmutilUnattended([command], timeout: 120) {
      if viaSudo.succeeded { return true }
      if !viaSudo.isSudoAuthFailure {
        CMLogger.log(
          "sudo tmutil \(command): exit code \(viaSudo.exitCode) \(shortError(viaSudo))")
        return false
      }
    }
    guard let direct = try? await ProcessRunner.run("/usr/bin/tmutil", [command], timeout: 120)
    else {
      CMLogger.log("tmutil \(command): NO ANSWER within the time limit.")
      return false
    }
    if !direct.succeeded {
      CMLogger.log("tmutil \(command): exit code \(direct.exitCode) \(shortError(direct))")
    }
    return direct.succeeded
  }

  private static func shortError(_ result: ProcessResult) -> String {
    let text = (result.stderr + " " + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "(no message)" : text.replacingOccurrences(of: "\n", with: " ")
  }
}
