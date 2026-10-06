import Foundation

/// Paths needed ONLY by the build tools (`build-app`, `make-dmg`,
/// `setup-signing-cert`) - unlike `CMPaths` (CloudMachineCore), which resolves
/// paths for the already running app/CLI (including inside the installed
/// .app), these tools make sense ONLY when run from the source checkout (they
/// PRODUCE the .app, they do not consume it) - hence `#filePath` (known at
/// compile time, independent of where the command is later run from) instead
/// of `CommandLine.arguments[0]`.
enum BuildPaths {
  static var macAppRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()  // CloudMachineAgent
      .deletingLastPathComponent()  // Sources
      .deletingLastPathComponent()  // mac-app
  }

  static var projectRoot: URL {
    macAppRoot.deletingLastPathComponent()
  }

  /// The version to build: `CM_RELEASE_VERSION` when set, else `mac-app/VERSION`.
  ///
  /// The release workflow computes patch versions (1.3.0 -> 1.3.1) and passes
  /// them in the environment. Writing them into VERSION instead would leave the
  /// tree modified, and every release would report itself as DIRTY-TREE.
  static var version: String {
    if let forced = ProcessInfo.processInfo.environment["CM_RELEASE_VERSION"]?
      .trimmingCharacters(in: .whitespacesAndNewlines), !forced.isEmpty
    {
      return forced
    }
    return (try? String(contentsOf: macAppRoot.appendingPathComponent("VERSION"), encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? "1.0.0"
  }
}
