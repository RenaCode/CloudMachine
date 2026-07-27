import Foundation

/// Wspolny helper do `rclone size --json` - uzywany przez GUI (karta
/// "Wykorzystanie limitu") i `QuotaWatchdogService` (decyzja o przycinaniu).
public enum RcloneSize {
  /// Domyslnie 60s (odpowiednie dla GUI, gdzie uzytkownik czeka na ekranie).
  /// `QuotaWatchdogService` przekazuje dluzszy timeout - zaobserwowane na
  /// zywo: `rclone size` potrafi trwac >2 min, gdy w tle akurat aktywnie
  /// dziala rclone nfsmount i konkuruje o ten sam limit API.
  public static func usedGB(remotePath: String, timeout: TimeInterval = 60) async -> Double? {
    guard
      let result = try? await ProcessRunner.runRclone(
        ["size", remotePath, "--json"], timeout: timeout),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let bytes = json["bytes"] as? Double
    else {
      return nil
    }
    return bytes / 1_073_741_824
  }
}
