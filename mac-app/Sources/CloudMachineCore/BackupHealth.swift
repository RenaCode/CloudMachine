import Foundation

/// Answers one question: is the hourly cycle STILL working.
///
/// The rest of this project measures the momentary state - whether the
/// machine runs, whether its services are up, how much is waiting in the
/// queue. None of these measurements detects the most dangerous failure of
/// this system: everything looks up, and Time Machine has not finished a
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
/// optimization: `tmutil latestbackup` mounts the backup volume and, with a
/// sick destination, can hang in uninterruptible I/O. A watchdog that hangs
/// exactly when it should raise the alarm is worse than none. Every tmutil
/// call has a hard limit (`TimeMachineStatus.commandTimeout`), and so does
/// every question to the machine; no answer is reported as a FAILURE - not as
/// "destination changed" and not as silence.
public enum BackupHealth {

  public static let preferencesPath = "/Library/Preferences/com.apple.TimeMachine.plist"

  /// After this many hours without a SUCCESSFUL backup we consider the cycle
  /// broken.
  ///
  /// The cycle is hourly, so three hours are three missed runs in a row - too
  /// many to be chance. At the same time it leaves headroom for a backup that
  /// takes long, and for the machine's guard, which deliberately pauses Time
  /// Machine while the upload catches up.
  public static let maxAgeHours = 3.0

  /// For this many minutes after system startup "the machine / its services /
  /// the destination is not up yet" is NOT a failure.
  ///
  /// The `backup-health` agent has `RunAtLoad`, so it starts together with the
  /// session - the same moment `vm-start` boots the machine. With the old
  /// layout the watchdog reported a failure 4-8 s after every login (21.09,
  /// 25.09, 01.10.2026), before anything had a chance to come up. An alarm
  /// that fires on every startup teaches people to ignore it - and then the
  /// one real alarm is lost.
  ///
  /// 20 min: a boot of the machine with a backlog in rclone's buffer takes
  /// minutes before Samba answers. ONLY the `false` states are deferred. The
  /// age of the last successful backup, RESULT, upload errors and "unknown"
  /// (a hung read) alarm from the first second, and the next watchdog run
  /// (every 30 min) already falls after this window and will report every
  /// state that did not fix itself.
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

  /// Dates from the Time Machine preferences for this Mac's CloudMachine
  /// destination. Pure function - takes an already read dictionary, so it can
  /// be tested without the system file and without Time Machine.
  ///
  /// The destination is the one named after the share (`LastKnownVolumeName`),
  /// else the one whose `NetworkURL` is the machine's share, else the only one
  /// there is.
  ///
  /// `result` is the `RESULT` field from the same block: 0 means the last run
  /// ended well, anything else - that it did not.
  public static func dates(
    inPreferences plist: [String: Any], volumeNamed volumeName: String = VMLayout.shareName
  ) -> (lastSuccess: Date?, lastAttempt: Date?, result: Int?) {
    guard let destinations = plist["Destinations"] as? [[String: Any]] else {
      return (nil, nil, nil)
    }
    // We pick the destination, not index 0 - a Mac can have several Time
    // Machine destinations registered, and we care only about this one.
    let destination =
      destinations.first { ($0["LastKnownVolumeName"] as? String) == volumeName }
      ?? destinations.first {
        ($0["NetworkURL"] as? String).map { VMStatus.isMachineShare($0, address: nil) } ?? false
      }
      ?? (destinations.count == 1 ? destinations[0] : nil)
    guard let destination else { return (nil, nil, nil) }

    let snapshots = (destination["SnapshotDates"] as? [Date]) ?? []
    let attempts = (destination["AttemptDates"] as? [Date]) ?? []
    let result = (destination["RESULT"] as? NSNumber)?.intValue

    return (snapshots.max(), attempts.max(), result)
  }

