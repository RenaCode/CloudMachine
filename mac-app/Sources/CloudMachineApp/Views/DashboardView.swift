import CloudMachineCore
import SwiftUI

/// The main interface of the CloudMachine app, kept in the modern RenaCode
/// visual system (consistent with Dietetyk-AI and Trader-AI).
///
/// Observes `AppStatus` itself, not only the controller: the status is a
/// separate `ObservableObject`, and its changes do not pass through the
/// controller's `objectWillChange`. Observing only the controller, the window
/// redrew when `credentials` was assigned - at the START of each refresh - so it
/// showed the readings of the previous cycle, 10 s late.
struct DashboardView: View {
  @EnvironmentObject private var controller: CloudMachineController

  var body: some View {
    DashboardContent(status: controller.status)
      .task { controller.startAutoRefresh() }
  }
}

/// The sections of the sidebar.
enum DashboardSection: String, CaseIterable, Identifiable {
  case overview
  case backups
  case storage
  case settings

  var id: String { rawValue }

  var title: String {
    switch self {
    case .overview: return L10n.tr("Overview")
    case .backups: return L10n.tr("Backups")
    case .storage: return L10n.tr("Storage")
    case .settings: return L10n.tr("Settings")
    }
  }

  var systemImage: String {
    switch self {
    case .overview: return "house"
    case .backups: return "clock.arrow.circlepath"
    case .storage: return "internaldrive"
    case .settings: return "gearshape"
    }
  }

  var shortcut: KeyEquivalent {
    switch self {
    case .overview: return "1"
    case .backups: return "2"
    case .storage: return "3"
    case .settings: return "4"
    }
  }
}

private struct DashboardContent: View {
  @EnvironmentObject private var controller: CloudMachineController
  @ObservedObject var status: AppStatus
  /// The window reopens on the section it was closed on.
  @AppStorage("dashboardSection") private var section: DashboardSection = .overview
  @State private var clientID = ""
  @State private var clientSecret = ""
  @State private var credentialsMessage: String?
  /// Logical size of a new backup image. Sparse: Drive holds only what is written.
  @State private var imageSizeGB = "4000"
  /// This Mac's folder on Google Drive, chosen before connecting. Empty means
  /// "not edited yet" and shows the suggestion from the computer name.
  @State private var driveFolder = ""
  /// The limit being typed; empty = show the stored one.
  @State private var limitText = ""

