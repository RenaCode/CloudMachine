import Foundation

/// Parsowanie tekstowego wyjscia `tmutil status`/`tmutil destinationinfo` -
/// oba to wlasciwie "plist-jak" tekst, nie prawdziwy JSON/plist, wiec
/// najprosciej i najbezpieczniej parsowac linia po linii, tak jak robily to
/// oryginalne `awk` w bash.
/// Postep aktywnego backupu, wyciagniety z bloku `Progress = { ... }` w
/// `tmutil status`. Wszystkie pola opcjonalne - macOS nie zawsze wypelnia
/// caly blok (np. w fazach innych niz "Copying" czesc pol moze brakowac).
public struct TimeMachineProgress: Equatable {
  public var phase: String?
  public var percent: Double?
  public var bytes: Double?
  public var totalBytes: Double?
  public var files: Int?
  public var totalFiles: Int?
  public var timeRemainingSeconds: Double?
}

public enum TimeMachineStatus {
  public static func isRunning() async -> Bool {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["status"]) else {
      return false
    }
    return isRunning(statusOutput: result.stdout)
  }

  /// Czysta funkcja parsujaca - wydzielona z `isRunning()`, zeby dalo sie ja
  /// przetestowac bez `tmutil` na prawdziwym Maku (patrz `CooldownGate` dla
  /// tego samego wzorca w tym projekcie). Cala logika parsujaca w tym pliku
  /// wczesniej nie miala ani jednego testu, mimo ze to wlasnie tutaj (blednie
  /// zgadywana nazwa wolumenu, kolizje mountowania) siedzialy realne bugi.
  static func isRunning(statusOutput: String) -> Bool {
    for line in statusOutput.split(separator: "\n") {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      if trimmed.hasPrefix("Running") {
        return trimmed.contains("= 1")
      }
    }
    return false
  }

  /// Parsuje `tmutil status` linia po linii (ten sam styl co reszta pliku) -
  /// klucze wewnatrz bloku `Progress` (`bytes`, `files`, `TimeRemaining`...)
  /// sa unikalne w calym wyjsciu, wiec nie trzeba osobno sledzic zagniezdzenia
  /// nawiasow klamrowych. Zwraca `nil`, jesli aktualnie nic nie kopiuje.
  public static func currentProgress() async -> TimeMachineProgress? {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["status"]) else {
      return nil
    }
    return currentProgress(statusOutput: result.stdout)
  }

  static func currentProgress(statusOutput: String) -> TimeMachineProgress? {
    var running = false
    var progress = TimeMachineProgress()

    for rawLine in statusOutput.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      guard let eqIndex = line.firstIndex(of: "=") else { continue }
      let key = line[line.startIndex..<eqIndex].trimmingCharacters(in: .whitespaces)
      var value = String(line[line.index(after: eqIndex)...]).trimmingCharacters(in: .whitespaces)
      if value.hasSuffix(";") { value.removeLast() }
      value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))

      switch key {
      case "Running": running = (value == "1")
      case "BackupPhase": progress.phase = value
      case "Percent": progress.percent = Double(value)
      case "bytes": progress.bytes = Double(value)
      case "totalBytes": progress.totalBytes = Double(value)
      case "files": progress.files = Int(value)
      case "totalFiles": progress.totalFiles = Int(value)
      case "TimeRemaining": progress.timeRemainingSeconds = Double(value)
      default: break
      }
    }
    return running ? progress : nil
  }

  /// Odpowiednik `tmutil destinationinfo | awk ... -v mp="$SP_MOUNT"` - szuka
  /// bloku, ktorego "Mount Point" zawiera `mountPoint`, i zwraca jego ID.
  public static func destinationID(forMountPointContaining mountPoint: String) async -> String? {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) else {
      return nil
    }
    return destinationID(forMountPointContaining: mountPoint, destinationInfoOutput: result.stdout)
  }

  static func destinationID(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  )
    -> String?
  {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("ID") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        return parts[1].trimmingCharacters(in: .whitespaces)
      }
    }
    return nil
  }

  /// Limit (GB) skonfigurowany dla celu TM pod danym punktem montowania -
  /// parsuje linie "Quota" (np. "300 GB") z bloku znalezionego tak samo jak
  /// w `destinationID`. `nil`, jesli TM nie raportuje limitu dla tego celu.
  public static func destinationQuotaGB(forMountPointContaining mountPoint: String) async
    -> Double?
  {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"])
    else {
      return nil
    }
    return destinationQuotaGB(
      forMountPointContaining: mountPoint, destinationInfoOutput: result.stdout)
  }

  static func destinationQuotaGB(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  ) -> Double? {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("Quota") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        let valueText = parts[1].trimmingCharacters(in: .whitespaces)
        let numberText = valueText.split(separator: " ").first.map(String.init) ?? valueText
        return Double(numberText)
      }
    }
    return nil
  }

  /// Punkt montowania AKTUALNIE zarejestrowanego celu Time Machine
  /// (architektura gwarantuje dokladnie jeden aktywny cel lokalny - patrz
  /// LocalBackupService). Zwraca prawdziwa, zarejestrowana sciezke zamiast
  /// zgadywac ja z domyslnej nazwy wolumenu - uzytkownik moze nazwac lokalny
  /// wolumin dowolnie (np. recznie utworzona partycja "TimeMachine" zamiast
  /// domyslnej "CloudMachine-Local"), a zgadywanie po nazwie bylo realnym
  /// bugiem: po recznej zmianie nazwy wolumenu caly status GUI/watchdogow
  /// pokazywal "brak lokalnego woluminu" / "TimeMachine niezarejestrowany",
  /// mimo poprawnie dzialajacego, zarejestrowanego celu.
  public static func currentDestinationMountPoint() async -> String? {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"])
    else {
      return nil
    }
    return currentDestinationMountPoint(destinationInfoOutput: result.stdout)
  }

  static func currentDestinationMountPoint(destinationInfoOutput: String) -> String? {
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("Mount Point") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      return parts[1].trimmingCharacters(in: .whitespaces)
    }
    return nil
  }

  /// Wszystkie zarejestrowane ID celow Time Machine - uzywane przez
  /// `LocalBackupService.setAsDestination` do usuniecia poprzednich celow
  /// przed zarejestrowaniem nowego (ta architektura utrzymuje dokladnie
  /// jeden aktywny lokalny cel, w przeciwienstwie do legacy podejscia).
  public static func allDestinationIDs() async -> [String] {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) else {
      return []
    }
    return allDestinationIDs(destinationInfoOutput: result.stdout)
  }

  static func allDestinationIDs(destinationInfoOutput: String) -> [String] {
    var ids: [String] = []
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("ID") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      ids.append(parts[1].trimmingCharacters(in: .whitespaces))
    }
    return ids
  }

  public static func destinationInfoContains(_ needle: String) async -> Bool {
    guard let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["destinationinfo"]) else {
      return false
    }
    return result.stdout.contains(needle)
  }
}
