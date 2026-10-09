import Foundation

/// Answers one question: is the hourly cycle STILL working.
///
/// The rest of this project measures the momentary state - whether the mount
/// is up, whether the image is attached, how much is waiting in the queue. None
/// of these measurements detects the most dangerous failure of this system:
/// everything looks mounted and attached, and Time Machine has not finished a
/// single backup for two days. The interface then shows a green badge and the
/// word "Ready".
///
/// That is why the source of truth here is the DATE OF THE LAST SUCCESSFUL
/// backup, not the state of the devices. We take a counter that grows only on
/// success from macOS itself: `SnapshotDates` in
/// `/Library/Preferences/com.apple.TimeMachine.plist` gets an entry only after
/// a COMPLETED backup. `AttemptDates` next to it counts attempts - including
/// the ones that failed - so the difference between them is exactly what we
/// are looking for.
///
/// We read the local file, not `tmutil latestbackup`. This is not an
/// optimization: `tmutil latestbackup` mounts a snapshot on the volume that
/// lives on Google Drive and, with a sick mount, can hang in uninterruptible
/// I/O. A watchdog that hangs exactly when it should raise the alarm is worse
/// than none.
///
/// Until 23.09.2026 that sentence was a declaration, not a fact:
/// `currentReport()` calls `tmutil destinationinfo` (for the Time Machine
/// destination), and that read reaches the mount and hung WITHOUT A TIME LIMIT
/// in uninterruptible I/O exactly like `latestbackup`, which this comment warns
/// against. Since that date every tmutil call has a hard limit
/// (`TimeMachineStatus.commandTimeout`), and no answer is reported as a FAILURE
/// - not as "destination changed" and not as silence.
public enum BackupHealth {

  public static let preferencesPath = "/Library/Preferences/com.apple.TimeMachine.plist"

  /// After this many hours without a SUCCESSFUL backup we consider the cycle
  /// broken.
  ///
  /// The cycle is hourly, so three hours are three missed runs in a row - too
  /// many to be chance. At the same time it leaves headroom for a backup that
  /// takes long, and for the buffer guard, which deliberately pauses Time
  /// Machine while the upload catches up.
  public static let maxAgeHours = 3.0

  /// For this many minutes after system startup "the mount / image /
  /// destination is not up yet" is NOT a failure.
  ///
  /// The `backup-health` agent has `RunAtLoad`, so it starts together with the
  /// session - a few seconds after rclone has only just started. After every
  /// restart (21.09, 25.09, 01.10.2026) the watchdog then reported "BACKUP
  /// FAILURE: Google Drive mount is not working" 4-8 s after login, before
  /// anything had a chance to come up. An alarm that fires on every startup
  /// teaches people to ignore it - and then the one real alarm is lost.
  ///
  /// 20 min, because that is what was measured in the worst case: on
  /// 01.10.2026, after a restart with ~19 GB of unsent bands, rclone was loading
  /// and uploading the backlog until 15:42, and the image attached at 15:49 -
  /// 17 min after the agents started. ONLY the devices' `false` states are
  /// deferred. The age of the last successful backup, RESULT, upload errors and
  /// "unknown" (a hung read) alarm from the first second, and the next
  /// watchdog run (every 30 min) already falls after this window and will
  /// report every state that did not fix itself.
  public static let startupGraceMinutes = 20.0

  /// How many seconds have passed since system startup (`kern.boottime`).
  /// `nil` = could not be read - then the startup grace period is NOT applied,
  /// because "I do not know" must not silence an alarm.
  public static func systemUptime(now: Date = Date()) -> TimeInterval? {
    var boot = timeval()
    var size = MemoryLayout<timeval>.size
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    guard sysctl(&mib, 2, &boot, &size, nil, 0) == 0, boot.tv_sec > 0 else { return nil }
    let booted = Date(
      timeIntervalSince1970: TimeInterval(boot.tv_sec) + TimeInterval(boot.tv_usec) / 1_000_000)
    return now.timeIntervalSince(booted)
  }

