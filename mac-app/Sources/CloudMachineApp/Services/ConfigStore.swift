import Foundation

enum ConfigStore {
    static func load() -> MachinesConfig {
        guard let data = try? Data(contentsOf: Paths.configPath) else {
            return .empty
        }
        guard let config = try? JSONDecoder().decode(MachinesConfig.self, from: data) else {
            return .empty
        }
        return config
    }

    static func save(_ config: MachinesConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: Paths.configPath, options: .atomic)
    }

    static var exists: Bool {
        FileManager.default.fileExists(atPath: Paths.configPath.path)
    }
}
