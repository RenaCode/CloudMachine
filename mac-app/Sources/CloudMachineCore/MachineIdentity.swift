import Foundation

/// Znormalizowany klucz tej maszyny - jedno miejsce prawdy dla GUI i CLI
/// (wczesniej zduplikowane jako `cm_machine_key` w common.sh ORAZ
/// `CloudMachineController.currentMachineKey()` w GUI).
public enum MachineIdentity {
  private static var identityFilePath: URL {
    CMPaths.appSupportDir.appendingPathComponent("machine-id")
  }

  /// Trwaly klucz tej maszyny - ustalany RAZ i zapisywany na dysk, NIE
  /// przeliczany na zywo z `scutil --get ComputerName` przy kazdym
  /// wywolaniu. Bez tego zmiana nazwy komputera (reczna, albo automatyczna,
  /// np. Migration Assistant dopisujacy "(2)" przy duplikacie) cicho
  /// fragmentowalaby tozsamosc backupu: nowy klucz = nowy folder na Google
  /// Drive, nowy wpis w machines.json, a caly dotychczasowy backup pod
  /// starym kluczem zostaje osierocony (i dalej zajmuje limit). Raz zapisany
  /// klucz przetrwa kazda pozniejsza zmiane nazwy Maca.
  public static func currentKey() async -> String {
    if let saved = try? String(contentsOf: identityFilePath, encoding: .utf8) {
      let trimmed = saved.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty { return trimmed }
    }
    guard let key = await deriveFromComputerName() else { return "this-mac" }
    try? key.write(to: identityFilePath, atomically: true, encoding: .utf8)
    return key
  }

  /// Wydzielone z `currentKey()`, zeby przejsciowy blad `scutil` (np. bardzo
  /// wczesnie przy starcie systemu) nie utrwalil na stale fallbacku
  /// "this-mac" - w takim wypadku po prostu nic nie zapisujemy i probujemy
  /// wyprowadzic prawdziwy klucz ponownie przy nastepnym wywolaniu.
  private static func deriveFromComputerName() async -> String? {
    guard let result = try? await ProcessRunner.run("/usr/sbin/scutil", ["--get", "ComputerName"])
    else { return nil }
    let raw = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !raw.isEmpty else { return nil }
    return normalizedKey(fromComputerName: raw)
  }

  /// Czysta funkcja (bez efektow ubocznych), testowalna bez shellowania do `scutil`.
  public static func normalizedKey(fromComputerName raw: String) -> String {
    let lowered = raw.lowercased().replacingOccurrences(of: " ", with: "-")
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
    return String(lowered.unicodeScalars.filter { allowed.contains($0) })
  }
}
