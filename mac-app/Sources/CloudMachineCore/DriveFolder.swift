import Foundation

/// The folder on Google Drive that holds THIS Mac's backup image:
/// `gdrive:CloudMachine/<name>`, with the image `<name>.sparsebundle` inside.
///
/// It used to be the constant `mac-studio` on every Mac, so two Macs on one
/// Google account would have shared one folder and one image. Each Mac now
/// keeps its own name in `~/Library/Application Support/CloudMachine/drive-folder`,
/// chosen once by `configure-remote` and never changed afterwards.
///
/// "Never changed" is the point. A different name is a different, empty
/// folder: Time Machine starts from zero and the old backup sits orphaned on
/// Drive, still using quota. So the name is decided once, and an installation
/// that predates this file keeps `mac-studio` - it is where its backup lives.
public enum DriveFolder {
  /// The name every installation used before names were per Mac.
  public static let legacyName = "mac-studio"

  static var file: URL { CMPaths.appSupportDir.appendingPathComponent("drive-folder") }

  /// The name the mount, the image and the status use.
  ///
  /// No file means an installation from before this setting existed (a new
  /// one gets the file from `configure-remote` before anything is mounted),
  /// so the answer is the legacy name, not a fresh one.
  public static var name: String {
    stored(in: file) ?? legacyName
  }

  static func stored(in file: URL) -> String? {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return nil }
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return isValid(trimmed) ? trimmed : nil
  }

  /// Lowercase letters, digits and dashes; 1-63 characters, not starting with
  /// a dash. Safe as a Drive folder, a file name and an rclone path segment.
  public static func isValid(_ name: String) -> Bool {
    name.range(of: #"^[a-z0-9][a-z0-9-]{0,62}$"#, options: .regularExpression) != nil
  }

  /// Whether this Mac was set up before folder names existed.
  ///
  /// The evidence is the rclone remote itself. `configure-remote` decides the
  /// folder BEFORE it creates the remote, so on a new Mac the remote is not
  /// there yet; on an installation that predates `drive-folder` it is, and its
  /// backup lives under the legacy name. Weaker traces were rejected: the
  /// buffer directory appears after any mount attempt, and the old
  /// `mount-desired.state` is no longer written by anything.
  static func hasLegacyInstallation() async -> Bool {
    await RemoteConfigurer.isConfigured(remoteName: DriveBufferService.remoteName)
  }

  public enum Decision: Equatable {
    /// Already decided; nothing to write.
    case keep(String)
    /// Write this name now.
    case assign(String)
    /// Refuse, with the reason to show.
    case refuse(String)
  }

  /// Pure decision, so every branch can be tested without touching the disk.
  ///
  /// - `existing`: the name already stored, if any.
  /// - `requested`: a name passed with `--folder`, if any.
  /// - `legacyEvidence`: `hasLegacyInstallation()`, asked before the remote
  ///   is created.
  /// - `machineKey`: `MachineIdentity` key, the default for a new Mac.
  public static func decide(
    existing: String?, requested: String?, legacyEvidence: Bool, machineKey: String
  ) -> Decision {
    if let requested, !isValid(requested) {
      return .refuse(
        L10n.tr(
          "'%@' is not a valid folder name: use lowercase letters, digits and dashes.", requested))
    }
    if let existing {
      guard let requested, requested != existing else { return .keep(existing) }
      return .refuse(
        L10n.tr(
          "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.",
          existing, requested))
    }
    if legacyEvidence {
      guard let requested, requested != legacyName else { return .assign(legacyName) }
      return .refuse(
        L10n.tr(
          "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.",
          legacyName, requested))
    }
    let fallback = isValid(machineKey) ? machineKey : "this-mac"
    return .assign(requested ?? fallback)
  }

  /// Decides and stores the name for this Mac. Returns the name to use, or
  /// the reason it refused.
  public static func resolve(requested: String?) async -> Result<String, RefusedError> {
    let decision = decide(
      existing: stored(in: file), requested: requested,
      legacyEvidence: await hasLegacyInstallation(), machineKey: await MachineIdentity.currentKey())
    switch decision {
    case .keep(let name):
      return .success(name)
    case .assign(let name):
      do {
        try name.write(to: file, atomically: true, encoding: .utf8)
      } catch {
        return .failure(
          RefusedError(
            message: L10n.tr(
              "Could not save the folder name to %@: %@", file.path, error.localizedDescription)))
      }
      CMLogger.log("Drive folder for this Mac set to '\(name)'")
      return .success(name)
    case .refuse(let reason):
      return .failure(RefusedError(message: reason))
    }
  }

  public struct RefusedError: Error, Equatable {
    public let message: String
  }
}
