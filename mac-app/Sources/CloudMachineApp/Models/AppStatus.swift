import CloudMachineCore
import Foundation

/// Readiness of the tools without which nothing will run.
enum DependencyState: Equatable {
  case unknown
  case checking
  /// What is missing and how to fix it - pairs of (missing item, command).
  case missing([String], [String])
  case ready
}

/// The Lima machine itself, as `limactl list` reports it.
enum MachineState: Equatable {
  case unknown
  /// `limactl` did not answer (or is not installed) - nothing is known.
  case noAnswer
  /// There is no machine `cmsmb` yet: `vm-setup` creates it.
  case notCreated
  /// The machine exists but does not run; Lima's word for it (`Stopped`, ...).
  case notRunning(String)
  case running

  /// Translates the `limactl list` answer. Pure, so a test can show that a
  /// missing answer does not pass for a stopped machine.
  static func from(instanceStatus: String??) -> MachineState {
    switch instanceStatus {
    case .none: return .noAnswer
    case .some(.none): return .notCreated
    case .some(.some("Running")): return .running
    case .some(.some(let other)): return .notRunning(other)
    }
  }
}

enum TimeMachineState: Equatable {
  case unknown
  /// No Time Machine destination is the machine's share - there is effectively no backup.
  case notRegistered
  /// `tmutil` DID NOT ANSWER within the time limit, so we know nothing about the destination.
  ///
  /// A separate state, because a missing answer has no right to pretend to be a
  /// result: "Time Machine does not point to CloudMachine" sends a person off to
  /// register a destination that may be intact, while it was the read that hung.
  case noAnswer
  case registered(url: String)
}

extension TimeMachineState {
  /// Translates the `tmutil destinationinfo` answer into a panel state. Pure,
  /// so a test can show that THREE answers give THREE states.
  ///
  /// `address` is the machine's current address; without it any CloudMachine
  /// share counts (see `VMStatus.isMachineShare`).
  static func from(_ destinations: [TimeMachineStatus.Destination]?, address: String?)
    -> TimeMachineState
  {
    guard let destinations else { return .noAnswer }
    guard let ours = VMStatus.machineDestination(in: destinations, address: address),
      let url = ours.url
    else { return .notRegistered }
    return .registered(url: url)
  }
}

/// What the machine said about itself: services, the upload buffer, the image.
struct MachineStatus: Equatable {
  var state: MachineState = .unknown
  var address: String?
  /// `systemctl is-active` per unit; empty = not read.
  var services: [String: String] = [:]
  /// `nil` = no reading (the machine is down or rclone did not answer).
  var reading: VMLayout.Reading?
  var punchfsOpenFiles: Int?
  var punchfsFileLimit: Int?
  var bundlePrepared: Bool?
  var imageCount: Int?

  var isRunning: Bool { state == .running }

  /// `nil` = not known (no answer from the machine).
  var servicesHealthy: Bool? {
    guard isRunning, !services.isEmpty else { return nil }
    return VMStatus.servicesHealthy(services)
  }

  /// Whether the counters below come from a reading at all. A fresh
  /// `MachineStatus` has nothing but zeros, which are not a measurement.
  var queueKnown: Bool { reading?.buffer.unsentBytes != nil }

  var unsentGiB: Int? { reading?.buffer.unsentBytes.map { Int($0 / VMGuard.gib) } }
  var cacheGiB: Int? { reading.map { Int($0.buffer.bytesUsed / VMGuard.gib) } }
  var freeGiB: Int? { reading.map { Int($0.freeBytes / VMGuard.gib) } }
  var erroredFiles: Int { reading?.buffer.erroredFiles ?? 0 }
  var uploadsQueued: Int { reading?.buffer.uploadsQueued ?? 0 }
  var uploadsInProgress: Int { reading?.buffer.uploadsInProgress ?? 0 }

  var draining: Bool { (reading?.buffer.unsentBytes ?? 0) > 0 }

  /// Time Machine has created its image, and it still has 875 MB bands on the
  /// machine's local disk: `vm-prepare-bundle` is due.
  var bundleNeedsPreparing: Bool {
    bundlePrepared == false && (imageCount ?? 0) > 0
  }

  var punchfsNearLimit: Bool {
    guard let open = punchfsOpenFiles, let limit = punchfsFileLimit else { return false }
    return Double(open) > Double(limit) * VMStatus.fileWarningRatio
  }

