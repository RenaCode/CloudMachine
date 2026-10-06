import ArgumentParser
import CloudMachineCore
import Foundation

/// Subcommands of the Google Drive layer. They replace the scripts in
/// `gdrive/` - from now on launchd and the GUI call only this binary, not the
/// shell.

// MARK: - Buffer

struct MountDrive: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "mount-drive",
    abstract: L10n.tr(
      "Mounts Google Drive with a write buffer. Stays in the foreground (for launchd)."))

  func run() async throws {
    if DriveBufferService.isMounted {
      print(L10n.tr("Already mounted: %@", DriveBufferService.mountPoint.path))
      return
    }

    // The FUSE-T uninstaller deletes the whole contents of /usr/local/lib under
    // its path, including our link - we recreate it before checking anything.
    FuseInstaller.ensureSystemLink()

    // Without FUSE, rclone exits immediately with "cgofuse: cannot find FUSE".
    // The agent has KeepAlive, so it would retry over and over every 30 s and
    // flood the log - better to stop right away and say what is missing.
    let readiness = CMTooling.checkReadiness()
    guard readiness.ready else {
      for (what, how) in zip(readiness.missing, readiness.remedies) {
        FileHandle.standardError.write(Data(L10n.tr("Missing: %@\n  %@\n", what, how).utf8))
      }
      throw ExitCode(1)
    }

    await DriveBufferService.excludeBufferFromTimeMachine()
    let args = try DriveBufferService.prepare()

    // Our own copy of the NFS server, if present - then a separate FUSE-T
    // installation in the system is not needed.
    if FileManager.default.isExecutableFile(atPath: CMTooling.bundledNfsServer.path) {
      setenv("FUSE_NFSSRV_PATH", CMTooling.bundledNfsServer.path, 1)
    }

    // We replace ourselves with rclone instead of supervising it: launchd is
    // meant to watch the process that actually holds the mount, not a middleman.
    let rclone = CMTooling.managedRclonePath.path
    var argv: [UnsafeMutablePointer<CChar>?] = ([rclone] + args).map { strdup($0) }
    argv.append(nil)
    execv(rclone, &argv)

    FileHandle.standardError.write(Data(L10n.tr("Could not start %@\n", rclone).utf8))
    throw ExitCode(1)
  }
}

// MARK: - Backup image

struct CreateImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "create-image",
    abstract: L10n.tr("Creates the backup image on Google Drive. One-off."))

  @Option(name: .long, help: ArgumentHelp(L10n.tr("Declared size in GB (the image is sparse).")))
  var sizeGB: Int = 4000

  func run() async throws {
    let result = await BackupImageService.create(sizeGB: sizeGB)
    print(result.message)
    if result.succeeded {
      print(L10n.tr("Next step: %@, then", "cloudmachine-agent attach-image"))
      print("  sudo tmutil setdestination \(BackupImageService.targetPath.path)")
    } else {
      throw ExitCode(1)
    }
  }
}

struct AttachImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "attach-image",
    abstract: L10n.tr("Attaches the backup image as the Time Machine destination."))

  func run() async throws {
    // Time Machine must not see the destination before the buffer is ready -
    // otherwise it decides that the backup disk has disappeared. How long we
    // wait and for what exactly - see `BufferReadiness`.
    let ready = await BufferReadiness.wait(
      sleep: { seconds in
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      },
      probe: {
        BufferReadiness.isReady(
          mounted: DriveBufferService.isMounted,
          imageVisible: BackupImageService.exists)
      })
    if !ready {
      print(
        L10n.tr(
          "The buffer did not come up within %@ min - not attaching the image.",
          "\(Int(BufferReadiness.defaultTimeout / 60))"))
      print(
        L10n.tr(
          "Time Machine now has NO DESTINATION. Check: %@", "cloudmachine-agent drive-status"))
      throw ExitCode(1)
    }
    let result = await BackupImageService.attach()
    print(result.message)

    // Three cases, not two. This command runs under launchd every 900 s, so
    // its exit code ends up as an entry in `launchd-gdrive-attach.err.log` -
    // the place a person looks when asking "is the backup working". "Image
    // busy with a detach that is in progress right now" is NOT a failure: the
    // next tick in 15 minutes will find the image free and attach it. Recording
    // that as an error is the same pattern this code fights in the other
    // direction - a normal state read as a failure, instead of a missing answer
    // read as an answer.
    //
    // The TYPE of the result (`CMActionResult.Disposition`) decides, not the
    // message text - matching on text breaks with the first rewording of the
    // sentence and nobody notices. The `switch` is exhaustive, so a new case
    // will not slip through here silently.
    switch result.disposition {
    case .ok:
      break
    case .skipped:
      print(L10n.tr("This is not an error - the agent's next run will try again."))
    case .failed:
      throw ExitCode(1)
    }
  }
}