  var body: some View {
    HStack(spacing: 0) {
      sidebar

      Rectangle()
        .fill(RenaCodeTheme.borderGlass)
        .frame(width: 1)

      VStack(spacing: 0) {
        windowTopBar

        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            Text(section == .overview ? "CloudMachine" : section.title)
              .font(.system(size: 34, weight: .bold))
              .foregroundStyle(RenaCodeTheme.textMain)
              .accessibilityAddTraits(.isHeader)
              .padding(.bottom, 2)

            // An error is shown in every section: switching tabs must not hide it.
            if let error = status.errorMessage {
              errorBanner(error)
            }

            switch section {
            case .overview: overviewSection
            case .backups: backupsSection
            case .storage: storageSection
            case .settings: settingsSection
            }
          }
          .padding(.horizontal, 28)
          .padding(.bottom, 28)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .background(AmbientGlowBackground())
    .overlay(GradientWindowFrame())
    .ignoresSafeArea()
  }

  // MARK: - Sidebar

  private var sidebar: some View {
    VStack(spacing: 6) {
      ForEach(DashboardSection.allCases) { item in
        sidebarItem(item)
      }
      Spacer()
    }
    // Below the traffic lights: the window has no title bar of its own.
    .padding(.top, 52)
    .frame(width: 96)
    .background(RenaCodeTheme.bgSidebar.opacity(0.7))
  }

  private func sidebarItem(_ item: DashboardSection) -> some View {
    let selected = section == item
    let alert = sectionAlert(item)
    return Button {
      section = item
    } label: {
      HStack(spacing: 0) {
        // The violet accent on the edge of the sidebar marks the active section.
        Capsule()
          .fill(RenaCodeTheme.frameGradient)
          .frame(width: 3, height: 34)
          .shadow(color: RenaCodeTheme.colorPrimary.opacity(0.8), radius: 4)
          .opacity(selected ? 1 : 0)

        VStack(spacing: 5) {
          Image(systemName: item.systemImage)
            .font(.system(size: 18, weight: selected ? .semibold : .regular))
            .frame(height: 22)
            .overlay(alignment: .topTrailing) {
              if let alert {
                StatusDot(alert, size: 7)
                  .offset(x: 6, y: -3)
              }
            }
          Text(item.title)
            .font(.system(size: 12, weight: selected ? .semibold : .regular))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .foregroundStyle(selected ? RenaCodeTheme.textMain : RenaCodeTheme.textMuted)
        .frame(width: 78, height: 60)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(selected ? 0.09 : 0))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.white.opacity(selected ? 0.10 : 0), lineWidth: 1)
        )
        .padding(.leading, 6)

        Spacer(minLength: 0)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .keyboardShortcut(item.shortcut, modifiers: .command)
    .accessibilityLabel(item.title)
    .accessibilityValue(alert == nil ? "" : L10n.tr("Attention"))
    .accessibilityAddTraits(selected ? .isSelected : [])
  }

  /// A dot on a section that holds a problem, in the problem's color. No dot
  /// when all is well: a row of green dots would say nothing.
  private func sectionAlert(_ item: DashboardSection) -> StatusTone? {
    switch item {
    case .overview, .settings:
      return nil
    case .backups:
      let tone = backupCycleTone.worst(status.watchdogRunning ? .success : .danger)
      return tone == .success ? nil : tone
    case .storage:
      let tone = uploadTone(status.buffer.uploadState)
        .worst(freeSpaceTone)
        .worst(status.budgetLimitGB == nil || budgetOK ? .success : .warning)
      return tone == .success ? nil : tone
    }
  }

  // MARK: - Top Bar

  private var windowTopBar: some View {
    HStack(spacing: 10) {
      Spacer()

      if status.isBusy {
        HStack(spacing: 6) {
          ProgressView().controlSize(.small)
          Text(status.busyLabel)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(RenaCodeTheme.colorCyan)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(RenaCodeTheme.colorCyan.opacity(0.12))
        .clipShape(Capsule())
      }

      // A frozen view looks exactly like a failure - the time of the last
      // reading tells them apart.
      if let at = status.lastRefresh {
        Text(L10n.tr("Refreshed %@", at.formatted(date: .omitted, time: .standard)))
          .font(.system(size: 11, weight: .medium).monospacedDigit())
          .foregroundStyle(RenaCodeTheme.textMuted)
      }

      Button(action: { Task { await controller.refreshAll() } }) {
        Image(systemName: "arrow.clockwise")
      }
      .buttonStyle(IconGlassButtonStyle())
      .help(L10n.tr("Refresh"))
      .accessibilityLabel(L10n.tr("Refresh"))
      .keyboardShortcut("r", modifiers: .command)
    }
    .padding(.horizontal, 16)
    .padding(.top, 10)
    .frame(height: 48, alignment: .top)
  }

  // MARK: - Overview

  private var overviewSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Until these are done nothing else works, so they come first.
      if !setupSteps.isEmpty {
        setupCard
      }

      HStack(alignment: .top, spacing: 16) {
        bufferSummaryCard
        driveSummaryCard
      }
      .fixedSize(horizontal: false, vertical: true)

      HStack(alignment: .top, spacing: 16) {
        healthCard
        disksCard
      }
      .fixedSize(horizontal: false, vertical: true)

      // Whether the backup reaches the Drive - and why not, if it does not
      uploadStateCard

      HStack(spacing: 12) {
        backupButton
        Spacer()
      }
    }
  }

  private var bufferTone: StatusTone {
    if status.buffer.outOfSpace { return .danger }
    return freeSpaceTone == .success ? .brand : freeSpaceTone
  }

  /// The same 80 GB threshold the details row has always used.
  private var freeSpaceTone: StatusTone {
    guard let free = status.buffer.freeDiskGB else { return .warning }
    return free > 80 ? .success : .danger
  }

