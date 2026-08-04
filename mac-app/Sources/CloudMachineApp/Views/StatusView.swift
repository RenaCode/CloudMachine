import SwiftUI

struct StatusView: View {
  @EnvironmentObject private var controller: CloudMachineController

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        if !controller.status.hasFullDiskAccess {
          FullDiskAccessAlertBanner(action: {
            controller.openFullDiskAccessSettings()
          })
        }

        if let errorMessage = controller.status.errorMessage {
          StatusAlertBanner(message: errorMessage)
        }

        // Siatka głównych kart statusu
        LazyVGrid(
          columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
          spacing: 16
        ) {
          // Karta 1: Stan Usług i Narzędzi
          StatusCard(title: "Status usług i narzędzi", systemImage: "checklist") {
            VStack(spacing: 12) {
              StatusRow(title: "Zależności (rclone)", status: dependencyStatus)
              StatusRow(title: "Konto Google Drive", status: driveConfigStatus)
              StatusRow(title: "Lokalny wolumin backupu", status: localVolumeStatus)
              StatusRow(title: "Time Machine", status: tmStatus)
              StatusRow(title: "Archiwizacja w chmurze", status: archiveStatus)
            }
          }

          // Karta 2: Zużycie lokalnego woluminu backupu
          StatusCard(title: "Wykorzystanie dysku lokalnego", systemImage: "chart.bar.fill") {
            VStack(alignment: .leading, spacing: 14) {
              if let total = controller.status.localVolume.totalGB,
                let used = controller.status.localVolume.usedGB
              {
                QuotaProgressGauge(
                  usedGB: used,
                  limitGB: Int(total),
                  fraction: controller.status.localVolume.usedFraction,
                  isNearLimit: controller.status.localVolume.usedFraction >= 0.9
                )

                if let free = controller.status.localVolume.freeContainerGB {
                  HStack {
                    Image(systemName: "internaldrive")
                    Text(String(format: "Realnie wolne miejsce na dysku: %.1f GB", free))
                  }
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                }
              } else {
                VStack(spacing: 8) {
                  Image(systemName: "exclamationmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                  Text("Brak lokalnego woluminu")
                    .font(.headline)
                  Text("Zarejestruj dysk jako cel Time Machine w Ustawieniach systemowych.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
              }
            }
          }
        }

        // Karta 2b: Zywy postep aktualnie trwajacego backupu (widoczna tylko
        // gdy Time Machine cos faktycznie kopiuje) - procent, dane, predkosc.
        if let progress = controller.status.backupProgress {
          BackupProgressCard(progress: progress)
        }

        // Karta 2c: Archiwizacja w chmurze - drugi poziom architektury
        // (patrz README): kopiuje ukonczone lokalne backupy na Google Drive.
        StatusCard(title: "Archiwizacja w chmurze", systemImage: "icloud.and.arrow.up") {
          VStack(alignment: .leading, spacing: 10) {
            if !controller.status.remoteConfigured {
              Text("Połącz konto Google Drive w zakładce Kreator, żeby włączyć archiwizację.")
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
              HStack {
                Label(
                  "\(controller.status.cloudArchive.archivedCount) zarchiwizowanych",
                  systemImage: "checkmark.icloud")
                Spacer()
                Label(
                  "\(controller.status.cloudArchive.pendingCount) oczekujących",
                  systemImage: "arrow.up.circle")
              }
              .font(.caption)
              .foregroundStyle(.secondary)

              if let lastBackup = controller.status.cloudArchive.lastArchivedBackup {
                Text("Ostatnio zarchiwizowany: \(lastBackup)")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
                  .truncationMode(.head)
              }
            }
          }
        }

        // Karta 3: Ostatnie operacje (na całą szerokość)
        StatusCard(
          title: "Historia ostatnich operacji (ta sesja aplikacji)",
          systemImage: "clock.arrow.circlepath"
        ) {
          VStack(spacing: 12) {
            OperationResultRow(
              title: "Weryfikacja spójności (checksums)",
              result: controller.status.lastVerify,
              placeholder: "Weryfikacja nie była jeszcze przeprowadzana."
            )
            Divider()
            OperationResultRow(
              title: "Archiwizacja na Google Drive",
              result: controller.status.lastArchive,
              placeholder: "Archiwizacja nie była jeszcze przeprowadzana."
            )
            Divider()
            OperationResultRow(
              title: "Udostępnienie dysku w sieci",
              result: controller.status.lastNetworkShare,
              placeholder: "Udostępnianie sieciowe nie było jeszcze przeprowadzane."
            )
          }
        }

        // Dolna sekcja akcji (Panel sterowania)
        VStack(spacing: 12) {
          HStack(spacing: 12) {
            Button(action: {
              Task { await controller.refreshAll(force: true) }
            }) {
              Label("Odśwież status", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(action: {
              Task { await controller.verifyNow() }
            }) {
              Label("Weryfikuj sumy kontrolne", systemImage: "checkmark.shield")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!controller.status.localVolume.exists)

            Button(action: {
              Task { await controller.archiveNow() }
            }) {
              Label("Archiwizuj teraz", systemImage: "icloud.and.arrow.up")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!controller.status.remoteConfigured || !controller.status.localVolume.exists)
          }
        }
        .disabled(controller.status.isBusy)
        .padding(.top, 8)
      }
      .padding()
    }
  }

  // MARK: - Mapowanie stanów na badges

  private var dependencyStatus: StatusType {
    switch controller.status.dependencyState {
    case .ready: return .active("Gotowe")
    case .checking: return .warning("Sprawdzanie...")
    case .missing: return .error("Brak narzędzi")
    case .unknown: return .inactive("Nieznany")
    }
  }

  private var driveConfigStatus: StatusType {
    controller.status.remoteConfigured ? .active("Połączone") : .inactive("Nieskonfigurowane")
  }

  private var localVolumeStatus: StatusType {
    controller.status.localVolume.exists ? .active("Utworzony") : .inactive("Nie istnieje")
  }

  private var tmStatus: StatusType {
    switch controller.status.timeMachineState {
    case .registered: return .active("Zarejestrowany")
    case .notRegistered: return .inactive("Niezarejestrowany")
    case .unknown: return .inactive("Nieznany")
    }
  }

  private var archiveStatus: StatusType {
    guard controller.status.remoteConfigured else { return .inactive("Nieskonfigurowane") }
    let pending = controller.status.cloudArchive.pendingCount
    return pending > 0 ? .warning("\(pending) oczekuje") : .active("Aktualne")
  }
}

// MARK: - Komponenty pomocnicze UI

enum StatusType {
  case active(String)
  case warning(String)
  case error(String)
  case inactive(String)

  var text: String {
    switch self {
    case .active(let t), .warning(let t), .error(let t), .inactive(let t): return t
    }
  }

  var color: Color {
    switch self {
    case .active: return .green
    case .warning: return .orange
    case .error: return .red
    case .inactive: return .gray
    }
  }
}

struct StatusRow: View {
  var title: String
  var status: StatusType

  var body: some View {
    HStack {
      Text(title)
        .foregroundStyle(.primary)
        .font(.body)
      Spacer()
      Text(status.text)
        .font(.caption.bold())
        .foregroundStyle(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
          Capsule()
            .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }
  }
}

struct StatusCard<Content: View>: View {
  var title: String
  var systemImage: String
  var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.headline)
          .foregroundStyle(Color.accentColor)
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
      }
      Divider()
      content()
    }
    .padding(16)
    .background(Color(nsColor: .windowBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
    )
  }
}

