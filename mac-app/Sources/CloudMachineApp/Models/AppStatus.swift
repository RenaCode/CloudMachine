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

enum TimeMachineState: Equatable {
  case unknown
  /// Time Machine does not point at our image - there is effectively no backup.
  case notRegistered
  /// `tmutil` DID NOT ANSWER within the time limit, so we know nothing about the destination.
  ///
  /// A separate state for the same reason as `TimeMachineStatus.DestinationReading.noAnswer`
  /// and `BufferStatus.queueKnown`: a missing answer has no right to pretend to be a result.
  /// Until 25.09.2026 the panel showed "Time Machine does not point to
  /// CloudMachine" here - a sentence that sounds true and is false, sending
  /// a person off to register the destination again while the destination is
  /// intact and it was the read that hung (`tmutil destinationinfo` reaches
  /// into the Google Drive mount).
  case noAnswer
  case registered(mountPoint: String)
}

extension TimeMachineState {
  /// Translates the `tmutil` answer into a panel state.
  ///
  /// Extracted from `CloudMachineController.refreshTimeMachine()` and pure,
  /// so a test can show that THREE answers give THREE states.
  /// Previously the controller asked `currentDestinationMountPoint()`, which returns
  /// `nil` both when there is no destination and when there is no answer - so both paths
  /// ended in the same `.notRegistered`. The `backup-health` watchdog has
  /// distinguished them since 23.09.2026 (`destinationReading()`); the panel did not.
  static func from(_ reading: TimeMachineStatus.DestinationReading, target: String)
    -> TimeMachineState
  {
    switch reading {
    case .mountPoint(let path):
      return path == target ? .registered(mountPoint: path) : .notRegistered
    case .none: return .notRegistered
    case .noAnswer: return .noAnswer
    }
  }
}

/// State of the buffer between Time Machine and Google Drive.
struct BufferStatus: Equatable {
  var mounted: Bool = false
  var imageAttached: Bool = false
  var sizeGB: Int = 0
  /// `nil` = there was NO measurement (statfs failed), not "zero gigabytes" -
  /// see `BufferGuardService.freeGB()`. The same distinction as
  /// `queueKnown` below.
  var freeDiskGB: Int?
  /// How many files are waiting to be uploaded. This number matters more than the
  /// buffer size: if it grows and does not return to zero between backups, uploading
  /// is not keeping up with writing.
  var uploadsQueued: Int = 0
  var uploadsInProgress: Int = 0
  /// Whether the counters above come from a reading at all.
  ///
  /// `false` by default, and that matters more than it looks: a freshly created
  /// `BufferStatus` has nothing but zeros, which are not a measurement. A default of `true`
  /// would mean "empty queue" and the menu bar would light up green before
  /// anything had been checked.
  var queueKnown: Bool = false
  var erroredFiles: Int = 0
  /// There is no space left on Google Drive. It will NOT pass on its own.
  var driveFull: Bool = false
  /// The Google daily UPLOAD limit (750 GB) is exhausted. It passes on its own.
  ///
  /// Kept separate from `driveFull`, because these are two different situations with
  /// the same symptom: one means "wait", the other "free up space". Previously they were
  /// a single field and the interface could not tell them apart.
  var dailyQuotaExhausted: Bool = false
  /// rclone has nowhere to put data - the buffer is full of nothing but unsent files.
  var outOfSpace: Bool = false

  var draining: Bool { uploadsInProgress > 0 || uploadsQueued > 0 }

  /// The single source of truth on whether the backup reaches the Drive - and why not.
  var uploadState: UploadState {
    UploadState.from(
      mounted: mounted,
      queueKnown: queueKnown,
      queued: uploadsQueued,
      inProgress: uploadsInProgress,
      failedFiles: erroredFiles,
      bufferOutOfSpace: outOfSpace,
      driveFull: driveFull,
      dailyQuotaExhausted: dailyQuotaExhausted)
  }
}

/// Whether the backup cycle is STILL working - measured by the date of the last SUCCESSFUL backup.
///
/// Until 23.09.2026 the interface did not ask this question even once: `grep -rn
/// "BackupHealth" Sources/CloudMachineApp/` returned not a single hit.
/// The panel computed health solely from the state of the DEVICES - the mount, the image, the
/// Time Machine destination, the queue - that is, from the MOMENTARY state. The failure described
/// in the `BackupHealth` header as the most dangerous one looks exactly the other way round:
/// everything mounted, the image attached, the queue empty, and Time Machine has not
/// finished a backup for two days. The panel then showed "Healthy / Ready".
struct BackupCycleStatus: Equatable {
  /// Whether the Time Machine preferences could be read at all.
  ///
  /// `false` by default, and that matters more than it looks - just as with
  /// `queueKnown`: a freshly created state is not a measurement, and missing Full
  /// Disk Access (the most common reason the preferences file is unreadable)
  /// must not pass for the absence of a problem.
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

