import CloudMachineCore
import Foundation
import SwiftUI

/// Connects the interface to the services in `CloudMachineCore`. It contains no backup
/// logic itself - what it knows about Google Drive, the image and the buffer lives in the services,
/// so that the CLI and the GUI do exactly the same thing.
@MainActor
final class CloudMachineController: ObservableObject {
  let status = AppStatus()

  /// State of our own Google credentials - only "present / absent", never the value.
  @Published var credentials = RemoteConfigurer.CredentialsState(
    hasClientID: false, hasClientSecret: false)

  private var refreshTask: Task<Void, Never>?
  private var lastBytesDone: Double?
  private var lastBytesSampledAt: Date?

  /// How often we refresh the answer to "when was a backup last made".
  ///
  /// Less often than the rest of the panel (10 s), and deliberately: `BackupHealth.currentReport()`
  /// reads the Time Machine preferences file, asks rclone for the Drive capacity
  /// and tmutil for the backup destination - that is seconds of work, not microseconds. The backup
  /// cycle is hourly, so an answer from five minutes ago is just as
  /// good as one from five seconds ago.
  private static let backupCycleInterval: TimeInterval = 300
  private var backupCycleCheckedAt: Date?

  // MARK: - Refresh cycle

  func startAutoRefresh(interval: TimeInterval = 10) {
    refreshTask?.cancel()
    refreshTask = Task { [weak self] in
      while !Task.isCancelled {
        await self?.refreshAll()
        try? await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
      }
    }
  }

  func stopAutoRefresh() {
    refreshTask?.cancel()
    refreshTask = nil
  }

  func refreshAll() async {
    await refreshCredentials()
    await refreshDependencies()
    await refreshBuffer()
    await refreshTimeMachine()
    await refreshProgress()
    await refreshBackupCycle()
    // A cheap read of one small file - the watchdog leaves the date of EVERY
    // run in it. See `WatchdogHeartbeat`: without this the only symptom of an
    // unloaded watchdog is silence, and silence is the normal state here.
    status.watchdog = WatchdogHeartbeat.current()
    status.lastRefresh = Date()
  }

  /// Age of the last SUCCESSFUL backup.
  ///
  /// The panel did not ask this question even once (see `BackupCycleStatus`),
  /// so the failure "everything attached, and no backup for two days" looked
  /// in it exactly the same as a working system. The source is the same one
  /// the `backup-health` watchdog uses - a single source of truth, so that
  /// the panel and the watchdog cannot claim different things about the same thing.
  private func refreshBackupCycle(force: Bool = false) async {
    if !force, let at = backupCycleCheckedAt,
      Date().timeIntervalSince(at) < Self.backupCycleInterval
    {
      return
    }
    backupCycleCheckedAt = Date()

    let report = await BackupHealth.currentReport()
    var cycle = BackupCycleStatus()
    // "Read" means here: the preferences file could be read. When it
    // cannot (most often missing Full Disk Access), `currentReport`
    // reports that as a problem and gives NO date - then `known`
    // stays `false` instead of pretending there simply is no backup.
    cycle.known = report.preferencesReadable
    cycle.lastSuccess = report.lastSuccess
    cycle.problems = report.problems.map(\.summary)
    cycle.checkedAt = Date()
    status.backupCycle = cycle
  }

  // MARK: - Individual reads

  private func refreshDependencies() async {
    let readiness = CMTooling.checkReadiness()
    status.dependencyState =
      readiness.ready ? .ready : .missing(readiness.missing, readiness.remedies)
    status.remoteConfigured = await RemoteConfigurer.isConfigured(
      remoteName: DriveBufferService.remoteName)
    // A REAL read of the file that actually matters - see
    // `BackupHealth.preferencesReadable`. Previously this was
    // `isReadableFile` (that is, `access(R_OK)`) on the DIRECTORY
    // `~/Library/Application Support/com.apple.TCC`: the wrong path and a check
    // that proves nothing under TCC.
    status.hasFullDiskAccess = BackupHealth.preferencesReadable()
    status.agentsInstalled = await LaunchdInstaller.isInstalled(
      label: "com.renacode.cloudmachine.gdrive-buffer")
  }

  /// State of our own OAuth credentials. We check ONLY that the entry exists -
  /// reaching for the value itself can raise a Keychain prompt, and that prompt
  /// has no right to pop up during an ordinary interface refresh.
  private func refreshCredentials() async {
    credentials = await RemoteConfigurer.credentialsState()
  }

