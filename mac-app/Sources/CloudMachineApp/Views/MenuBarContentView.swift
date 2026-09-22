import SwiftUI

/// Zawartość paska menu (MenuBar Extra), utrzymana w nowoczesnym
/// stylu wizualnym RenaCode.
struct MenuBarContentView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @Environment(\.openWindow) private var openWindow

  /// Otwiera panel i wyciąga go NA WIERZCH.
  ///
  /// Aplikacja jest agentem paska menu (`LSUIElement`), więc samo
  /// `openWindow` tworzy okno, ale nie aktywuje aplikacji - okno lądowało
  /// pod oknami programu, w którym użytkownik akurat pracował. Aktywacja
  /// musi być jawna i musi iść PO utworzeniu okna, stąd odłożenie na
  /// następny obieg pętli zdarzeń.
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
      // Nagłówek z logo i indeksem sprawności
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

      // Postęp aktywnej kopii zapasowej
      if let progress = controller.status.backupProgress, let percent = progress.percent {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text("Backup w toku")
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

      // Stan kolejki i bufora
      VStack(spacing: 6) {
        HStack {
          Text("Czeka na wysłanie")
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Spacer()
          Text(
            controller.status.buffer.draining
              ? "\(controller.status.buffer.uploadsQueued) plików" : "nic"
          )
          .font(.system(size: 12, weight: .semibold, design: .monospaced))
          .foregroundStyle(
            controller.status.buffer.draining
              ? RenaCodeTheme.colorWarning : RenaCodeTheme.textMain)
        }

        HStack {
          Text("Bufor SSD")
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMuted)
          Spacer()
          Text("\(controller.status.buffer.sizeGB) GB")
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(RenaCodeTheme.textMain)
        }
      }

      Divider().background(RenaCodeTheme.borderGlass)

      // Przyciski akcji
      VStack(spacing: 6) {
        if controller.status.backupProgress == nil {
          Button(action: { Task { await controller.startBackup() } }) {
            HStack {
              Image(systemName: "play.fill")
              Text("Zrób backup teraz")
              Spacer()
            }
          }
          .buttonStyle(PrimaryGradientButtonStyle())
          .disabled(!controller.status.healthy)
        } else {
          Button(action: { Task { await controller.stopBackup() } }) {
            HStack {
              Image(systemName: "stop.fill")
              Text("Wstrzymaj backup")
              Spacer()
            }
          }
          .buttonStyle(SecondaryGlassButtonStyle())
        }

        Button(action: showDashboard) {
          HStack {
            Image(systemName: "macwindow")
            Text("Otwórz CloudMachine")
            Spacer()
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())

        Button(action: { NSApplication.shared.terminate(nil) }) {
          HStack {
            Image(systemName: "power")
            Text("Zakończ")
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