  private var bufferSummaryCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 10) {
        IconTile(
          systemImage: "internaldrive.fill",
          gradient: LinearGradient(
            colors: [RenaCodeTheme.colorCyan, RenaCodeTheme.colorIndigo],
            startPoint: .topLeading, endPoint: .bottomTrailing))
        Text(L10n.tr("SSD buffer"))
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(RenaCodeTheme.textMain)
      }

      HStack(alignment: .firstTextBaseline) {
        Text(L10n.tr("%@ GB", "\(status.buffer.sizeGB)"))
          .font(.system(size: 34, weight: .bold).monospacedDigit())
          .foregroundStyle(RenaCodeTheme.textMain)
          .lineLimit(1)
          .minimumScaleFactor(0.6)

        Spacer(minLength: 8)

        // Where the mockup has a sparkline: the app keeps no history of the
        // buffer, so the card shows the queue, which it does read.
        VStack(alignment: .trailing, spacing: 2) {
          Text(L10n.tr("Waiting to upload"))
            .font(.system(size: 11))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Text(queueText)
            .font(.system(size: 13, weight: .semibold).monospacedDigit())
            .foregroundStyle(queueTone == .success ? RenaCodeTheme.textMain : queueTone.color)
        }
      }

      // A missing measurement must look different from a number - see
      // `BufferGuardService.freeGB()`. Simply putting the optional value
      // into the text gave "Free on disk: Optional(427) GB", and the compiler
      // reported it ONLY as a warning, so no test would have caught it.
      Text(
        L10n.tr(
          "Free on disk: %@",
          status.buffer.freeDiskGB.map { L10n.tr("%@ GB", "\($0)") } ?? L10n.tr("not measured"))
      )
      .font(.system(size: 13))
      .foregroundStyle(freeSpaceTone == .success ? RenaCodeTheme.textMuted : freeSpaceTone.color)
    }
    .accessibilityElement(children: .combine)
    .toneCard(bufferTone)
  }

  /// Without a queue reading there is no right to say "nothing" - the zeros
  /// are then a missing measurement, not a result.
  private var queueText: String {
    guard status.buffer.queueKnown else { return "?" }
    return status.buffer.draining
      ? L10n.tr("%@ files", "\(status.buffer.uploadsQueued)") : L10n.tr("nothing")
  }

  /// Cyan while the queue drains: that is the normal state during a backup,
  /// and amber there made a working upload look like a warning.
  private var queueTone: StatusTone {
    guard status.buffer.queueKnown else { return .warning }
    return status.buffer.draining ? .info : .success
  }

  private var driveSummaryCard: some View {
    let upload = status.buffer.uploadState
    return VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 10) {
        IconTile(systemImage: "icloud.fill", gradient: RenaCodeTheme.aiGradient)
        Text(verbatim: "Google Drive Time Machine")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(RenaCodeTheme.textMain)
          .lineLimit(1)
          .minimumScaleFactor(0.85)
      }

      HStack(alignment: .firstTextBaseline, spacing: 8) {
        StatusDot(uploadTone(upload), live: upload.isMovingData)
        Text(upload.headline)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(RenaCodeTheme.textMain)
          .fixedSize(horizontal: false, vertical: true)
      }

      if let progress = status.backupProgress {
        VStack(alignment: .leading, spacing: 8) {
          if let percent = progress.percent {
            GradientProgressBar(fraction: percent)
          }
          Text(progressCaption(progress))
            .font(.system(size: 13).monospacedDigit())
            .foregroundStyle(RenaCodeTheme.textMuted)
        }
      } else {
        // No bar when nothing runs: an empty bar would read as "0%".
        HStack(spacing: 8) {
          StatusDot(backupCycleTone)
          Text(L10n.tr("Last completed backup"))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Spacer(minLength: 4)
          Text(status.backupCycle.ageText())
            .fontWeight(.semibold)
            .foregroundStyle(
              backupCycleTone == .success ? RenaCodeTheme.textMain : backupCycleTone.color)
        }
        .font(.system(size: 13).monospacedDigit())
      }
    }
    .accessibilityElement(children: .combine)
    .toneCard(uploadTone(upload) == .success ? .brand : uploadTone(upload))
  }

  /// "84% | Backing up: 3.4 GB of 4 GB", with whatever tmutil reported.
  private func progressCaption(_ progress: BackupProgressInfo) -> String {
    var parts: [String] = []
    if let percent = progress.percent {
      parts.append(String(format: "%.0f%%", percent * 100))
    }
    if let done = progress.bytesDone, let total = progress.bytesTotal, total > 0 {
      parts.append(
        L10n.tr(
          "Backing up: %@ of %@", Self.bytes(done), Self.bytes(total)))
    } else {
      parts.append(L10n.tr("Backup in progress"))
    }
    return parts.joined(separator: " | ")
  }

  private static func bytes(_ value: Double) -> String {
    ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .file)
  }

  /// Green only when the state is really good; a hard failure is red, the rest
  /// (unknown, not yet checked, passes by itself) amber.
  private var healthTone: StatusTone {
    if status.healthy { return .success }
    if case .missing = status.dependencyState { return .danger }
    if !status.remoteConfigured || !status.buffer.mounted || !status.buffer.imageAttached {
      return .danger
    }
    if case .notRegistered = status.timeMachineState { return .danger }
    if status.buffer.uploadState.needsAttention { return .danger }
    if status.backupCycle.known && !status.backupCycle.isFresh() { return .danger }
    return .warning
  }

  private var healthCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(L10n.tr("System Status"))
          .font(.system(size: 13, weight: .bold))
          .textCase(.uppercase)
          .tracking(0.6)
          .foregroundStyle(RenaCodeTheme.textMuted)
        Spacer()
        StatusPill(
          healthTone == .success
            ? L10n.tr("Healthy")
            : (healthTone == .danger ? L10n.tr("Action needed") : L10n.tr("Attention")),
          tone: healthTone)
      }

      Text(L10n.tr("Current status: %@", status.headline))
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(RenaCodeTheme.textMain)
        .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .combine)
    .toneCard(healthTone)
  }

  private var timeMachineTone: StatusTone {
    switch status.timeMachineState {
    case .registered: return .success
    case .notRegistered: return .danger
    case .noAnswer: return .warning
    case .unknown: return .neutral
    }
  }

  private var timeMachineText: String {
    switch status.timeMachineState {
    case .registered: return L10n.tr("Points to CloudMachine")
    case .notRegistered: return L10n.tr("Does not point to CloudMachine")
    case .noAnswer: return L10n.tr("tmutil did not answer")
    case .unknown: return L10n.tr("not checked")
    }
  }

  private var disksTone: StatusTone {
    (status.buffer.mounted ? StatusTone.success : .danger)
      .worst(status.buffer.imageAttached ? .success : .danger)
      .worst(timeMachineTone == .neutral ? .warning : timeMachineTone)
  }

  private var disksPill: String {
    if !status.buffer.mounted { return L10n.tr("Drive disconnected") }
    if !status.buffer.imageAttached { return L10n.tr("Not attached") }
    switch disksTone {
    case .success: return L10n.tr("Attached")
    case .danger: return L10n.tr("Action needed")
    default: return L10n.tr("Attention")
    }
  }

  private var disksCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(L10n.tr("Disks"))
          .font(.system(size: 13, weight: .bold))
          .textCase(.uppercase)
          .tracking(0.6)
          .foregroundStyle(RenaCodeTheme.textMuted)
        Spacer()
        StatusPill(disksPill, tone: disksTone)
      }

      VStack(alignment: .leading, spacing: 6) {
        compactRow(
          "Google Drive",
          status.buffer.mounted ? L10n.tr("Mounted") : L10n.tr("Inactive"),
          tone: status.buffer.mounted ? .success : .danger)
        compactRow(
          L10n.tr("Backup image"),
          status.buffer.imageAttached ? L10n.tr("Attached") : L10n.tr("Detached"),
          tone: status.buffer.imageAttached ? .success : .danger)
        compactRow("Time Machine", timeMachineText, tone: timeMachineTone)
      }
    }
    .accessibilityElement(children: .combine)
    .toneCard(disksTone)
  }

  private func compactRow(_ label: String, _ value: String, tone: StatusTone) -> some View {
    HStack(spacing: 8) {
      StatusDot(tone, size: 6)
      Text(label)
        .foregroundStyle(RenaCodeTheme.textMuted)
      Spacer(minLength: 4)
      Text(value)
        .fontWeight(.medium)
        .foregroundStyle(
          tone == .success || tone == .neutral ? RenaCodeTheme.textMain : tone.color
        )
        .multilineTextAlignment(.trailing)
    }
    .font(.system(size: 13))
  }

  @ViewBuilder
  private var backupButton: some View {
    if status.backupProgress == nil {
      Button(action: { Task { await controller.startBackup() } }) {
        HStack(spacing: 6) {
          Image(systemName: "play.fill")
          Text(L10n.tr("Back up now"))
        }
      }
      .buttonStyle(PrimaryGradientButtonStyle())
      .disabled(!status.healthy || status.isBusy)
    } else {
      Button(action: { Task { await controller.stopBackup() } }) {
        HStack(spacing: 6) {
          Image(systemName: "stop.fill")
          Text(L10n.tr("Stop backup"))
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())
    }
  }

  // MARK: - Error Banner

  private func errorBanner(_ message: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 18))
        .foregroundStyle(RenaCodeTheme.colorDanger)
        .accessibilityHidden(true)

      Text(message)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(RenaCodeTheme.textMain)
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)
    }
    .toneCard(.danger, cornerRadius: 12, padding: 14)
  }

  // MARK: - Backups

  private var backupCycleTone: StatusTone {
    if status.backupCycle.isFresh() { return .success }
    return status.backupCycle.known ? .danger : .warning
  }

  private var backupsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      if let progress = status.backupProgress {
        progressCard(progress)
      } else {
        idleBackupCard
      }

      backupCycleCard

      HStack(spacing: 12) {
        backupButton

        Button(action: { Task { await controller.verifyImage() } }) {
          HStack(spacing: 6) {
            Image(systemName: "checkmark.shield")
            Text(L10n.tr("Check image consistency"))
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())
        .disabled(status.buffer.imageAttached || status.isBusy)

        Spacer()
      }
    }
  }

  private var idleBackupCard: some View {
    HStack(spacing: 12) {
      IconTile(systemImage: "pause.fill", gradient: RenaCodeTheme.aiGradient)
      VStack(alignment: .leading, spacing: 3) {
        Text(L10n.tr("No backup is running"))
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(RenaCodeTheme.textMain)
        Text(L10n.tr("Time Machine starts the next one on its own schedule."))
          .font(.system(size: 13))
          .foregroundStyle(RenaCodeTheme.textMuted)
      }
    }
    .accessibilityElement(children: .combine)
    .toneCard(.neutral)
  }

  private func progressCard(_ progress: BackupProgressInfo) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 10) {
          IconTile(systemImage: "arrow.triangle.2.circlepath", gradient: RenaCodeTheme.aiGradient)
          Text(L10n.tr("Backup in Progress"))
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(RenaCodeTheme.textMain)
        }

        Spacer()

        if let percent = progress.percent {
          Text(String(format: "%.1f%%", percent * 100))
            .font(.system(size: 22, weight: .bold).monospacedDigit())
            .foregroundStyle(RenaCodeTheme.textMain)
        }
      }

      if let percent = progress.percent {
        GradientProgressBar(fraction: percent, height: 10)
      }

      HStack(alignment: .top, spacing: 28) {
        if let done = progress.bytesDone, let total = progress.bytesTotal, total > 0 {
          metric(L10n.tr("Copied"), L10n.tr("%@ of %@", Self.bytes(done), Self.bytes(total)))
        }

        if let done = progress.filesDone, let total = progress.filesTotal, total > 0 {
          metric(L10n.tr("Files processed"), "\(done) / \(total)")
        }

        if let rate = progress.transferRateMBs {
          metric(L10n.tr("Write speed"), String(format: "%.1f MB/s", rate))
        }

        if let phase = progress.phase {
          metric(L10n.tr("Operation phase"), phase)
        }
      }
    }
    .accessibilityElement(children: .combine)
    .toneCard(.brand)
  }

  private func metric(_ label: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(label)
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMuted)
      Text(value)
        .font(.system(size: 14, weight: .semibold).monospacedDigit())
        .foregroundStyle(RenaCodeTheme.textMain)
    }
  }

  /// Whether a backup was MADE, and whether anyone still checks that. Every
  /// other card describes the devices at this moment and can be green while
  /// Time Machine has not finished a backup for two days.
  private var backupCycleCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      cardTitle(L10n.tr("Backup cycle"), systemImage: "clock.arrow.circlepath")

      row(
        L10n.tr("Last completed backup"),
        status.backupCycle.ageText(),
        tone: backupCycleTone)

      Divider().background(RenaCodeTheme.borderGlass)

      // Who watches the watchdog. The watchdog runs without KeepAlive, so
      // when unloaded or hung it gives no symptom other than silence - see
      // `WatchdogHeartbeat`.
      row(
        L10n.tr("Last backup watchdog run"),
        status.watchdog.map { StatusLines.watchdogRun($0) } ?? L10n.tr("not checked"),
        tone: status.watchdogRunning ? .success : .danger)

      // Ready-made sentences from the watchdog's report.
      ForEach(status.backupCycle.problems, id: \.self) { problem in
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 11))
            .accessibilityHidden(true)
          Text(problem)
            .font(.system(size: 13))
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
        }
        .foregroundStyle(RenaCodeTheme.colorDanger)
      }
    }
    .toneCard(backupCycleTone.worst(status.watchdogRunning ? .success : .danger))
  }

  // MARK: - Storage

  private var storageSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      uploadStateCard
      bufferCard
      // This Mac's space limit on Google Drive
      if status.remoteConfigured {
        budgetCard
      }
    }
  }

  // MARK: - Settings

  private var settingsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      credentialsCard
    }
  }

  // MARK: - Setup Steps ("To Do")

  private var setupSteps: [SetupStep] { controller.setupPlan }

  /// One button per step the app can do itself. Disabled while anything runs:
  /// image operations share one lock, and a second click would only report
  /// "another operation is in progress".
  @ViewBuilder
  private func setupActionButton(_ action: SetupStep.Action) -> some View {
    HStack(spacing: 8) {
      if action == .createImage {
        Text(L10n.tr("Size (GB)"))
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMain)
        TextField("", text: $imageSizeGB)
          .textFieldStyle(.roundedBorder)
          .frame(width: 80)
      }
      Button(action: { Task { await perform(action) } }) {
        Text(setupActionTitle(action))
          .font(.system(size: 12, weight: .semibold))
      }
      .buttonStyle(SecondaryGlassButtonStyle())
      .disabled(status.isBusy || (action == .createImage && parsedImageSize == nil))
    }
  }

  private var effectiveDriveFolder: String {
    driveFolder.isEmpty ? status.suggestedDriveFolder : driveFolder
  }

  /// Each Mac on the same Google account needs its own folder, otherwise
  /// they would share one backup image. Chosen once: a Mac that already has a
  /// folder refuses to switch, because the new one would be an empty backup.
  private var folderField: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 8) {
        Text(L10n.tr("Folder on Google Drive"))
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMain)
        Text("CloudMachine/")
          .font(.system(size: 12, design: .monospaced))
          .foregroundStyle(RenaCodeTheme.textMain.opacity(0.6))
        TextField(status.suggestedDriveFolder, text: $driveFolder)
          .textFieldStyle(.roundedBorder)
          .font(.system(size: 12, design: .monospaced))
          .frame(width: 180)
      }
      Text(
        DriveFolder.isValid(effectiveDriveFolder)
          ? L10n.tr(
            "One folder per Mac. Set once - it cannot be changed after connecting.")
          : L10n.tr("Use lowercase letters, digits and dashes.")
      )
      .font(.system(size: 11))
      .foregroundStyle(
        DriveFolder.isValid(effectiveDriveFolder)
          ? RenaCodeTheme.textMuted : RenaCodeTheme.colorWarning)
    }
  }

  private var parsedImageSize: Int? {
    guard let value = Int(imageSizeGB.trimmingCharacters(in: .whitespaces)), value >= 100
    else { return nil }
    return value
  }

  private func setupActionTitle(_ action: SetupStep.Action) -> String {
    switch action {
    case .installRclone: return L10n.tr("Install rclone")
    case .installFuse: return L10n.tr("Install FUSE-T")
    case .grantFullDiskAccess: return L10n.tr("Open System Settings")
    case .installAgents: return L10n.tr("Install agents")
    case .createImage: return L10n.tr("Create image")
    case .attachImage: return L10n.tr("Attach image")
    }
  }

  private func perform(_ action: SetupStep.Action) async {
    switch action {
    case .installRclone: await controller.installRclone()
    case .installFuse: await controller.installFuse()
    case .grantFullDiskAccess: controller.openFullDiskAccessSettings()
    case .installAgents: await controller.installAgents()
    case .createImage:
      if let size = parsedImageSize { await controller.createImage(sizeGB: size) }
    case .attachImage: await controller.attachImage()
    }
  }

  private var setupCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      cardTitle(
        L10n.tr("Required Setup Steps"), systemImage: "wrench.and.screwdriver.fill",
        tone: .warning)

      VStack(alignment: .leading, spacing: 12) {
        // Numbered, because the steps ARE a sequence: each needs the one before.
        ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
          VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
              Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(RenaCodeTheme.fillWarning)
                .clipShape(Circle())

              Text(step.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RenaCodeTheme.textMain)
            }

            if let action = step.action {
              setupActionButton(action)
            }

            if step.choosesFolder {
              folderField
            }

            if let command = step.choosesFolder
              ? controller.connectDriveCommand(folder: effectiveDriveFolder) : step.command
            {
              commandBox(command)
            }
          }
        }
      }
    }
    .toneCard(.warning)
  }

  /// A command the user has to run themselves, with a Copy button.
  private func commandBox(_ command: String) -> some View {
    HStack {
      Text(command)
        .font(.system(size: 12, design: .monospaced))
        .foregroundStyle(RenaCodeTheme.textMain)
        .textSelection(.enabled)
      Spacer()
      Button(action: {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
      }) {
        HStack(spacing: 4) {
          Image(systemName: "doc.on.doc")
            .font(.system(size: 11))
          Text(L10n.tr("Copy"))
            .font(.system(size: 11, weight: .medium))
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())
    }
    .padding(10)
    .background(RenaCodeTheme.bgInset)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
    )
  }

  // MARK: - Space Limit

  /// Several Macs on one Google account share its space; each gets a limit.
  /// Time Machine enforces it through its quota (deleting the oldest
  /// backups), the watchdog warns from 90% of the real usage on Drive.
  private var budgetCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      cardTitle(L10n.tr("Space limit for this Mac"), systemImage: "chart.pie.fill")

      row(
        L10n.tr("Used on Google Drive"),
        MachineBudget.summary(limitGB: status.budgetLimitGB, usage: status.budgetUsage),
        tone: budgetOK ? .success : .danger)

      if let usage = status.budgetUsage {
        Text(
          L10n.tr(
            "Measured %@. The watchdog measures again every few hours.",
            usage.measuredAt.formatted(date: .abbreviated, time: .shortened))
        )
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMuted)
      }

      HStack(spacing: 8) {
        Text(L10n.tr("Limit (GB)"))
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMain)
        // `String(_:)`, not an interpolated literal: that one became a
        // LocalizedStringKey and showed the placeholder as "1.500".
        TextField(status.budgetLimitGB.map { String($0) } ?? "1500", text: $limitText)
          .textFieldStyle(.roundedBorder)
          .frame(width: 90)
        Button(action: {
          if let gb = Int(limitText.trimmingCharacters(in: .whitespaces)), gb > 0 {
            Task {
              await controller.saveLimit(gb: gb)
              limitText = ""
            }
          }
        }) {
          Text(L10n.tr("Save")).font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(SecondaryGlassButtonStyle())
        .disabled(status.isBusy || (Int(limitText.trimmingCharacters(in: .whitespaces)) ?? 0) <= 0)
        Button(action: { Task { await controller.measureDriveUsage() } }) {
          Text(L10n.tr("Measure now")).font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(SecondaryGlassButtonStyle())
        .disabled(status.isBusy)
      }

      if let limit = status.budgetLimitGB {
        Text(
          L10n.tr(
            "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.",
            "\(MachineBudget.timeMachineQuotaGB(forLimitGB: limit))")
        )
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .fixedSize(horizontal: false, vertical: true)
      }

      if let command = controller.quotaCommand {
        Text(L10n.tr("Set the Time Machine quota: run this in Terminal (needs sudo)"))
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(RenaCodeTheme.colorWarning)
        commandBox(command)
      }
    }
    .toneCard(budgetOK ? .neutral : .warning)
  }

  private var budgetOK: Bool {
    guard let limit = status.budgetLimitGB, let usage = status.budgetUsage
    else { return status.budgetLimitGB != nil }
    return MachineBudget.level(usageBytes: usage.bytes, limitGB: limit) == .ok
  }

  // MARK: - Buffer and Upload Details

  private var bufferCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      cardTitle(L10n.tr("Local Buffer & Upload Status"), systemImage: "server.rack")
        .padding(.bottom, 4)

      row(
        L10n.tr("Google Drive mount (FUSE-T)"),
        status.buffer.mounted ? L10n.tr("Mounted") : L10n.tr("Inactive"),
        tone: status.buffer.mounted ? .success : .danger)

      Divider().background(RenaCodeTheme.borderGlass)

      if status.remoteConfigured {
        row(L10n.tr("Folder on Google Drive"), status.driveFolderPath, tone: .neutral)

        Divider().background(RenaCodeTheme.borderGlass)
      }

      row(
        L10n.tr("Backup disk image (.sparsebundle)"),
        status.buffer.imageAttached ? L10n.tr("Attached to the system") : L10n.tr("Detached"),
        tone: status.buffer.imageAttached ? .success : .danger)

      Divider().background(RenaCodeTheme.borderGlass)

      row(
        L10n.tr("Buffer allocated on the SSD"),
        L10n.tr("%@ GB", "\(status.buffer.sizeGB)"),
        tone: status.buffer.outOfSpace ? .danger : .neutral)

      Divider().background(RenaCodeTheme.borderGlass)

      // A missing measurement MUST look different from "0 GB" - see
      // `BufferGuardService.freeGB()`. A failed statfs is a failure of the buffer
      // guard, not information about an empty disk.
      row(
        L10n.tr("Free space on the local volume"),
        status.buffer.freeDiskGB.map { L10n.tr("%@ GB", "\($0)") } ?? L10n.tr("not measured"),
        tone: (status.buffer.freeDiskGB ?? 0) > 80 ? .success : .danger)

      Divider().background(RenaCodeTheme.borderGlass)

      row(
        L10n.tr("Cloud sync queue"),
        !status.buffer.queueKnown
          ? L10n.tr("not read")
          : (status.buffer.draining
            ? L10n.tr(
              "%@ in progress, %@ queued", "\(status.buffer.uploadsInProgress)",
              "\(status.buffer.uploadsQueued)")
            : L10n.tr("Everything uploaded")),
        tone: status.buffer.queueKnown && status.buffer.erroredFiles == 0 ? .success : .danger)

      if status.buffer.erroredFiles > 0 {
        Divider().background(RenaCodeTheme.borderGlass)
        row(
          L10n.tr("File upload errors"),
          L10n.tr("%@ files", "\(status.buffer.erroredFiles)"),
          tone: .danger)
      }

      if status.buffer.driveFull {
        Divider().background(RenaCodeTheme.borderGlass)
        row(L10n.tr("Space on Google Drive"), L10n.tr("Out of space"), tone: .danger)
      }

      if status.buffer.dailyQuotaExhausted {
        Divider().background(RenaCodeTheme.borderGlass)
        // Amber, not red: the limit passes by itself - see `UploadState`.
        row(L10n.tr("Google Drive limit"), L10n.tr("Daily 750 GB exhausted"), tone: .warning)
      }
    }
    .toneCard(.neutral)
  }

  // MARK: - Google OAuth Credentials

  /// Entered ONCE, when setting up your own OAuth client. Settings is their own
  /// section now, so they no longer sit folded on top of the backup state.
  private var credentialsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        cardTitle(L10n.tr("Google Drive Credentials (OAuth 2.0)"), systemImage: "key.fill")

        Spacer()

        StatusPill(
          controller.credentials.isComplete
            ? L10n.tr("Keychain OK") : L10n.tr("No custom keys"),
          tone: controller.credentials.isComplete ? .success : .warning,
          icon: controller.credentials.isComplete ? "checkmark.seal.fill" : "lock.open.fill")
      }

      Text(controller.credentials.summary)
        .font(.system(size: 12))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .fixedSize(horizontal: false, vertical: true)

      VStack(spacing: 10) {
        credentialField("client_id:", L10n.tr("Paste client_id..."), text: $clientID)
        credentialField("client_secret:", L10n.tr("Paste client_secret..."), text: $clientSecret)
      }

      HStack {
        Button(L10n.tr("Save securely in the Keychain")) {
          let id = clientID
          let secret = clientSecret
          Task {
            credentialsMessage = await controller.saveCredentials(
              clientID: id, clientSecret: secret)
            clientID = ""
            clientSecret = ""
          }
        }
        .buttonStyle(PrimaryGradientButtonStyle())
        .disabled(
          clientID.trimmingCharacters(in: .whitespaces).isEmpty
            || clientSecret.trimmingCharacters(in: .whitespaces).isEmpty)

        Spacer()
      }

      if let message = credentialsMessage {
        Text(message)
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.colorCyan)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .toneCard(.neutral)
  }

  private func credentialField(_ label: String, _ prompt: String, text: Binding<String>)
    -> some View
  {
    HStack {
      Text(label)
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .lineLimit(1)
        .fixedSize()
        .frame(width: 120, alignment: .leading)

      SecureField(prompt, text: text)
        .textFieldStyle(.plain)
        .padding(8)
        .background(RenaCodeTheme.bgInset)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
        )
        .accessibilityLabel(label)
    }
  }

  // MARK: - Google Drive Upload Status

  /// Answers the only question the user really asks: is my
  /// backup safe. One sentence, with a plain-language explanation below it.
  ///
  /// The color distinguishes THREE things, not two. Green - all is well. Amber -
  /// not nominal, but do nothing, it will pass on its own (the Google daily limit).
  /// Red - you need to act. Without the middle state an exhausted limit
  /// would have to pretend to be either a failure or all-clear, and it is neither.
  private var uploadStateCard: some View {
    let state = status.buffer.uploadState
    let tone = uploadTone(state)

    return VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        ZStack {
          Circle()
            .fill(tone.color.opacity(0.15))
            .frame(width: 40, height: 40)

          Image(systemName: uploadIcon(state))
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(tone.color)
        }
        .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 3) {
          // The label comes straight from `UploadState`. Assembling it here from
          // two bools limited the interface to three variants, and there are more.
          Text(state.badge)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(tone.color)

          Text(state.headline)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(RenaCodeTheme.textMain)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)
      }

      Text(state.explanation)
        .font(.system(size: 13))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .fixedSize(horizontal: false, vertical: true)
        .textSelection(.enabled)
    }
    .toneCard(tone)
  }

  private func uploadTone(_ state: UploadState) -> StatusTone {
    if state.needsAttention { return .danger }
    if !state.isNominal { return .warning }
    return .success
  }

  private func uploadIcon(_ state: UploadState) -> String {
    switch state {
    case .mountDown: return "icloud.slash.fill"
    case .driveFull: return "externaldrive.badge.xmark"
    case .failedFiles: return "exclamationmark.triangle.fill"
    case .bufferFull: return "tray.full.fill"
    case .dailyQuotaExhausted: return "hourglass"
    case .flowing: return "arrow.up.circle.fill"
    case .upToDate: return "checkmark.icloud.fill"
    case .queueUnknown: return "questionmark.circle.fill"
    }
  }

  // MARK: - Helpers

  private func cardTitle(
    _ title: String, systemImage: String, tone: StatusTone = .brand
  ) -> some View {
    HStack(spacing: 8) {
      Image(systemName: systemImage)
        .font(.system(size: 15))
        .foregroundStyle(tone == .brand ? RenaCodeTheme.colorCyan : tone.color)
        .accessibilityHidden(true)
      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(RenaCodeTheme.textMain)
        .accessibilityAddTraits(.isHeader)
    }
  }

  private func row(_ label: String, _ value: String, tone: StatusTone) -> some View {
    HStack(alignment: .firstTextBaseline) {
      HStack(spacing: 8) {
        StatusDot(tone, size: 7)
        Text(label)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(RenaCodeTheme.textMuted)
      }

      Spacer(minLength: 12)

      Text(value)
        .font(.system(size: 13, weight: .semibold).monospacedDigit())
        .foregroundStyle(
          tone == .success || tone == .neutral ? RenaCodeTheme.textMain : tone.color
        )
        .multilineTextAlignment(.trailing)
        .textSelection(.enabled)
    }
    .accessibilityElement(children: .combine)
  }
}
