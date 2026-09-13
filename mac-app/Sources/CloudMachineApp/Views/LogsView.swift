import AppKit
import CloudMachineCore
import SwiftUI

/// Konsola podglądu logów z filtrowaniem i wyszukiwaniem,
/// dostosowana do systemu wizualnego RenaCode.
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

    var localizedName: String {
      return self.rawValue.localized
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {

      // Pasek narzędzi logów
      HStack(spacing: 12) {
        // Pole wyszukiwania z ikoną szkła powiększającego
        HStack(spacing: 6) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMuted)

          TextField("Szukaj w logach...".localized, text: $searchText)
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.textMain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RenaCodeTheme.bgInset)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
        )
        .frame(maxWidth: 240)

        // Filtry typu logów (Segmented tab style)
        HStack(spacing: 3) {
          ForEach(LogFilter.allCases) { filter in
            Button(action: {
              withAnimation(.easeInOut(duration: 0.15)) {
                selectedFilter = filter
              }
            }) {
              Text(filter.localizedName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(
                  selectedFilter == filter ? RenaCodeTheme.textMain : RenaCodeTheme.textMuted
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                  ZStack {
                    if selectedFilter == filter {
                      RoundedRectangle(cornerRadius: 6)
                        .fill(RenaCodeTheme.colorPrimary.opacity(0.3))
                    }
                  }
                )
            }
            .buttonStyle(.plain)
          }
        }
        .padding(3)
        .background(RenaCodeTheme.bgInset)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
        )

        Spacer()

        // Przełącznik autoprzewijania
        Toggle(isOn: $autoScroll) {
          Text("Autoprzewijanie".localized)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(RenaCodeTheme.textMuted)
        }
        .toggleStyle(.checkbox)

        // Odśwież logi
        Button(action: { controller.refreshLogTail() }) {
          HStack(spacing: 4) {
            Image(systemName: "arrow.clockwise")
              .font(.system(size: 11))
            Text("Odśwież".localized)
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())

        // Otwórz folder z logami
        Button(action: { NSWorkspace.shared.open(CMPaths.logDir) }) {
          HStack(spacing: 4) {
            Image(systemName: "folder")
              .font(.system(size: 11))
            Text("Folder logów".localized)
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())
      }
      .padding(.horizontal, 22)
      .padding(.top, 14)

      // Okno konsoli logów (Dark Terminal Window)
      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 3) {
            let filteredLines = filterLogLines()

            if filteredLines.isEmpty {
              VStack(spacing: 8) {
                Image(systemName: "text.magnifyingglass")
                  .font(.system(size: 28))
                  .foregroundStyle(RenaCodeTheme.textDim)
                Text("Brak wpisów pasujących do wybranych filtrów.".localized)
                  .font(.system(size: 13, weight: .medium))
                  .foregroundStyle(RenaCodeTheme.textMuted)
              }
              .padding(40)
              .frame(maxWidth: .infinity, alignment: .center)
            } else {
              ForEach(0..<filteredLines.count, id: \.self) { index in
                let line = filteredLines[index]
                LogLineView(line: line)
                  .id(index)
              }
            }

            Color.clear
              .frame(height: 1)
              .id("bottom")
          }
          .padding(14)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(RenaCodeTheme.bgInset)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(RenaCodeTheme.borderGlassStrong, lineWidth: 1)
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
      .padding(.horizontal, 22)
      .padding(.bottom, 22)
    }
    .onReceive(timer) { _ in
      controller.refreshLogTail()
    }
  }

  // Filtrowanie linii logu
  private func filterLogLines() -> [String] {
    let allLines = controller.status.logTail.split(separator: "\n").map(String.init)

    return allLines.filter { line in
      if !searchText.isEmpty {
        guard line.localizedCaseInsensitiveContains(searchText) else {
          return false
        }
      }

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

// MARK: - Komponent Pojedynczej Linii Logu

struct LogLineView: View {
  var line: String

  var body: some View {
    HStack(alignment: .top, spacing: 6) {
      Text(line)
        .font(.system(size: 11, weight: .medium, design: .monospaced))
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
      return RenaCodeTheme.colorDanger
    }

    if line.localizedCaseInsensitiveContains("ostrzezenie")
      || line.localizedCaseInsensitiveContains("warning:")
      || line.localizedCaseInsensitiveContains("warn:")
    {
      return RenaCodeTheme.colorWarning
    }

    if line.localizedCaseInsensitiveContains("rclone:")
      || line.localizedCaseInsensitiveContains("transfer")
    {
      return RenaCodeTheme.colorCyan
    }

    if line.localizedCaseInsensitiveContains("OK")
      || line.localizedCaseInsensitiveContains("sukces")
      || line.localizedCaseInsensitiveContains("success")
    {
      return RenaCodeTheme.colorSuccess
    }

    return RenaCodeTheme.textMain
  }
}