  /// Saves the credentials and refreshes the state.
  ///
  /// Does not reconfigure the remote: a token issued for the old `client_id` keeps
  /// working, so entering new values alone changes NOTHING until
  /// `configure-remote --replace-existing` is run. We say so plainly.
  func saveCredentials(clientID: String, clientSecret: String) async -> String {
    do {
      try await RemoteConfigurer.storeCredentials(
        clientID: clientID, clientSecret: clientSecret)
      await refreshCredentials()
      return L10n.tr(
        "Saved in the Keychain. Note: the existing connection still uses the old client_id - to use the new one, run configure-remote --replace-existing."
      )
    } catch {
      return L10n.tr("Not saved: %@", error.localizedDescription)
    }
  }

  private func refreshBuffer() async {
    let stats = await DriveBufferService.queueStats()
    var buffer = BufferStatus()
    buffer.mounted = DriveBufferService.isMounted
    // A dead image (in the mount table, but unreadable) counts as
    // NOT ATTACHED - from Time Machine's point of view that is exactly what it is.
    //
    // `await`, not a computed property: this function runs on `@MainActor`
    // every 10 s, and the probe contains a `read()` on FUSE-T. Until 26.09.2026 this was
    // an ordinary, blocking read - a wedged volume froze the whole interface
    // (window movement, menus, buttons) for as long as the I/O took, that is, potentially
    // forever. Now the probe runs on its own thread with a time limit, and the panel
    // waits for the result without blocking the main thread.
    buffer.imageAttached = await BackupImageService.attachment().isUsable
    // We take the buffer size from rclone; walking the directory ourselves means 6504
    // stat calls every 10 seconds on the disk the backup is being written to.
    buffer.sizeGB = BufferGuardService.bufferGB(stats: stats)
    buffer.freeDiskGB = BufferGuardService.freeGB()
    // Two separate questions, because the answers mean different things: lack of space has to be
    // fixed, the daily limit passes on its own.
    buffer.driveFull = DriveBufferService.hitStorageQuota()
    buffer.dailyQuotaExhausted = DriveBufferService.uploadStalled()
    // Distinguishes "read" from "came out as zero" - without it, no answer from
    // rclone looked like an empty queue.
    buffer.queueKnown = stats != nil
    if let stats {
      buffer.uploadsQueued = stats.uploadsQueued
      buffer.uploadsInProgress = stats.uploadsInProgress
      buffer.erroredFiles = stats.erroredFiles
      buffer.outOfSpace = stats.outOfSpace
    }
    status.buffer = buffer
    status.imageExists =
      buffer.mounted
      ? FileManager.default.fileExists(atPath: BackupImageService.imagePath.path) : nil
  }

  /// `destinationReading()`, and NOT `currentDestinationMountPoint()`.
  ///
  /// The latter returns `nil` both when there is no destination and when there is no
  /// answer from tmutil, so the panel showed "Time Machine does not point to
  /// CloudMachine" even when it knew NOTHING about the destination. The direction of the error
  /// was safe (a false alarm instead of false calm), but the message
  /// sent a person off to register a destination that is intact. The distinction has existed
  /// in `DestinationReading` since 23.09.2026 and the `backup-health` watchdog already
  /// uses it - the panel is the last place that conflated these two things.
  ///
  /// The destination may also exist and point somewhere else - then there is no backup on Drive,
  /// even though Time Machine looks configured; that is still
  /// `.notRegistered`.
  private func refreshTimeMachine() async {
    status.timeMachineState = TimeMachineState.from(
      await TimeMachineStatus.destinationReading(),
      target: BackupImageService.targetPath.path)
  }

  private func refreshProgress() async {
    guard await TimeMachineStatus.isRunning(),
      let progress = await TimeMachineStatus.currentProgress()
    else {
      status.backupProgress = nil
      lastBytesDone = nil
      lastBytesSampledAt = nil
      return
    }

    var info = BackupProgressInfo(
      phase: progress.phase, percent: progress.percent, bytesDone: progress.bytes,
      bytesTotal: progress.totalBytes, filesDone: progress.files, filesTotal: progress.totalFiles,
      timeRemainingSeconds: progress.timeRemainingSeconds)

    // tmutil does not report the rate - we compute it from the difference between readings.
    if let bytes = progress.bytes, let previous = lastBytesDone, let at = lastBytesSampledAt {
      let seconds = Date().timeIntervalSince(at)
      if seconds > 0, bytes >= previous {
        info.transferRateMBs = (bytes - previous) / seconds / 1_048_576
      }
    }
    lastBytesDone = progress.bytes
    lastBytesSampledAt = Date()
    status.backupProgress = info
  }

