import CloudMachineCore
import SwiftUI

/// Contents of the menu bar (MenuBar Extra), kept in the modern
/// RenaCode visual style.
///
/// Observes `AppStatus` directly for the same reason as `DashboardView`.
struct MenuBarContentView: View {
  @EnvironmentObject private var controller: CloudMachineController

  var body: some View {
    MenuBarPanel(status: controller.status)
      .task { controller.startAutoRefresh(interval: 15) }
  }
}

private struct MenuBarPanel: View {
  @EnvironmentObject private var controller: CloudMachineController
  @ObservedObject var status: AppStatus
  @Environment(\.openWindow) private var openWindow

  /// Opens the panel and brings it TO THE FRONT.
  ///
  /// The app is a menu bar agent (`LSUIElement`), so `openWindow` on its own
  /// creates the window but does not activate the app - the window ended up
  /// beneath the windows of whatever program the user happened to be working in. Activation
  /// has to be explicit and has to come AFTER the window is created, hence deferring it to
  /// the next pass of the event loop.
  private func showDashboard() {
    openWindow(id: "dashboard")
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
      let dashboard = NSApp.windows.first {
        $0.identifier?.rawValue == "dashboard" || $0.title == "CloudMachine"
      }
      dashboard?.makeKeyAndOrderFront(nil)
    }
  }

  /// Green only for a really good state - the same rule as the window's
  /// health card.
  private var tone: StatusTone {
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

  private var cycleTone: StatusTone {
    if status.backupCycle.isFresh() { return .success }
    return status.backupCycle.known ? .danger : .warning
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header with the logo and the health verdict
      HStack(spacing: 10) {
        IconTile(systemImage: "icloud.and.arrow.up.fill", gradient: RenaCodeTheme.frameGradient)

        Text(verbatim: "CloudMachine")
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(RenaCodeTheme.textMain)
          .lineLimit(1)
          .fixedSize()

        Spacer()

        StatusPill(
          tone == .success
            ? L10n.tr("Healthy")
            : (tone == .danger ? L10n.tr("Action needed") : L10n.tr("Attention")),
          tone: tone)
      }

      // The one-sentence answer to "is my data safe", in the verdict's color.
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        StatusDot(tone, live: status.buffer.uploadState.isMovingData)
        Text(status.headline)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(tone == .success ? RenaCodeTheme.textMain : tone.color)
          .fixedSize(horizontal: false, vertical: true)
      }
      .accessibilityElement(children: .combine)

      // Progress of the running backup
      if let progress = status.backupProgress, let percent = progress.percent {
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            // Not repeated when the headline above already says it.
            if status.headline != L10n.tr("Backup in progress") {
              Text(L10n.tr("Backup in progress"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(RenaCodeTheme.textMuted)
            }
            Spacer()
            Text(String(format: "%.1f%%", percent * 100))
              .font(.system(size: 12, weight: .bold).monospacedDigit())
              .foregroundStyle(RenaCodeTheme.textMain)
          }
          GradientProgressBar(fraction: percent, height: 6)
        }
        .accessibilityElement(children: .combine)
      }

      // Queue and buffer state, as two tiles like the window's cards
      HStack(spacing: 8) {
        tile(
          L10n.tr("Waiting to upload"),
          !status.buffer.queueKnown
            ? "?"
            : (status.buffer.draining
              ? L10n.tr("%@ files", "\(status.buffer.uploadsQueued)") : L10n.tr("nothing")),
          // Cyan while draining - the normal state during a backup; amber only
          // when the queue could not be read.
          valueColor: !status.buffer.queueKnown
            ? RenaCodeTheme.colorWarning
            : (status.buffer.draining ? RenaCodeTheme.colorCyan : RenaCodeTheme.textMain))
        tile(
          L10n.tr("SSD buffer"), L10n.tr("%@ GB", "\(status.buffer.sizeGB)"),
          valueColor: RenaCodeTheme.textMain)
      }

      HStack(spacing: 8) {
        StatusDot(cycleTone, size: 6)
        Text(L10n.tr("Last completed backup"))
          .foregroundStyle(RenaCodeTheme.textMuted)
        Spacer(minLength: 4)
        Text(status.backupCycle.ageText())
          .fontWeight(.semibold)
          .foregroundStyle(cycleTone == .success ? RenaCodeTheme.textMain : cycleTone.color)
      }
      .font(.system(size: 12).monospacedDigit())
      .accessibilityElement(children: .combine)

      Divider().background(RenaCodeTheme.borderGlass)

      // Action buttons
      VStack(spacing: 6) {
        if status.backupProgress == nil {
          Button(action: { Task { await controller.startBackup() } }) {
            HStack {
              Image(systemName: "play.fill")
              Text(L10n.tr("Back up now"))
              Spacer()
            }
          }
          .buttonStyle(PrimaryGradientButtonStyle())
          .disabled(!status.canStartBackup)
        } else {
          Button(action: { Task { await controller.stopBackup() } }) {
            HStack {
              Image(systemName: "stop.fill")
              Text(L10n.tr("Stop backup"))
              Spacer()
            }
          }
          .buttonStyle(SecondaryGlassButtonStyle())
        }

        HStack(spacing: 6) {
          Button(action: showDashboard) {
            HStack {
              Image(systemName: "macwindow")
              Text(L10n.tr("Open CloudMachine"))
              Spacer()
            }
          }
          .buttonStyle(SecondaryGlassButtonStyle())

          Button(action: { NSApplication.shared.terminate(nil) }) {
            Image(systemName: "power")
          }
          .buttonStyle(SecondaryGlassButtonStyle())
          .help(L10n.tr("Quit"))
          .accessibilityLabel(L10n.tr("Quit"))
        }
      }
    }
    .padding(14)
    .frame(width: 300)
    .background(
      ZStack {
        RenaCodeTheme.bgDark
        RenaCodeTheme.cardGradient
      }
    )
    .overlay(GradientWindowFrame(cornerRadius: 14, lineWidth: 1))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  private func tile(_ label: String, _ value: String, valueColor: Color) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(label)
        .font(.system(size: 11))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(value)
        .font(.system(size: 17, weight: .bold).monospacedDigit())
        .foregroundStyle(valueColor)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .accessibilityElement(children: .combine)
    .toneCard(.brand, cornerRadius: 10, padding: 10)
  }
}
