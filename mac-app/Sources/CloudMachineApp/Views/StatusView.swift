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
              StatusRow(title: "Wolumin NFS", status: mountStatus)
              StatusRow(title: "Time Machine", status: tmStatus)
              StatusRow(title: "Watchdog montowania (launchd)", status: mountWatchdogStatus)
              StatusRow(title: "Watchdog limitu miejsca (launchd)", status: watchdogStatus)
            }
          }

          // Karta 2: Zużycie limitu maszyny
          StatusCard(title: "Wykorzystanie limitu", systemImage: "chart.bar.fill") {
            VStack(alignment: .leading, spacing: 14) {
              if controller.status.quota.limitGB > 0 {
                QuotaProgressGauge(
                  usedGB: controller.status.quota.usedGB,
                  limitGB: controller.status.quota.limitGB,
                  fraction: controller.status.quota.fraction,
                  isNearLimit: controller.status.quota.isNearLimit
                )

                if let checked = controller.status.quota.lastChecked {
                  HStack {
                    Image(systemName: "clock")
                    Text(
                      "Ostatnia synchronizacja: \(checked.formatted(date: .abbreviated, time: .shortened))"
                    )
                  }
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                }
              } else {
                VStack(spacing: 8) {
                  Image(systemName: "exclamationmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                  Text("Brak przypisanego limitu")
                    .font(.headline)
                  Text("Skonfiguruj nazwę i limit maszyny w zakładce Maszyny lub Kreator.")
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

        // Karta 3: Ostatnie operacje (na całą szerokość)
        StatusCard(
          title: "Historia ostatnich operacji (ta sesja aplikacji)",
          systemImage: "clock.arrow.circlepath"
        ) {
          VStack(spacing: 12) {
            OperationResultRow(
              title: "Backup Time Machine",
              result: controller.status.lastBackup,
              placeholder: "Brak uruchomionych backupów w tej sesji aplikacji."
            )
            Divider()
            OperationResultRow(
              title: "Weryfikacja spójności (checksums)",
              result: controller.status.lastVerify,
              placeholder: "Weryfikacja nie była jeszcze przeprowadzana."
            )
          }
        }

        // Karta 4: aktywnosc watchdogow dzialajacych w tle przez launchd -
        // odrebna od karty wyzej, bo ta pokazuje wylacznie akcje klikniete
        // recznie W TEJ appce, a watchdogi dzialaja niezaleznie od tego,
        // czy appka jest w ogole otwarta.
        StatusCard(
          title: "Automatyzacja w tle (watchdogi launchd)",
          systemImage: "gearshape.arrow.triangle.2.circlepath"
        ) {
          VStack(spacing: 12) {
            BackgroundActivityRow(
              title: "Ostatnia naprawa montowania",
              line: controller.status.backgroundActivity.lastMountRepair,
              placeholder:
                "Brak zarejestrowanej naprawy - montowanie jeszcze nigdy nie musiało być automatycznie odzyskiwane."
            )
            Divider()
            BackgroundActivityRow(
              title: "Ostatnia automatyczna weryfikacja",
              line: controller.status.backgroundActivity.lastVerify,
              placeholder:
                "Jeszcze nie wykonana - verify-watchdog uruchamia się raz na 7 dni (jeśli włączony w kroku 5 Kreatora)."
            )
            Divider()
            BackgroundActivityRow(
              title: "Ostatnie automatyczne wznowienie backupu",
              line: controller.status.backgroundActivity.lastBackupResume,
              placeholder:
                "Backup nigdy nie musiał być automatycznie wznawiany przez backup-watchdog."
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
              Task {
                if controller.status.mountState == .mounted {
                  await controller.unmountNow()
                } else {
                  await controller.mountNow()
                }
              }
            }) {
              let label =
                controller.status.mountState == .mounted ? "Odmontuj dysk" : "Zamontuj dysk"
              let icon = controller.status.mountState == .mounted ? "eject.fill" : "play.fill"
              Label(label, systemImage: icon)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(controller.status.mountState == .mounted ? .red : .accentColor)
          }

          HStack(spacing: 12) {
            Button(action: {
              Task { await controller.verifyNow() }
            }) {
              Label("Weryfikuj sumy kontrolne", systemImage: "checkmark.shield")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(controller.status.mountState != .mounted)

            Button(action: {
              Task { await controller.startBackupNow() }
            }) {
              Label("Backupuj teraz", systemImage: "icloud.and.arrow.up.fill")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(controller.status.mountState != .mounted)

            Button(action: {
              Task { await controller.stopBackupNow() }
            }) {
              Label("Zatrzymaj backup", systemImage: "stop.circle")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.red)
            .disabled(controller.status.mountState != .mounted)
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

  private var mountStatus: StatusType {
    switch controller.status.mountState {
    case .mounted: return .active("Zamontowany")
    case .mounting: return .warning("Montowanie...")
    case .notMounted: return .inactive("Odmontowany")
    case .failed: return .error("Błąd")
    case .unknown: return .inactive("Nieznany")
    }
  }

  private var tmStatus: StatusType {
    switch controller.status.timeMachineState {
    case .registered: return .active("Zarejestrowany")
    case .notRegistered: return .inactive("Niezarejestrowany")
    case .unknown: return .inactive("Nieznany")
    }
  }

  private var watchdogStatus: StatusType {
    controller.status.watchdogInstalled ? .active("Aktywny") : .inactive("Nieaktywny")
  }

  private var mountWatchdogStatus: StatusType {
    controller.status.mountWatchdogInstalled ? .active("Aktywny") : .inactive("Nieaktywny")
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

struct BackgroundActivityRow: View {
  var title: String
  var line: String?
  var placeholder: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.subheadline.bold())

      if let line {
        Text(line)
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
          .fixedSize(horizontal: false, vertical: true)
      } else {
        Text(placeholder)
          .font(.callout)
          .foregroundStyle(.secondary)
          .italic()
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
