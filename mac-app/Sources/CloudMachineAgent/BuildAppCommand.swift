import ArgumentParser
import CloudMachineCore
import Foundation

/// Port of `scripts/build-app.sh` - builds `CloudMachine.app` (Release) from the
/// Swift package: the GUI (`CloudMachineApp`) AND the CLI (`cloudmachine-agent`,
/// called by launchd instead of the old bash scripts) go in as two binaries in
/// the same `Contents/MacOS/`, plus the launchd/config templates as Resources -
/// so the app is fully self-contained and does not need a separately cloned
/// repo next to it.
///
/// Signs with the local certificate (see `setup-signing-cert`) if it exists -
/// and ad-hoc otherwise (no Apple Developer account). An ad-hoc signature
/// produces a NEW identity hash on every rebuild, so macOS revokes previously
/// granted Full Disk Access after every rebuild; a stable local certificate
/// solves this problem once and for all.
struct BuildApp: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "build-app",
    abstract:
      L10n.tr(
        "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/config as Resources."
      )
  )

  @Flag(
    name: .long,
    help:
      ArgumentHelp(
        L10n.tr(
          "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally)."
        )))
  var universal = false

  func run() async throws {
    let macAppRoot = BuildPaths.macAppRoot
    let projectRoot = BuildPaths.projectRoot
    let appName = "CloudMachine"
    let buildDir = macAppRoot.appendingPathComponent("build")
    let appBundle = buildDir.appendingPathComponent("\(appName).app")
    let fm = FileManager.default

    let version = BuildPaths.version
    let buildNumber = await resolveBuildNumber(projectRoot: projectRoot)

    print(
      L10n.tr(
        "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)", version,
        buildNumber)
    )
    // `/usr/bin/env swift` (not a hard-coded /usr/bin/swift path), to respect
    // PATH - developers with a non-standard toolchain (e.g. the swift.org
    // installer, the TOOLCHAINS env var) may have a different `swift` than
    // the default one from Xcode. The original bash did the same (`swift
    // build` with no path, resolved through the shell's PATH).
    let swiftArgs =
      ["build", "-c", "release", "--package-path", macAppRoot.path]
      + (universal ? ["--arch", "arm64", "--arch", "x86_64"] : [])
    let buildStatus = try await InteractiveProcess.run("/usr/bin/env", ["swift"] + swiftArgs)
    guard buildStatus == 0 else {
      print(L10n.tr("ERROR: swift build exited with code %@.", "\(buildStatus)"))
      throw ExitCode.failure
    }

    // SwiftPM itself reports the binaries directory: with several
    // architectures it is not `.build/release` but a directory that depends on
    // the tools version (`.build/apple/...` or `.build/out/...`) - guessing it
    // would break with the first Xcode update.
    guard
      let binPathResult = try? await ProcessRunner.run(
        "/usr/bin/env", ["swift"] + swiftArgs + ["--show-bin-path"]),
      binPathResult.succeeded
    else {
      print(L10n.tr("ERROR: swift build --show-bin-path did not report the binaries directory."))
      throw ExitCode.failure
    }
    let binDir = URL(
      fileURLWithPath: binPathResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
    let appBinPath = binDir.appendingPathComponent("\(appName)App")
    let agentBinPath = binDir.appendingPathComponent("cloudmachine-agent")
    for path in [appBinPath, agentBinPath] {
      guard fm.fileExists(atPath: path.path) else {
        print(L10n.tr("ERROR: no built binary found at %@", path.path))
        throw ExitCode.failure
      }
    }

    print(L10n.tr("==> Assembling the .app bundle in %@", appBundle.path))
    try? fm.removeItem(at: appBundle)
    let macOSDir = appBundle.appendingPathComponent("Contents/MacOS")
    let resourcesDir = appBundle.appendingPathComponent("Contents/Resources")
    try fm.createDirectory(at: macOSDir, withIntermediateDirectories: true)
    try fm.createDirectory(at: resourcesDir, withIntermediateDirectories: true)

    try fm.copyItem(at: appBinPath, to: macOSDir.appendingPathComponent(appName))
    // cloudmachine-agent sits NEXT TO the main GUI binary in the same
    // Contents/MacOS - this is the binary launchd calls (see
    // launchd/*.plist.template, __CM_AGENT_BIN__) and the one
    // CMPaths.agentBinaryPath points to when the GUI installs the agents.
    try fm.copyItem(at: agentBinPath, to: macOSDir.appendingPathComponent("cloudmachine-agent"))

    let infoPlistTemplate = macAppRoot.appendingPathComponent("Resources/Info.plist")
    var infoPlistContent = try String(contentsOf: infoPlistTemplate, encoding: .utf8)
    infoPlistContent = infoPlistContent.replacingOccurrences(of: "__CM_VERSION__", with: version)
    infoPlistContent = infoPlistContent.replacingOccurrences(of: "__CM_BUILD__", with: buildNumber)
    let commit = await resolveCommit(projectRoot: projectRoot)
    let changes = await uncommittedChanges(projectRoot: projectRoot)
    let dirty = !changes.isEmpty
    infoPlistContent = infoPlistContent.replacingOccurrences(of: "__CM_COMMIT__", with: commit)
    infoPlistContent = infoPlistContent.replacingOccurrences(
      of: "__CM_DIRTY__", with: dirty ? "true" : "false")
    if dirty {
      // We do not abort - building from a dirty tree is normal during work.
      // But the binary then carries code that is in no commit, so a later
      // "version X is installed" would be a lie if nobody said so out loud.
      print(
        L10n.tr(
          "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit."
        ))
      // Named, not just counted: on a CI runner nobody can look at the tree
      // afterwards, and v1.3.0 shipped marked dirty with no clue which file.
      for line in changes { print("    \(line)") }
    }
    try infoPlistContent.write(
      to: appBundle.appendingPathComponent("Contents/Info.plist"), atomically: true, encoding: .utf8
    )

    // We bundle the launchd templates and the example config as Resources -
    // the same ones the CLI-only version uses (see CMPaths.resourcesRoot).
    try fm.copyItem(
      at: projectRoot.appendingPathComponent("launchd"),
      to: resourcesDir.appendingPathComponent("launchd"))
    let configDir = resourcesDir.appendingPathComponent("config")
    try fm.createDirectory(at: configDir, withIntermediateDirectories: true)
    try fm.copyItem(
      at: projectRoot.appendingPathComponent("config/machines.example.json"),
      to: configDir.appendingPathComponent("machines.example.json"))

    let appIcon = macAppRoot.appendingPathComponent("Resources/AppIcon.icns")
    guard fm.fileExists(atPath: appIcon.path) else {
      print(
        L10n.tr(
          "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns"
        )
      )
      throw ExitCode.failure
    }
    try fm.copyItem(at: appIcon, to: resourcesDir.appendingPathComponent("AppIcon.icns"))

    let certName =
      ProcessInfo.processInfo.environment["CM_SIGNING_CERT_NAME"] ?? "CloudMachine Local Signing"
    let certExists =
      (try? await ProcessRunner.run("/usr/bin/security", ["find-certificate", "-c", certName]))?
      .succeeded
      == true
    let signStatus: Int32
    if certExists {
      print(
        L10n.tr(
          "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)",
          certName)
      )
      signStatus = try await InteractiveProcess.run(
        "/usr/bin/codesign", ["--force", "--deep", "--sign", certName, appBundle.path])
    } else {
      print(
        L10n.tr(
          "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds"
        )
      )
      signStatus = try await InteractiveProcess.run(
        "/usr/bin/codesign", ["--force", "--deep", "--sign", "-", appBundle.path])
    }
    guard signStatus == 0 else {
      print(L10n.tr("ERROR: codesign exited with code %@.", "\(signStatus)"))
      throw ExitCode.failure
    }

    print(L10n.tr("==> Done: %@", appBundle.path))
    print(L10n.tr("Next step: %@", "cloudmachine-agent make-dmg"))
  }

  /// Short SHA of the commit we are building from.
  private func resolveCommit(projectRoot: URL) async -> String {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/git", ["-C", projectRoot.path, "rev-parse", "--short", "HEAD"]),
      result.succeeded
    else { return AppVersion.unknownCommit }
    let sha = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return sha.isEmpty ? AppVersion.unknownCommit : sha
  }

  /// Whether the tree has changes that are not in the commit.
  ///
  /// `status --porcelain` also covers untracked files - and rightly so: a new
  /// source file that nobody added goes into the binary just the same.
  private func uncommittedChanges(projectRoot: URL) async -> [String] {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/git", ["-C", projectRoot.path, "status", "--porcelain"]),
      result.succeeded
    else { return [] }
    return result.stdout.split(separator: "\n").map(String.init).filter {
      !$0.trimmingCharacters(in: .whitespaces).isEmpty
    }
  }

  private func resolveBuildNumber(projectRoot: URL) async -> String {
    // The release workflow computes it itself: v1.3.1 came out with a date
    // here instead of the commit count, and nothing said why git failed.
    if let given = ProcessInfo.processInfo.environment["CM_BUILD_NUMBER"]?
      .trimmingCharacters(in: .whitespacesAndNewlines), !given.isEmpty
    {
      return given
    }
    let result = try? await ProcessRunner.run(
      "/usr/bin/git", ["-C", projectRoot.path, "rev-list", "--count", "HEAD"])
    if let result, result.succeeded {
      let count = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
      if !count.isEmpty { return count }
    }
    print(
      L10n.tr(
        "==> WARNING: git rev-list failed (%@) - using the date as the build number.",
        result?.stderr.trimmingCharacters(in: .whitespacesAndNewlines) ?? "no answer"))
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmm"
    return formatter.string(from: Date())
  }
}