  /// The "To upload" row. An empty queue is "everything uploaded" only when
  /// rclone abandoned nothing on the way: an abandoned band drops out of the
  /// queue exactly like an uploaded one.
  var queueSummary: String {
    guard let unsent = unsentGiB else { return L10n.tr("not read") }
    if draining {
      return L10n.tr(
        "%@ GiB in %@ bands, %@ uploading", "\(unsent)", "\(uploadsQueued)",
        "\(uploadsInProgress)")
    }
    if erroredFiles > 0 {
      return L10n.tr("%@ fragments abandoned - only in the machine", "\(erroredFiles)")
    }
    return L10n.tr("Everything uploaded")
  }

  /// The single source of truth on whether the backup reaches the Drive - and why not.
  ///
  /// `driveFull` and `dailyQuotaExhausted` are not read here: the rclone log
  /// that tells them lives in the machine. A stalled upload still shows - the
  /// backlog grows and the guard pauses Time Machine.
  var uploadState: UploadState {
    UploadState.from(
      mounted: isRunning && services["rclone-tm"] == "active",
      queueKnown: queueKnown,
      queued: uploadsQueued,
      inProgress: uploadsInProgress,
      failedFiles: erroredFiles,
      bufferOutOfSpace: reading?.buffer.outOfSpace ?? false,
      driveFull: false,
      dailyQuotaExhausted: false)
  }
}

/// Whether the backup cycle is STILL working - measured by the date of the last SUCCESSFUL backup.
///
/// The state of the machine at this moment can be flawless while Time Machine
/// has not finished a backup for two days; this is the one measure that moves
/// only on success.
struct BackupCycleStatus: Equatable {
  /// Whether the Time Machine preferences could be read at all. `false` by
  /// default: a freshly created state is not a measurement, and missing Full
  /// Disk Access must not pass for the absence of a problem.
  var known: Bool = false
  /// Date of the last COMPLETED backup. `nil` = there is not a single one.
  var lastSuccess: Date?
  /// Ready-made sentences from `BackupHealth.Report` - to show without translating.
  var problems: [String] = []
  /// When we last asked (the watchdog runs less often than the panel refreshes).
  var checkedAt: Date?

  func age(now: Date = Date()) -> TimeInterval? {
    lastSuccess.map { now.timeIntervalSince($0) }
  }

  /// Whether the last SUCCESSFUL backup is recent enough. No reading and no
  /// backup both give `false` - nobody has confirmed the backup works.
  func isFresh(now: Date = Date(), maxAgeHours: Double = BackupHealth.maxAgeHours) -> Bool {
    guard known, let age = age(now: now) else { return false }
    return age <= maxAgeHours * 3600
  }

  /// The age in words, for a row in the panel.
  func ageText(now: Date = Date()) -> String {
    guard known else { return L10n.tr("not checked") }
    guard let age = age(now: now) else { return L10n.tr("none at all") }
    return L10n.tr("%@ ago", BackupHealth.formatAge(age))
  }
}

struct LastRunResult: Equatable {
  var succeeded: Bool
  var message: String
  var date: Date
}

/// Live progress of a running backup (`tmutil status`). `nil` when nothing is
/// being copied. We compute `transferRateMBs` ourselves from the byte difference between
/// refreshes - `tmutil` does not report it.
struct BackupProgressInfo: Equatable {
  var phase: String?
  var percent: Double?
  var bytesDone: Double?
  var bytesTotal: Double?
  var filesDone: Int?
  var filesTotal: Int?
  var timeRemainingSeconds: Double?
  var transferRateMBs: Double?
}

@MainActor
final class AppStatus: ObservableObject {
  @Published var dependencyState: DependencyState = .unknown
  @Published var remoteConfigured: Bool = false
  @Published var machine = MachineStatus()
  /// The answer to "when was a BACKUP last made" - the only measure
  /// that moves only on success.
  @Published var backupCycle = BackupCycleStatus()
  @Published var timeMachineState: TimeMachineState = .unknown
  /// When the `backup-health` watchdog last RAN. `nil` = the panel has not
  /// asked yet. DELIBERATELY not part of `healthy`: a dead watchdog does not
  /// mean the backup is not working - it means nobody reports a failure, and
  /// that is a different failure with its own red row.
  @Published var watchdog: WatchdogHeartbeat.Freshness?
  @Published var backupProgress: BackupProgressInfo?
  @Published var lastAction: LastRunResult?
  @Published var hasFullDiskAccess: Bool = false
  /// Folder name offered for this Mac before Google Drive is connected
  /// (from the computer name), and the folder in use once it is.
  @Published var suggestedDriveFolder = ""
  @Published var driveFolderPath = ""
  /// This Mac's space limit on Drive, its measured usage, and what Time
  /// Machine's quota is now - see `MachineBudget`.
  @Published var budgetLimitGB: Int?
  @Published var budgetUsage: MachineBudget.Usage?
  @Published var timeMachineQuotaGB: Double?
  @Published var timeMachineDestinationID: String?
  /// Whether the backup watchdog agent is loaded in launchd; `nil` until asked.
  @Published var agentsInstalled: Bool?
  /// rclone's remote control in the machine answers on the Mac's
  /// 127.0.0.1:5572 (Lima's port forwarding) - any web page can send it
  /// commands. See `VMStatus.remoteControlOpenOnMac`.
  @Published var remoteControlOpen: Bool = false
  @Published var isBusy: Bool = false
  @Published var busyLabel: String = ""
  @Published var errorMessage: String?
  /// When the state was last read successfully. A frozen view looks exactly
  /// like a failure - and those are two different things.
  @Published var lastRefresh: Date?

