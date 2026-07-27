import Foundation

/// Czysta logika "czy minal juz cooldown od ostatniej proby" - wydzielona z
/// `BackupWatchdogService`/`VerifyWatchdogService` (obie mialy identyczna,
/// zduplikowana logike zmieszana z odczytem pliku stanu), zeby dalo sie ja
/// przetestowac bez dotykania systemu plikow.
public enum CooldownGate {
  /// `true`, jesli od `lastEpoch` (unix timestamp z pliku stanu, `nil` gdy
  /// nigdy jeszcze nie probowano) minelo mniej niz `cooldown` sekund - czyli
  /// NALEZY POMINAC ten przebieg.
  public static func isWithinCooldown(
    lastEpoch: Double?, now: Date = Date(), cooldown: TimeInterval
  ) -> Bool {
    guard let lastEpoch else { return false }
    return now.timeIntervalSince1970 - lastEpoch < cooldown
  }

  /// Parsuje zawartosc pliku stanu (tekstowy unix timestamp) - `nil`, jesli
  /// plik nie istnieje albo zawiera smieci.
  public static func parseStateFile(_ url: URL) -> Double? {
    guard let raw = try? String(contentsOf: url, encoding: .utf8) else { return nil }
    return Double(raw.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  public static func writeStateFile(_ url: URL, now: Date = Date()) {
    try? "\(Int(now.timeIntervalSince1970))".write(to: url, atomically: true, encoding: .utf8)
  }
}
