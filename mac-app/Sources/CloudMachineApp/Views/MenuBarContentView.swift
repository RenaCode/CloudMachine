import SwiftUI

/// Zawartosc ikony w pasku menu. Ma sie czytac jednym spojrzeniem - stan
/// i jedna liczba, ktora naprawde cos znaczy. Reszta jest w oknie glownym.
struct MenuBarContentView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        Image(
          systemName: controller.status.healthy
            ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
        )
        .foregroundStyle(controller.status.healthy ? .green : .orange)
        Text(controller.status.headline).bold()
      }

      Divider()

      if let progress = controller.status.backupProgress, let percent = progress.percent {
        HStack {
          Text("Backup")
          Spacer()
          Text(String(format: "%.1f%%", percent * 100)).monospacedDigit()
        }
        .font(.callout)
      }

      // Kolejka wysylki mowi wiecej niz rozmiar bufora: dopoki nie wraca do
      // zera miedzy backupami, dane sa jeszcze tylko lokalnie.
      HStack {
        Text("Czeka na wyslanie")
        Spacer()
        Text(
          controller.status.buffer.draining ? "\(controller.status.buffer.uploadsQueued)" : "nic"
        )
        .monospacedDigit()
        .foregroundStyle(controller.status.buffer.draining ? .orange : .secondary)
      }
      .font(.callout)

      HStack {
        Text("Bufor")
        Spacer()
        Text("\(controller.status.buffer.sizeGB) GB").monospacedDigit().foregroundStyle(.secondary)
      }
      .font(.callout)

      Divider()

      if controller.status.backupProgress == nil {
        Button("Zrob backup teraz") { Task { await controller.startBackup() } }
          .disabled(!controller.status.healthy)
      } else {
        Button("Wstrzymaj backup") { Task { await controller.stopBackup() } }
      }
      Button("Otworz CloudMachine") { openWindow(id: "dashboard") }
      Button("Zakoncz") { NSApplication.shared.terminate(nil) }
    }
    .padding(14)
    .frame(width: 260)
    .task { controller.startAutoRefresh(interval: 15) }
  }
}