  /// Assessment of the state. Pure function - every input is passed in
  /// directly, so injecting a KNOWN BAD sample (an old date, a non-zero
  /// RESULT, a stopped machine) is one call in a test, not breaking production.
  ///
  /// `nil` means "no answer" for every three-state input: it is reported as
  /// its own problem, never folded into "fine" or into "broken".
  public static func evaluate(
    lastSuccess: Date?,
    lastAttempt: Date?,
    result: Int?,
    now: Date,
    machineRunning: Bool?,
    servicesHealthy: Bool?,
    destinationRegistered: Bool?,
    erroredFiles: Int,
    outOfSpace: Bool,
    queueReadable: Bool,
    driveFreeBytes: UInt64? = nil,
    localFreeGB: Int? = nil,
    machineFreeGB: Int? = nil,
    punchfsNearFileLimit: Bool = false,
    remoteControlOpen: Bool = false,
    // Seconds since the last copy of the image's metadata to Drive
    // (`.infinity` = never); `nil` = not known or nothing to copy yet.
    metaSyncAge: TimeInterval? = nil,
    // Seconds since Google's daily upload limit last refused an upload, while
    // it still holds (`VMStatus.Report.uploadLimitAge`); `nil`/0 = it does not.
    uploadLimitAge: TimeInterval? = nil,
    // Seconds uploads have been "in progress" with none going through
    // (`VMStatus.uploadStalledFor`); `nil` = they do not hang.
    uploadStalledFor: TimeInterval? = nil,
    maxAgeHours: Double = BackupHealth.maxAgeHours,
    // Whether the startup grace period is in progress - see `startupGraceMinutes`.
    withinStartupGrace: Bool = false,
    // Whether Time Machine is RIGHT NOW performing a run (`tmutil status`).
    backupRunning: Bool? = nil
  ) -> Report {
    var problems: [Problem] = []
    var deferred: [Problem] = []
    // A state that is NORMAL right after startup, because nothing has had
    // time to come up yet. After the grace period it is an ordinary failure.
    func notReadyYet(_ problem: Problem) {
      if withinStartupGrace { deferred.append(problem) } else { problems.append(problem) }
    }

    // Order from cause to effect: if the machine is down, the backup age will
    // grow anyway, but it is the machine that has to be fixed.
    switch machineRunning {
    case .some(true):
      switch servicesHealthy {
      case .some(true):
        break
      case .some(false):
        notReadyYet(
          Problem(
            summary: L10n.tr("A service in the CloudMachine machine is not running"),
            detail: L10n.tr(
              "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status"
            ),
            code: "machine-service-down"))
      case .none:
        problems.append(
          Problem(
            summary: L10n.tr("The CloudMachine machine does not answer"),
            detail: L10n.tr(
              "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status"
            ),
            code: "machine-no-answer"))
      }
    case .some(false):
      notReadyYet(
        Problem(
          summary: L10n.tr("The CloudMachine machine is not running"),
          detail: L10n.tr(
            "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).",
            VMLayout.instanceName),
          code: "machine-stopped"))
    case .none:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether the CloudMachine machine is running"),
          detail: L10n.tr(
            "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked."
          ),
          code: "machine-unknown"))
    }

    // `nil` is NOT the same as `false`: no answer from tmutil has to sound
    // different from a changed destination, so as not to send the person off
    // to change something that is set correctly.
    switch destinationRegistered {
    case .some(true):
      break
    case .some(false):
      notReadyYet(
        Problem(
          summary: L10n.tr("Time Machine does not point to CloudMachine"),
          detail: L10n.tr(
            "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup"
          ),
          code: "destination-not-registered"))
    case .none:
      problems.append(
        Problem(
          summary: L10n.tr("tmutil is not responding - unknown where the backup goes"),
          detail: L10n.tr(
            "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.",
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
    // Exception: a run that is STILL IN PROGRESS. A first or a long backup can
    // take hours, and after an hour the watchdog then reported "the attempt did
    // not end in a backup" about an attempt that simply had not finished yet.
    // A run stuck forever will be caught by the age threshold above anyway.
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
            "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open."
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
    // Only for a machine whose services answered: when it is down or silent,
    // harder messages above already say so, and a second message about the
    // same thing only dilutes the first.
    if !queueReadable && machineRunning == true && servicesHealthy == true {
      problems.append(
        Problem(
          summary: L10n.tr("The rclone control interface is not responding"),
          detail: L10n.tr(
            "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then."
          ),
          code: "rclone-rc-no-answer"))
    }
    if punchfsNearFileLimit {
      problems.append(
        Problem(
          summary: L10n.tr("punchfs is close to its open-file limit"),
          detail: L10n.tr(
            "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status"
          ),
          code: "punchfs-file-limit"))
    }
    if remoteControlOpen {
      problems.append(
        Problem(
          summary: L10n.tr("rclone's remote control is open on this Mac"),
          detail: L10n.tr(
            "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md)."
          ),
          code: "rc-port-open"))
    }

    // The bands on Drive cannot be opened without the image's metadata, which
    // otherwise exists only on the machine's disk - kept out of Time Machine.
    // A stale copy is a backup that cannot be restored after losing the Mac,
    // while every other light is green. Deferred after startup: the stamp
    // keeps its age across a night with the Mac off, and the timer's first
    // run comes 5 min after the machine boots.
    if let metaSyncAge, metaSyncAge > VMLayout.metaSyncMaxAge {
      notReadyYet(
        Problem(
          summary: metaSyncAge.isFinite
            ? L10n.tr(
              "The image's metadata was last copied to Drive %@ ago", formatAge(metaSyncAge))
            : L10n.tr("The image's metadata has never been copied to Drive"),
          detail: L10n.tr(
            "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync",
            VMLayout.remote, VMLayout.metaRemote),
          code: "metadata-sync-stale"))
    }

    // Not a failure that needs fixing - it passes by itself - but while it
    // lasts every "successful" backup exists only on this Mac. Without this
    // the panel stayed green: Time Machine finishes into the machine's
    // buffer, and the guard pauses only at 110 GiB.
    if let uploadLimitAge, uploadLimitAge > 0 {
      problems.append(
        Problem(
          summary: L10n.tr("Google Drive's daily upload limit stops the upload"),
          detail: L10n.tr(
            "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.",
            formatAge(uploadLimitAge), "\(VMGuard.Thresholds().highGiB)"),
          code: "drive-upload-limit"))
    }

    if let uploadStalledFor {
      problems.append(
        Problem(
          summary: L10n.tr("The upload to Google Drive hangs"),
          detail: L10n.tr(
            "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. Check the network, then: cloudmachine-agent vm-status; restarting the machine (prepare-shutdown, limactl start) drops the dead connections.",
            formatAge(uploadStalledFor)),
          code: "upload-stalled"))
    }

    // Space on the Drive. Running out of it stops every upload, and the
    // machine's buffer then fills up - this has to be known EARLIER, not from
    // a failure. The threshold is counted in cycles, not in percent: at a
    // growth of ~600 MB per hour, 30 GB is about two weeks of headroom.
    if let driveFreeBytes {
      let freeGB = Int(driveFreeBytes / 1_073_741_824)
      if freeGB < driveFreeWarningGB {
        problems.append(
          Problem(
            summary: L10n.tr("Google Drive is running out of space (%@ GB)", "\(freeGB)"),
            detail: L10n.tr(
              "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.",
              "\(max(1, freeGB * 1024 / 600 / 24))"),
            code: "drive-low-space"))
      }
    }

    if let machineFreeGB, machineFreeGB < machineFreeWarningGB {
      problems.append(
        Problem(
          summary: L10n.tr(
            "The machine's disk is running out of space (%@ GB)", "\(machineFreeGB)"),
          detail: L10n.tr(
            "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused."
          ),
          code: "machine-low-space"))
    }

    if let localFreeGB, localFreeGB < localFreeWarningGB {
      problems.append(
        Problem(
          summary: L10n.tr("The Mac's disk is running out of space (%@ GB)", "\(localFreeGB)"),
          detail: L10n.tr(
            "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either."
          ),
          code: "local-low-space"))
    }

    return Report(
      problems: problems, lastSuccess: lastSuccess, lastAttempt: lastAttempt, deferred: deferred)
  }

  /// Below this many GB free on Google Drive we report a problem.
  public static let driveFreeWarningGB = 30
  /// Below this many GB free on the Mac we report a problem: the machine's
  /// disk file can still grow by most of its 200 GiB buffer.
  public static let localFreeWarningGB = 120
  /// Below this many GB free in the machine we report a problem. Above the
  /// guard's pause threshold (`VMGuard.Thresholds.minFreeGiB`), so the
  /// watchdog warns before the guard starts braking.
  public static let machineFreeWarningGB = 50

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

    let (lastSuccess, lastAttempt, result) = dates(inPreferences: plist)

    // The machine first: everything below it is asked through it.
    let machineRunning: Bool?
    do {
      machineRunning = (try await VMLayout.instanceStatus()) == "Running"
    } catch {
      machineRunning = nil
    }
    let report = machineRunning == true ? await VMStatus.currentReport() : nil
    let reading = report?.reading
    let servicesHealthy = report.flatMap { VMStatus.servicesHealthy($0.services) }
    let address = machineRunning == true ? await VMLayout.currentAddress() : nil
    let registered = await VMStatus.timeMachineTargetsMachine(address: address)

    var nearFileLimit = false
    if let open = report?.punchfsOpenFiles, let limit = report?.punchfsFileLimit {
      nearFileLimit = Double(open) > Double(limit) * VMStatus.fileWarningRatio
    }

    // Measuring free space can FAIL (statfs returns an error), and then
    // `macFreeGB()` returns `nil`, not a made-up zero.
    let localFree = macFreeGB()

    var health = evaluate(
      lastSuccess: lastSuccess,
      lastAttempt: lastAttempt,
      result: result,
      now: now,
      machineRunning: machineRunning,
      servicesHealthy: machineRunning == true ? servicesHealthy : nil,
      destinationRegistered: registered,
      erroredFiles: reading?.buffer.erroredFiles ?? 0,
      outOfSpace: reading?.buffer.outOfSpace ?? false,
      queueReadable: reading?.buffer.unsentBytes != nil,
      // An unreadable Drive quota is NOT a separate alarm here: when rclone
      // does not respond, harder signals above already say so.
      driveFreeBytes: await driveFreeBytes(),
      localFreeGB: localFree,
      machineFreeGB: reading.map { Int($0.freeBytes / VMGuard.gib) },
      punchfsNearFileLimit: nearFileLimit,
      remoteControlOpen: VMStatus.remoteControlOpenOnMac(),
      metaSyncAge: report.flatMap {
        VMStatus.metaSyncOverdue($0) != nil ? $0.metaSync?.ageSeconds : nil
      },
      uploadLimitAge: report?.uploadLimitAge,
      uploadStalledFor: report.flatMap(VMStatus.uploadStalledFor),
      maxAgeHours: maxAgeHours,
      // The REAL clock, not `now`: tests substitute a `now` from the past, and
      // uptime computed from it would come out negative, i.e. "startup in
      // progress".
      withinStartupGrace: (systemUptime() ?? .infinity) < startupGraceMinutes * 60,
      backupRunning: await TimeMachineStatus.runningState())

    health.problems.append(contentsOf: unmeasuredLocalDiskProblems(localFreeGB: localFree))
    health.problems.append(contentsOf: await MachineBudget.currentProblems())
    return health
  }

  /// Free space on the Mac's data volume, in GB. `nil` = NOT MEASURED (statfs
  /// failed) - never a made-up zero, which would read as "the disk is full".
  public static func macFreeGB() -> Int? {
    var stats = statfs()
    guard statfs("/System/Volumes/Data", &stats) == 0 else { return nil }
    let available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
    return Int(available / 1_073_741_824)
  }

  /// Free space on the Google account (`rclone about`), through the Mac's
  /// rclone. `nil` = no answer, or an account without a limit.
  static func driveFreeBytes() async -> UInt64? {
    guard
      let result = try? await CMTooling.runRclone(
        ["about", "--json", "\(DriveFolder.remoteName):"], timeout: 120),
      result.succeeded
    else { return nil }
    return driveFreeBytes(aboutJSON: result.stdout)
  }

  static func driveFreeBytes(aboutJSON: String) -> UInt64? {
    guard let data = aboutJSON.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    func bytes(_ key: String) -> UInt64? {
      if let v = json[key] as? NSNumber, v.int64Value >= 0 { return UInt64(v.int64Value) }
      return nil
    }
    // `total` is sometimes absent (accounts without a limit) - then there is nothing to watch.
    guard let total = bytes("total"), total > 0 else { return nil }
    let used = bytes("used") ?? 0
    return bytes("free") ?? (total > used ? total - used : 0)
  }

  /// Problem reported when the free-space measurement CANNOT be made.
  ///
  /// `evaluate` treats `localFreeGB: nil` as "not asked" (that has been its
  /// contract from the start, and a dozen or so tests rely on it), but
  /// `currentReport` KNOWS it asked and it did not work. That is a separate
  /// failure: the machine's disk is a file on this disk, and nobody then
  /// knows whether it still has room to grow.
  ///
  /// Split out of `currentReport()` SOLELY so that it can be tested:
  /// `currentReport()` touches rclone, tmutil and the machine.
  static func unmeasuredLocalDiskProblems(localFreeGB: Int?) -> [Problem] {
    guard localFreeGB == nil else { return [] }
    return [
      Problem(
        summary: L10n.tr("Cannot measure free space on the Mac's disk"),
        detail: L10n.tr(
          "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac."
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
