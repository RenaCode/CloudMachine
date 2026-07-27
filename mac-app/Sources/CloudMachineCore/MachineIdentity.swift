import Foundation

/// Znormalizowany klucz tej maszyny - jedno miejsce prawdy dla GUI i CLI
/// (wczesniej zduplikowane jako `cm_machine_key` w common.sh ORAZ
/// `CloudMachineController.currentMachineKey()` w GUI).
public enum MachineIdentity {
  public static func currentKey() async -> String {
    guard let result = try? await ProcessRunner.run("/usr/sbin/scutil", ["--get", "ComputerName"])
    else {
      return "this-mac"
    }
    let raw = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalizedKey(fromComputerName: raw)
  }

  /// Czysta funkcja (bez efektow ubocznych), testowalna bez shellowania do `scutil`.
  public static func normalizedKey(fromComputerName raw: String) -> String {
    let lowered = raw.lowercased().replacingOccurrences(of: " ", with: "-")
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
    return String(lowered.unicodeScalars.filter { allowed.contains($0) })
  }
}
