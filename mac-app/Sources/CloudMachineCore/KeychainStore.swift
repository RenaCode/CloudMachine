import Foundation

/// Writing credentials to the Keychain.
///
/// **Why via `security` and not via the Security API (SecItemAdd).**
/// An item created by `SecItemAdd` gets an ACL restricted to the program that
/// created it. Reading it from ANOTHER binary - which is exactly what
/// `RemoteConfigurer.keychainSecret`, called from the launchd agent, does -
/// then raises an "allow access" dialog. The launchd agent has nobody to show
/// that dialog to, so the read hangs or comes back empty, and rclone silently
/// connects with the shared `client_id`. Measured 13 Sep 2026: `SecItemAdd`
/// returned 0, after which `security find-generic-password -w` from another
/// process hung on a SecurityAgent dialog.
///
/// Writing via `security` produces an item readable by `security` - i.e.
/// exactly by the path the running system uses.
///
/// **The price: the password goes into `security`'s argv,** so for a fraction
/// of a second it is visible in `ps`. A deliberate trade-off against the
/// alternative, which is a silent backup failure. The exposure concerns a
/// process living for milliseconds and only on this machine; the secret lands
/// in the same user's Keychain right afterwards anyway.
public enum KeychainStore {

  public enum StoreError: LocalizedError {
    case emptyValue
    case failed(String)

    public var errorDescription: String? {
      switch self {
      case .emptyValue: return L10n.tr("Empty value - not saving.")
      case .failed(let detail): return L10n.tr("Keychain refused: %@", detail)
      }
    }
  }

  /// Saves or overwrites an item. `-U` means "replace if it already exists" -
  /// without it, fixing a typo would end in an error with the old value still
  /// in use.
  public static func save(_ value: String, account: String, service: String) async throws {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw StoreError.emptyValue }

    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["add-generic-password", "-a", account, "-s", service, "-w", trimmed, "-U"],
      timeout: 30)
    guard result?.succeeded == true else {
      throw StoreError.failed(result?.stderr ?? L10n.tr("unknown error"))
    }
  }

  /// Whether the item exists - WITHOUT `-w`, i.e. without reaching for the
  /// value itself.
  ///
  /// This is not a detail: checking existence alone does not touch the ACL
  /// and does not raise a dialog, while reading the value (`-w`) can. The
  /// interface has to show "set / missing", and the value is not needed for
  /// that.
  public static func exists(account: String, service: String) async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["find-generic-password", "-a", account, "-s", service],
      timeout: 30)
    return result?.succeeded == true
  }

  public static func delete(account: String, service: String) async throws {
    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["delete-generic-password", "-a", account, "-s", service],
      timeout: 30)
    // A missing item is not an error - deletion must be idempotent.
    guard result?.succeeded == true || result?.stderr.contains("could not be found") == true else {
      throw StoreError.failed(result?.stderr ?? L10n.tr("unknown error"))
    }
  }
}
