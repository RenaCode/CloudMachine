import Foundation

/// Generuje pliki `.plist` z podstawiona sciezka do skompilowanej binarki
/// `cloudmachine-agent` i instaluje je jako LaunchAgents (sesja zalogowanego
/// uzytkownika) - instaluje generycznie KAZDY szablon `*.plist.template`
/// znaleziony w `launchd/` (obecnie `verify-watchdog` i `archive-watchdog`).
/// W usunietej wczesniejszej architekturze sieciowego mountu NFS istnialy tu
/// dodatkowo szablony dla mount/backup/quota, ktore odpadly wraz z nia.
public enum LaunchdInstaller {
  public static var launchAgentsDir: URL {
    FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents")
  }

  public static func install() async -> CMActionResult {
    // Zeby polecenia z dokumentacji dzialaly z terminala, a nie konczyly sie
    // "command not found" - binarka siedzi w bundlu aplikacji.
    CMTooling.linkCommandIntoPath()

    // Instalacja przeladowuje agentow, w tym ten trzymajacy montowanie. Zrobienie
    // tego przy podpietym obrazie wyrywa mu podloge w trakcie - a odpiecie jest
    // zapisem, ktory musi jeszcze doleciec na Dysk. Popelnilem ten blad trzy razy
    // z rzedu, wiec nie polegamy juz na pamietaniu o nim.
    if BackupImageService.isAttached {
      CMLogger.log("Instalacja agentow: najpierw odpinam obraz i czekam na wysylke")
      let detached = await BackupImageService.detach()
      CMLogger.log("Instalacja agentow: \(detached.message)")
      if !detached.succeeded {
        return CMActionResult(
          succeeded: false,
          message: """
            Nie odpieto obrazu przed przeladowaniem agentow - przerywam, zeby nie \
            stracic danych czekajacych w buforze.
            \(detached.message)
            """)
      }
    }

    guard let templatesDir = CMPaths.launchdTemplatesDir else {
      return CMActionResult(
        succeeded: false, message: "Nie znaleziono katalogu launchd/ z szablonami.")
    }
    guard let resolvedAgentBin = CMPaths.agentBinaryPath else {
      return CMActionResult(
        succeeded: false, message: "Nie znaleziono skompilowanej binarki cloudmachine-agent.")
    }
    // PRZERYWAMY, nie ostrzegamy. Wczesniej nieudane odlozenie binarki
    // konczylo sie wpisem "OSTRZEZENIE" w logu i dokonczeniem instalacji -
    // launchd dostawal sciezke do `.build/`, ktora kolejny `swift build` albo
    // `git clean` kasuje spod dzialajacych agentow. Agent, ktory znika, to
    // backup, ktory przestaje powstawac, a jedynym sladem jest linia w logu,
    // do ktorej nikt nie zaglada. Instalacja bez stabilnej binarki jest gorsza
    // niz brak instalacji, bo wyglada na udana.
    let agentBin: URL
    do {
      agentBin = try stableAgentBinaryPath(resolvedFrom: resolvedAgentBin)
    } catch let error as NoStableBinary {
      return CMActionResult(
        succeeded: false,
        message: """
          PRZERWANO: nie udalo sie odlozyc cloudmachine-agent w stabilnym miejscu
          (\(error.attemptedPath)) - najczesciej brak miejsca albo uprawnien.
          NIE instaluje agentow wskazujacych na \(error.fallbackPath): ta sciezka
          znika przy kolejnym `swift build` albo `git clean`, a backupy ustaja
          bez zadnego widocznego sygnalu.
          """)
    } catch {
      return CMActionResult(
        succeeded: false, message: "PRZERWANO: \(error.localizedDescription)")
    }

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

  /// Rzucane, gdy nie da sie odlozyc binarki w stabilnym miejscu. Wolajacy ma
  /// wtedy PRZERWAC instalacje, nie dokonczyc jej gorszym wariantem.
  struct NoStableBinary: Error {
    var attemptedPath: String
    var fallbackPath: String
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
  ///
  /// Rzuca `NoStableBinary`, gdy sie nie uda - patrz `install()`.
  private static func stableAgentBinaryPath(resolvedFrom resolved: URL) throws -> URL {
    guard resolved.path.contains("/.build/") else { return resolved }
    let stableDir = CMPaths.appSupportDir.appendingPathComponent("bin")
    try? FileManager.default.createDirectory(at: stableDir, withIntermediateDirectories: true)
    let stableBin = stableDir.appendingPathComponent("cloudmachine-agent")

    // Kopiujemy OBOK, a stara kopie podmieniamy dopiero po udanym zapisie.
    // Poprzednia wersja kasowala stary plik PRZED kopiowaniem, wiec nieudane
    // kopiowanie zostawialo instalacje bez stabilnej binarki w ogole.
    let staging = stableDir.appendingPathComponent("cloudmachine-agent.nowy")
    try? FileManager.default.removeItem(at: staging)
    guard (try? FileManager.default.copyItem(at: resolved, to: staging)) != nil else {
      throw NoStableBinary(attemptedPath: stableBin.path, fallbackPath: resolved.path)
    }
    try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: staging.path)
    guard
      (try? FileManager.default.replaceItemAt(stableBin, withItemAt: staging)) != nil
        || (try? FileManager.default.moveItem(at: staging, to: stableBin)) != nil
    else {
      try? FileManager.default.removeItem(at: staging)
      throw NoStableBinary(attemptedPath: stableBin.path, fallbackPath: resolved.path)
    }
    return stableBin
  }

  public static func isInstalled(label: String) async -> Bool {
    guard let result = try? await ProcessRunner.run("/bin/launchctl", ["list"]) else {
      return false
    }
    return result.stdout.contains(label)
  }
}
