import CloudMachineCore
import SwiftUI

/// The main interface of the CloudMachine app, kept in the modern RenaCode
/// visual system (consistent with Dietetyk-AI and Trader-AI).
struct DashboardView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @State private var clientID = ""
  @State private var clientSecret = ""
  @State private var credentialsMessage: String?
  @State private var credentialsExpanded = false
  /// Logical size of a new backup image. Sparse: Drive holds only what is written.
  @State private var imageSizeGB = "4000"
  /// This Mac's folder on Google Drive, chosen before connecting. Empty means
  /// "not edited yet" and shows the suggestion from the computer name.
  @State private var driveFolder = ""
  /// The limit being typed; empty = show the stored one.
  @State private var limitText = ""

  var body: some View {
    ZStack {
      // Glowing RenaCode background
      AmbientGlowBackground()

      VStack(spacing: 0) {
        // Top bar / header with the logo and tabs
        topHeaderBar

        // Main content
        dashboardContent
      }
    }
    .task { controller.startAutoRefresh() }
  }

  // MARK: - Top Navigation Bar

  private var topHeaderBar: some View {
    VStack(spacing: 12) {
      HStack(spacing: 16) {
        // Logo icon with a violet and cyan glow
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(RenaCodeTheme.aiGradient)
            .frame(width: 42, height: 42)
            .shadow(color: RenaCodeTheme.colorPrimary.opacity(0.45), radius: 12, x: 0, y: 4)

          Image(systemName: "icloud.and.arrow.up.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
        }

        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 8) {
            Text("CloudMachine")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(RenaCodeTheme.textMain)

            RenaCodePillBadge(
              text: "Time Machine",
              icon: "cloud.fill",
              color: RenaCodeTheme.colorPrimary
            )

            RenaCodePillBadge(
              text: controller.status.healthy ? L10n.tr("Healthy") : L10n.tr("Attention"),
              color: controller.status.healthy
                ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
            )
          }

          Text(L10n.tr("Local SSD buffer & backup to Google Drive"))
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(RenaCodeTheme.textMuted)
        }

        Spacer()

        // Refresh information and activity indicator
        HStack(spacing: 12) {
          if let at = controller.status.lastRefresh {
            HStack(spacing: 5) {
              Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 11))
              Text(L10n.tr("Refreshed %@", at.formatted(date: .omitted, time: .standard)))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .foregroundStyle(RenaCodeTheme.textDim)
          }

          if controller.status.isBusy {
            HStack(spacing: 6) {
              ProgressView().controlSize(.small)
              Text(controller.status.busyLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(RenaCodeTheme.colorCyan)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RenaCodeTheme.colorCyan.opacity(0.12))
            .clipShape(Capsule())
          }
        }
      }

    }
    .padding(.horizontal, 22)
    .padding(.top, 18)
    .padding(.bottom, 14)
    .background(
      RenaCodeTheme.bgDark.opacity(0.85)
    )
    .overlay(
      Rectangle()
        .fill(RenaCodeTheme.borderGlass)
        .frame(height: 1),
      alignment: .bottom
    )
  }

  // MARK: - Dashboard Content

  private var dashboardContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {

        // Banner for an error, if any
        if let error = controller.status.errorMessage {
          errorBanner(error)
        }

        // Grid of KPI stat cards (top row)
        kpiSummaryGrid

        // Whether the backup reaches the Drive - and why not, if it does not
        uploadStateCard

        // Card with the progress of the running backup (if one is running)
        if let progress = controller.status.backupProgress {
          progressCard(progress)
        }

        // Card with setup steps ("To do")
        if !setupSteps.isEmpty {
          setupCard
        }

        // Buffer and upload details
        bufferCard

        // This Mac's space limit on Google Drive
        if controller.status.remoteConfigured {
          budgetCard
        }

        // Google OAuth credentials
        credentialsCard

        // Bottom action bar
        actionsToolbar
      }
      .padding(22)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: - Error Banner

  private func errorBanner(_ message: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 18))
        .foregroundStyle(RenaCodeTheme.colorDanger)

      Text(message)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(RenaCodeTheme.textMain)
        .textSelection(.enabled)

      Spacer()
    }
    .padding(14)
    .background(RenaCodeTheme.colorDanger.opacity(0.12))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(RenaCodeTheme.colorDanger.opacity(0.35), lineWidth: 1)
    )
  }

  // MARK: - KPI Summary Grid

  private var kpiSummaryGrid: some View {
    LazyVGrid(
      columns: [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
      ], spacing: 14
    ) {
      StatCard(
        title: L10n.tr("System Status"),
        value: controller.status.healthy ? L10n.tr("Healthy") : L10n.tr("Action needed"),
        subtitle: controller.status.headline,
        systemImage: controller.status.healthy
          ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
        iconColor: controller.status.healthy
          ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
      )

      StatCard(
        title: L10n.tr("Buffer Size"),
        value: "\(controller.status.buffer.sizeGB) GB",
        // A missing measurement must look different from a number - see
        // `BufferGuardService.freeGB()`. Simply putting the optional value
        // into the text gave "Free on disk: Optional(427) GB", and the compiler
        // reported it ONLY as a warning, so no test would have caught it.
        subtitle: L10n.tr(
          "Free on disk: %@",
          controller.status.buffer.freeDiskGB.map { L10n.tr("%@ GB", "\($0)") }
            ?? L10n.tr("not measured")),
        systemImage: "internaldrive.fill",
        iconColor: RenaCodeTheme.colorCyan
      )

      StatCard(
        title: L10n.tr("Upload Queue"),
        // Without a queue reading this card has no right to say "Nothing
        // pending" - the zeros are then a missing measurement, not a result.
        value: !controller.status.buffer.queueKnown
          ? "—"
          : (controller.status.buffer.draining
            ? L10n.tr("%@ queued", "\(controller.status.buffer.uploadsQueued)")
            : L10n.tr("Nothing pending")),
        subtitle: !controller.status.buffer.queueKnown
          ? L10n.tr("rclone did not answer")
          : (controller.status.buffer.draining
            ? L10n.tr("%@ transfers in progress", "\(controller.status.buffer.uploadsInProgress)")
            : L10n.tr("Everything in the cloud")),
        systemImage: "icloud.and.arrow.up.fill",
        iconColor: !controller.status.buffer.queueKnown
          ? RenaCodeTheme.colorWarning
          : (controller.status.buffer.draining
            ? RenaCodeTheme.colorWarning : RenaCodeTheme.colorSuccess)
      )

      StatCard(
        title: "Time Machine",
        value: controller.status.buffer.imageAttached
          ? L10n.tr("Attached") : L10n.tr("Not attached"),
        subtitle: controller.status.buffer.mounted
          ? L10n.tr("Google Drive mounted") : L10n.tr("Drive disconnected"),
        systemImage: "clock.arrow.circlepath",
        iconColor: controller.status.buffer.imageAttached
          ? RenaCodeTheme.colorPrimaryLight : RenaCodeTheme.textDim
      )
    }
  }

  // MARK: - Backup Progress

  private func progressCard(_ progress: BackupProgressInfo) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          ZStack {
            Circle()
              .fill(RenaCodeTheme.colorCyan.opacity(0.2))
              .frame(width: 28, height: 28)
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(RenaCodeTheme.colorCyan)
          }

          Text(L10n.tr("Backup in Progress"))
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)
        }

        Spacer()

        if let percent = progress.percent {
          Text(String(format: "%.1f%%", percent * 100))
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundStyle(RenaCodeTheme.colorCyan)
        }
      }

      if let percent = progress.percent {
        GeometryReader { geo in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
              .fill(RenaCodeTheme.bgInset)
              .frame(height: 10)

            RoundedRectangle(cornerRadius: 6)
              .fill(RenaCodeTheme.cyanGradient)
              .frame(
                width: max(0, min(geo.size.width * CGFloat(percent), geo.size.width)), height: 10
              )
              .shadow(color: RenaCodeTheme.colorCyan.opacity(0.5), radius: 6, x: 0, y: 0)
          }
        }
        .frame(height: 10)
      }

      HStack(spacing: 24) {
        if let done = progress.filesDone, let total = progress.filesTotal, total > 0 {
          VStack(alignment: .leading, spacing: 2) {
            Text(L10n.tr("Files processed"))
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text("\(done) / \(total)")
              .font(.system(size: 13, weight: .semibold, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMain)
          }
        }

        if let rate = progress.transferRateMBs {
          VStack(alignment: .leading, spacing: 2) {
            Text(L10n.tr("Write speed"))
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text(String(format: "%.1f MB/s", rate))
              .font(.system(size: 13, weight: .semibold, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.colorSuccess)
          }
        }

        if let phase = progress.phase {
          VStack(alignment: .leading, spacing: 2) {
            Text(L10n.tr("Operation phase"))
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text(phase)
              .font(.system(size: 13, weight: .medium))
              .foregroundStyle(RenaCodeTheme.textMain)
          }
        }
      }
    }
    .glassCard(borderColor: RenaCodeTheme.colorCyan.opacity(0.35))
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
      .disabled(controller.status.isBusy || (action == .createImage && parsedImageSize == nil))
    }
  }

  private var effectiveDriveFolder: String {
    driveFolder.isEmpty ? controller.status.suggestedDriveFolder : driveFolder
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
        TextField(controller.status.suggestedDriveFolder, text: $driveFolder)
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
          ? RenaCodeTheme.textMain.opacity(0.6) : RenaCodeTheme.colorWarning)
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
      HStack(spacing: 8) {
        Image(systemName: "wrench.and.screwdriver.fill")
          .font(.system(size: 15))
          .foregroundStyle(RenaCodeTheme.colorWarning)
        Text(L10n.tr("Required Setup Steps"))
          .font(.system(size: 15, weight: .bold, design: .rounded))
          .foregroundStyle(RenaCodeTheme.textMain)
      }

      VStack(alignment: .leading, spacing: 12) {
        ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
          VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
              Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(RenaCodeTheme.colorWarning)
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
          }
        }
      }
    }
    .glassCard(borderColor: RenaCodeTheme.colorWarning.opacity(0.35))
  }

  // MARK: - Buffer and Upload Details

  /// Several Macs on one Google account share its space; each gets a limit.
  /// Time Machine enforces it through its quota (deleting the oldest
  /// backups), the watchdog warns from 90% of the real usage on Drive.
  private var budgetCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 8) {
        Image(systemName: "chart.pie.fill")
          .font(.system(size: 15))
          .foregroundStyle(RenaCodeTheme.colorCyan)
        Text(L10n.tr("Space limit for this Mac"))
          .font(.system(size: 15, weight: .bold, design: .rounded))
          .foregroundStyle(RenaCodeTheme.textMain)
      }

      row(
        L10n.tr("Used on Google Drive"),
        MachineBudget.summary(
          limitGB: controller.status.budgetLimitGB, usage: controller.status.budgetUsage),
        ok: budgetOK)

      if let usage = controller.status.budgetUsage {
        Text(
          L10n.tr(
            "Measured %@. The watchdog measures again every few hours.",
            usage.measuredAt.formatted(date: .abbreviated, time: .shortened))
        )
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMain.opacity(0.6))
      }

      HStack(spacing: 8) {
        Text(L10n.tr("Limit (GB)"))
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMain)
        TextField(
          controller.status.budgetLimitGB.map { "\($0)" } ?? "1500", text: $limitText
        )
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
        .disabled(
          controller.status.isBusy
            || (Int(limitText.trimmingCharacters(in: .whitespaces)) ?? 0) <= 0)
        Button(action: { Task { await controller.measureDriveUsage() } }) {
          Text(L10n.tr("Measure now")).font(.system(size: 12, weight: .semibold))
        }
        .buttonStyle(SecondaryGlassButtonStyle())
        .disabled(controller.status.isBusy)
      }

      if let limit = controller.status.budgetLimitGB {
        Text(
          L10n.tr(
            "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.",
            "\(MachineBudget.timeMachineQuotaGB(forLimitGB: limit))")
        )
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMain.opacity(0.7))
        .fixedSize(horizontal: false, vertical: true)
      }

      if let command = controller.quotaCommand {
        Text(L10n.tr("Set the Time Machine quota: run this in Terminal (needs sudo)"))
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(RenaCodeTheme.colorWarning)
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
            Text(L10n.tr("Copy")).font(.system(size: 11, weight: .medium))
          }
          .buttonStyle(SecondaryGlassButtonStyle())
        }
        .padding(10)
        .background(RenaCodeTheme.bgInset)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
    .glassCard(borderColor: RenaCodeTheme.colorCyan.opacity(0.35))
  }

  private var budgetOK: Bool {
    guard let limit = controller.status.budgetLimitGB, let usage = controller.status.budgetUsage
    else { return controller.status.budgetLimitGB != nil }
    return MachineBudget.level(usageBytes: usage.bytes, limitGB: limit) == .ok
  }

  private var bufferCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          Image(systemName: "server.rack")
            .font(.system(size: 15))
            .foregroundStyle(RenaCodeTheme.colorCyan)
          Text(L10n.tr("Local Buffer & Upload Status"))
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)
        }

        Spacer()
      }

      VStack(spacing: 10) {
        row(
          L10n.tr("Google Drive mount (FUSE-T)"),
          controller.status.buffer.mounted ? L10n.tr("Mounted") : L10n.tr("Inactive"),
          ok: controller.status.buffer.mounted
        )

        Divider().background(RenaCodeTheme.borderGlass)

        if controller.status.remoteConfigured {
          row(
            L10n.tr("Folder on Google Drive"),
            controller.status.driveFolderPath,
            ok: true
          )

          Divider().background(RenaCodeTheme.borderGlass)
        }

        row(
          L10n.tr("Backup disk image (.sparsebundle)"),
          controller.status.buffer.imageAttached
            ? L10n.tr("Attached to the system") : L10n.tr("Detached"),
          ok: controller.status.buffer.imageAttached
        )

        Divider().background(RenaCodeTheme.borderGlass)

        row(
          L10n.tr("Buffer allocated on the SSD"),
          L10n.tr("%@ GB", "\(controller.status.buffer.sizeGB)"),
          ok: true
        )

        Divider().background(RenaCodeTheme.borderGlass)

        // A missing measurement MUST look different from "0 GB" - see
        // `BufferGuardService.freeGB()`. A failed statfs is a failure of the buffer
        // guard, not information about an empty disk.
        row(
          L10n.tr("Free space on the local volume"),
          controller.status.buffer.freeDiskGB.map { L10n.tr("%@ GB", "\($0)") }
            ?? L10n.tr("not measured"),
          ok: (controller.status.buffer.freeDiskGB ?? 0) > 80
        )

        Divider().background(RenaCodeTheme.borderGlass)

        // The only row that answers the question "WAS a backup made".
        // All the others describe the state of the devices and can be green while
        // Time Machine has not finished a backup for two days.
        row(
          L10n.tr("Last completed backup"),
          controller.status.backupCycle.ageText(),
          ok: controller.status.backupCycle.isFresh()
        )

        Divider().background(RenaCodeTheme.borderGlass)

        // Who watches the watchdog. The row above says whether a backup was made; this one says
        // whether anyone is still CHECKING that. The watchdog runs without KeepAlive, so
        // when unloaded or hung it gives no symptom other than silence - see
        // `WatchdogHeartbeat`.
        row(
          L10n.tr("Last backup watchdog run"),
          controller.status.watchdog.map { StatusLines.watchdogRun($0) }
            ?? L10n.tr("not checked"),
          ok: controller.status.watchdogRunning
        )

        Divider().background(RenaCodeTheme.borderGlass)

        row(
          L10n.tr("Cloud sync queue"),
          !controller.status.buffer.queueKnown
            ? L10n.tr("not read")
            : (controller.status.buffer.draining
              ? L10n.tr(
                "%@ in progress, %@ queued", "\(controller.status.buffer.uploadsInProgress)",
                "\(controller.status.buffer.uploadsQueued)")
              : L10n.tr("Everything uploaded")),
          ok: controller.status.buffer.queueKnown && controller.status.buffer.erroredFiles == 0
        )

        if controller.status.buffer.erroredFiles > 0 {
          Divider().background(RenaCodeTheme.borderGlass)
          row(
            L10n.tr("File upload errors"),
            L10n.tr("%@ files", "\(controller.status.buffer.erroredFiles)"),
            ok: false
          )
        }

        if controller.status.buffer.driveFull {
          Divider().background(RenaCodeTheme.borderGlass)
          row(L10n.tr("Space on Google Drive"), L10n.tr("Out of space"), ok: false)
        }

        if controller.status.buffer.dailyQuotaExhausted {
          Divider().background(RenaCodeTheme.borderGlass)
          row(
            L10n.tr("Google Drive limit"),
            L10n.tr("Daily 750 GB exhausted"),
            ok: false
          )
        }
      }
    }
    .glassCard()
  }

  // MARK: - Google OAuth Credentials

  /// The credentials are collapsed by default. They are entered ONCE, when setting up
  /// your own OAuth client, and then never again - keeping two password fields
  /// on top of a panel that is meant to answer the question about the backup's state only
  /// distracts. The badge next to the header says whether there is anything to expand.
  private var credentialsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      Button {
        withAnimation(.easeInOut(duration: 0.18)) { credentialsExpanded.toggle() }
      } label: {
        HStack(spacing: 8) {
          Image(systemName: "key.fill")
            .font(.system(size: 15))
            .foregroundStyle(RenaCodeTheme.colorPrimaryLight)

          Text(L10n.tr("Google Drive Credentials (OAuth 2.0)"))
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)

          Spacer()

          RenaCodePillBadge(
            text: controller.credentials.isComplete
              ? L10n.tr("Keychain OK") : L10n.tr("No custom keys"),
            icon: controller.credentials.isComplete ? "checkmark.seal.fill" : "lock.open.fill",
            color: controller.credentials.isComplete
              ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
          )

          Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(RenaCodeTheme.textMuted)
            .rotationEffect(.degrees(credentialsExpanded ? 90 : 0))
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if credentialsExpanded {

        Text(controller.credentials.summary)
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMuted)
          .fixedSize(horizontal: false, vertical: true)

        VStack(spacing: 10) {
          HStack {
            Text("client_id:")
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMuted)
              .frame(width: 100, alignment: .leading)

            SecureField(L10n.tr("Paste client_id..."), text: $clientID)
              .textFieldStyle(.plain)
              .padding(8)
              .background(RenaCodeTheme.bgInset)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
              )
          }

          HStack {
            Text("client_secret:")
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMuted)
              .frame(width: 100, alignment: .leading)

            SecureField(L10n.tr("Paste client_secret..."), text: $clientSecret)
              .textFieldStyle(.plain)
              .padding(8)
              .background(RenaCodeTheme.bgInset)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
              )
          }
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
    }
    .glassCard()
  }

  // MARK: - Bottom Action Bar

  private var actionsToolbar: some View {
    HStack(spacing: 12) {
      if controller.status.backupProgress == nil {
        Button(action: { Task { await controller.startBackup() } }) {
          HStack(spacing: 6) {
            Image(systemName: "play.fill")
            Text(L10n.tr("Back up now"))
          }
        }
        .buttonStyle(PrimaryGradientButtonStyle())
        .disabled(!controller.status.healthy || controller.status.isBusy)
      } else {
        Button(action: { Task { await controller.stopBackup() } }) {
          HStack(spacing: 6) {
            Image(systemName: "stop.fill")
            Text(L10n.tr("Stop backup"))
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())
      }

      Button(action: { Task { await controller.verifyImage() } }) {
        HStack(spacing: 6) {
          Image(systemName: "checkmark.shield")
          Text(L10n.tr("Check image consistency"))
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())
      .disabled(controller.status.buffer.imageAttached || controller.status.isBusy)

      Button(action: { Task { await controller.refreshAll() } }) {
        HStack(spacing: 6) {
          Image(systemName: "arrow.clockwise")
          Text(L10n.tr("Refresh"))
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())

      Spacer()
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
  ///
  /// The texts deliberately do not go through `.localized`: most variants insert
  /// a number into the sentence, so they would not have matched the translation dictionary anyway.
  private var uploadStateCard: some View {
    let state = controller.status.buffer.uploadState
    let accent = uploadAccent(state)

    return VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        ZStack {
          Circle()
            .fill(accent.opacity(0.15))
            .frame(width: 40, height: 40)

          Image(systemName: uploadIcon(state))
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(accent)
        }

        VStack(alignment: .leading, spacing: 3) {
          Text(uploadBadge(state))
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(accent)

          Text(state.headline)
            .font(.system(size: 15, weight: .semibold))
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
    .frame(maxWidth: .infinity, alignment: .leading)
    .glassCard(borderColor: accent.opacity(0.35))
  }

  private func uploadAccent(_ state: UploadState) -> Color {
    if state.needsAttention { return RenaCodeTheme.colorDanger }
    if !state.isNominal { return RenaCodeTheme.colorWarning }
    return RenaCodeTheme.colorSuccess
  }

  /// The label comes straight from `UploadState`. Assembling it here from two bools
  /// limited the interface to three variants, and there are more states.
  private func uploadBadge(_ state: UploadState) -> String { state.badge }

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

  // MARK: - Helper Table Row

  private func row(_ label: String, _ value: String, ok: Bool) -> some View {
    HStack {
      HStack(spacing: 8) {
        Circle()
          .fill(ok ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorDanger)
          .frame(width: 7, height: 7)

        Text(label)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(RenaCodeTheme.textMuted)
      }

      Spacer()

      Text(value)
        .font(.system(size: 13, weight: .semibold, design: .monospaced))
        .foregroundStyle(ok ? RenaCodeTheme.textMain : RenaCodeTheme.colorDanger)
    }
  }
}
