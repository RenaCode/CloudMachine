import Foundation

/// Resolves the external tools the Google Drive layer needs and checks whether
/// they are usable at all.
///
/// It exists because `ProcessRunner.runRclone` calls `/usr/bin/env rclone`,
/// and that hits rclone from Homebrew - built WITHOUT FUSE support. When asked
/// to mount, it refuses outright:
///
///     rclone mount is not supported on MacOS when rclone is installed via Homebrew
///
/// The official binary from rclone.org is needed. We keep it in our own
/// directory so as not to clash with the Homebrew installation, which the
/// remaining, non-mounting code paths use.
public enum CMTooling {

  // MARK: - rclone

  /// Directory for tools managed by CloudMachine.
  public static var toolsDir: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine/bin")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  /// Official rclone binary with mount support.
  public static var managedRclonePath: URL {
    toolsDir.appendingPathComponent("rclone")
  }

  public static var hasManagedRclone: Bool {
    FileManager.default.isExecutableFile(atPath: managedRclonePath.path)
  }

  /// Runs an rclone that CERTAINLY can mount. Every code path touching
  /// mounting must go through here, not through `ProcessRunner.runRclone`.
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
  /// Without it, every command from the documentation - `prepare-shutdown`,
  /// `drive-status` - ends in "command not found", because the binary sits
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

  // MARK: - FUSE

  /// Our copy of FUSE-T - so as not to keep a separate application in the
  /// system. See `FuseInstaller`.
  public static var bundledFuseDir: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine/fuse")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var bundledFuseLib: URL { bundledFuseDir.appendingPathComponent("libfuse-t.dylib") }

  /// The NFS server that actually holds the mount. Its path can be given via
  /// the `FUSE_NFSSRV_PATH` variable, so it can live in our directory.
  public static var bundledNfsServer: URL { bundledFuseDir.appendingPathComponent("go-nfsv4") }

  /// Paths where FUSE may live. One is enough.
  private static let fuseCandidates = [
    "/usr/local/lib/libfuse-t.dylib",
    "/usr/local/lib/libfuse.2.dylib",
    "/usr/local/lib/libfuse.dylib",
    "/Library/Filesystems/fuse-t.fs",
  ]

  /// Whether FUSE is installed.
  ///
  /// BEWARE of a trap that has already sprung once: the first version of this
  /// check in bash ran `ls a b c` and checked the exit code. `ls` returns an
  /// error when ANY of the paths is missing, not when all of them are - so it
  /// refused to start with a correctly installed FUSE-T. We check one by one.
  public static var hasFuse: Bool {
    // Our own copy counts the same as a system installation: we can recreate
    // the symlink in /usr/local/lib ourselves (FuseInstaller.ensureSystemLink),
    // so its temporary absence does not mean there is no FUSE. The FUSE-T
    // uninstaller deletes that symlink when removing the separate application
    // - without this condition the status would then report FUSE missing even
    // though mounting works.
    if FileManager.default.fileExists(atPath: bundledFuseLib.path) { return true }
    return fuseCandidates.contains { FileManager.default.fileExists(atPath: $0) }
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
    // The check is also an opportunity to repair - the symlink is sometimes
    // deleted by the FUSE-T uninstaller and there is no reason to wait with
    // that until the next startup.
    FuseInstaller.ensureSystemLink()

    var missing: [String] = []
    var remedies: [String] = []

    if !hasManagedRclone {
      missing.append(L10n.tr("rclone with mount support"))
      remedies.append("cloudmachine-agent install-rclone")
    }
    if !hasFuse {
      missing.append("FUSE")
      remedies.append("cloudmachine-agent install-fuse")
    }
    return Readiness(missing: missing, remedies: remedies)
  }
}