  /// A single thing that went wrong. The text is ready to be shown to the
  /// user - it is the only form in which anyone will see it.
  public struct Problem: Equatable {
    public var summary: String
    public var detail: String
    /// Stable, language-independent name of the problem.
    ///
    /// `summary` follows the UI language, so it cannot identify the problem:
    /// `HealthAlert` recognizes "the same failure" by this field, and the alert
    /// state written by a Polish-language run must still match an
    /// English-language run. Defaults to `summary` for problems built outside
    /// `BackupHealth` (tests), which keeps the old behaviour for them.
    public var code: String

    public init(summary: String, detail: String, code: String? = nil) {
      self.summary = summary
      self.detail = detail
      self.code = code ?? summary
    }
  }

  public struct Report: Equatable {
    public var problems: [Problem]
    public var lastSuccess: Date?
    public var lastAttempt: Date?
    /// Whether the counter of successful backups could be READ at all.
    ///
    /// Without this field `lastSuccess == nil` meant two completely different
    /// things: "Time Machine has not made a single backup" and "we have no
    /// access to the file, so we know nothing". Whoever reads this report
    /// (e.g. the GUI panel) has to tell them apart, so as not to present a
    /// lack of knowledge as a fact.
    public var preferencesReadable: Bool
    /// "Not ready yet" states deferred for the startup grace period - see
    /// `startupGraceMinutes`. They are NOT a failure and do NOT go to a
    /// notification, but they do not disappear: `backup-health` prints them
    /// separately, so that a person asking right after startup sees what we
    /// are still waiting for.
    public var deferred: [Problem]
    public var healthy: Bool { problems.isEmpty }

    public init(
      problems: [Problem], lastSuccess: Date?, lastAttempt: Date?,
      preferencesReadable: Bool = true, deferred: [Problem] = []
    ) {
      self.problems = problems
      self.lastSuccess = lastSuccess
      self.lastAttempt = lastAttempt
      self.preferencesReadable = preferencesReadable
      self.deferred = deferred
    }
  }

  // MARK: - Reading the counter of successful backups

  /// Dates from the Time Machine preferences for the destination at the given
  /// mount point. Pure function - takes an already read dictionary, so it can
  /// be tested without the system file and without Time Machine.
  ///
  /// `result` is the `RESULT` field from the same block: 0 means the last run
  /// ended well, anything else - that it did not.
  public static func dates(
    inPreferences plist: [String: Any], volumeNamed volumeName: String
  ) -> (lastSuccess: Date?, lastAttempt: Date?, result: Int?) {
    guard let destinations = plist["Destinations"] as? [[String: Any]] else {
      return (nil, nil, nil)
    }
    // We pick the destination by volume name, not by index 0 - a Mac can have
    // several Time Machine destinations registered, and we care only about
    // this one.
    let destination =
      destinations.first { ($0["LastKnownVolumeName"] as? String) == volumeName }
      ?? (destinations.count == 1 ? destinations[0] : nil)
    guard let destination else { return (nil, nil, nil) }

    let snapshots = (destination["SnapshotDates"] as? [Date]) ?? []
    let attempts = (destination["AttemptDates"] as? [Date]) ?? []
    let result = (destination["RESULT"] as? NSNumber)?.intValue

    return (snapshots.max(), attempts.max(), result)
  }

