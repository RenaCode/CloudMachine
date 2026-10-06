import CloudMachineCore
import SwiftUI

/// Contents of the menu bar (MenuBar Extra), kept in the modern
/// RenaCode visual style.
struct MenuBarContentView: View {
  @EnvironmentObject private var controller: CloudMachineController
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

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header with the logo and the health indicator
      HStack(spacing: 10) {
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(RenaCodeTheme.aiGradient)
            .frame(width: 28, height: 28)
          Image(systemName: "icloud.and.arrow.up.fill")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
        }

        VStack(alignment: .leading, spacing: 1) {
          Text("CloudMachine")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)

          Text(controller.status.headline)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(
              controller.status.healthy
                ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning)
        }

        Spacer()

        Circle()
          .fill(
            controller.status.healthy ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
          )
          .frame(width: 8, height: 8)
          .shadow(
            color: (controller.status.healthy
              ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning).opacity(0.6), radius: 4
          )
      }

      Divider().background(RenaCodeTheme.borderGlass)

      // Progress of the running backup
      if let progress = controller.status.backupProgress, let percent = progress.percent {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(L10n.tr("Backup in progress"))
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Spacer()
            Text(String(format: "%.1f%%", percent * 100))
              .font(.system(size: 12, weight: .bold, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.colorCyan)
          }

          GeometryReader { geo in
            ZStack(alignment: .leading) {
              RoundedRectangle(cornerRadius: 3)
                .fill(RenaCodeTheme.bgInset)

              RoundedRectangle(cornerRadius: 3)
                .fill(RenaCodeTheme.cyanGradient)
                .frame(
                  width: max(0, min(geo.size.width * CGFloat(percent), geo.size.width)), height: 5)
            }
          }
          .frame(height: 5)
        }
      }

      // Queue and buffer state
      VStack(spacing: 6) {
        HStack {
          Text(L10n.tr("Waiting to upload"))
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Spacer()
          Text(
            !controller.status.buffer.queueKnown
              ? "?"
              : (controller.status.buffer.draining
                ? L10n.tr("%@ files", "\(controller.status.buffer.uploadsQueued)")
                : L10n.tr("nothing"))
          )
          .font(.system(size: 12, weight: .semibold, design: .monospaced))
          .foregroundStyle(
            !controller.status.buffer.queueKnown || controller.status.buffer.draining
              ? RenaCodeTheme.colorWarning : RenaCodeTheme.textMain)
        }

        HStack {
          Text(L10n.tr("SSD buffer"))
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Spacer()
          Text("\(controller.status.buffer.sizeGB) GB")
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(RenaCodeTheme.textMain)
        }
      }

      Divider().background(RenaCodeTheme.borderGlass)

      // Action buttons
      VStack(spacing: 6) {
        if controller.status.backupProgress == nil {
          Button(action: { Task { await controller.startBackup() } }) {
            HStack {
              Image(systemName: "play.fill")
              Text(L10n.tr("Back up now"))
              Spacer()
            }
          }
          .buttonStyle(PrimaryGradientButtonStyle())
          .disabled(!controller.status.healthy)
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

        Button(action: showDashboard) {
          HStack {
            Image(systemName: "macwindow")
            Text(L10n.tr("Open CloudMachine"))
            Spacer()
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())

        Button(action: { NSApplication.shared.terminate(nil) }) {
          HStack {
            Image(systemName: "power")
            Text(L10n.tr("Quit"))
            Spacer()
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())
      }
    }
    .padding(14)
    .frame(width: 270)
    .background(RenaCodeTheme.bgDark)
    .task { controller.startAutoRefresh(interval: 15) }
  }
}