struct DetachImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "detach-image",
    abstract: L10n.tr("Detaches the image and waits until everything reaches Google Drive."))

  @Flag(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("Do not wait for the upload - RISKY, see BackupImageService.detach.")))
  var noWait = false

  func run() async throws {
    let result = await BackupImageService.detach(waitForUpload: !noWait)
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

struct VerifyImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "verify-image",
    abstract:
      L10n.tr(
        "Checks the image's consistency with fsck_apfs (hdiutil verify does not work on a sparsebundle)."
      ))

  func run() async throws {
    let result = await BackupImageService.verify()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Buffer guard

struct BufferGuard: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "buffer-guard",
    abstract:
      L10n.tr(
        "Pauses Time Machine when the unsent backlog grows faster than the upload goes."))

  // The default thresholds come FROM `Thresholds`, which derives them from the
  // buffer size - we do NOT type them in here a second time by hand.
  //
  // The typed-in numbers (150/40/80) matched the derived ones only by
  // accident, for a 100 GB buffer. launchd runs `buffer-guard` WITHOUT
  // arguments, so it was exactly these literals that reached production -
  // deriving the thresholds from `cacheSizeGB` was dead in practice, and the
  // three tests guarding that derivation checked `Thresholds()` directly and
  // passed without touching the path that actually runs. After a change to
  // `cacheSizeGB` the thresholds would have drifted apart silently: the guard
  // would either pause the backup nonstop, or never pause it at all.
  // The thresholds refer to the UNSENT BACKLOG, not to the cache size - the
  // old measure sat at the limit constantly, so the resume threshold was
  // unreachable (one PAUSE and zero RESUMES in the whole log). See
  // `Thresholds.init`.
  @Option(
    name: .long,
    help: ArgumentHelp(L10n.tr("Above this many GB of unsent backlog we pause Time Machine.")))
  var highGB: Int = BufferGuardService.Thresholds().highGB

  @Option(
    name: .long, help: ArgumentHelp(L10n.tr("Below this many GB of unsent backlog we resume.")))
  var lowGB: Int = BufferGuardService.Thresholds().lowGB

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("Below this many GB free on disk we pause regardless of the buffer.")))
  var minFreeGB: Int = BufferGuardService.Thresholds().minFreeGB

  @Option(name: .long, help: ArgumentHelp(L10n.tr("How often to check, in seconds.")))
  var interval: Int = 30

  func run() async throws {
    let guardService = BufferGuardService(
      thresholds: .init(highGB: highGB, lowGB: lowGB, minFreeGB: minFreeGB))
    CMLogger.log(
      "Buffer guard: pause above \(highGB) GB backlog / resume below \(lowGB) GB / min. free on disk \(minFreeGB) GB"
    )

    // Forever: the guard has to outlive every backup, not just the first one.
    while true {
      await guardService.step()
      try? await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
    }
  }
}

// MARK: - Backup cycle watchdog

struct BackupHealthCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "backup-health",
    abstract:
      L10n.tr(
        "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures."
      ))

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("After this many hours without a successful backup we consider the cycle broken.")))
  var maxAgeHours: Double = BackupHealth.maxAgeHours

  @Flag(
    name: .long, help: ArgumentHelp(L10n.tr("Only print the state, without a system notification."))
  )
  var quiet = false

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr(
        "A different Time Machine preferences file - to test the watchdog on a known sample.")))
  var preferences: String = BackupHealth.preferencesPath

  func run() async throws {
    let report = await BackupHealth.currentReport(
      maxAgeHours: maxAgeHours, preferencesFile: preferences)

    // The "watchdog ran" marker - BEFORE printing anything and before deciding
    // the exit code, because a run that found a failure is just as much a run
    // as one that found nothing. Without it, the only symptom of a dead or hung
    // watchdog would be silence - and silence is the normal state here (see
    // `WatchdogHeartbeat`).
    WatchdogHeartbeat.record()

    if let lastSuccess = report.lastSuccess {
      print(L10n.tr("Last successful backup: %@", BackupHealth.stamp(lastSuccess)))
    } else {
      print(L10n.tr("Last successful backup: NONE"))
    }
    if let lastAttempt = report.lastAttempt {
      print(L10n.tr("Last attempt:           %@", BackupHealth.stamp(lastAttempt)))
    }

    // Deferred for the startup period - not a failure, but we do not hide them.
    for problem in report.deferred {
      print(L10n.tr("WAITING (system startup): %@", problem.summary))
    }

    guard !report.healthy else {
      print(L10n.tr("Backup cycle: OK"))
      if !quiet { await HealthAlert.report(report) }
      return
    }

    for problem in report.problems {
      print(L10n.tr("FAILURE: %@", problem.summary))
      print(L10n.tr("         %@", problem.detail))
    }
    if !quiet { await HealthAlert.report(report) }

    // A non-zero exit code, so that launchd, `&&` in a script and a person
    // looking at `echo $?` get the same signal as the text above.
    throw ExitCode(1)
  }
}

