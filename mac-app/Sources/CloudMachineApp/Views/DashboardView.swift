import CloudMachineCore
import SwiftUI

/// Glowne okno. Ma odpowiadac na jedno pytanie od razu po otwarciu: czy moje
/// dane sa bezpieczne. Szczegoly sa nizej, dla tych chwil, gdy odpowiedz brzmi
/// "nie".
struct DashboardView: View {
  @EnvironmentObject private var controller: CloudMachineController

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        header
        if let error = controller.status.errorMessage { errorBanner(error) }
        if !setupSteps.isEmpty { setupCard }
        bufferCard
        if let progress = controller.status.backupProgress { progressCard(progress) }
        actions
      }
      .padding(24)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .task { controller.startAutoRefresh() }
    // Celowo BEZ onDisappear: kontroler jest wspolny dla okna i paska menu,
    // wiec zatrzymanie odswiezania przy zamknieciu okna zamrazalo takze
    // pasek menu - pokazywal wtedy stan sprzed zamkniecia, wygladajacy jak
    // awaria, mimo ze wszystko dzialalo.
  }

  // MARK: - Naglowek

  private var header: some View {
    HStack(spacing: 12) {
      Image(systemName: controller.status.healthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
        .font(.system(size: 32))
        .foregroundStyle(controller.status.healthy ? .green : .orange)
      VStack(alignment: .leading, spacing: 2) {
        Text(controller.status.headline).font(.title2).bold()
        Text("Time Machine na Google Drive").font(.subheadline).foregroundStyle(.secondary)
      }
      Spacer()
      if let at = controller.status.lastRefresh {
        Text("odswiezono \(at.formatted(date: .omitted, time: .standard))")
          .font(.caption).foregroundStyle(.secondary)
      }
      if controller.status.isBusy {
        HStack(spacing: 8) {
          ProgressView().controlSize(.small)
          Text(controller.status.busyLabel).font(.caption).foregroundStyle(.secondary)
        }
      }
    }
  }

  private func errorBanner(_ message: String) -> some View {
    Text(message)
      .font(.callout)
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
      .textSelection(.enabled)
  }

  // MARK: - Konfiguracja

  /// Kroki, ktorych brakuje. Pusta lista znaczy, ze wszystko jest na miejscu -
  /// wtedy karta w ogole sie nie pokazuje.
  private var setupSteps: [(String, String?)] {
    var steps: [(String, String?)] = []
    if case .missing(let what, let how) = controller.status.dependencyState {
      for (miss, remedy) in zip(what, how) { steps.append(("Brakuje: \(miss)", remedy)) }
    }
    if !controller.status.remoteConfigured {
      steps.append(("Google Drive niepolaczony", controller.connectDriveCommand))
    }
    if case .notRegistered = controller.status.timeMachineState,
      controller.status.buffer.imageAttached
    {
      steps.append(("Time Machine nie wskazuje na CloudMachine", controller.setDestinationCommand))
    }
    return steps
  }

  private var setupCard: some View {
    card("Do zrobienia") {
      ForEach(Array(setupSteps.enumerated()), id: \.offset) { _, step in
        VStack(alignment: .leading, spacing: 4) {
          Text(step.0).font(.callout)
          if let command = step.1 {
            HStack {
              Text(command)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
              Spacer()
              Button("Kopiuj") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(command, forType: .string)
              }
              .controlSize(.small)
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
          }
        }
      }
    }
  }

  // MARK: - Bufor

  private var bufferCard: some View {
    card("Bufor i wysylka") {
      row("Montowanie Drive", controller.status.buffer.mounted ? "dziala" : "brak",
        ok: controller.status.buffer.mounted)
      row("Obraz backupu", controller.status.buffer.imageAttached ? "podpiety" : "niepodpiety",
        ok: controller.status.buffer.imageAttached)
      row("Bufor na dysku", "\(controller.status.buffer.sizeGB) GB", ok: true)
      row("Wolne na dysku", "\(controller.status.buffer.freeDiskGB) GB",
        ok: controller.status.buffer.freeDiskGB > 80)

      // Ta liczba jest wazniejsza od rozmiaru bufora: jesli rosnie i nie wraca
      // do zera miedzy backupami, wysylka nie nadaza za zapisem.
      row(
        "Czeka na wyslanie",
        controller.status.buffer.draining
          ? "\(controller.status.buffer.uploadsInProgress) w toku, \(controller.status.buffer.uploadsQueued) w kolejce"
          : "nic",
        ok: controller.status.buffer.erroredFiles == 0)

      if controller.status.buffer.erroredFiles > 0 {
        row("Bledy wysylki", "\(controller.status.buffer.erroredFiles)", ok: false)
      }
      if controller.status.buffer.dailyQuotaHit {
        row("Limit Google Drive", "dobowy limit wyczerpany", ok: false)
      }
    }
  }

  // MARK: - Postep

  private func progressCard(_ progress: BackupProgressInfo) -> some View {
    card("Backup w toku") {
      if let percent = progress.percent {
        ProgressView(value: min(max(percent, 0), 1))
        Text(String(format: "%.1f%%", percent * 100)).font(.caption).foregroundStyle(.secondary)
      }
      if let done = progress.filesDone, let total = progress.filesTotal, total > 0 {
        row("Pliki", "\(done) z \(total)", ok: true)
      }
      if let rate = progress.transferRateMBs {
        row("Tempo", String(format: "%.1f MB/s", rate), ok: true)
      }
      if let phase = progress.phase {
        row("Faza", phase, ok: true)
      }
    }
  }

  // MARK: - Akcje

  private var actions: some View {
    HStack(spacing: 10) {
      if controller.status.backupProgress == nil {
        Button("Zrob backup teraz") { Task { await controller.startBackup() } }
          .disabled(!controller.status.healthy || controller.status.isBusy)
      } else {
        Button("Wstrzymaj backup") { Task { await controller.stopBackup() } }
      }
      Button("Sprawdz spojnosc obrazu") { Task { await controller.verifyImage() } }
        .disabled(controller.status.buffer.imageAttached || controller.status.isBusy)
      Button("Odswiez") { Task { await controller.refreshAll() } }
      Spacer()
    }
  }

  // MARK: - Elementy wspolne

  private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title).font(.headline)
      content()
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
  }

  private func row(_ label: String, _ value: String, ok: Bool) -> some View {
    HStack {
      Text(label).foregroundStyle(.secondary)
      Spacer()
      Text(value).foregroundStyle(ok ? Color.primary : Color.red)
    }
    .font(.callout)
  }
}
