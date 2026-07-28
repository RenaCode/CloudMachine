import CloudMachineCore
import SwiftUI

struct MachinesConfigView: View {
  @EnvironmentObject private var controller: CloudMachineController

  /// Dolna granica limitu maszyny. `Slider` ponizej byl juz chroniony przez
  /// swoj `in:` (100...), ale sasiednie pole tekstowe pisalo BEZPOSREDNIO do
  /// `machine.limitGB` bez zadnej walidacji - literowka (np. przypadkowe
  /// "0" przy poprawianiu liczby) ustawialaby limit na 0 lub ujemny.
  /// scripts/quota-watchdog.sh liczy prog przycinania jako `limit * 0.9` i
  /// kasuje najstarsze backupy Time Machine az do zejscia ponizej niego -
  /// przy limicie <=0 uznalby, ze ZAWSZE jest nad limitem i zaczal aktywnie
  /// kasowac prawdziwe kopie zapasowe co 6h, az do ostatniej. To nie jest
  /// kosmetyczny bug w UI - to bezposrednia sciezka do utraty realnych
  /// backupow, wiec oba pola (Slider i TextField) musza dzielic ta sama dolna granice.
  static let minimumMachineLimitGB = 100

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {

        // Karta 1: Dysk Google i Budżetowanie
        StatusCard(title: "Status dysku i budżet przestrzeni", systemImage: "icloud.fill") {
          VStack(alignment: .leading, spacing: 14) {
            if let info = controller.status.driveInfo {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Rozmiar konta: \(Int(info.totalGB)) GB")
                    .font(.headline)
                  Text(
                    String(format: "Wolne: %.0f GB  •  Zajęte: %.0f GB", info.freeGB, info.usedGB)
                  )
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: {
                  Task { await controller.refreshDriveInfo() }
                }) {
                  Label("Odśwież z chmury", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
              }

              if let checked = info.lastChecked {
                Text(
                  "Ostatnio sprawdzone: \(checked.formatted(date: .abbreviated, time: .shortened))"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
              }
            } else {
              HStack {
                Text("Brak połączenia z dyskiem. Połącz się w Kreatorze.")
                  .foregroundStyle(.secondary)
                Spacer()
                Button(action: {
                  Task { await controller.refreshDriveInfo() }
                }) {
                  Label("Spróbuj połączyć", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(!controller.status.remoteConfigured)
              }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("Margines bezpieczeństwa:")
                  .font(.subheadline.bold())
                Spacer()
                Text("\(controller.config.safetyMarginPercent)% (\(safetyMarginGB) GB)")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }

              Slider(
                value: Binding(
                  get: { Double(controller.config.safetyMarginPercent) },
                  set: { controller.config.safetyMarginPercent = Int($0) }
                ),
                in: 0...50,
                step: 1
              )

              Text(
                "Margines zapobiega zapełnieniu całego Google Drive, zostawiając bufor na pliki spoza backupu."
              )
              .font(.caption2)
              .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("Limit prędkości wysyłania:")
                  .font(.subheadline.bold())
                Spacer()
                Text(
                  controller.config.bwLimitMbps > 0
                    ? "\(controller.config.bwLimitMbps) Mbps" : "Bez limitu"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
              }

              Slider(
                value: Binding(
                  get: { Double(controller.config.bwLimitMbps) },
                  set: { controller.config.bwLimitMbps = Int($0) }
                ),
                in: 0...1000,
                step: 10
              )

              Text(
                "Ogranicza rclone, żeby backup nie zajmował całego dostępnego łącza. Dotyczy tylko tego komputera. 0 = bez limitu."
              )
              .font(.caption2)
              .foregroundStyle(.secondary)

              // WAZNE: `--bwlimit` jest wpisywany w argumenty demona rclone
              // TYLKO przy starcie (`startRcloneDaemon`) - nie ma interfejsu
              // rc/reload, wiec zmiana suwaka NIE dziala na juz dzialajacy
              // proces. Automatyczny remount przy kazdym tyknieciu suwaka
              // podczas przeciagania bylby gorszy (wielokrotne, niepotrzebne
              // przerywanie aktywnego backupu) - zamiast tego jawnie mowimy
              // uzytkownikowi, kiedy zmiana faktycznie zacznie obowiazywac.
              if controller.status.mountState == .mounted {
                HStack(spacing: 4) {
                  Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                  Text(
                    "Zmiana zacznie obowiązywać po następnym odmontowaniu i zamontowaniu (ręcznym lub automatycznej naprawie)."
                  )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
              }
            }

            Divider()

            // Pasek alokacji przestrzeni dyskowej
            VStack(alignment: .leading, spacing: 8) {
              Text("Wizualizacja alokacji przestrzeni:")
                .font(.subheadline.bold())

              StorageAllocationBar(
                totalGB: Double(controller.config.driveTotalGB),
                marginGB: Double(safetyMarginGB),
                machines: controller.config.machines
              )

              if controller.config.isOverBudget {
                HStack(spacing: 4) {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                  Text(
                    "Suma limitów (\(controller.config.allocatedGB) GB) przekracza bezpieczny budżet (\(controller.config.safeBudgetGB) GB)!"
                  )
                  .font(.caption)
                  .foregroundStyle(.orange)
                }
              } else {
                Text(
                  "Przydzielono \(controller.config.allocatedGB) GB z \(controller.config.safeBudgetGB) GB bezpiecznego budżetu."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
              }
            }
          }
        }

        // Karta 2: Konfiguracja bieżącego komputera Mac
        if controller.status.currentMachineKey.isEmpty {
          StatusCard(title: "Konfiguracja tej maszyny", systemImage: "laptopcomputer") {
            HStack {
              Spacer()
              ProgressView("Pobieram identyfikator komputera...")
              Spacer()
            }
            .padding(.vertical, 10)
          }
        } else if let idx = currentMachineIndex {
          let machineBinding = Binding(
            get: { controller.config.machines[idx] },
            set: { controller.config.machines[idx] = $0 }
          )

          StatusCard(title: "Ustawienia limitu tej maszyny", systemImage: "laptopcomputer") {
            VStack(alignment: .leading, spacing: 16) {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Identyfikator sieciowy komputera:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                  Text(machineBinding.wrappedValue.key)
                    .font(.system(.body, design: .monospaced))
                }
                Spacer()
              }

              VStack(alignment: .leading, spacing: 6) {
                Text("Nazwa wyświetlana komputera:")
                  .font(.subheadline.bold())
                TextField("Nazwa komputera", text: machineBinding.displayName)
                  .textFieldStyle(.roundedBorder)
              }

              VStack(alignment: .leading, spacing: 6) {
                Text("Limit kopii zapasowych:")
                  .font(.subheadline.bold())

                HStack(spacing: 12) {
                  Slider(
                    value: Binding(
                      get: { Double(machineBinding.wrappedValue.limitGB) },
                      set: { machineBinding.wrappedValue.limitGB = Int($0) }
                    ),
                    in: Double(
                      Self.minimumMachineLimitGB)...sliderMax(for: machineBinding.wrappedValue),
                    step: 50
                  )

                  HStack(spacing: 4) {
                    TextField(
                      "Limit",
                      value: Binding(
                        get: { machineBinding.wrappedValue.limitGB },
                        set: {
                          machineBinding.wrappedValue.limitGB = max($0, Self.minimumMachineLimitGB)
                        }
                      ), formatter: NumberFormatter()
                    )
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
                    Text("GB")
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                  }
                }
              }
            }
          }
        } else {
          // Maszyna nie jest jeszcze dodana do machines.json
          StatusCard(title: "Ustawienia tej maszyny", systemImage: "laptopcomputer") {
            VStack(alignment: .leading, spacing: 12) {
              Text(
                "Bieżący komputer Mac (\(controller.status.currentMachineKey)) nie jest jeszcze skonfigurowany w tej instancji CloudMachine."
              )
              .font(.callout)
              .foregroundStyle(.secondary)

              Button(action: {
                configureThisMachine()
              }) {
                Label("Skonfiguruj ten komputer", systemImage: "plus.circle.fill")
              }
              .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 6)
          }
        }

        // Wskaźnik automatycznego zapisu
        HStack {
          Spacer()
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
          Text("Konfiguracja zapisuje się automatycznie po każdej zmianie")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
        }
        .padding(.top, 4)
      }
      .padding()
    }
    .onChange(of: controller.config) { _, _ in
      controller.saveConfig()
    }
  }

