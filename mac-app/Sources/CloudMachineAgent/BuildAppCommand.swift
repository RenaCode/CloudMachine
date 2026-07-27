import ArgumentParser
import CloudMachineCore
import Foundation

/// Port `scripts/build-app.sh` - buduje `CloudMachine.app` (Release) z pakietu
/// Swift: GUI (`CloudMachineApp`) ORAZ CLI (`cloudmachine-agent`, wolany przez
/// launchd zamiast dawnych skryptow bash) trafiaja jako dwie binarki w tym
/// samym `Contents/MacOS/`, plus szablony launchd/config jako Resources -
/// appka jest wiec w pelni samodzielna, nie wymaga osobno sklonowanego repo obok.
///
/// Podpisuje lokalnym certyfikatem (patrz `setup-signing-cert`), jesli
/// istnieje - a w przeciwnym razie ad-hoc (bez konta Apple Developer). Podpis
/// ad-hoc generuje NOWY hash tozsamosci przy kazdym rebuildzie, wiec macOS
/// cofa wczesniej przyznane Full Disk Access po kazdym rebuildzie; stabilny
/// lokalny certyfikat rozwiazuje ten problem raz na zawsze.
struct BuildApp: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "build-app",
    abstract:
      "Buduje CloudMachine.app (Release) - GUI + cloudmachine-agent w Contents/MacOS/, plus launchd/config jako Resources."
  )

  func run() async throws {
    let macAppRoot = BuildPaths.macAppRoot
    let projectRoot = BuildPaths.projectRoot
    let appName = "CloudMachine"
    let buildDir = macAppRoot.appendingPathComponent("build")
    let appBundle = buildDir.appendingPathComponent("\(appName).app")
    let fm = FileManager.default

    let version =
      (try? String(contentsOf: macAppRoot.appendingPathComponent("VERSION"), encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? "1.0.0"
    let buildNumber = await resolveBuildNumber(projectRoot: projectRoot)

    print(
      "==> Buduje CloudMachineApp + cloudmachine-agent (release) - wersja \(version) (\(buildNumber))"
    )
    let buildStatus = try await InteractiveProcess.run(
      "/usr/bin/swift", ["build", "-c", "release", "--package-path", macAppRoot.path])
    guard buildStatus == 0 else {
      print("BLAD: swift build zakonczyl sie kodem \(buildStatus).")
      throw ExitCode.failure
    }

    let appBinPath = macAppRoot.appendingPathComponent(".build/release/\(appName)App")
    let agentBinPath = macAppRoot.appendingPathComponent(".build/release/cloudmachine-agent")
    for path in [appBinPath, agentBinPath] {
      guard fm.fileExists(atPath: path.path) else {
        print("BLAD: nie znaleziono zbudowanej binarki pod \(path.path)")
        throw ExitCode.failure
      }
    }

    print("==> Skladam .app bundle w \(appBundle.path)")
    try? fm.removeItem(at: appBundle)
    let macOSDir = appBundle.appendingPathComponent("Contents/MacOS")
    let resourcesDir = appBundle.appendingPathComponent("Contents/Resources")
    try fm.createDirectory(at: macOSDir, withIntermediateDirectories: true)
    try fm.createDirectory(at: resourcesDir, withIntermediateDirectories: true)

    try fm.copyItem(at: appBinPath, to: macOSDir.appendingPathComponent(appName))
    // cloudmachine-agent siedzi OBOK glownej binarki GUI w tym samym
    // Contents/MacOS - to ta binarka wola launchd (patrz
    // launchd/*.plist.template, __CM_AGENT_BIN__) i to na nia wskazuje
    // CMPaths.agentBinaryPath, gdy GUI instaluje agentow.
    try fm.copyItem(at: agentBinPath, to: macOSDir.appendingPathComponent("cloudmachine-agent"))

    let infoPlistTemplate = macAppRoot.appendingPathComponent("Resources/Info.plist")
    var infoPlistContent = try String(contentsOf: infoPlistTemplate, encoding: .utf8)
    infoPlistContent = infoPlistContent.replacingOccurrences(of: "__CM_VERSION__", with: version)
    infoPlistContent = infoPlistContent.replacingOccurrences(of: "__CM_BUILD__", with: buildNumber)
    try infoPlistContent.write(
      to: appBundle.appendingPathComponent("Contents/Info.plist"), atomically: true, encoding: .utf8
    )

    // Bundlujemy szablony launchd i przykladowy config jako Resources -
    // to samo, czego uzywa wersja CLI-only (patrz CMPaths.resourcesRoot).
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
        "BLAD: brak Resources/AppIcon.icns - wygeneruj go: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns"
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
        "==> Podpisuje lokalnym certyfikatem '\(certName)' (Pelny dostep do dysku przetrwa kolejne przebudowy)"
      )
      signStatus = try await InteractiveProcess.run(
        "/usr/bin/codesign", ["--force", "--deep", "--sign", certName, appBundle.path])
    } else {
      print(
        "==> Podpisuje ad-hoc (bez konta Apple Developer) - uruchom raz 'cloudmachine-agent setup-signing-cert', zeby uprawnienia TCC przetrwaly kolejne przebudowy"
      )
      signStatus = try await InteractiveProcess.run(
        "/usr/bin/codesign", ["--force", "--deep", "--sign", "-", appBundle.path])
    }
    guard signStatus == 0 else {
      print("BLAD: codesign zakonczyl sie kodem \(signStatus).")
      throw ExitCode.failure
    }

    print("==> Gotowe: \(appBundle.path)")
    print("Nastepny krok: cloudmachine-agent make-dmg")
  }

  private func resolveBuildNumber(projectRoot: URL) async -> String {
    if let result = try? await ProcessRunner.run(
      "/usr/bin/git", ["-C", projectRoot.path, "rev-list", "--count", "HEAD"]),
      result.succeeded
    {
      let count = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
      if !count.isEmpty { return count }
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmm"
    return formatter.string(from: Date())
  }
}