  /// Whether the backup watchdog is RUNNING. `false` also when the panel has not
  /// asked yet - unchecked has no right to show green.
  var watchdogRunning: Bool {
    if case .fresh = watchdog { return true }
    return false
  }

  /// A one-sentence answer to the question "is my data safe".
  var headline: String {
    if case .missing(let what, _) = dependencyState {
      return L10n.tr("Missing: %@", what.joined(separator: ", "))
    }
    if !remoteConfigured { return L10n.tr("Google Drive not connected") }
    switch machine.state {
    case .notCreated: return L10n.tr("The CloudMachine machine is not set up yet")
    case .notRunning: return L10n.tr("The CloudMachine machine is stopped")
    case .noAnswer: return L10n.tr("The CloudMachine machine does not answer")
    case .unknown, .running: break
    }
    if machine.servicesHealthy == false {
      return L10n.tr("A service in the CloudMachine machine is not running")
    }
    if case .notRegistered = timeMachineState {
      return L10n.tr("Time Machine does not point to CloudMachine")
    }
    // No answer from tmutil MUST sound different from a changed destination:
    // "does not point" tells a person to register the destination again.
    if case .noAnswer = timeMachineState {
      return L10n.tr(
        "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer")
    }
    // ONE source speaks about uploading - otherwise the menu bar and the status
    // card could claim different things.
    let upload = machine.uploadState
    if !upload.isNominal { return upload.headline }
    // Backups work in this state, but any web page can delete them - so it
    // comes before every sentence that sounds like "all is well".
    if remoteControlOpen { return L10n.tr("rclone's remote control is open on this Mac") }
    if backupProgress != nil { return L10n.tr("Backup in progress") }
    // The machine can be flawless while there has been no backup for two days.
    if !backupCycle.isFresh() {
      guard backupCycle.known else { return L10n.tr("Unknown when the last backup was made") }
      guard let age = backupCycle.age() else {
        return L10n.tr("There is no completed backup at all")
      }
      return L10n.tr("No completed backup for %@", BackupHealth.formatAge(age))
    }
    if upload.isMovingData { return upload.headline }
    return L10n.tr("Ready")
  }

  /// Whether the state is really good: every device AND a fresh completed
  /// backup AND no open remote control. The green badge says "the data is
  /// safe", and that follows solely from a backup having BEEN MADE.
  var healthy: Bool {
    guard case .ready = dependencyState, remoteConfigured, machine.isRunning,
      machine.servicesHealthy == true, case .registered = timeMachineState,
      machine.uploadState.isNominal, backupCycle.isFresh(), !remoteControlOpen
    else { return false }
    return true
  }

  /// Whether "Back up now" can do anything: the backup has somewhere to go.
  /// NOT `healthy` - after two days without a backup, the button that fixes
  /// that must not be grey.
  var canStartBackup: Bool {
    guard remoteConfigured, machine.isRunning, machine.servicesHealthy == true,
      case .registered = timeMachineState, !isBusy
    else { return false }
    return true
  }

  /// Whether "Start the machine" makes sense.
  var canStartMachine: Bool {
    if case .notRunning = machine.state { return !isBusy }
    return false
  }
}

extension AppStatus {
  /// The verdict's colour, shared by the menu bar and the window: green only
  /// for a really good state, red for what needs a person, amber for the rest
  /// (unknown, not checked yet, passes by itself).
  var overallTone: StatusTone {
    if healthy { return .success }
    if case .missing = dependencyState { return .danger }
    if !remoteConfigured { return .danger }
    switch machine.state {
    case .notCreated, .notRunning, .noAnswer: return .danger
    case .unknown, .running: break
    }
    if machine.servicesHealthy == false { return .danger }
    if case .notRegistered = timeMachineState { return .danger }
    if machine.uploadState.needsAttention { return .danger }
    if remoteControlOpen { return .danger }
    if backupCycle.known && !backupCycle.isFresh() { return .danger }
    return .warning
  }
}