  private var currentMachineIndex: Int? {
    let key = controller.status.currentMachineKey
    guard !key.isEmpty else { return nil }
    return controller.config.machines.firstIndex(where: { $0.key == key })
  }

  private var safetyMarginGB: Int {
    controller.config.driveTotalGB * controller.config.safetyMarginPercent / 100
  }

  private func sliderMax(for machine: MachineEntry) -> Double {
    let free = controller.status.driveInfo?.freeGB ?? 0
    return max(Double(machine.limitGB) + free, 500)
  }

  private func configureThisMachine() {
    let key = controller.status.currentMachineKey
    guard !key.isEmpty else { return }

    let defaultName = Host.current().localizedName ?? "Mój Mac"
    let newEntry = MachineEntry(key: key, displayName: defaultName, limitGB: 1000)

    controller.config.machines.append(newEntry)
    controller.saveConfig()
  }
}

// MARK: - Komponent wizualizacji podziału przestrzeni dyskowej

struct StorageAllocationBar: View {
  var totalGB: Double
  var marginGB: Double
  var machines: [MachineEntry]

  var body: some View {
    VStack(spacing: 8) {
      GeometryReader { geo in
        HStack(spacing: 0) {
          if totalGB > 0 {
            // Segmenty dla poszczególnych maszyn
            ForEach(machines) { machine in
              let width = geo.size.width * CGFloat(Double(machine.limitGB) / totalGB)
              if width > 1 {
                Rectangle()
                  .fill(colorForMachine(machine.key))
                  .frame(width: width)
                  .help("\(machine.displayName): \(machine.limitGB) GB")
              }
            }

            // Segment marginesu bezpieczeństwa
            let marginWidth = geo.size.width * CGFloat(marginGB / totalGB)
            if marginWidth > 1 {
              Rectangle()
                .fill(Color.orange.opacity(0.8))
                .frame(width: marginWidth)
                .help("Margines bezpieczeństwa: \(Int(marginGB)) GB")
            }

            // Segment pozostałego wolnego miejsca (budżetu)
            let allocatedSum = machines.reduce(0.0) { $0 + Double($1.limitGB) } + marginGB
            let remainingGB = max(totalGB - allocatedSum, 0.0)
            let remainingWidth = geo.size.width * CGFloat(remainingGB / totalGB)
            if remainingWidth > 1 {
              Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: remainingWidth)
                .help("Wolny budżet: \(Int(remainingGB)) GB")
            }
          } else {
            Rectangle()
              .fill(Color.gray.opacity(0.2))
              .frame(width: geo.size.width)
          }
        }
      }
      .frame(height: 24)
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
      )

