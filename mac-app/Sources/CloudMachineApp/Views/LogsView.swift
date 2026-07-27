import AppKit
import CloudMachineCore
import SwiftUI

struct LogsView: View {
  @EnvironmentObject private var controller: CloudMachineController
  private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

  @State private var searchText = ""
  @State private var selectedFilter: LogFilter = .all
  @State private var autoScroll = true

  enum LogFilter: String, CaseIterable, Identifiable {
    case all = "Wszystkie"
    case errors = "Błędy"
    case transfers = "Transfery rclone"

    var id: String { self.rawValue }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {

      // Pasek narzędzi logów
      HStack(spacing: 12) {
        // Pole wyszukiwania
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)
        TextField("Szukaj w logach...", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .frame(maxWidth: 240)

        // Filtry typu logów
        Picker("Filtr:", selection: $selectedFilter) {
          ForEach(LogFilter.allCases) { filter in
            Text(filter.rawValue).tag(filter)
          }
        }
        .pickerStyle(.segmented)
        .frame(width: 280)

        Spacer()

        // Opcje kontrolne
        Toggle("Autoprzewijanie", isOn: $autoScroll)
          .toggleStyle(.checkbox)

        Button(action: {
          controller.refreshLogTail()
        }) {
          Label("Odśwież", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.bordered)

        Button(action: {
          NSWorkspace.shared.open(CMPaths.logDir)
        }) {
          Label("Folder logów", systemImage: "folder")
        }
        .buttonStyle(.bordered)
      }
      .padding(.horizontal, 16)
      .padding(.top, 12)

      // Konsola logów
      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 4) {
            let filteredLines = filterLogLines()

            if filteredLines.isEmpty {
              Text("Brak wpisów pasujących do wybranych filtrów.")
                .italic()
                .foregroundStyle(.secondary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
              ForEach(0..<filteredLines.count, id: \.self) { index in
                let line = filteredLines[index]
                LogLineView(line: line)
                  .id(index)
              }
            }

            // Element pomocniczy do przewijania do dołu
            Color.clear
              .frame(height: 1)
              .id("bottom")
          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .onChange(of: controller.status.logTail) { _, _ in
          if autoScroll {
            withAnimation {
              proxy.scrollTo("bottom", anchor: .bottom)
            }
          }
        }
        .onAppear {
          controller.refreshLogTail()
          if autoScroll {
            proxy.scrollTo("bottom", anchor: .bottom)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
    }
    .onReceive(timer) { _ in
      controller.refreshLogTail()
    }
  }

  // Filtrowanie linii logu
  private func filterLogLines() -> [String] {
    let allLines = controller.status.logTail.split(separator: "\n").map(String.init)

    return allLines.filter { line in
      // Najpierw filtr wyszukiwania tekstowego
      if !searchText.isEmpty {
        guard line.localizedCaseInsensitiveContains(searchText) else {
          return false
        }
      }

      // Następnie filtry kategorii
      switch selectedFilter {
      case .all:
        return true
      case .errors:
        return line.localizedCaseInsensitiveContains("BLAD")
          || line.localizedCaseInsensitiveContains("ERROR")
          || line.localizedCaseInsensitiveContains("failed")
          || line.localizedCaseInsensitiveContains("failed:")
      case .transfers:
        return line.localizedCaseInsensitiveContains("rclone")
          || line.localizedCaseInsensitiveContains("transfer")
          || line.localizedCaseInsensitiveContains("size")
          || line.localizedCaseInsensitiveContains("stats")
      }
    }
  }
}

// MARK: - Komponent pojedynczej linii logu

struct LogLineView: View {
  var line: String

  var body: some View {
    HStack(alignment: .top, spacing: 6) {
      Text(line)
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(lineColor)
        .textSelection(.enabled)
        .multilineTextAlignment(.leading)
    }
  }

  private var lineColor: Color {
    if line.localizedCaseInsensitiveContains("BLAD:")
      || line.localizedCaseInsensitiveContains("ERROR:")
      || line.localizedCaseInsensitiveContains("critical:")
      || line.localizedCaseInsensitiveContains("fatal:")
    {
      return .red
    }

    if line.localizedCaseInsensitiveContains("ostrzezenie")
      || line.localizedCaseInsensitiveContains("warning:")
      || line.localizedCaseInsensitiveContains("warn:")
    {
      return .orange
    }

    if line.localizedCaseInsensitiveContains("rclone:")
      || line.localizedCaseInsensitiveContains("transfer")
    {
      return .cyan
    }

    if line.localizedCaseInsensitiveContains("OK")
      || line.localizedCaseInsensitiveContains("sukces")
      || line.localizedCaseInsensitiveContains("success")
    {
      return .green
    }

    return .primary
  }
}
