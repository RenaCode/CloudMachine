import Foundation

/// Wynik proby wczytania configu - rozroznia "pliku nie ma" (bezpieczne, nowa
/// instalacja) od "plik jest, ale sie nie parsuje" (COS poszlo nie tak - reczna
/// edycja z bledem, przerwany zapis, niezgodny schemat). Te dwa przypadki NIE
/// moga byc tak samo obslugiwane - patrz komentarz przy `load()`.
public enum ConfigLoadResult {
    case loaded(MachinesConfig)
    case missing
    case corrupt(Error)
}

public enum ConfigStore {
    /// Wczytuje config, rozrozniajac przyczyne niepowodzenia - uzywaj tego,
    /// nie `load()`, wszedzie tam gdzie brak configu powinien byc widoczny dla
    /// uzytkownika (np. przy starcie appki).
    public static func loadResult() -> ConfigLoadResult {
        guard FileManager.default.fileExists(atPath: CMPaths.configPath.path) else {
            return .missing
        }
        do {
            let data = try Data(contentsOf: CMPaths.configPath)
            let config = try JSONDecoder().decode(MachinesConfig.self, from: data)
            return .loaded(config)
        } catch {
            return .corrupt(error)
        }
    }

    /// Wygodny wrapper na `loadResult()` dla miejsc, ktorym wystarczy sama
    /// wartosc - zwraca `.empty` zarowno dla "brak pliku" jak i "plik
    /// uszkodzony", WIEC NIE uzywaj go przy starcie appki/CLI (tam trzeba
    /// odroznic te dwa przypadki, zeby nie nadpisac cicho uszkodzonego-ale-
    /// mozliwego-do-odzyskania pliku pusta konfiguracja przy pierwszym
    /// auto-zapisie).
    public static func load() -> MachinesConfig {
        if case .loaded(let config) = loadResult() {
            return config
        }
        return .empty
    }

    public static func save(_ config: MachinesConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: CMPaths.configPath, options: .atomic)
    }

    public static var exists: Bool {
        FileManager.default.fileExists(atPath: CMPaths.configPath.path)
    }

    /// Kopiuje uszkodzony plik configu obok, z sufiksem znacznika czasu, ZANIM
    /// cokolwiek go nadpisze - jedyna siec bezpieczenstwa miedzy "plik sie nie
    /// sparsowal" a "auto-zapis cicho nadpisal go pusta konfiguracja".
    @discardableResult
    public static func backupCorruptFile() -> URL? {
        guard exists else { return nil }
        let stamp = Int(Date().timeIntervalSince1970)
        let backupPath = CMPaths.configPath
            .deletingLastPathComponent()
            .appendingPathComponent("machines.json.corrupt-\(stamp)")
        do {
            try FileManager.default.copyItem(at: CMPaths.configPath, to: backupPath)
            return backupPath
        } catch {
            return nil
        }
    }

    /// Odpowiednik `cm_require_config` - jesli brak configu, tworzy pusty (tak
    /// samo jak GUI robilo dotad w `init()`) i zwraca go razem z wynikiem, tak
    /// zeby wywolujacy (GUI init, watchdogi CLI) mogl wyswietlic komunikat o
    /// uszkodzeniu, jesli taki byl, zamiast go cicho polykac.
    public static func loadOrInitialize() -> (config: MachinesConfig, corruption: Error?) {
        switch loadResult() {
        case .loaded(let config):
            return (config, nil)
        case .missing:
            try? save(.empty)
            return (.empty, nil)
        case .corrupt(let error):
            backupCorruptFile()
            return (.empty, error)
        }
    }
}
