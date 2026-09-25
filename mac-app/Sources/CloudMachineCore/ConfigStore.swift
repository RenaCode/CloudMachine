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
  /// `nil` = kopii NIE MA. Wolajacy nie ma wtedy prawa niczego nadpisac -
  /// patrz `ConfigInitialization`.
  ///
  /// `configPath` jest podmienialny, zeby test mogl sprawdzic OBA warianty -
  /// kopia powstala i kopia nie powstala - bez ruszania prawdziwego pliku
  /// konfiguracyjnego tej maszyny.
  @discardableResult
  public static func backupCorruptFile(configPath: URL = CMPaths.configPath) -> URL? {
    guard FileManager.default.fileExists(atPath: configPath.path) else { return nil }
    let stamp = Int(Date().timeIntervalSince1970)
    let backupPath = configPath.deletingLastPathComponent()
      .appendingPathComponent("\(configPath.lastPathComponent).corrupt-\(stamp)")
    do {
      try FileManager.default.copyItem(at: configPath, to: backupPath)
      return backupPath
    } catch {
      return nil
    }
  }

  /// Odpowiednik `cm_require_config` - jesli brak configu, tworzy pusty (tak
  /// samo jak GUI robilo dotad w `init()`) i zwraca go razem z wynikiem, tak
  /// zeby wywolujacy (GUI init, watchdogi CLI) mogl wyswietlic komunikat o
  /// uszkodzeniu, jesli taki byl, zamiast go cicho polykac.
  public static func loadOrInitialize() -> ConfigInitialization {
    switch loadResult() {
    case .loaded(let config):
      return .ready(config)
    case .missing:
      try? save(.empty)
      return .ready(.empty)
    case .corrupt(let error):
      return decideAfterCorruption(backup: backupCorruptFile(), error: error)
    }
  }

  /// Co robimy po nieudanym parsowaniu - w zaleznosci od tego, czy kopia
  /// bezpieczenstwa POWSTALA.
  ///
  /// Czysta, zeby dalo sie sprawdzic testem oba warianty bez psucia
  /// prawdziwego pliku konfiguracyjnego.
  static func decideAfterCorruption(backup: URL?, error: Error) -> ConfigInitialization {
    guard let backup else { return .corruptWithoutBackup(error: error) }
    return .corruptButBackedUp(config: .empty, backup: backup, error: error)
  }
}

/// Wynik `loadOrInitialize()`. Trzy stany, nie para `(config, corruption)`.
///
/// Do 25.09.2026 wynik `backupCorruptFile()` byl tu IGNOROWANY, a ta funkcja
/// przy porazce kopiowania oddaje `nil`. Wolajacy dostawal wiec pusta
/// konfiguracje i - w `CLIContext.load()` - komunikat "oryginal zachowany na
/// dysku z kopia zapasowa obok" takze wtedy, gdy zadnej kopii nie bylo.
/// Komentarz przy `backupCorruptFile` nazywa te kopie jedyna siecia
/// bezpieczenstwa miedzy "plik sie nie sparsowal" a "auto-zapis cicho nadpisal
/// go pusta konfiguracja" - i wlasnie ta siec potrafila nie istniec.
///
/// Brak kopii musi PRZERWAC operacje nieodwracalna, a nie tylko dopisac
/// ostrzezenie do logu. Dlatego `.corruptWithoutBackup` NIE NIESIE
/// konfiguracji: typ nie pozwala dokonczyc pracy bez kopii, wiec zaden przyszly
/// wolajacy nie ma jak przeoczyc tego przypadku.
public enum ConfigInitialization {
  case ready(MachinesConfig)
  /// Plik uszkodzony, ale lezy juz jego kopia pod `backup` - wolno pracowac
  /// na pustej konfiguracji, bo oryginal da sie odzyskac.
  case corruptButBackedUp(config: MachinesConfig, backup: URL, error: Error)
  /// Plik uszkodzony I kopii nie udalo sie zrobic. Pracowac NIE WOLNO.
  case corruptWithoutBackup(error: Error)

  /// Konfiguracja do pracy - `nil` znaczy "przerwij", nie "pusta".
  public var config: MachinesConfig? {
    switch self {
    case .ready(let config): return config
    case .corruptButBackedUp(let config, _, _): return config
    case .corruptWithoutBackup: return nil
    }
  }

  public var corruption: Error? {
    switch self {
    case .ready: return nil
    case .corruptButBackedUp(_, _, let error): return error
    case .corruptWithoutBackup(let error): return error
    }
  }
}