  /// Assessment of the state. Pure function - every input is passed in
  /// directly, so injecting a KNOWN BAD sample (an old date, a non-zero
  /// RESULT, a dead mount) is one call in a test, not breaking production.
  public static func evaluate(
    lastSuccess: Date?,
    lastAttempt: Date?,
    result: Int?,
    now: Date,
    mounted: Bool?,
    attached: Bool?,
    destinationRegistered: Bool?,
    erroredFiles: Int,
    outOfSpace: Bool,
    queueReadable: Bool,
    driveFreeBytes: UInt64? = nil,
    localFreeGB: Int? = nil,
    imageDeadErrno: Int32? = nil,
    // The image IS in the mount table, but the readability probe did not
    // return. Goes together with `attached: nil` and serves ONLY to tell the
    // person exactly what we do not know - the decision is the same.
    imageProbeTimedOut: Bool = false,
    maxAgeHours: Double = BackupHealth.maxAgeHours,
    // Whether the startup grace period is in progress - see `startupGraceMinutes`.
    withinStartupGrace: Bool = false,
    // Whether Time Machine is RIGHT NOW performing a run (`tmutil status`).
    backupRunning: Bool? = nil
  ) -> Report {
    var problems: [Problem] = []
    var deferred: [Problem] = []
    // A device state that is NORMAL right after startup, because nothing has
    // had time to come up yet. After the grace period it is an ordinary
    // failure.
    func notReadyYet(_ problem: Problem) {
      if withinStartupGrace { deferred.append(problem) } else { problems.append(problem) }
    }

    // Order from cause to effect: if the mount is down, the backup age will
    // grow anyway, but it is the mount that has to be fixed.
    //
    // `mounted` and `attached` are THREE-STATE for the same reason as
    // `destinationRegistered` below: reading the mount table can fail, and
    // then we know neither that it is there nor that it is not. Collapsing
    // that into a `Bool` ended in one of two ways and both were wrong -
    // `?? false` produced an alarm about an unmounted Drive that may be
    // mounted, and `!= .detached` produced SILENCE about an image we know
    // nothing about.
    switch mounted {
    case .some(true):
      break
    case .some(false):
      notReadyYet(
        Problem(
          summary: L10n.tr("Google Drive mount is not working"),
          detail: L10n.tr(
            "Without it the backup image is unreachable and Time Machine has nowhere to write."),
          code: "drive-not-mounted"))
    case .none:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether the Google Drive mount is working"),
          detail: L10n.tr(
            "Could not read the mount table. That does not mean the Drive is unmounted - it means nobody has checked. Without this answer there is no way to tell whether backups have anywhere to go."
          ),
          code: "drive-mount-unknown"))
    }

    switch attached {
    case .some(true):
      if let errno = imageDeadErrno {
        // Attached but dead - a state that until 22 Sep 2026 did not exist for
        // any sensor and therefore lasted 15 hours. See `ImageProbe`.
        problems.append(
          Problem(
            summary: L10n.tr("The backup image is attached, but DEAD (errno %@)", "\(errno)"),
            detail: L10n.tr(
              "The image device stopped returning data - Time Machine sees it as a disconnected disk. Fix: cloudmachine-agent attach-image (force-detaches and attaches again)."
            ),
            code: "image-dead"))
      }
    case .some(false):
      notReadyYet(
        Problem(
          summary: L10n.tr("The backup image is not attached"),
          detail: L10n.tr(
            "Time Machine cannot see the destination %@.", BackupImageService.targetPath.path),
          code: "image-detached"))
    case .none:
      // THAT silence. Until 23.09.2026 the caller passed `attachment !=
      // .detached` here, so the new `.unknown` case ("the mount table could
      // not be read") fell into `true` - i.e. "attached". The watchdog, whose
      // ONLY job is not to claim things it does not know, stayed silent about
      // a state it did not know. The message must be DIFFERENT from a real
      // detachment: "is not attached" sends the person off to attach an image
      // that may be attached correctly.
      // Two causes of "I do not know" and TWO different messages, because they
      // send the person to two different places. The third point at which the
      // same distinction saves this report - see `mounted` above and
      // `destinationRegistered` below.
      if imageProbeTimedOut {
        problems.append(
          Problem(
            summary: L10n.tr("Unknown whether the backup image returns data"),
            detail: L10n.tr(
              "The image %@ is listed in the mount table, but the readability probe did not answer within %@ s - that is how a read blocked on a dead FUSE-T mount behaves. This is NOT proof that the image is dead, so do NOT force-detach it: `attach-image` deliberately does nothing in that case, because detaching a live device abandons data waiting to be uploaded. First check whether rclone responds (cloudmachine-agent drive-status) and whether the gdrive-buffer agent is alive.",
              BackupImageService.targetPath.path, "\(Int(ImageProbe.probeTimeout))"),
            code: "image-probe-timed-out"))
      } else {
        problems.append(
          Problem(
            summary: L10n.tr("Unknown whether the backup image is attached"),
            detail: L10n.tr(
              "Could not read the mount table, so the state of the image %@ is UNKNOWN. Do not attach it blindly - first check whether `mount` responds at all (with a dead FUSE-T mount it can hang).",
              BackupImageService.targetPath.path),
            code: "image-attachment-unknown"))
      }
    }
    // `nil` is NOT the same as `false`. Since 23.09.2026 `tmutil` has a time
    // limit (see `TimeMachineStatus.commandTimeout`), so with a dead mount the
    // watchdog comes back with no answer instead of hanging. No answer is a
    // FAILURE - but a different one from a changed destination, and it has to
    // sound different, so as not to send the person off to change something
    // that is set correctly.
    switch destinationRegistered {
    case .some(true):
      break
    case .some(false):
      notReadyYet(
        Problem(
          summary: L10n.tr("Time Machine does not point to CloudMachine"),
          detail: L10n.tr(
            "The backup destination was changed or unregistered - backups are not being made."),
          code: "destination-not-registered"))
    case .none:
      problems.append(
        Problem(
          summary: L10n.tr("tmutil is not responding - unknown where the backup goes"),
          detail: L10n.tr(
            "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when blocked on a dead Google Drive mount. Fix: cloudmachine-agent attach-image, and if that does not help - restart the gdrive-buffer agent.",
            "\(Int(TimeMachineStatus.commandTimeout))"),
          code: "tmutil-no-answer"))
    }

    // THIS is the counter that grows only on success.
    if let lastSuccess {
      let age = now.timeIntervalSince(lastSuccess)
      if age > maxAgeHours * 3600 {
        problems.append(
          Problem(
            summary: L10n.tr("No successful backup for %@", formatAge(age)),
            detail: L10n.tr(
              "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.",
              stamp(lastSuccess), "\(max(1, Int(age / 3600)))"),
            code: "no-recent-backup"))
      }
    } else {
      problems.append(
        Problem(
          summary: L10n.tr("There is NOT A SINGLE successful backup"),
          detail: L10n.tr(
            "The Time Machine preferences contain no date of a completed backup for this destination."
          ),
          code: "no-backup-ever"))
    }

    // An attempt with no success after it is a backup that started and failed.
    // The age of the last success alone will not show that until it crosses
    // the threshold.
    //
    // Exception: a run that is STILL IN PROGRESS. After a restart Time Machine
    // can walk the whole disk (01.10.2026: 882 GB, 3.6 million files, ~4 h),
    // and after an hour the watchdog then reported "the attempt did not end
    // in a backup" about an attempt that simply had not finished yet. A run
    // stuck forever will be caught by the last-successful-backup age
    // threshold above anyway.
    if let lastAttempt, let lastSuccess, lastAttempt > lastSuccess,
      now.timeIntervalSince(lastAttempt) > 3600, backupRunning != true
    {
      problems.append(
        Problem(
          summary: L10n.tr("The last backup attempt did not end in a backup"),
          detail: L10n.tr(
            "The attempt at %@ is newer than the last successful backup at %@.",
            stamp(lastAttempt), stamp(lastSuccess)),
          code: "last-attempt-failed"))
    }

    if let result, result != 0 {
      problems.append(
        Problem(
          summary: L10n.tr(
            "Time Machine reports an error in the last run (RESULT=%@)", "\(result)"),
          detail: L10n.tr(
            "A non-zero RESULT in the Time Machine preferences means the run did not succeed."),
          code: "time-machine-result"))
    }

    if erroredFiles > 0 {
      problems.append(
        Problem(
          summary: L10n.tr("rclone failed to upload %@ files", "\(erroredFiles)"),
          detail: L10n.tr(
            "These image bands exist only locally. The backup on Google Drive is INCOMPLETE and may not open."
          ),
          code: "upload-errors"))
    }
    if outOfSpace {
      problems.append(
        Problem(
          summary: L10n.tr("Buffer full of nothing but unsent data"),
          detail: L10n.tr(
            "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled."
          ),
          code: "buffer-out-of-space"))
    }
    // `mounted == true`, not `mounted != false`: when there is no mount OR it
    // is unknown whether there is one, harder messages above already say so,
    // and a second message about the same thing only dilutes the first.
    if !queueReadable && mounted == true {
      problems.append(
        Problem(
          summary: L10n.tr("The rclone control interface is not responding"),
          detail: L10n.tr(
            "Without it there is no way to check whether anything reached the Drive - the buffer guard is blind then."
          ),
          code: "rclone-rc-no-answer"))
    }

    // Space on the Drive. Running out of it is a FATAL error for rclone, so
    // the mount disappears and Time Machine loses its destination - this has
    // to be known EARLIER, not from a failure. The threshold is counted in
    // cycles, not in percent: at a growth of ~600 MB per hour, 30 GB is about
    // two weeks of headroom.
    if let driveFreeBytes {
      let freeGB = Int(driveFreeBytes / 1_073_741_824)
      if freeGB < driveFreeWarningGB {
        problems.append(
          Problem(
            summary: L10n.tr("Google Drive is running out of space (%@ GB)", "\(freeGB)"),
            detail: L10n.tr(
              "Once it runs out, rclone exits with a storageQuotaExceeded error, the mount disappears and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.",
              "\(max(1, freeGB * 1024 / 600 / 24))"),
            code: "drive-low-space"))
      }
    }

    if let localFreeGB, localFreeGB < localFreeWarningGB {
      problems.append(
        Problem(
          summary: L10n.tr("The Mac's disk is running out of space (%@ GB)", "\(localFreeGB)"),
          detail: L10n.tr(
            "The upload buffer lives on this disk. When it fills up, the guard pauses Time Machine, and with no space left at all rclone has nowhere to put data waiting to be uploaded."
          ),
          code: "local-low-space"))
    }

    return Report(
      problems: problems, lastSuccess: lastSuccess, lastAttempt: lastAttempt, deferred: deferred)
  }

  /// Below this many GB free on Google Drive we report a problem.
  public static let driveFreeWarningGB = 30
  /// Below this many GB free locally we report a problem. Higher than the
  /// buffer guard's pause threshold - the watchdog should warn before the
  /// guard starts braking.
  public static let localFreeWarningGB = 120

  // MARK: - Live reading

  /// Whether the file we read the backup history from CAN BE READ.
  ///
  /// This is at the same time the only honest answer to the question "do we
  /// have Full Disk Access": TCC has no interface for asking about the
  /// permission, so it is checked by TRYING.
  ///
  /// Until 25.09.2026 the interface did this via
  /// `FileManager.isReadableFile(atPath:)` on
  /// `~/Library/Application Support/com.apple.TCC`. Two bugs in one line: that
  /// is a DIRECTORY, not the file with the backup history, and
  /// `isReadableFile` boils down to `access(R_OK)`, which looks only at POSIX
  /// permissions and knows nothing about TCC. So the answer came out
  /// affirmative regardless of the permission state - and the panel said
  /// "access granted" at a moment when the watchdog could not read a single
  /// backup date. The person then looked for the failure everywhere except
  /// where it was.
  ///
  /// `preferencesFile` is replaceable for the same reason as in `currentReport`.
  public static func preferencesReadable(
    preferencesFile: String = BackupHealth.preferencesPath
  ) -> Bool {
    (try? Data(contentsOf: URL(fileURLWithPath: preferencesFile))) != nil
  }

  /// How many times the Time Machine preferences are read before "cannot read"
  /// counts, and how long to wait between the reads.
  ///
  /// One failed read is not evidence: on 08.10.2026 at 19:52, two minutes into
  /// a backup, the watchdog could not read the file and reported "most often
  /// Full Disk Access is missing" - while the runs 30 minutes before and after
  /// read it fine. backupd rewrites this file during a backup, and a read can
  /// land in the middle. Missing Full Disk Access fails EVERY read, so asking
  /// again costs a real alarm only these seconds, never the alarm itself.
  public static let preferencesReadAttempts = 3
  public static let preferencesRetryPause: TimeInterval = 5

  /// The file read and parsed; `nil` for either failure.
  static func loadPreferences(_ path: String) -> [String: Any]? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
    return (try? PropertyListSerialization.propertyList(from: data, format: nil))
      as? [String: Any]
  }

  /// Reads until one read works, at most `attempts` times. `nil` only when
  /// every read failed. Pure in its inputs, so the confirmation can be tested.
  static func readPreferences(
    _ read: () -> [String: Any]?, attempts: Int = preferencesReadAttempts,
    pause: () async -> Void
  ) async -> [String: Any]? {
    for attempt in 1...max(1, attempts) {
      if let plist = read() { return plist }
      if attempt < attempts { await pause() }
    }
    return nil
  }

  /// The panel's "Full Disk Access" answer, which reads the file every 10 s:
  /// it says "missing" only after `required` failed reads in a row, and
  /// "granted" again at the first good one. Without it a read landing in a
  /// backupd rewrite brought back the "Grant Full Disk Access" setup step for
  /// one refresh. Until the first failure is confirmed the earlier answer
  /// stands - and at launch that is `false`, so a missing permission still
  /// shows from the start.
  public struct ReadConfirmation: Equatable, Sendable {
    public let required: Int
    public private(set) var failuresInARow = 0

    public init(required: Int = 2) { self.required = required }

    /// The answer to show after this read, given the one shown so far.
    public mutating func readable(after readSucceeded: Bool, shown: Bool) -> Bool {
      if readSucceeded {
        failuresInARow = 0
        return true
      }
      failuresInARow += 1
      return failuresInARow >= required ? false : shown
    }
  }

  /// `preferencesFile` can be replaced so that the WHOLE watchdog path can be
  /// run on a known bad sample - reading the file, parsing, choosing the
  /// destination, assessment, reporting, exit code - without breaking the
  /// working backup. A unit test of `evaluate` does not cover what happens
  /// between the file and the decision, and that is exactly where the silent
  /// failures in this project were.
  public static func currentReport(
    now: Date = Date(), maxAgeHours: Double = BackupHealth.maxAgeHours,
    preferencesFile: String = BackupHealth.preferencesPath,
    preferencesRetryPause: TimeInterval = BackupHealth.preferencesRetryPause
  ) async -> Report {
    let plist = await readPreferences(
      { loadPreferences(preferencesFile) },
      pause: {
        try? await Task.sleep(nanoseconds: UInt64(preferencesRetryPause * 1_000_000_000))
      })

    guard let plist else {
      return Report(
        problems: [
          Problem(
            summary: L10n.tr("Cannot read the Time Machine preferences"),
            detail: L10n.tr(
              "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.",
              preferencesFile),
            code: "preferences-unreadable")
        ], lastSuccess: nil, lastAttempt: nil, preferencesReadable: false)
    }

    let (lastSuccess, lastAttempt, result) = dates(
      inPreferences: plist, volumeNamed: BackupImageService.volumeName)

    let stats = await DriveBufferService.queueStats()
    // `attachmentReading()`, not `attachment()`: the readability probe has a
    // time limit and, once it is exceeded, returns `.unknown`. The watchdog
    // then FINISHES the run and reports the lack of knowledge - that is the
    // whole difference compared with the state until 26.09.2026, in which
    // this read had no limit, and `StartInterval 1800` without `KeepAlive`
    // means launchd will NOT start a second instance while the first one is
    // alive. A single hang therefore silenced the watchdog PERMANENTLY, and
    // silence in this system looks identical to health.
    let reading = await BackupImageService.attachmentReading()
    let attachment = reading.attachment
    var deadErrno: Int32?
    if case .dead(let errno) = attachment { deadErrno = errno }

    // Three states, just like for the Time Machine destination below.
    //
    // We derive them from `attachment`, not from a second call to
    // `BackupImageService.attachedState()` - the same mount-table read already
    // gave `deadErrno` above, and two separate reads could diverge and
    // produce a report describing two different moments.
    let attached: Bool?
    switch attachment {
    // `.dead` is still an ATTACHED image - just a dead one, and that is a
    // separate problem reported via `imageDeadErrno`.
    case .attached, .dead: attached = true
    case .detached: attached = false
    case .unknown: attached = nil
    }
    // Three states, not two: `noAnswer` (a hung tmutil) has no right to
    // pretend to be "destination changed" - see `evaluate`.
    let registered: Bool?
    switch await TimeMachineStatus.destinationReading() {
    case .mountPoint(let path): registered = (path == BackupImageService.targetPath.path)
    case .none: registered = false
    case .noAnswer: registered = nil
    }

    // Measuring free space can FAIL (statfs returns an error), and then
    // `freeGB()` returns `nil`, not a made-up zero - see the comment on it.
    let localFree = BufferGuardService.freeGB()

    var report = evaluate(
      lastSuccess: lastSuccess,
      lastAttempt: lastAttempt,
      result: result,
      now: now,
      // `mountedState()`, and NOT `isMounted` - the latter is
      // `mountedState() ?? false`, i.e. it turns "I do not know" into "not
      // working" and tells the person to fix a mount that may be fine.
      mounted: DriveBufferService.mountedState(),
      attached: attached,
      destinationRegistered: registered,
      erroredFiles: stats?.erroredFiles ?? 0,
      outOfSpace: stats?.outOfSpace ?? false,
      queueReadable: stats != nil,
      // An unreadable Drive quota is NOT a separate alarm here: when rclone
      // does not respond, harder signals above already say so, and a second
      // message about the same thing only dilutes the first.
      driveFreeBytes: (await DriveBufferService.remoteQuota())?.free,
      localFreeGB: localFree,
      imageDeadErrno: deadErrno,
      imageProbeTimedOut: reading.probeTimedOut,
      maxAgeHours: maxAgeHours,
      // The REAL clock, not `now`: tests substitute a `now` from the past, and
      // uptime computed from it would come out negative, i.e. "startup in
      // progress".
      withinStartupGrace: (systemUptime() ?? .infinity) < startupGraceMinutes * 60,
      backupRunning: await TimeMachineStatus.runningState())

    report.problems.append(contentsOf: unmeasuredLocalDiskProblems(localFreeGB: localFree))
    report.problems.append(contentsOf: await MachineBudget.currentProblems())
    return report
  }

  /// Problem reported when the free-space measurement CANNOT be made.
  ///
  /// `evaluate` treats `localFreeGB: nil` as "not asked" (that has been its
  /// contract from the start, and a dozen or so tests rely on it), but
  /// `currentReport` KNOWS it asked and it did not work. That is a separate
  /// failure: the buffer guard decides on pausing Time Machine precisely on
  /// this number, so when it is missing, it no longer protects the disk from
  /// filling up.
  ///
  /// Split out of `currentReport()` SOLELY so that it can be tested:
  /// `currentReport()` touches rclone, tmutil and hdiutil, so this branch
  /// would otherwise be untestable - and an "I do not know" branch nobody has
  /// checked is exactly the kind of dead code the review asked about (the
  /// compiler warned earlier that an `Int` compared to `nil` always yields
  /// false, i.e. that the branch was dead).
  static func unmeasuredLocalDiskProblems(localFreeGB: Int?) -> [Problem] {
    guard localFreeGB == nil else { return [] }
    return [
      Problem(
        summary: L10n.tr("Cannot measure free space on the Mac's disk"),
        detail: L10n.tr(
          "statfs('/System/Volumes/Data') returned an error. The buffer guard will then not pause Time Machine before the disk fills up, because it does not know the number it bases that decision on."
        ),
        code: "local-space-unmeasured")
    ]
  }

  // MARK: - Formatting

  /// Age in words. Minutes below two hours - otherwise, with a low threshold,
  /// the message reads "No successful backup for 0 h", which means nothing.
  public static func formatAge(_ seconds: TimeInterval) -> String {
    let hours = Int(seconds / 3600)
    if hours < 2 { return "\(Int(seconds / 60)) min" }
    if hours < 48 { return "\(hours) h" }
    return L10n.tr("%@ days", "\(hours / 24)")
  }

  public static func stamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
  }
}