struct QuotaProgressGauge: View {
  var usedGB: Double
  var limitGB: Int
  var fraction: Double
  var isNearLimit: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Zużycie przestrzeni:")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Spacer()
        Text(String(format: "%.1f%%", fraction * 100))
          .font(.headline.bold())
          .foregroundStyle(isNearLimit ? .orange : .accentColor)
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color.secondary.opacity(0.12))
            .frame(height: 12)

          Capsule()
            .fill(
              LinearGradient(
                colors: isNearLimit ? [.orange, .red] : [.accentColor, .blue],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: geo.size.width * CGFloat(fraction), height: 12)
        }
      }
      .frame(height: 12)

      HStack {
        Text(String(format: "%.1f GB użyte", usedGB))
          .font(.subheadline.bold())
        Spacer()
        Text("Limit: \(limitGB) GB")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .padding(.top, 4)
    }
  }
}

/// Karta z zywym postepem trwajacego backupu Time Machine - pokazuje sie
/// tylko wtedy, gdy `tmutil status` faktycznie raportuje aktywne kopiowanie
/// (patrz `CloudMachineController.refreshBackupProgress`).
struct BackupProgressCard: View {
  var progress: BackupProgressInfo

  var body: some View {
    StatusCard(title: "Postęp backupu", systemImage: "clock.arrow.2.circlepath") {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text(phaseLabel)
            .font(.subheadline.bold())
          Spacer()
          if let percent = progress.percent {
            Text(String(format: "%.1f%%", percent * 100))
              .font(.headline.bold())
              .foregroundStyle(Color.accentColor)
          }
        }

        if let percent = progress.percent {
          GeometryReader { geo in
            ZStack(alignment: .leading) {
              Capsule()
                .fill(Color.secondary.opacity(0.12))
                .frame(height: 10)
              Capsule()
                .fill(
                  LinearGradient(
                    colors: [.accentColor, .blue], startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: geo.size.width * CGFloat(min(percent, 1.0)), height: 10)
            }
          }
          .frame(height: 10)
        }

        HStack {
          if let bytesDone = progress.bytesDone, let bytesTotal = progress.bytesTotal,
            bytesTotal > 0
          {
            Label(
              "\(formatGB(bytesDone)) / \(formatGB(bytesTotal))", systemImage: "internaldrive"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          Spacer()
          if let rate = progress.transferRateMBs, rate > 0 {
            Label(String(format: "%.1f MB/s", rate), systemImage: "speedometer")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }

        HStack {
          if let filesDone = progress.filesDone, let filesTotal = progress.filesTotal {
            Label(
              "\(filesDone.formatted()) / \(filesTotal.formatted()) plików",
              systemImage: "doc.on.doc"
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
          }
          Spacer()
          if let remaining = progress.timeRemainingSeconds, remaining > 0 {
            Label("Pozostało: \(formatDuration(remaining))", systemImage: "hourglass")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
  }

  private var phaseLabel: String {
    switch progress.phase {
    case "Copying": return "Kopiowanie danych"
    case "ThinningPreBackup", "ThinningPostBackup": return "Zwalnianie miejsca (thinning)"
    case "FindingChanges": return "Wyszukiwanie zmian"
    case "MountingBackupVolume": return "Montowanie wolumenu backupu"
    case "Mounting": return "Montowanie"
    case "CleaningUp": return "Porządkowanie"
    case .some(let other): return other
    case nil: return "Backup w toku"
    }
  }

  private func formatGB(_ bytes: Double) -> String {
    String(format: "%.1f GB", bytes / 1_073_741_824)
  }

  private func formatDuration(_ seconds: Double) -> String {
    let totalMinutes = Int(seconds / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours > 0 {
      return "\(hours) godz. \(minutes) min"
    }
    return "\(minutes) min"
  }
}

struct OperationResultRow: View {
  var title: String
  var result: LastRunResult?
  var placeholder: String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.subheadline.bold())

      if let result {
        HStack(alignment: .top, spacing: 8) {
          Image(
            systemName: result.succeeded ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
          )
          .foregroundStyle(result.succeeded ? .green : .red)
          .font(.title3)

          VStack(alignment: .leading, spacing: 2) {
            Text(result.message)
              .font(.body)
              .fixedSize(horizontal: false, vertical: true)

            Text(result.date.formatted(date: .abbreviated, time: .shortened))
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        .padding(.vertical, 4)
      } else {
        Text(placeholder)
          .font(.callout)
          .foregroundStyle(.secondary)
          .italic()
          .padding(.vertical, 2)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct StatusAlertBanner: View {
  var message: String

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "exclamationmark.octagon.fill")
        .font(.title2)
        .foregroundStyle(.red)
      VStack(alignment: .leading, spacing: 4) {
        Text("Problem z działaniem")
          .font(.headline)
          .foregroundStyle(.red)
        Text(message)
          .font(.callout)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer()
    }
    .padding(14)
    .background(Color.red.opacity(0.08))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color.red.opacity(0.25), lineWidth: 1)
    )
  }
}

struct FullDiskAccessAlertBanner: View {
  var action: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      Image(systemName: "lock.shield.fill")
        .font(.largeTitle)
        .foregroundStyle(.orange)

      VStack(alignment: .leading, spacing: 6) {
        Text("Wymagany Pełny dostęp do dysku (Full Disk Access)")
          .font(.headline)
          .foregroundStyle(.primary)
        Text(
          "System macOS wymaga tego uprawnienia, aby aplikacja mogła sterować kopiami zapasowymi Time Machine. Kliknij poniższy przycisk, przejdź do Ustawień systemowych i dodaj aplikację CloudMachine oraz Terminal do listy."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)

        Button(action: action) {
          Label("Otwórz Ustawienia systemowe", systemImage: "gearshape")
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding(.top, 4)
      }
      Spacer()
    }
    .padding(16)
    .background(Color.orange.opacity(0.08))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
    )
  }
}
