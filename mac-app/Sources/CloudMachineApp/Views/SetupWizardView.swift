import SwiftUI
import CloudMachineCore

struct SetupWizardView: View {
    @EnvironmentObject private var controller: CloudMachineController

    @State private var displayName: String = ""
    @State private var limitGBText: String = "1000"
    
    // Statusy walidacji dla kroku 3. Dolna granica taka sama jak w
    // MachinesConfigView (MachinesConfigView.minimumMachineLimitGB) - `> 0`
    // samo w sobie nie wystarczy, bo bardzo mala wartosc (np. "1" GB) i tak
    // ustawia scripts/quota-watchdog.sh na tryb ciaglego, agresywnego
    // przycinania backupow niemal do zera.
    private var isLimitValid: Bool {
        if let limit = Int(limitGBText), limit >= MachinesConfigView.minimumMachineLimitGB {
            return true
        }
        return false
    }
    
    private var isStep3Valid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isLimitValid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Nagłówek kreatora
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kreator konfiguracji CloudMachine")
                        .font(.title2.bold())
                    Text("Przejdź przez poniższe kroki kolejno od góry do dołu. Kolejne kroki zostaną odblokowane automatycznie po ukończeniu poprzednich.")
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
                    description: "Aplikacja wymaga narzędzia 'rclone'. Kliknij poniżej, aby zainstalować je automatycznie za pomocą Homebrew."
                ) {
                    Button(action: {
                        Task { await controller.installDependencies() }
                    }) {
                        Label(step1Done ? "Zależności gotowe (Sprawdź ponownie)" : "Zainstaluj narzędzia", systemImage: "square.and.arrow.down")
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
                    description: "Kliknij przycisk, aby autoryzować rclone. Otworzy się przeglądarka internetowa, w której musisz zalogować się do swojego Google Drive."
                ) {
                    Button(action: {
                        Task { await controller.connectGoogleDrive() }
                    }) {
                        Label(step2Done ? "Połączono z Google Drive" : "Autoryzuj Google Drive", systemImage: "link")
                    }
                    .buttonStyle(.bordered)
                    .tint(step2Done ? .green : .accentColor)
                    .disabled(!step2Allowed)
                }

                // KROK 3: Limit i nazwa maszyny
                let step3Allowed = step2Done
                // Po kluczu maszyny (stabilny identyfikator), NIE po displayName -
                // displayName to dowolny tekst edytowalny przez uzytkownika i NIE
                // jest gwarantowany unikalny (dwa Maki moga nazywac sie tak samo),
                // wiec porownanie po nim moglo pokazac krok jako "ukonczony" dla
                // maszyny, ktora nigdy nie zostala faktycznie zapisana.
                let isRegistered = controller.config.machines.contains(where: { $0.key == controller.status.currentMachineKey })
                let step3Done = step3Allowed && isRegistered
                WizardStepCard(
                    number: 3,
                    title: "Skonfiguruj nazwę i limit dysku dla tego Maka",
                    status: step3Done ? .completed : (step3Allowed ? .active : .locked),
                    description: "Zdefiniuj przyjazną nazwę wyświetlaną dla tego komputera oraz maksymalny limit przestrzeni na kopie zapasowe Google Drive."
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Nazwa komputera:")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                TextField("np. MacBook Pro (Praca)", text: $displayName)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(!step3Allowed)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Limit przestrzeni (GB):")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                TextField("Limit GB", text: $limitGBText)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 120)
                                    .disabled(!step3Allowed)
                            }
                        }
                        
                        if !limitGBText.isEmpty && !isLimitValid {
                            Text("Wprowadź liczbę co najmniej \(MachinesConfigView.minimumMachineLimitGB) GB")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }

                        Button(action: {
                            let limit = Int(limitGBText) ?? 1000
                            Task { await controller.ensureMachineRegistered(displayName: displayName, limitGB: limit) }
                        }) {
                            Label("Zapisz konfigurację maszyny", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!step3Allowed || !isStep3Valid)
                    }
                }

                // KROK 4: Montowanie NFS i Time Machine
                let step4Allowed = step3Done
                let step4Done = controller.status.mountState == .mounted && controller.status.timeMachineState == .registered
                WizardStepCard(
                    number: 4,
                    title: "Zamontuj dysk i zarejestruj w Time Machine",
                    status: step4Done ? .completed : (step4Allowed ? .active : .locked),
                    description: "Zamontuj dedykowany folder z Google Drive jako wirtualny dysk lokalny NFS, a następnie wskaż go jako cel dla Time Machine."
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Button(action: {
                                Task { await controller.mountNow() }
                            }) {
                                let isMounted = controller.status.mountState == .mounted
                                Label(isMounted ? "Zamontowano" : "Zamontuj wolumin NFS", systemImage: isMounted ? "folder.fill.badge.checkmark" : "folder.badge.plus")
                            }
                            .buttonStyle(.bordered)
                            .tint(controller.status.mountState == .mounted ? .green : .accentColor)
                            .disabled(!step4Allowed || controller.status.mountState == .mounted)

                            Button(action: {
                                Task { await controller.registerTimeMachineDestination() }
                            }) {
                                let isTM = controller.status.timeMachineState == .registered
                                Label(isTM ? "Zarejestrowano" : "Zarejestruj w Time Machine", systemImage: "clock.badge.checkmark")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!step4Allowed || controller.status.mountState != .mounted)
                        }
                        
                        Text("Rejestracja w Time Machine wymaga jednorazowego wpisania hasła administratora macOS.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // KROK 5: Automatyzacja tła
                let step5Allowed = step4Done
                let step5Done = controller.status.watchdogInstalled && controller.status.mountWatchdogInstalled
                WizardStepCard(
                    number: 5,
                    title: "Włącz automatyzację w tle (launchd)",
                    status: step5Done ? .completed : (step5Allowed ? .active : .locked),
                    description: "Ostatni krok. Skonfiguruj automatyczne montowanie dysku po starcie systemu, watchdog pilnujący, żeby montowanie nigdy nie zawisło, oraz proces w tle pilnujący limitu pamięci dyskowej."
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: {
                                Task { await controller.installLaunchdAgents() }
                            }) {
                                Label("Zainstaluj demony startowe", systemImage: "gearshape.2")
                            }
                            .buttonStyle(.bordered)
                            .tint(step5Done ? .green : .accentColor)
                            .disabled(!step5Allowed)

                            Button(action: {
                                Task { await controller.enableUnattendedPruning() }
                            }) {
                                Label("Zezwól na automatyczne przycinanie backupów", systemImage: "scissors")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!step5Allowed)
                        }
                        
                        Text("Druga opcja dodaje ograniczoną regułę do sudoers w celu automatycznego usuwania najstarszych kopii zapasowych bez pytania o hasło, gdy skończy się przydzielona przestrzeń.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .disabled(controller.status.isBusy)
        .onAppear {
            Task {
                if let machine = await controller.currentMachine {
                    displayName = machine.displayName
                    limitGBText = String(machine.limitGB)
                }
            }
        }
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
                    status == .active ? Color.accentColor.opacity(0.5) : (status == .completed ? Color.green.opacity(0.3) : Color.secondary.opacity(0.1)),
                    lineWidth: status == .active ? 1.5 : 1.0
                )
        )
    }
}
