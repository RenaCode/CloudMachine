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
}
