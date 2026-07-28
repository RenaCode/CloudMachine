import SwiftUI

struct SetupWizardView: View {
  @EnvironmentObject private var controller: CloudMachineController

  @State private var quotaGBText: String = "300"

  private var isQuotaValid: Bool {
    if let quota = Int(quotaGBText), quota >= 20 { return true }
    return false
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

        // KROK 3: Utworzenie lokalnego woluminu i rejestracja w Time Machine
        let step4Done =
          controller.status.localVolume.exists && controller.status.timeMachineState == .registered
        WizardStepCard(
          number: 3,
          title: "Utwórz lokalny dysk backupu i zarejestruj w Time Machine",
          status: step4Done ? .completed : .active,
          description:
            "Tworzy prawdziwy lokalny wolumin APFS (nie sieciowy) jako cel Time Machine - to jest w 100% natywny, w pełni trwały backup. Rozmiar to sufit, nie gwarancja: faktyczna dostępna przestrzeń zależy od realnie wolnego miejsca na dysku. Chcesz wykluczyć foldery z backupu? Zrób to w Ustawieniach systemowych -> Time Machine -> Opcje."
        ) {
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Rozmiar (GB):")
                  .font(.caption.bold())
                  .foregroundStyle(.secondary)
                TextField("300", text: $quotaGBText)
                  .textFieldStyle(.roundedBorder)
                  .frame(width: 100)
                  .disabled(controller.status.localVolume.exists)
              }

              Button(action: {
                let quota = Int(quotaGBText) ?? 300
                Task { await controller.createLocalVolumeAndRegister(quotaGB: quota) }
              }) {
                Label(
                  step4Done ? "Gotowe" : "Utwórz i zarejestruj",
                  systemImage: step4Done ? "checkmark.circle.fill" : "externaldrive.badge.plus"
                )
              }
              .buttonStyle(.borderedProminent)
              .disabled(!isQuotaValid || step4Done)
            }

            if !quotaGBText.isEmpty && !isQuotaValid {
              Text("Wprowadź liczbę co najmniej 20 GB")
                .font(.caption2)
                .foregroundStyle(.red)
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
