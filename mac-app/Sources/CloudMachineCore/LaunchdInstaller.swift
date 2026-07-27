import Foundation

/// Port `install-launchd.sh` - generuje pliki `.plist` z podstawiona sciezka
/// do skompilowanej binarki `cloudmachine-agent` i instaluje je jako
/// LaunchAgents (sesja zalogowanego uzytkownika - montowanie NFS musi dziac
/// sie w kontekscie uzytkownika, nie systemowym).
public enum LaunchdInstaller {
  public static var launchAgentsDir: URL {
    FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents")
  }

  public static func install() async -> CMActionResult {
    guard let templatesDir = CMPaths.launchdTemplatesDir else {
      return CMActionResult(
        succeeded: false, message: "Nie znaleziono katalogu launchd/ z szablonami.")
    }
    guard let resolvedAgentBin = CMPaths.agentBinaryPath else {
      return CMActionResult(
        succeeded: false, message: "Nie znaleziono skompilowanej binarki cloudmachine-agent.")
    }
    let agentBin = stableAgentBinaryPath(resolvedFrom: resolvedAgentBin)

    try? FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)

    // Migracja: starsza wersja instalowala oddzielny agent
    // "com.renacode.cloudmachine.mount", zastapiony dawno przez
    // mount-watchdog - usuwamy, jesli nadal zaladowany na czyims Maku.
    let oldMountPlist = launchAgentsDir.appendingPathComponent(
      "com.renacode.cloudmachine.mount.plist")
    if FileManager.default.fileExists(atPath: oldMountPlist.path) {
      CMLogger.log(
        "Usuwam przestarzaly agent com.renacode.cloudmachine.mount (zastapiony przez mount-watchdog)."
      )
      _ = try? await ProcessRunner.run("/bin/launchctl", ["unload", oldMountPlist.path])
      try? FileManager.default.removeItem(at: oldMountPlist)
    }

    guard
      let templates = try? FileManager.default.contentsOfDirectory(
        at: templatesDir, includingPropertiesForKeys: nil)
    else {
      return CMActionResult(
        succeeded: false, message: "Nie udalo sie wylistowac szablonow w \(templatesDir.path).")
    }

    var installedLabels: [String] = []
    for template in templates.filter({ $0.pathExtension == "template" }) {
      let destName = template.deletingPathExtension().lastPathComponent
      let destURL = launchAgentsDir.appendingPathComponent(destName)

      guard var content = try? String(contentsOf: template, encoding: .utf8) else { continue }
      content = content.replacingOccurrences(of: "__CM_AGENT_BIN__", with: agentBin.path)
      content = content.replacingOccurrences(of: "__CM_LOG_DIR__", with: CMPaths.logDir.path)
      try? content.write(to: destURL, atomically: true, encoding: .utf8)
      CMLogger.log("Wygenerowano \(destURL.path)")

      let label = destURL.deletingPathExtension().lastPathComponent
      _ = try? await ProcessRunner.run("/bin/launchctl", ["unload", destURL.path])
      let loadResult = try? await ProcessRunner.run("/bin/launchctl", ["load", "-w", destURL.path])
      if loadResult?.succeeded == true {
        installedLabels.append(label)
        CMLogger.log("Zaladowano \(label) przez launchctl")
      }
    }

    guard !installedLabels.isEmpty else {
      return CMActionResult(
        succeeded: false, message: "Nie udalo sie zaladowac zadnego agenta launchd.")
    }
    return CMActionResult(
      succeeded: true, message: "Zainstalowano agentow: \(installedLabels.joined(separator: ", "))")
  }

  /// Jesli `resolved` wskazuje do wewnatrz `.build/` checkoutu
  /// deweloperskiego (przypadek 3 w `CMPaths.agentBinaryPath` - GUI/CLI
  /// odpalone przez `swift run` w drzewie repo), zywa automatyzacja launchd
  /// wskazywalaby WPROST na plik, ktory kazdy kolejny `swift build`/`git
  /// clean` w repo moze podmienic albo skasowac (zaobserwowane realnie: to
  /// dokladnie sciezka, ktora prowadzila produkcyjne watchdogi tej
  /// instalacji). Kopiujemy wiec binarke RAZ, przy kazdej instalacji, do
  /// stabilnej lokalizacji poza drzewem repo - launchd wskazuje na TA kopie.
  /// Binarka spakowana w .app (przypadek 1/2) jest juz stabilna sama w
  /// sobie i nie wymaga kopiowania.
  private static func stableAgentBinaryPath(resolvedFrom resolved: URL) -> URL {
    guard resolved.path.contains("/.build/") else { return resolved }
    let stableDir = CMPaths.appSupportDir.appendingPathComponent("bin")
    try? FileManager.default.createDirectory(at: stableDir, withIntermediateDirectories: true)
    let stableBin = stableDir.appendingPathComponent("cloudmachine-agent")
    try? FileManager.default.removeItem(at: stableBin)
    guard (try? FileManager.default.copyItem(at: resolved, to: stableBin)) != nil else {
      return resolved
    }
    try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: stableBin.path)
    return stableBin
  }

  public static func isInstalled(label: String) async -> Bool {
    guard let result = try? await ProcessRunner.run("/bin/launchctl", ["list"]) else {
      return false
    }
    return result.stdout.contains(label)
  }
}
