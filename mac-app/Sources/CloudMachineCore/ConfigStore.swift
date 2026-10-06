import Foundation

/// Result of an attempt to load the config - tells "there is no file" (safe, a
/// new installation) apart from "the file is there, but does not parse"
/// (SOMETHING went wrong - a manual edit with a mistake, an interrupted write,
/// an incompatible schema). These two cases must NOT be handled the same way -
/// see the comment on `load()`.
public enum ConfigLoadResult {
  case loaded(MachinesConfig)
  case missing
  case corrupt(Error)
}

public enum ConfigStore {
  /// Loads the config, distinguishing the cause of failure - use this, not
  /// `load()`, wherever a missing config should be visible to the user (e.g.
  /// at app startup).
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

  /// Convenience wrapper around `loadResult()` for places that only need the
  /// value - returns `.empty` both for "no file" and for "corrupt file", SO do
  /// NOT use it at app/CLI startup (there the two cases have to be told apart,
  /// so that a corrupt-but-recoverable file is not silently overwritten with an
  /// empty configuration on the first auto-save).
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

  /// Copies the corrupt config file next to itself, with a timestamp suffix,
  /// BEFORE anything overwrites it - the only safety net between "the file did
  /// not parse" and "an auto-save silently overwrote it with an empty
  /// configuration". `nil` = there is NO copy. The caller then has no right to
  /// overwrite anything - see `ConfigInitialization`.
  ///
  /// `configPath` is replaceable so that a test can check BOTH variants - the
  /// copy was made and the copy was not made - without touching this machine's
  /// real configuration file.
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

  /// Counterpart of `cm_require_config` - if there is no config, creates an
  /// empty one (just as the GUI used to do in `init()`) and returns it together
  /// with the result, so that the caller (GUI init, CLI watchdogs) can display
  /// a corruption message, if there was one, instead of silently swallowing it.
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

  /// What we do after a failed parse - depending on whether the safety copy
  /// WAS MADE.
  ///
  /// Pure, so that both variants can be tested without breaking the real
  /// configuration file.
  static func decideAfterCorruption(backup: URL?, error: Error) -> ConfigInitialization {
    guard let backup else { return .corruptWithoutBackup(error: error) }
    return .corruptButBackedUp(config: .empty, backup: backup, error: error)
  }
}

/// Result of `loadOrInitialize()`. Three states, not a `(config, corruption)`
/// pair.
///
/// Until 25.09.2026 the result of `backupCorruptFile()` was IGNORED here, and
/// that function returns `nil` when copying fails. The caller therefore got an
/// empty configuration and - in `CLIContext.load()` - the message "original
/// kept on disk with a backup copy next to it" even when there was no copy at
/// all. The comment on `backupCorruptFile` calls this copy the only safety net
/// between "the file did not parse" and "an auto-save silently overwrote it
/// with an empty configuration" - and that very net could be missing.
///
/// A missing copy must ABORT an irreversible operation, not just add a warning
/// to the log. That is why `.corruptWithoutBackup` does NOT CARRY a
/// configuration: the type does not allow finishing the work without a copy,
/// so no future caller can overlook this case.
public enum ConfigInitialization {
  case ready(MachinesConfig)
  /// File corrupt, but a copy of it already sits at `backup` - it is fine to
  /// work on an empty configuration, because the original can be recovered.
  case corruptButBackedUp(config: MachinesConfig, backup: URL, error: Error)
  /// File corrupt AND the copy could not be made. Work must NOT proceed.
  case corruptWithoutBackup(error: Error)

  /// Configuration to work with - `nil` means "abort", not "empty".
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
