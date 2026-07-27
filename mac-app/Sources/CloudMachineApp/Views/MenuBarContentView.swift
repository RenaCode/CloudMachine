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

      // Sekcja użycia limitu dyskowego
      if controller.status.quota.limitGB > 0 {
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text("Limit przestrzeni".localized)
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Text(
              String(
                format: "%.1f GB / %d GB", controller.status.quota.usedGB,
                controller.status.quota.limitGB)
            )
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
                    colors: controller.status.quota.isNearLimit
                      ? [.orange, .red] : [.accentColor, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                )
                .frame(width: geo.size.width * CGFloat(controller.status.quota.fraction), height: 6)
            }
          }
          .frame(height: 6)
        }
        .padding(.vertical, 4)
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
    switch controller.status.mountState {
    case .mounted: return .green
    case .mounting: return .orange
    case .failed: return .red
    default: return .secondary
    }
  }

  private var mountLabel: String {
    switch controller.status.mountState {
    case .mounted: return "Połączono".localized
    case .mounting: return "Łączenie...".localized
    case .notMounted: return "Rozłączono".localized
    case .failed: return "Błąd".localized
    default: return "Nieznany".localized
    }
  }
}
