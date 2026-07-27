import Foundation

/// Wynik proby wczytania configu - rozroznia "pliku nie ma" (bezpieczne, nowa
/// instalacja) od "plik jest, ale sie nie parsuje" (COS poszlo nie tak - reczna
/// edycja z bledem, przerwany zapis, niezgodny schemat). Te dwa przypadki NIE
/// moga byc tak samo obslugiwane - patrz komentarz przy `load()`.
enum ConfigLoadResult {
    case loaded(MachinesConfig)
    case missing
    case corrupt(Error)
}

enum ConfigStore {
    /// Wczytuje config, rozrozniajac przyczyne niepowodzenia - uzywaj tego,
    /// nie `load()`, wszedzie tam gdzie brak configu powinien byc widoczny dla
    /// uzytkownika (np. przy starcie appki).
    static func loadResult() -> ConfigLoadResult {
        guard FileManager.default.fileExists(atPath: Paths.configPath.path) else {
            return .missing
        }
        do {
            let data = try Data(contentsOf: Paths.configPath)
            let config = try JSONDecoder().decode(MachinesConfig.self, from: data)
            return .loaded(config)
        } catch {
            return .corrupt(error)
        }
    }

    /// Wygodny wrapper na `loadResult()` dla miejsc, ktorym wystarczy sama
    /// wartosc (np. domyslny argument inicjalizatora widoku w SwiftUI Preview) -
    /// zwraca `.empty` zarowno dla "brak pliku" jak i "plik uszkodzony", WIEC
    /// NIE uzywaj go przy starcie appki (tam trzeba odroznic te dwa przypadki,
    /// zeby nie nadpisac cicho uszkodzonego-ale-mozliwego-do-odzyskania pliku
    /// pusta konfiguracja przy pierwszym auto-zapisie - patrz
    /// CloudMachineController.init i backupCorruptFileIfNeeded).
    static func load() -> MachinesConfig {
        if case .loaded(let config) = loadResult() {
            return config
        }
        return .empty
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

    /// Kopiuje uszkodzony plik configu obok, z sufiksem znacznika czasu, ZANIM
    /// cokolwiek go nadpisze - jedyna siec bezpieczenstwa miedzy "plik sie nie
    /// sparsowal" a "uzytkownik dotknal dowolnego pola w zakladce Maszyny i
    /// auto-zapis cicho nadpisal go pusta konfiguracja". Zwraca sciezke kopii,
    /// jesli sie udalo.
    @discardableResult
    static func backupCorruptFile() -> URL? {
        guard exists else { return nil }
        let stamp = Int(Date().timeIntervalSince1970)
        let backupPath = Paths.configPath
            .deletingLastPathComponent()
            .appendingPathComponent("machines.json.corrupt-\(stamp)")
        do {
            try FileManager.default.copyItem(at: Paths.configPath, to: backupPath)
            return backupPath
        } catch {
            return nil
        }
    }
}
