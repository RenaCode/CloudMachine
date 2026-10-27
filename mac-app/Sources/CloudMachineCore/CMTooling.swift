import Foundation

/// Resolves the external tools the Mac side needs and checks whether they are
/// there: the official rclone (Google sign-in, `rclone.conf` for the machine,
/// usage measurements) and Lima (the machine itself).
///
/// rclone lives in our own directory, so the configuration is always written
/// and read by the same binary, whatever Homebrew has installed.
public enum CMTooling {

  // MARK: - rclone

  /// Directory for tools managed by CloudMachine.
  public static var toolsDir: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine/bin")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  /// The official rclone binary, managed by CloudMachine.
  public static var managedRclonePath: URL {
    toolsDir.appendingPathComponent("rclone")
  }

  public static var hasManagedRclone: Bool {
    FileManager.default.isExecutableFile(atPath: managedRclonePath.path)
  }

  /// Runs the managed rclone. Every code path that reads or writes the
  /// Google Drive configuration goes through here.
  public static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws
    -> ProcessResult
  {
    try await ProcessRunner.run(managedRclonePath.path, args, timeout: timeout)
  }

  // MARK: - Availability from the terminal

  /// Path under which `cloudmachine-agent` should be visible in PATH.
  public static let commandLinkPath = "/usr/local/bin/cloudmachine-agent"

  /// Creates a symlink to the agent binary in PATH.
  ///
  /// Without it, every command from the documentation - `vm-setup`,
  /// `vm-status` - ends in "command not found", because the binary sits
  /// inside the app bundle. Root is not needed: `/usr/local/bin` belongs to
  /// the user and the admin group.
  @discardableResult
  public static func linkCommandIntoPath() -> Bool {
    guard let agent = CMPaths.agentBinaryPath else { return false }
    let fm = FileManager.default
    let link = URL(fileURLWithPath: commandLinkPath)

    if let existing = try? fm.destinationOfSymbolicLink(atPath: commandLinkPath),
      existing == agent.path
    {
      return true
    }
    try? fm.createDirectory(
      at: link.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? fm.removeItem(at: link)
    do {
      try fm.createSymbolicLink(at: link, withDestinationURL: agent)
      CMLogger.log("Added \(commandLinkPath) -> \(agent.path)")
      return true
    } catch {
      return false
    }
  }

  // MARK: - Readiness diagnostics

  public struct Readiness {
    public var ready: Bool { missing.isEmpty }
    /// What is missing, in the order in which it has to be fixed.
    public var missing: [String]
    /// Commands that fix it - ready to be shown to the user.
    public var remedies: [String]
  }

  public static func checkReadiness() -> Readiness {
    var missing: [String] = []
    var remedies: [String] = []
    if !hasManagedRclone {
      missing.append("rclone")
      remedies.append("cloudmachine-agent install-rclone")
    }
    if VMLayout.limactlPath == nil {
      missing.append("Lima")
      remedies.append("brew install lima")
    }
    return Readiness(missing: missing, remedies: remedies)
  }
}
