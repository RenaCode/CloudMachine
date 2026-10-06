import Foundation

/// Resolves all paths used by CloudMachine - config, logs, mount points, and
/// (for the CLI/launchd) the resources directory (`launchd/`,
/// `config/machines.example.json`) - regardless of whether the code runs as a
/// packaged .app (Resources are read-only, next to the binary in
/// Contents/MacOS) or as `swift run`/a compiled CLI binary started from the
/// source tree.
///
/// A single source of truth for the GUI and the CLI - previously the same logic
/// was duplicated (once as common.sh, once partly in CloudMachineController).
public enum CMPaths {
  /// Real path of the running binary, with symlinks resolved.
  ///
  /// NOT `CommandLine.arguments[0]`: when invoked via PATH (the symlink
  /// `/usr/local/bin/cloudmachine-agent`, a binary from Homebrew) the shell
  /// puts just the name there, and `URL(fileURLWithPath:)` appends it to the
  /// current directory. `cd /tmp && cloudmachine-agent version` then reported
  /// "Build from the working tree", and `install-launchd` would have pointed
  /// launchd at the binary `/tmp/cloudmachine-agent`, which does not exist.
  /// `Bundle.main.executableURL` takes the path from the kernel, regardless of
  /// how the command was typed.
  public static var runningExecutable: URL {
    (Bundle.main.executableURL ?? URL(fileURLWithPath: CommandLine.arguments[0]))
      .resolvingSymlinksInPath()
  }

  /// Directory with the project resources (`launchd/`, `config/`) - in the
  /// .app it is `Contents/Resources`, in a development checkout it is the repo
  /// root (the parent of `mac-app/`). `nil` if none of these directories
  /// exists (e.g. a binary started completely outside the project context).
  public static var resourcesRoot: URL? {
    if let bundled = Bundle.main.resourceURL,
      FileManager.default.fileExists(atPath: bundled.appendingPathComponent("launchd").path)
    {
      return bundled
    }
    // Fallback for `swift run`/`.build/*/cloudmachine-agent` in the repo tree:
    // that binary sits under mac-app/.build/<triple>/<config>/, so the repo
    // root is 5 levels up. We also check a shallower path in case it is run
    // directly from the mac-app directory.
    let exeDir = runningExecutable.deletingLastPathComponent()
    // Agent invoked through a symlink: `Bundle.main` is then sometimes
    // computed from the symlink's directory, not from the .app - so we also
    // look for Resources next to the real binary (Contents/MacOS ->
    // Contents/Resources).
    let bundleResources = exeDir.deletingLastPathComponent().appendingPathComponent("Resources")
    if FileManager.default.fileExists(
      atPath: bundleResources.appendingPathComponent("launchd").path)
    {
      return bundleResources
    }
    var candidate = exeDir
    for _ in 0..<6 {
      if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("launchd").path) {
        return candidate
      }
      candidate = candidate.deletingLastPathComponent()
    }
    return nil
  }

  public static var launchdTemplatesDir: URL? {
    resourcesRoot?.appendingPathComponent("launchd")
  }

  public static var machinesExampleConfigPath: URL? {
    resourcesRoot?.appendingPathComponent("config/machines.example.json")
  }

  public static var appSupportDir: URL {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let dir = base.appendingPathComponent("CloudMachine")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var configPath: URL { appSupportDir.appendingPathComponent("machines.json") }

  public static var logDir: URL {
    let base = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    let dir = base.appendingPathComponent("Logs/CloudMachine")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var combinedLogFile: URL { logDir.appendingPathComponent("cloudmachine.log") }

  /// Path to the compiled `cloudmachine-agent` binary that launchd should call
  /// instead of the old `.sh` scripts. Resolved in 3 steps:
  /// 1. If WE OURSELVES are `cloudmachine-agent` (the `install-launchd`
  ///    subcommand run from the CLI) - point at our own, currently running
  ///    binary. Works identically in the .app and in a development checkout.
  /// 2. Otherwise (the GUI calls this from `CloudMachineApp`) - the sibling
  ///    binary next to the GUI binary in the same `.app` bundle.
  /// 3. Fallback for a GUI started via `swift run` in the repo tree - look for
  ///    `cloudmachine-agent` in `.build/*/{release,debug}/` next to the GUI binary.
  public static var agentBinaryPath: URL? {
    let selfURL = runningExecutable
    if selfURL.lastPathComponent == "cloudmachine-agent" {
      return selfURL
    }
    if let bundled = Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent(
      "cloudmachine-agent"),
      FileManager.default.fileExists(atPath: bundled.path)
    {
      return bundled
    }
    let buildDir = selfURL.deletingLastPathComponent()
    let sibling = buildDir.appendingPathComponent("cloudmachine-agent")
    if FileManager.default.fileExists(atPath: sibling.path) {
      return sibling
    }
    return nil
  }
}
