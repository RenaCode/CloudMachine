import Foundation

public struct MachineEntry: Identifiable, Equatable {
  public var id: String { key }
  public var key: String
  public var displayName: String
  public var limitGB: Int

  public init(key: String, displayName: String, limitGB: Int) {
    self.key = key
    self.displayName = displayName
    self.limitGB = limitGB
  }
}

public struct MachinesConfig: Codable, Equatable {
  public var driveTotalGB: Int
  public var safetyMarginPercent: Int
  public var remoteName: String
  public var remoteRootFolder: String
  /// Limit predkosci wysylania rclone (Mbps - megabity/s, jak u dostawcow
  /// internetu), przekazywany jako `--bwlimit` (ktory oczekuje megabajtow/s -
  /// konwersja w `CloudArchiveService.bwLimitArgs`). `0` = bez limitu.
  /// Uzywane przez warstwe archiwizacji w chmurze (`CloudArchiveService`) przy
  /// kazdym `rclone copy` ukonczonego backupu na Google Drive.
  public var bwLimitMbps: Int
  public var machines: [MachineEntry]

  enum CodingKeys: String, CodingKey {
    case driveTotalGB = "drive_total_gb"
    case safetyMarginPercent = "safety_margin_percent"
    case remoteName = "remote_name"
    case remoteRootFolder = "remote_root_folder"
    case bwLimitMbps = "bwlimit_mbps"
    case machines
  }

  public static let empty = MachinesConfig(
    driveTotalGB: 5000,
    safetyMarginPercent: 10,
    remoteName: "gdrive-cloudmachine",
    remoteRootFolder: "CloudMachine",
    bwLimitMbps: 0,
    machines: []
  )

  /// Suma limitow przydzielonych maszynom, w GB.
  public var allocatedGB: Int { machines.reduce(0) { $0 + $1.limitGB } }

  /// Realny budzet po odjeciu marginesu bezpieczenstwa.
  public var safeBudgetGB: Int {
    driveTotalGB - (driveTotalGB * safetyMarginPercent / 100)
  }

  public var isOverBudget: Bool { allocatedGB > safeBudgetGB }

  public init(
    driveTotalGB: Int, safetyMarginPercent: Int, remoteName: String, remoteRootFolder: String,
    bwLimitMbps: Int = 0,
    machines: [MachineEntry]
  ) {
    self.driveTotalGB = driveTotalGB
    self.safetyMarginPercent = safetyMarginPercent
    self.remoteName = remoteName
    self.remoteRootFolder = remoteRootFolder
    self.bwLimitMbps = bwLimitMbps
    self.machines = machines
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    driveTotalGB = try container.decode(Int.self, forKey: .driveTotalGB)
    safetyMarginPercent = try container.decode(Int.self, forKey: .safetyMarginPercent)
    remoteName = try container.decode(String.self, forKey: .remoteName)
    remoteRootFolder = try container.decode(String.self, forKey: .remoteRootFolder)
    // WAZNE: `decodeIfPresent` - pole dodane pozniej, istniejace pliki
    // machines.json na dyskach uzytkownikow go nie maja. Domyslnie bez
    // limitu, zeby nie zmienic zachowania juz dzialajacych instalacji.
    bwLimitMbps = try container.decodeIfPresent(Int.self, forKey: .bwLimitMbps) ?? 0
    let dict = try container.decode([String: MachineEntryPayload].self, forKey: .machines)
    machines = dict.map {
      MachineEntry(key: $0.key, displayName: $0.value.displayName, limitGB: $0.value.limitGB)
    }
    .sorted { $0.key < $1.key }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(driveTotalGB, forKey: .driveTotalGB)
    try container.encode(safetyMarginPercent, forKey: .safetyMarginPercent)
    try container.encode(remoteName, forKey: .remoteName)
    try container.encode(remoteRootFolder, forKey: .remoteRootFolder)
    try container.encode(bwLimitMbps, forKey: .bwLimitMbps)
    var dict: [String: MachineEntryPayload] = [:]
    for machine in machines {
      dict[machine.key] = MachineEntryPayload(
        displayName: machine.displayName, limitGB: machine.limitGB)
    }
    try container.encode(dict, forKey: .machines)
  }

  /// Odpowiednik `cm_remote_path_for` z common.sh, np.
  /// `gdrive-cloudmachine:CloudMachine/marcin-mac-studio`.
  public func remotePath(forMachineKey key: String) -> String {
    "\(remoteName):\(remoteRootFolder)/\(key)"
  }

  /// Odpowiednik `cm_machine_limit_gb` - `nil`, jesli maszyna nie jest zdefiniowana.
  public func limitGB(forMachineKey key: String) -> Int? {
    machines.first(where: { $0.key == key })?.limitGB
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
