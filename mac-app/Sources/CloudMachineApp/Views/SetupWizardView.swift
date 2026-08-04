import CloudMachineCore
import SwiftUI

struct SetupWizardView: View {
  @EnvironmentObject private var controller: CloudMachineController

  @State private var selectedDiskID: String?
  @State private var shareName: String = ""

  private var selectedDisk: DiskCandidate? {
    controller.status.networkShare.candidateDisks.first { $0.id == selectedDiskID }
  }

  private func diskLabel(_ disk: DiskCandidate) -> String {
    let kind = disk.isInternal ? "wewnętrzny" : "zewnętrzny"
    if let totalGB = disk.totalGB {
      return String(format: "%@ (%.0f GB, %@)", disk.name, totalGB, kind)
    }
    return "\(disk.name) (\(kind))"
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Nagłówek kreatora
        VStack(alignment: .leading, spacing: 6) {
          Text("Kreator konfiguracji CloudMachine")
            .font(.title2.bold())
          Text(
            "Przejdź przez poniższe kroki kolejno od góry do dołu. Kolejne kroki zostaną odblokowane automatycznie po ukończeniu poprzednich."
          )
          .font(.callout)
          .foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)

        if !controller.status.hasFullDiskAccess {
          FullDiskAccessAlertBanner(action: {
            controller.openFullDiskAccessSettings()
          })
        }

        if let errorMessage = controller.status.errorMessage {
          StatusAlertBanner(message: errorMessage)
        }

        // KROK 1: Instalacja Zależności
        let step1Done = controller.status.dependencyState == .ready
        WizardStepCard(
          number: 1,
          title: "Zainstaluj wymagane narzędzia",
          status: step1Done ? .completed : .active,
          description:
            "Aplikacja wymaga narzędzia 'rclone'. Kliknij poniżej, aby zainstalować je automatycznie za pomocą Homebrew."
        ) {
          Button(action: {
            Task { await controller.installDependencies() }
          }) {
            Label(
              step1Done ? "Zależności gotowe (Sprawdź ponownie)" : "Zainstaluj narzędzia",
              systemImage: "square.and.arrow.down")
          }
          .buttonStyle(.bordered)
          .tint(step1Done ? .green : .accentColor)
        }

        // KROK 2: Połączenie z Google Drive
        let step2Allowed = step1Done
        let step2Done = controller.status.remoteConfigured
        WizardStepCard(
          number: 2,
          title: "Połącz konto Google Drive",
          status: step2Done ? .completed : (step2Allowed ? .active : .locked),
          description:
            "Kliknij przycisk, aby autoryzować rclone. Otworzy się przeglądarka internetowa, w której musisz zalogować się do swojego Google Drive."
        ) {
          Button(action: {
            Task { await controller.connectGoogleDrive() }
          }) {
            Label(
              step2Done ? "Połączono z Google Drive" : "Autoryzuj Google Drive", systemImage: "link"
            )
          }
          .buttonStyle(.bordered)
          .tint(step2Done ? .green : .accentColor)
          .disabled(!step2Allowed)
        }

        // KROK 3: Udostepnienie lokalnego dysku w sieci (SMB)
        let step3Done = controller.status.lastNetworkShare?.succeeded == true
        WizardStepCard(
          number: 3,
          title: "Wybierz dysk i udostępnij go w sieci",
          status: step3Done ? .completed : .active,
          description:
            "Wybierz lokalny dysk (np. podłączony dysk zewnętrzny) i udostępnij go przez SMB (File Sharing), żeby inny Mac w sieci lokalnej mógł go użyć jako własny cel Time Machine. Ten krok TYLKO włącza File Sharing i tworzy zwykły udział sieciowy - rejestrację jako cel Time Machine (dla tego i innych Maców) rób ręcznie w Ustawieniach systemowych -> Time Machine / Udostępnianie."
        ) {
          VStack(alignment: .leading, spacing: 10) {
            if controller.status.networkShare.candidateDisks.isEmpty {
              HStack(spacing: 12) {
                Text(
                  "Nie znaleziono żadnego dysku pod /Volumes poza dyskiem systemowym. Podłącz dysk zewnętrzny i odśwież."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                Spacer()
                Button(action: {
                  Task { await controller.refreshNetworkShare() }
                }) {
                  Label("Odśwież", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
              }
            } else {
              Picker("Dysk:", selection: $selectedDiskID) {
                Text("Wybierz dysk...").tag(String?.none)
                ForEach(controller.status.networkShare.candidateDisks) { disk in
                  Text(diskLabel(disk)).tag(String?.some(disk.id))
                }
              }
              .pickerStyle(.menu)
              .frame(maxWidth: 380)

              HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Nazwa udziału sieciowego:")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                  TextField("np. Network-MacBook", text: $shareName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)
                }

                Button(action: {
                  guard let disk = selectedDisk else { return }
                  Task { await controller.shareDiskOverNetwork(disk: disk, shareName: shareName) }
                }) {
                  Label("Udostępnij w sieci", systemImage: "wifi")
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                  selectedDisk == nil || shareName.trimmingCharacters(in: .whitespaces).isEmpty)
              }

              if !controller.status.networkShare.fileSharingEnabled {
                Text("File Sharing jest obecnie wyłączony - zostanie włączony automatycznie.")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
              }

              if let result = controller.status.lastNetworkShare {
                Text(result.message)
                  .font(.caption2)
                  .foregroundStyle(result.succeeded ? .green : .red)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
          }
        }
      }
      .padding()
    }
    .disabled(controller.status.isBusy)
  }
}

// MARK: - Komponent Karty Kroku Kreatora

enum StepStatus {
  case locked
  case active
  case completed

  var iconName: String {
    switch self {
    case .locked: return "lock.fill"
    case .active: return "play.circle.fill"
    case .completed: return "checkmark.circle.fill"
    }
  }

  var color: Color {
    switch self {
    case .locked: return .secondary
    case .active: return .accentColor
    case .completed: return .green
    }
  }
}

struct WizardStepCard<Content: View>: View {
  var number: Int
  var title: String
  var status: StepStatus
  var description: String
  var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 10) {
        ZStack {
          Circle()
            .fill(status.color.opacity(0.12))
            .frame(width: 28, height: 28)

          Image(systemName: status.iconName)
            .font(.body.bold())
            .foregroundStyle(status.color)
        }

        Text("Krok \(number): \(title)")
          .font(.headline)
          .foregroundStyle(status == .locked ? .secondary : .primary)

        Spacer()
      }

      Text(description)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.leading, 38)

      if status != .locked {
        VStack(alignment: .leading) {
          content()
        }
        .padding(.leading, 38)
        .padding(.top, 4)
      }
    }
    .padding(16)
    .background(
      Color(nsColor: .windowBackgroundColor)
        .opacity(status == .locked ? 0.5 : 1.0)
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(status == .locked ? 0 : 0.03), radius: 3, x: 0, y: 1)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(
          status == .active
            ? Color.accentColor.opacity(0.5)
            : (status == .completed ? Color.green.opacity(0.3) : Color.secondary.opacity(0.1)),
          lineWidth: status == .active ? 1.5 : 1.0
        )
    )
  }
}
