import AppKit
import CloudMachineCore
import SwiftUI

struct MenuBarContentView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {

      // Nagłówek panelu
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("CloudMachine")
            .font(.headline.bold())
          Text("Time Machine Cloud Utility")
            .font(.system(size: 9))
            .foregroundStyle(.secondary)
        }
        Spacer()

        // Pigułka statusu montowania
        HStack(spacing: 4) {
          Circle()
            .fill(mountColor)
            .frame(width: 6, height: 6)
          Text(mountLabel)
            .font(.caption2.bold())
            .foregroundStyle(mountColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(mountColor.opacity(0.1))
        .clipShape(Capsule())
      }
      .padding(.bottom, 2)

      // Alert o błędzie
      if let error = controller.status.errorMessage {
        HStack(alignment: .top, spacing: 6) {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.red)
            .font(.caption)
          Text(error)
            .font(.system(size: 10))
            .foregroundStyle(.red)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
      }

      // Sekcja wykorzystania lokalnego woluminu backupu
      if let total = controller.status.localVolume.totalGB,
        let used = controller.status.localVolume.usedGB
      {
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text("Lokalny wolumin".localized)
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f GB / %.0f GB", used, total))
              .font(.caption.bold())
              .foregroundStyle(.primary)
          }

          GeometryReader { geo in
            ZStack(alignment: .leading) {
              Capsule()
                .fill(Color.secondary.opacity(0.12))
                .frame(height: 6)

              Capsule()
                .fill(
                  LinearGradient(
                    colors: controller.status.localVolume.usedFraction >= 0.9
                      ? [.orange, .red] : [.accentColor, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                )
                .frame(
                  width: geo.size.width * CGFloat(controller.status.localVolume.usedFraction),
                  height: 6)
            }
          }
          .frame(height: 6)
        }
        .padding(.vertical, 4)
      }

      // Pasek aktualnej predkosci wysylania - jedyna czesc "postepu
      // backupu" ktora ma sens w waskim popupie paska menu (jedna linia,
      // bez wykresow), reszta (procent/pliki/ETA) zostaje w pelnym Panelu
      // sterowania nizej. Widoczny tylko gdy backup faktycznie kopiuje.
      if let progress = controller.status.backupProgress, let rate = progress.transferRateMBs,
        rate > 0
      {
        HStack {
          Label("Wysyłanie".localized, systemImage: "arrow.up.circle")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
          Text(String(format: "%.1f MB/s", rate))
            .font(.caption.bold())
            .foregroundStyle(.primary)
        }
      }

      Divider()

      // Montowanie i backup przenieione do pelnego Panelu sterowania (karta
      // Status) - tam jest tez miejsce na info o postepie/predkosci, ktorego
      // w waskim popupie paska menu nie dalo sie sensownie pokazac.

      // Menu sterowania / preferencji
      HStack(spacing: 8) {
        Button(action: {
          openWindow(id: "dashboard")
          NSApp.activate(ignoringOtherApps: true)
        }) {
          Label("Panel sterowania".localized, systemImage: "gauge")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)

        Button(action: {
          NSApp.terminate(nil)
        }) {
          Label("Zakończ".localized, systemImage: "power")
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .tint(.red)
      }
    }
    .padding(12)
    .frame(width: 270)
    .task {
      await controller.refreshAll()
    }
  }

  // MARK: - Pomocnicze zmienne statusu

  private var mountColor: Color {
    guard controller.status.localVolume.exists else { return .secondary }
    return controller.status.timeMachineState == .registered ? .green : .orange
  }

  private var mountLabel: String {
    guard controller.status.localVolume.exists else { return "Brak woluminu".localized }
    return controller.status.timeMachineState == .registered
      ? "Gotowy".localized : "Niezarejestrowany".localized
  }
}
