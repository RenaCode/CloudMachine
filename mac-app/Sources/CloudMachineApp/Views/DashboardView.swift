import SwiftUI
import CloudMachineCore

struct DashboardView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @State private var selectedTab: Tab = .status

  /// W przeciwienstwie do `MenuBarContentView` (ktorego `.task` odpala sie
  /// na nowo za KAZDYM razem, gdy uzytkownik otwiera popup paska menu - patrz
  /// komentarz przy `refreshAllMinInterval` w `CloudMachineController`), to
  /// okno raz otwarte zyje dlugo i NIGDY samo z siebie nie odswiezaloby
  /// statusu ponownie - `.task` ponizej odpala sie tylko RAZ, przy pierwszym
  /// pojawieniu sie okna. Bez tego timera stan (np. "Montowanie...") moze
  /// pozostac zamrozony na godziny w oknie otwartym akurat w trakcie
  /// przejsciowego problemu, mimo ze system pod spodem dawno juz wrocil do
  /// zdrowia - zaobserwowane realnie na zywo.
  private let refreshTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

  enum Tab: Hashable {
    case status
    case wizard
    case config
    case logs
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedTab) {
        Section("Narzędzia".localized) {
          NavigationLink(value: Tab.status) {
            Label("Status".localized, systemImage: "gauge.with.needle")
          }
          NavigationLink(value: Tab.wizard) {
            Label("Kreator".localized, systemImage: "wand.and.stars")
          }
          NavigationLink(value: Tab.config) {
            Label("Maszyny i limity".localized, systemImage: "macbook.and.iphone")
          }
          NavigationLink(value: Tab.logs) {
            Label("Logi systemowe".localized, systemImage: "doc.text.magnifyingglass")
          }
        }
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 250)
      .safeAreaInset(edge: .bottom) {
        SidebarStatusFooter()
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(.thinMaterial)
      }
    } detail: {
      Group {
        switch selectedTab {
        case .status:
          StatusView()
        case .wizard:
          SetupWizardView()
        case .config:
          MachinesConfigView()
        case .logs:
          LogsView()
        }
      }
      .navigationTitle(navigationTitle(for: selectedTab))
      .toolbar {
        ToolbarItem(placement: .navigation) {
          if controller.status.isBusy {
            HStack(spacing: 8) {
              ProgressView()
                .controlSize(.small)
              Text(controller.status.busyLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
    }
    .task {
      await controller.refreshAll()
    }
    .onReceive(refreshTimer) { _ in
      Task { await controller.refreshAll() }
    }
  }

  private func navigationTitle(for tab: Tab) -> String {
    switch tab {
    case .status: return "Stan systemu".localized
    case .wizard: return "Kreator konfiguracji".localized
    case .config: return "Zarządzanie maszynami i limitami".localized
    case .logs: return "Logi konsoli".localized
    }
  }
}

struct SidebarStatusFooter: View {
  @EnvironmentObject private var controller: CloudMachineController
  @State private var isPulse = false

  var body: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(statusColor)
        .frame(width: 8, height: 8)
        .scaleEffect(isPulse ? 1.25 : 0.8)
        .opacity(isPulse ? 1.0 : 0.5)
        .onAppear {
          withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isPulse = true
          }
        }

      VStack(alignment: .leading, spacing: 2) {
        Text(statusText)
          .font(.caption2.bold())
        Text(subText)
          .font(.system(size: 9))
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
      Spacer()
    }
  }

  private var statusColor: Color {
    if controller.status.errorMessage != nil {
      return .red
    }
    switch controller.status.mountState {
    case .mounted:
      return .green
    case .mounting:
      return .orange
    case .failed:
      return .red
    default:
      return .secondary
    }
  }

  private var statusText: String {
    if controller.status.errorMessage != nil {
      return "Problem z konfiguracją".localized
    }
    switch controller.status.mountState {
    case .mounted:
      return "Połączono z chmurą".localized
    case .mounting:
      return "Montowanie...".localized
    case .failed:
      return "Błąd montowania".localized
    default:
      return "Brak połączenia".localized
    }
  }

  private var subText: String {
    if let err = controller.status.errorMessage {
      return err
    }
    switch controller.status.mountState {
    case .mounted:
      return "NFS wolumin gotowy".localized
    case .mounting:
      return "Nawiązywanie połączenia...".localized
    case .failed(let err):
      return err
    default:
      return "Dysk nie jest zamontowany".localized
    }
  }
}