      // Legenda
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(machines) { machine in
            LegendItem(
              color: colorForMachine(machine.key),
              label: "\(machine.displayName) (\(machine.limitGB) GB)")
          }
          LegendItem(color: Color.orange.opacity(0.8), label: "Margines (\(Int(marginGB)) GB)")

          let allocatedSum = machines.reduce(0.0) { $0 + Double($1.limitGB) } + marginGB
          let remainingGB = max(totalGB - allocatedSum, 0.0)
          if remainingGB > 0 {
            LegendItem(
              color: Color.gray.opacity(0.2), label: "Wolny budżet (\(Int(remainingGB)) GB)")
          }
        }
        .font(.caption2)
      }
    }
  }

  private func colorForMachine(_ key: String) -> Color {
    let colors: [Color] = [.blue, .purple, .teal, .indigo, .cyan]
    // FNV-1a, NIE `key.hashValue` - w Swift `String.hashValue` jest celowo
    // losowany od nowa przy kazdym starcie procesu (ochrona przed hash-
    // flooding), wiec kolory maszyn na pasku alokacji zmienialyby sie po
    // kazdym restarcie appki. FNV-1a jest deterministyczny miedzy uruchomieniami.
    var hash: UInt64 = 14_695_981_039_346_656_037
    for byte in key.utf8 {
      hash ^= UInt64(byte)
      hash = hash &* 1_099_511_628_211
    }
    return colors[Int(hash % UInt64(colors.count))]
  }
}

struct LegendItem: View {
  var color: Color
  var label: String

  var body: some View {
    HStack(spacing: 4) {
      RoundedRectangle(cornerRadius: 3)
        .fill(color)
        .frame(width: 12, height: 12)
      Text(label)
        .foregroundStyle(.secondary)
    }
  }
}