  /// Whether the last SUCCESSFUL backup is recent enough.
  ///
  /// No reading and no backup both give `false` - either one means that nobody
  /// has confirmed the backup works, and a green badge is exactly such a
  /// confirmation.
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
  @Published var buffer = BufferStatus()
  /// The answer to "when was a BACKUP last made" - the only measure
  /// that moves only on success.
  @Published var backupCycle = BackupCycleStatus()
  @Published var timeMachineState: TimeMachineState = .unknown
  /// When the `backup-health` watchdog last RAN. `nil` = the panel has not
  /// asked yet (not: "has never run" - that is a separate state, `.never`).
  ///
  /// The panel shows this for the same reason it shows the age of the last
  /// backup: the watchdog runs with `StartInterval 1800` and without `KeepAlive`, so
  /// when unloaded or hung it gives no symptom other than silence - and silence
  /// is the normal state here.
  ///
  /// DELIBERATELY not part of `healthy`: the panel computes backup freshness ITSELF, from the
  /// same preferences file the watchdog computes it from. A dead watchdog therefore does not
  /// mean the backup is not working - it means nobody reports a failure,
  /// and that is a different failure with its own red row.
  @Published var watchdog: WatchdogHeartbeat.Freshness?
  @Published var backupProgress: BackupProgressInfo?
  @Published var lastAction: LastRunResult?
  @Published var hasFullDiskAccess: Bool = false
  /// Folder name offered for this Mac before Google Drive is connected
  /// (from the computer name), and the folder in use once it is.
  @Published var suggestedDriveFolder = ""
  @Published var driveFolderPath = ""
  /// Whether the mount agent is loaded in launchd; `nil` until asked.
  @Published var agentsInstalled: Bool?
  /// Whether this Mac's image exists on the mounted Drive; `nil` while the
  /// Drive is not mounted, because then nobody can know.
  @Published var imageExists: Bool?
  @Published var isBusy: Bool = false
  @Published var busyLabel: String = ""
  @Published var errorMessage: String?
  /// When the state was last read successfully. Shown in the interface, because
  /// a frozen view looks exactly like a failure - and those are two different things
  /// that the user has to tell apart without looking into the logs.
  @Published var lastRefresh: Date?

  /// Whether the backup watchdog is RUNNING. `false` also when the panel has not
  /// asked yet - unchecked has no right to show green, just like
  /// `queueKnown` and `BackupCycleStatus.known`.
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
    if !buffer.mounted { return L10n.tr("Buffer is not working") }
    if !buffer.imageAttached { return L10n.tr("Backup image not attached") }
    if case .notRegistered = timeMachineState {
      return L10n.tr("Time Machine does not point to CloudMachine")
    }
    // No answer from tmutil MUST sound different from a changed destination: it is
    // the first sentence a person reads, and it decides what they will do.
    // "Does not point" tells them to register the destination again - a needless and misleading
    // step when the destination is intact and it was the read that hung.
    if case .noAnswer = timeMachineState {
      return L10n.tr(
        "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer")
    }
    // ONE source speaks about uploading - otherwise the menu bar and the status card could
    // claim different things. Files that rclone did not upload exist ONLY
    // on this Mac, which is exactly where the backup has no right to be the only
    // copy; that is precisely why `UploadState` puts them ahead of the daily limit.
    let upload = buffer.uploadState
    if !upload.isNominal { return upload.headline }
    if backupProgress != nil { return L10n.tr("Backup in progress") }
    // The state of the devices can be flawless while there has been no backup for two days.
    // This sentence must come BEFORE "Ready", otherwise the headline contradicts the
    // badge next to it (healthy = false, and the text says "Ready").
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

  /// Whether the state is really good.
  ///
  /// WARNING: `erroredFiles` and `outOfSpace` MUST be here. Without them the menu bar
  /// showed a green badge and "Ready" while some of the image's bands never
  /// reached the Drive - and such a backup may not open. Broken
  /// looked exactly the same as working.
  ///
  /// SECOND WARNING, from 23.09.2026: `backupCycle` MUST be here for the same
  /// reason. All the other conditions describe the state of the DEVICES at this moment,
  /// and each of them can be met when no backup has been made for two days.
  /// The green badge is meant to say "the data is safe", and that follows
  /// solely from a backup having BEEN MADE - not from the disk being attached.
  var healthy: Bool {
    guard case .ready = dependencyState, remoteConfigured, buffer.mounted, buffer.imageAttached,
      case .registered = timeMachineState, buffer.uploadState.isNominal,
      backupCycle.isFresh()
    else { return false }
    return true
  }
}
