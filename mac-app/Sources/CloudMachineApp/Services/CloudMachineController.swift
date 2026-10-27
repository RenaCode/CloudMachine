import CloudMachineCore
import Foundation
import SwiftUI

/// Connects the interface to the services in `CloudMachineCore`. It contains no backup
/// logic itself - what it knows about Google Drive and the machine lives in the services,
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
  /// reads the Time Machine preferences file, asks the machine, rclone for the Drive capacity
  /// and tmutil for the backup destination - that is seconds of work, not microseconds. The backup
  /// cycle is hourly, so an answer from five minutes ago is just as
  /// good as one from five seconds ago.
  private static let backupCycleInterval: TimeInterval = 300
  private var backupCycleCheckedAt: Date?
  /// One failed read of the Time Machine preferences is not "no Full Disk Access".
  private var preferencesReads = BackupHealth.ReadConfirmation()

  // MARK: - Refresh cycle

  func startAutoRefresh(interval: TimeInterval = 10) {
    refreshTask?.cancel()
    refreshTask = Task { [weak self] in
      // Homebrew quits the app for an upgrade and reopens it afterwards, so
      // this is the first code that runs after the bundle was replaced - see
      // `AgentRepair` for what breaks if nobody reloads the agents.
      await AgentRepair.afterLaunch()
      var cycles = 0
      while !Task.isCancelled {
        await self?.refreshAll()
        // An agent can stop being startable later too, so check every few minutes.
        cycles += 1
        if cycles % 30 == 0 { await AgentRepair.repairBroken() }
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
    await refreshMachine()
    await refreshTimeMachine()
    await refreshProgress()
    await refreshBackupCycle()
    // A cheap read of one small file - the watchdog leaves the date of EVERY
    // run in it. See `WatchdogHeartbeat`: without this the only symptom of an
    // unloaded watchdog is silence, and silence is the normal state here.
    status.watchdog = WatchdogHeartbeat.current()
    status.lastRefresh = Date()
  }

  /// Age of the last SUCCESSFUL backup. The source is the same one
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
    // No answer keeps what we knew: flipping to "not connected" would offer
    // the "Connect Google Drive" card on a working installation.
    if let configured = await RemoteConfigurer.isConfigured(remoteName: DriveFolder.remoteName) {
      status.remoteConfigured = configured
    }
    // A REAL read of the file that actually matters - see
    // `BackupHealth.preferencesReadable`.
    status.hasFullDiskAccess = preferencesReads.readable(
      after: BackupHealth.preferencesReadable(), shown: status.hasFullDiskAccess)
    status.driveFolderPath = VMLayout.remote
    if !status.remoteConfigured, status.suggestedDriveFolder.isEmpty {
      let key = await MachineIdentity.currentKey()
      status.suggestedDriveFolder = DriveFolder.isValid(key) ? key : "this-mac"
    }
    status.agentsInstalled = await LaunchdInstaller.isInstalled(
      label: "com.renacode.cloudmachine.vm-guard")
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
  /// working, so entering new values alone changes NOTHING on a connected Mac -
  /// and must not lead to replacing the connection there (see
  /// `RemoteConfigurer.credentialsSavedMessage`).
  func saveCredentials(clientID: String, clientSecret: String) async -> String {
    do {
      try await RemoteConfigurer.storeCredentials(
        clientID: clientID, clientSecret: clientSecret)
      await refreshCredentials()
      return RemoteConfigurer.credentialsSavedMessage(
        remoteConfigured: await RemoteConfigurer.isConfigured(remoteName: DriveFolder.remoteName))
    } catch {
      return L10n.tr("Not saved: %@", error.localizedDescription)
    }
  }

  /// The machine: Lima's view of it, then - only when it runs - one script in
  /// it for the services, the upload buffer and the image, and its address.
  private func refreshMachine() async {
    var machine = MachineStatus()
    let instance: String??
    do {
      instance = .some(try await VMLayout.instanceStatus())
    } catch {
      instance = .none
    }
    machine.state = MachineState.from(instanceStatus: instance)
    if machine.isRunning, let report = await VMStatus.currentReport() {
      machine.services = report.services
      machine.reading = report.reading
      machine.punchfsOpenFiles = report.punchfsOpenFiles
      machine.punchfsFileLimit = report.punchfsFileLimit
      machine.bundlePrepared = report.bundlePrepared
      machine.imageCount = report.imageCount
      machine.address = await VMLayout.currentAddress()
    }
    status.machine = machine
    status.remoteControlOpen = VMStatus.remoteControlOpenOnMac()
  }

  /// `destinationsReading()` keeps "no answer" apart from "no destination":
  /// the panel must not tell a person to register a destination that is intact
  /// while it was the read that hung. A destination pointing somewhere else is
  /// still `.notRegistered`.
  private func refreshTimeMachine() async {
    let destinations = await TimeMachineStatus.destinationsReading()
    status.timeMachineState = TimeMachineState.from(destinations, address: status.machine.address)
    // Cheap reads only: the limit from machines.json, the last stored usage
    // measurement and `tmutil destinationinfo`. Measuring the Drive folder
    // is the watchdog's job (or the Measure button).
    status.budgetLimitGB = MachineBudget.limitGB()
    status.budgetUsage = MachineBudget.storedUsage()
    let ours = destinations.flatMap { VMStatus.machineDestination(in: $0, address: nil) }
    status.timeMachineQuotaGB = ours?.quotaGB
    status.timeMachineDestinationID = ours?.id
  }

  /// Stores this Mac's limit, then measures the Drive folder so the card
  /// shows usage against it straight away.
  func saveLimit(gb: Int) async {
    await run(L10n.tr("Saving the space limit"), log: "Saving the space limit") {
      do {
        try MachineBudget.setLimitGB(gb)
      } catch let error as MachineBudget.BudgetError {
        return CMActionResult(succeeded: false, message: error.message)
      } catch {
        return CMActionResult(succeeded: false, message: error.localizedDescription)
      }
      await MachineBudget.measureUsage()
      return CMActionResult(
        succeeded: true, message: L10n.tr("Limit for this Mac: %@ GB.", "\(gb)"))
    }
  }

  func measureDriveUsage() async {
    await run(L10n.tr("Measuring usage on Google Drive"), log: "Measuring usage on Google Drive") {
      let usage = await MachineBudget.measureUsage()
      return CMActionResult(
        succeeded: usage != nil,
        message: usage != nil
          ? L10n.tr("Measured.") : L10n.tr("Google Drive did not answer - try again later."))
    }
  }

  /// The quota command to copy, when the quota does not match the limit yet.
  var quotaCommand: String? {
    guard let limit = status.budgetLimitGB, let id = status.timeMachineDestinationID,
      !MachineBudget.quotaMatches(currentQuotaGB: status.timeMachineQuotaGB, limitGB: limit)
    else { return nil }
    return MachineBudget.setQuotaCommand(destinationID: id, limitGB: limit)
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
    let machineExists: Bool?
    switch status.machine.state {
    case .unknown, .noAnswer: machineExists = nil
    case .notCreated: machineExists = false
    case .notRunning, .running: machineExists = true
    }
    let address = status.machine.address
    let password = VMSetup.storedPassword()
    return SetupPlan.steps(
      SetupPlan.Inputs(
        hasRclone: CMTooling.hasManagedRclone, remoteConfigured: status.remoteConfigured,
        hasLima: VMLayout.limactlPath != nil, machineExists: machineExists,
        machineRunning: status.machine.isRunning, hasFullDiskAccess: status.hasFullDiskAccess,
        agentsInstalled: status.agentsInstalled,
        timeMachineNotPointingHere: status.timeMachineState == .notRegistered,
        bundleNeedsPreparing: status.machine.bundleNeedsPreparing,
        connectCommand: connectDriveCommand,
        setDestinationCommand: address.flatMap { address in
          password.map { VMSetup.destinationCommand(password: $0, address: address) }
        },
        maskedSetDestinationCommand: address.map { VMSetup.maskedDestinationCommand(address: $0) })
    )
  }

  func installRclone() async {
    await run(L10n.tr("Installing rclone"), log: "Installing rclone") {
      await RcloneInstaller.install()
    }
  }

  /// Connecting to Google Drive is done from the terminal, not from the GUI: OAuth opens
  /// the browser and waits for approval, and we read the keys from the Keychain.
  var connectDriveCommand: String { connectDriveCommand(folder: nil) }

  /// With `folder`, the command fixes this Mac's Drive folder name. The name
  /// is validated by `DriveFolder.isValid` (letters, digits, dashes), so it
  /// needs no shell quoting.
  func connectDriveCommand(folder: String?) -> String {
    SetupPlan.connectCommand(
      agent: CMPaths.agentBinaryPath?.path ?? "cloudmachine-agent", folder: folder)
  }

  /// `vm-setup` from the app. The `tmutil` command it returns holds the SMB
  /// password, so it is NOT part of the message (which goes to the log and on
  /// screen); the setup card builds it from the password file instead.
  func setUpMachine() async {
    await run(L10n.tr("Setting up the CloudMachine machine"), log: "Setting up the machine") {
      let result = await VMSetup.run(replaceRcloneConfig: false)
      return CMActionResult(
        succeeded: result.succeeded, message: result.messages.joined(separator: "\n"))
    }
  }

  func startMachine() async {
    await run(L10n.tr("Starting the CloudMachine machine"), log: "Starting the machine") {
      await VMLayout.start()
    }
  }

  /// `vm-prepare-bundle`: refuses by itself while Time Machine backs up to the machine.
  func prepareBundle() async {
    await run(L10n.tr("Converting the image to 32 MB bands"), log: "Preparing the image") {
      let outcome = await VMBundlePrep.run(bundleOverride: nil)
      return CMActionResult(succeeded: outcome.succeeded, message: outcome.message)
    }
  }

  /// Stops the backup, waits a while for the upload, then stops the machine
  /// (`VMShutdown`). The menu asks for confirmation first.
  func prepareForRestart() async {
    await run(L10n.tr("Preparing for restart"), log: "Preparing for restart") {
      await VMShutdown.perform()
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