  // MARK: - Actions

  func installFuse() async {
    await run(L10n.tr("Installing FUSE-T"), log: "Installing FUSE-T") {
      await FuseInstaller.install()
    }
  }

  /// Opens System Settings at Full Disk Access. Granting it is a decision
  /// only the user can make; the app can only take them to the right pane.
  func openFullDiskAccessSettings() {
    if let url = URL(
      string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
    {
      NSWorkspace.shared.open(url)
    }
  }

  var setupPlan: [SetupStep] {
    SetupPlan.steps(
      SetupPlan.Inputs(
        hasRclone: CMTooling.hasManagedRclone, hasFuse: CMTooling.hasFuse,
        remoteConfigured: status.remoteConfigured, hasFullDiskAccess: status.hasFullDiskAccess,
        agentsInstalled: status.agentsInstalled, mounted: status.buffer.mounted,
        imageExists: status.imageExists, imageAttached: status.buffer.imageAttached,
        timeMachineNotPointingHere: status.timeMachineState == .notRegistered,
        connectCommand: connectDriveCommand, setDestinationCommand: setDestinationCommand))
  }

  func installRclone() async {
    await run(L10n.tr("Installing rclone"), log: "Installing rclone") {
      await RcloneInstaller.install()
    }
  }

  /// Connecting to Google Drive is done from the terminal, not from the GUI: OAuth opens
  /// the browser and waits for approval, and we read the keys from the Keychain.
  var connectDriveCommand: String {
    "\(CMPaths.agentBinaryPath?.path ?? "cloudmachine-agent") configure-remote"
  }

  func createImage(sizeGB: Int) async {
    await run(L10n.tr("Creating the backup image"), log: "Creating the backup image") {
      await BackupImageService.create(sizeGB: sizeGB)
    }
  }

  func attachImage() async {
    await run(L10n.tr("Attaching the image"), log: "Attaching the image") {
      await BackupImageService.attach()
    }
  }

  func verifyImage() async {
    await run(L10n.tr("Checking image consistency"), log: "Checking image consistency") {
      await BackupImageService.verify()
    }
  }

  func installAgents() async {
    await run(L10n.tr("Installing launchd agents"), log: "Installing launchd agents") {
      await LaunchdInstaller.install()
    }
  }

  func startBackup() async {
    await run(L10n.tr("Starting backup"), log: "Starting backup") {
      let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["startbackup"], timeout: 60)
      return CMActionResult(
        succeeded: result?.succeeded == true,
        message: result?.succeeded == true
          ? L10n.tr("Backup started.") : L10n.tr("Could not start the backup."))
    }
  }

  func stopBackup() async {
    await run(L10n.tr("Stopping backup"), log: "Stopping backup") {
      let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 60)
      return CMActionResult(
        succeeded: result?.succeeded == true,
        message: result?.succeeded == true
          ? L10n.tr("Backup stopped.") : L10n.tr("Could not stop the backup."))
    }
  }

  /// A command the user has to paste themselves - `tmutil setdestination`
  /// requires root, and the app has no sudoers rule.
  var setDestinationCommand: String {
    "sudo tmutil setdestination '\(BackupImageService.targetPath.path)'"
  }

  // MARK: - Shared action handling

  /// `label` is shown in the interface (translated); `logName` goes to the log,
  /// which stays in English whatever the system language.
  private func run(
    _ label: String, log logName: String, _ action: () async -> CMActionResult
  ) async {
    status.isBusy = true
    status.busyLabel = label
    status.errorMessage = nil
    defer {
      status.isBusy = false
      status.busyLabel = ""
    }

    let result = await action()
    status.lastAction = LastRunResult(
      succeeded: result.succeeded, message: result.message, date: Date())
    if !result.succeeded { status.errorMessage = result.message }
    CMLogger.log("[gui] \(logName): \(result.message)")
    await refreshAll()
  }
}
