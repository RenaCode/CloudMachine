import Foundation

/// Normalized key of this machine - a single source of truth for the GUI and
/// the CLI (previously duplicated as `cm_machine_key` in common.sh AND
/// `CloudMachineController.currentMachineKey()` in the GUI).
public enum MachineIdentity {
  private static var identityFilePath: URL {
    CMPaths.appSupportDir.appendingPathComponent("machine-id")
  }

  /// Persistent key of this machine - determined ONCE and written to disk, NOT
  /// recomputed live from `scutil --get ComputerName` on every call. Without
  /// this, a computer rename (manual, or automatic, e.g. Migration Assistant
  /// appending "(2)" on a duplicate) would silently fragment the backup
  /// identity: new key = new folder on Google Drive, new entry in
  /// machines.json, and the whole existing backup under the old key is left
  /// orphaned (and still counts against the quota). Once written, the key
  /// survives every later rename of the Mac.
  public static func currentKey() async -> String {
    if let saved = try? String(contentsOf: identityFilePath, encoding: .utf8) {
      let trimmed = saved.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty { return trimmed }
    }
    guard let key = await deriveFromComputerName() else { return "this-mac" }
    try? key.write(to: identityFilePath, atomically: true, encoding: .utf8)
    return key
  }

  /// Split out of `currentKey()` so that a transient `scutil` failure (e.g.
  /// very early during system startup) does not permanently persist the
  /// "this-mac" fallback - in that case we simply write nothing and try to
  /// derive the real key again on the next call.
  private static func deriveFromComputerName() async -> String? {
    guard let result = try? await ProcessRunner.run("/usr/sbin/scutil", ["--get", "ComputerName"])
    else { return nil }
    let raw = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !raw.isEmpty else { return nil }
    return normalizedKey(fromComputerName: raw)
  }

  /// Pure function (no side effects), testable without shelling out to `scutil`.
  public static func normalizedKey(fromComputerName raw: String) -> String {
    let lowered = raw.lowercased().replacingOccurrences(of: " ", with: "-")
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
    return String(lowered.unicodeScalars.filter { allowed.contains($0) })
  }
}