// MARK: - Safe shutdown

struct PrepareShutdown: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "prepare-shutdown",
    abstract: L10n.tr(
      "Prepares for a restart: pauses the backup, detaches the image and waits for the upload."))

  func run() async throws {
    // The order is not arbitrary. First Time Machine stops adding new writes,
    // only then do we detach the image - otherwise the detach would fight with
    // the running backup.
    if await TimeMachineStatus.isRunning() {
      print(L10n.tr("Pausing the backup..."))
      _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 120)
      try? await Task.sleep(nanoseconds: 3_000_000_000)
    }

    print(L10n.tr("Detaching the image and waiting for the upload..."))
    let result = await BackupImageService.detach()
    print(result.message)

    guard result.succeeded else {
      print("")
      print(L10n.tr("Do NOT restart yet - the buffer holds data that has not reached Drive."))
      print(L10n.tr("Check the state:  %@", "cloudmachine-agent drive-status"))
      throw ExitCode(1)
    }

    print("")
    print(
      L10n.tr(
        "Safe to restart. After startup the agents will bring up the buffer and attach the image themselves."
      ))
  }
}

// MARK: - Status

struct DriveStatus: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "drive-status",
    abstract: L10n.tr("State of the buffer, the upload queue and Time Machine."))

  func run() async throws {
    let readiness = CMTooling.checkReadiness()
    print(
      L10n.tr(
        "Tools:            %@",
        readiness.ready
          ? "OK" : L10n.tr("missing: %@", readiness.missing.joined(separator: ", "))))
    let mounted = DriveBufferService.mountedState()
    print(L10n.tr("Drive mount:      %@", StatusLines.mounted(mounted)))
    print(
      L10n.tr(
        "Drive folder:     %@",
        "\(DriveBufferService.remoteName):\(DriveBufferService.remotePath)"))
    // Since 26.09.2026 the readability probe has a time limit - which is why
    // this tool does not hang on a dead mount (on 25.09.2026 it hung for over
    // 25 s and had to be killed), but reports that there is no answer.
    let image = await BackupImageService.attachmentReading()
    print(
      L10n.tr(
        "Image attached:   %@",
        BackupImageService.describe(image.attachment, probeTimedOut: image.probeTimedOut)))

    // We read the queue BEFORE the buffer lines, because both of them use it.
    // A second query to rclone would cost up to 60 s with a clogged buffer
    // (see `DriveBufferService.queueStats`).
    let queueStats = await DriveBufferService.queueStats()

    // Two lines, because these are TWO DIFFERENT quantities. A single line
    // "Buffer: 103 GB of 100G" looked like an answer to "is the upload keeping
    // up", and it was not: the cache size sits at the limit constantly. The
    // buffer guard made decisions on that number and that is why it never
    // resumed the backup even once.
    print(
      L10n.tr(
        "Cache on disk:    %@",
        StatusLines.cacheSize(
          BufferGuardService.cacheSizeGB(stats: queueStats),
          limitGB: DriveBufferService.cacheSizeGB)))
    print(
      L10n.tr(
        "To upload:        %@",
        StatusLines.backlog(
          BufferGuardService.backlogGB(stats: queueStats), items: queueStats?.unsentItems)))
    // NOT `\(BufferGuardService.freeGB()) GB` - that returns `Int?` since a
    // missing measurement stopped pretending to be zero, and interpolating the
    // optional value printed `Free on disk: Optional(427) GB`. The compiler
    // only said so with a warning, so it stopped neither the build nor the
    // tests.
    print(L10n.tr("Free on disk:     %@", StatusLines.freeDisk(BufferGuardService.freeGB())))

    if let stats = queueStats {
      print(
        L10n.tr(
          "Upload queue:     %@ in progress, %@ queued, %@ errors", "\(stats.uploadsInProgress)",
          "\(stats.uploadsQueued)", "\(stats.erroredFiles)"))
    } else {
      print(L10n.tr("Upload queue:     (rc interface unreachable)"))
    }

    let safe = await BackupImageService.safeToRebootNow()
    print(
      L10n.tr(
        "Restart without asking: %@",
        safe ? L10n.tr("YES - queue empty") : L10n.tr("NO - run prepare-shutdown first")))

    // The same answer as on the card in the UI - one source, so that the CLI
    // and the GUI cannot claim different things about the same state.
    let upload = UploadState.from(
      // `UploadState` has no "unknown whether mounted" state, and adding it
      // would touch files outside my scope. `?? false` then gives `.mountDown`
      // ("Upload is not working") - so it warns instead of reassuring, and the
      // "Drive mount" line above already says outright that it is UNKNOWN. A
      // false alarm is the right direction of error here.
      mounted: mounted ?? false,
      queueKnown: queueStats != nil,
      queued: queueStats?.uploadsQueued ?? 0,
      inProgress: queueStats?.uploadsInProgress ?? 0,
      failedFiles: queueStats?.erroredFiles ?? 0,
      bufferOutOfSpace: queueStats?.outOfSpace ?? false,
      driveFull: DriveBufferService.hitStorageQuota(),
      dailyQuotaExhausted: DriveBufferService.uploadStalled())
    print(L10n.tr("Upload:           %@", upload.headline))
    if !upload.isNominal {
      print("                  \(upload.explanation.replacingOccurrences(of: "\n", with: " "))")
    }

    if let mountPoint = await TimeMachineStatus.currentDestinationMountPoint() {
      print(L10n.tr("TM destination:   %@", mountPoint))
    } else {
      print(L10n.tr("TM destination:   none"))
    }
    if await TimeMachineStatus.isRunning(), let progress = await TimeMachineStatus.currentProgress()
    {
      let percent = (progress.percent ?? 0) * 100
      print(
        L10n.tr(
          "Backup:           running, %@%% (%@)", String(format: "%.1f", percent),
          progress.phase ?? "?"))
    } else {
      print(L10n.tr("Backup:           not running"))
    }
    // Who watches the watchdog. Without this line "no alarm" meant both
    // "the backup works" and "nobody checked" at once - see `WatchdogHeartbeat`.
    print(L10n.tr("Backup watchdog:  %@", StatusLines.watchdogRun(WatchdogHeartbeat.current())))

    // At the very end and not aligned to the column - this is not another
    // status line but something meant to interrupt the reading. Since recently
    // `HealthAlert` does not close the case with a marker until the
    // notification has been delivered, so an undelivered alarm no longer gets
    // lost for 12 h - but without this block nobody would find out about it,
    // because a system notification that failed is by definition not seen.
    for line in StatusLines.undeliveredAlert(HealthAlert.lastDeliveryFailure()) {
      print(line)
    }
  }
}

