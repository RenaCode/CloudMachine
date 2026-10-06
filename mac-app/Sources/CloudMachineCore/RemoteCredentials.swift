import Foundation

/// Own OAuth credentials for Google Drive.
///
/// They are not decoration: without them rclone connects with rclone's SHARED
/// `client_id`, rate-limited jointly with all of its users and being retired
/// in 2026. Until now they could only be entered by a manual
/// `security add-generic-password` from the README - i.e. a step nobody takes
/// until something stops working.
///
/// They are NOT in the repository and never were: the code reads them from the
/// Keychain, and the git history contains only the placeholder
/// `...apps.googleusercontent.com` in a comment. Verified 13 Sep 2026.
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

    /// A half-done configuration is worse than none, because it looks done.
    /// rclone needs BOTH values - with only one it falls back to the shared
    /// `client_id` anyway.
    public var isComplete: Bool { hasClientID && hasClientSecret }
    public var isPartial: Bool { (hasClientID || hasClientSecret) && !isComplete }

    public var summary: String {
      if isComplete { return L10n.tr("Own Google credentials: set.") }
      if isPartial {
        return L10n.tr(
          "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.",
          hasClientID ? "client_secret" : "client_id")
      }
      return L10n.tr(
        "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026."
      )
    }
  }

  public static func credentialsState() async -> CredentialsState {
    async let id = KeychainStore.exists(account: clientIDAccount, service: keychainService)
    async let secret = KeychainStore.exists(
      account: clientSecretAccount, service: keychainService)
    return CredentialsState(hasClientID: await id, hasClientSecret: await secret)
  }

  /// Stores both credentials.
  ///
  /// Changing the credentials does NOT reconfigure an existing remote - a
  /// token already issued keeps working on the old `client_id`. For the new
  /// ones to take effect, `configure-remote --replace-existing` has to be run,
  /// and the message says so instead of leaving the illusion that it will
  /// happen by itself.
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
