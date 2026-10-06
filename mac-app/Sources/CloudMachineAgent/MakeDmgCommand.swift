import ArgumentParser
import CloudMachineCore
import Foundation

/// Port of `scripts/make-dmg.sh` - packs the built `CloudMachine.app` (see
/// `build-app`) into a `.dmg` installer with a draggable shortcut to `/Applications`.
struct MakeDmg: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "make-dmg",
    abstract: L10n.tr("Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.")
  )

  func run() async throws {
    let macAppRoot = BuildPaths.macAppRoot
    let appName = "CloudMachine"
    let buildDir = macAppRoot.appendingPathComponent("build")
    let appBundle = buildDir.appendingPathComponent("\(appName).app")
    let stagingDir = buildDir.appendingPathComponent("dmg-staging")
    let version = BuildPaths.version
    let dmgPath = buildDir.appendingPathComponent("\(appName)-\(version).dmg")
    let fm = FileManager.default

    guard fm.fileExists(atPath: appBundle.path) else {
      print(
        L10n.tr(
          "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first", appBundle.path))
      throw ExitCode.failure
    }

    print(L10n.tr("==> Preparing the staging folder"))
    try? fm.removeItem(at: stagingDir)
    try? fm.removeItem(at: dmgPath)
    try fm.createDirectory(at: stagingDir, withIntermediateDirectories: true)
    try fm.copyItem(at: appBundle, to: stagingDir.appendingPathComponent("\(appName).app"))
    try fm.createSymbolicLink(
      at: stagingDir.appendingPathComponent("Applications"),
      withDestinationURL: URL(fileURLWithPath: "/Applications"))

    print(L10n.tr("==> Creating %@", dmgPath.path))
    let status = try await InteractiveProcess.run(
      "/usr/bin/hdiutil",
      [
        "create", "-volname", appName, "-srcfolder", stagingDir.path, "-ov", "-format", "UDZO",
        dmgPath.path,
      ])
    try? fm.removeItem(at: stagingDir)
    guard status == 0 else {
      print(L10n.tr("ERROR: hdiutil exited with code %@.", "\(status)"))
      throw ExitCode.failure
    }

    print(L10n.tr("==> Done: %@", dmgPath.path))
    print("")
    print(L10n.tr("On first launch (the app is not signed with an Apple Developer account):"))
    print(L10n.tr("1. Open %@ and drag CloudMachine.app to Applications.", dmgPath.path))
    print(
      L10n.tr(
        "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\")."
      ))
    print(L10n.tr("3. Later launches work normally, with a double-click."))
  }
}