// MARK: - FUSE installation

struct InstallFuse: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-fuse",
    abstract: L10n.tr(
      "Pulls FUSE-T into CloudMachine, so there is no separate app in the system."))

  func run() async throws {
    let result = await FuseInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - rclone installation

struct InstallRclone: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-rclone",
    abstract: L10n.tr(
      "Downloads the official rclone binary (the Homebrew one cannot mount)."))

  func run() async throws {
    let result = await RcloneInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Version

/// Answers the question "is what runs the same as what is in the repository".
///
/// `1.1.0` alone does not answer it - so we print the commit and the state of
/// the tree at build time, and with no bundle we say outright that it is a
/// build from the working tree, instead of making up a number.
struct Version: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "version",
    abstract: L10n.tr(
      "Prints the version, the build number and the commit this binary was built from."))

  @Flag(name: .long, help: ArgumentHelp(L10n.tr("Only one line, without a description.")))
  var short = false

  func run() async throws {
    guard let version = AppVersionReader.current() else {
      print(L10n.tr("Build from the working tree (outside a bundle) - no version data."))
      return
    }
    guard !short else {
      print(version.summary)
      return
    }
    print(L10n.tr("Version: %@", version.shortVersion))
    print(L10n.tr("Build:   %@", version.build))
    print(L10n.tr("Commit:  %@", version.commit))
    if version.dirty {
      print("")
      print(
        L10n.tr(
          "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs."
        ))
    }
  }
}
