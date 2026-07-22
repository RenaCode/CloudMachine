import Foundation

struct MachineEntry: Identifiable, Equatable {
    var id: String { key }
    var key: String
    var displayName: String
    var limitGB: Int

    init(key: String, displayName: String, limitGB: Int) {
        self.key = key
        self.displayName = displayName
        self.limitGB = limitGB
    }
}

struct MachinesConfig: Codable, Equatable {
    var driveTotalGB: Int
    var safetyMarginPercent: Int
    var remoteName: String
    var remoteRootFolder: String
    var machines: [MachineEntry]

    enum CodingKeys: String, CodingKey {
        case driveTotalGB = "drive_total_gb"
        case safetyMarginPercent = "safety_margin_percent"
        case remoteName = "remote_name"
        case remoteRootFolder = "remote_root_folder"
        case machines
    }

    static let empty = MachinesConfig(
        driveTotalGB: 5000,
        safetyMarginPercent: 10,
        remoteName: "gdrive-cloudmachine",
        remoteRootFolder: "CloudMachine",
        machines: []
    )

    /// Suma limitow przydzielonych maszynom, w GB.
    var allocatedGB: Int { machines.reduce(0) { $0 + $1.limitGB } }

    /// Realny budzet po odjeciu marginesu bezpieczenstwa.
    var safeBudgetGB: Int {
        driveTotalGB - (driveTotalGB * safetyMarginPercent / 100)
    }

    var isOverBudget: Bool { allocatedGB > safeBudgetGB }

    init(driveTotalGB: Int, safetyMarginPercent: Int, remoteName: String, remoteRootFolder: String, machines: [MachineEntry]) {
        self.driveTotalGB = driveTotalGB
        self.safetyMarginPercent = safetyMarginPercent
        self.remoteName = remoteName
        self.remoteRootFolder = remoteRootFolder
        self.machines = machines
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        driveTotalGB = try container.decode(Int.self, forKey: .driveTotalGB)
        safetyMarginPercent = try container.decode(Int.self, forKey: .safetyMarginPercent)
        remoteName = try container.decode(String.self, forKey: .remoteName)
        remoteRootFolder = try container.decode(String.self, forKey: .remoteRootFolder)
        let dict = try container.decode([String: MachineEntryPayload].self, forKey: .machines)
        machines = dict.map { MachineEntry(key: $0.key, displayName: $0.value.displayName, limitGB: $0.value.limitGB) }
            .sorted { $0.key < $1.key }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(driveTotalGB, forKey: .driveTotalGB)
        try container.encode(safetyMarginPercent, forKey: .safetyMarginPercent)
        try container.encode(remoteName, forKey: .remoteName)
        try container.encode(remoteRootFolder, forKey: .remoteRootFolder)
        var dict: [String: MachineEntryPayload] = [:]
        for machine in machines {
            dict[machine.key] = MachineEntryPayload(displayName: machine.displayName, limitGB: machine.limitGB)
        }
        try container.encode(dict, forKey: .machines)
    }
}

/// Ksztalt pojedynczego wpisu maszyny w JSON-ie (bez klucza, ktory jest kluczem slownika).
private struct MachineEntryPayload: Codable {
    var displayName: String
    var limitGB: Int

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case limitGB = "limit_gb"
    }
}
