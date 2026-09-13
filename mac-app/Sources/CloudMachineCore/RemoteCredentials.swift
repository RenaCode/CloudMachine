import Foundation

/// Wlasne poswiadczenia OAuth do Google Drive.
///
/// Nie sa ozdobnikiem: bez nich rclone laczy sie na WSPoLDZIELONYM `client_id`
/// rclone, limitowanym wspolnie ze wszystkimi jego uzytkownikami i wycofywanym
/// w 2026. Do tej pory dalo sie je wprowadzic wylacznie recznym
/// `security add-generic-password` z README - czyli krokiem, ktorego nikt nie
/// robi, dopoki cos nie przestanie dzialac.
///
/// W repozytorium ICH NIE MA i nigdy nie bylo: kod czyta je z Keychaina, a
/// historia gita zawiera wylacznie placeholder `...apps.googleusercontent.com`
/// w komentarzu. Sprawdzone 13 wrz 2026.
extension RemoteConfigurer {

  public static let clientIDAccount = "client_id"
  public static let clientSecretAccount = "client_secret"

  public struct CredentialsState: Equatable {
    public let hasClientID: Bool
    public let hasClientSecret: Bool

    public init(hasClientID: Bool, hasClientSecret: Bool) {
      self.hasClientID = hasClientID
      self.hasClientSecret = hasClientSecret
    }

    /// Polowiczna konfiguracja jest gorsza niz zadna, bo wyglada na zrobiona.
    /// rclone potrzebuje OBU wartosci - przy jednej i tak wraca na
    /// wspoldzielony `client_id`.
    public var isComplete: Bool { hasClientID && hasClientSecret }
    public var isPartial: Bool { (hasClientID || hasClientSecret) && !isComplete }

    public var summary: String {
      if isComplete { return "Wlasne poswiadczenia Google: ustawione." }
      if isPartial {
        return
          "NIEPELNE: brakuje \(hasClientID ? "client_secret" : "client_id") - rclone i tak uzyje wspoldzielonego client_id rclone."
      }
      return
        "Brak wlasnych poswiadczen - rclone uzywa wspoldzielonego client_id, limitowanego wspolnie i wycofywanego w 2026."
    }
  }

  public static func credentialsState() async -> CredentialsState {
    async let id = KeychainStore.exists(account: clientIDAccount, service: keychainService)
    async let secret = KeychainStore.exists(
      account: clientSecretAccount, service: keychainService)
    return CredentialsState(hasClientID: await id, hasClientSecret: await secret)
  }

  /// Zapisuje oba poswiadczenia.
  ///
  /// Zmiana poswiadczen NIE przekonfigurowuje istniejacego remote - token juz
  /// wydany dziala dalej na starym `client_id`. Zeby nowe weszly w zycie,
  /// trzeba przejsc `configure-remote --replace-existing`, i o tym mowi
  /// komunikat, zamiast zostawiac zludzenie, ze samo zadziala.
  public static func storeCredentials(clientID: String, clientSecret: String) async throws {
    try await KeychainStore.save(clientID, account: clientIDAccount, service: keychainService)
    try await KeychainStore.save(
      clientSecret, account: clientSecretAccount, service: keychainService)
  }

  public static func deleteCredentials() async throws {
    try await KeychainStore.delete(account: clientIDAccount, service: keychainService)
    try await KeychainStore.delete(account: clientSecretAccount, service: keychainService)
  }
}
