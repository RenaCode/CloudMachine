import Foundation

/// Port of `install.sh` - installs `rclone` via Homebrew. Assumes Homebrew is
/// already present (for bootstrapping Homebrew itself from scratch the GUI has
/// its own, more elaborate step that needs an authorization dialog, see
/// `CloudMachineController.installDependencies`).
///
/// `jq` is NO longer required - it was needed only to parse JSON in bash; the
/// whole config is now parsed by the native `JSONDecoder` (see
/// `MachinesConfig`), so that dependency went away entirely with the migration
/// to Swift.
public enum DependencyInstaller {
  public static let requiredTools = ["rclone"]

  /// Path to the brew binary, if Homebrew is already installed (Apple
  /// Silicon: /opt/homebrew, Intel: /usr/local).
  public static func resolvedBrewPath() -> String? {
    ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first {
      FileManager.default.isExecutableFile(atPath: $0)
    }
  }

  public static func missingTools() async -> [String] {
    var missing: [String] = []
    for tool in requiredTools {
      let result = try? await ProcessRunner.run("/usr/bin/which", [tool])
      if result == nil || result?.succeeded != true {
        missing.append(tool)
      }
    }
    return missing
  }

  @discardableResult
  public static func installRclone() async -> CMActionResult {
    guard let brewPath = resolvedBrewPath() else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Homebrew is not installed. Install it manually: https://brew.sh"))
    }
    let result = try? await ProcessRunner.run(brewPath, ["install", "rclone"], timeout: 600)
    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Installing rclone failed: %@", result?.stderr ?? L10n.tr("unknown error")))
    }
    return CMActionResult(succeeded: true, message: L10n.tr("Installed rclone."))
  }
}
