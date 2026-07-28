import Foundation

/// Rozwiazuje wszystkie sciezki uzywane przez CloudMachine - config, logi,
/// punkty montowania, oraz (dla CLI/launchd) katalog z zasobami (`launchd/`,
/// `config/machines.example.json`) - niezaleznie od tego, czy kod dziala jako
/// spakowany .app (Resources sa read-only, obok binarki w Contents/MacOS), czy
/// jako `swift run`/skompilowana binarka CLI uruchomiona z drzewa zrodel.
///
/// Jedno miejsce prawdy dla GUI i CLI - wczesniej ta sama logika byla
/// zduplikowana (raz jako common.sh, raz czesciowo w CloudMachineController).
public enum CMPaths {
  /// Katalog z zasobami projektu (`launchd/`, `config/`) - w .app to
  /// `Contents/Resources`, w checkoutcie deweloperskim to korzen repo
  /// (rodzic `mac-app/`). `nil`, jesli zaden z tych katalogow nie istnieje
  /// (np. binarka uruchomiona calkowicie poza kontekstem projektu).
  public static var resourcesRoot: URL? {
    if let bundled = Bundle.main.resourceURL,
      FileManager.default.fileExists(atPath: bundled.appendingPathComponent("launchd").path)
    {
      return bundled
    }
    // Fallback dla `swift run`/`.build/*/cloudmachine-agent` w drzewie repo:
    // ta binarka siedzi pod mac-app/.build/<triple>/<config>/, wiec korzen
    // repo to 5 poziomow wyzej. Sprawdzamy tez plytsza sciezke na wypadek
    // uruchomienia bezposrednio z katalogu mac-app.
    let exeDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
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

  /// Sciezka do skompilowanej binarki `cloudmachine-agent`, ktora launchd ma
  /// wolac zamiast dawnych `.sh`. Rozwiazywana w 3 krokach:
  /// 1. Jesli TO WLASNIE MY jestesmy `cloudmachine-agent` (subkomenda
  ///    `install-launchd` odpalona z CLI) - wskazujemy na wlasna, biezaco
  ///    dzialajaca binarke. Dziala identycznie w .app i w checkoutcie deweloperskim.
  /// 2. W przeciwnym razie (GUI woła to z poziomu `CloudMachineApp`) -
  ///    binarka-siostra obok binarki GUI w tym samym bundlu `.app`.
  /// 3. Fallback dla GUI uruchomionego przez `swift run` w drzewie repo -
  ///    szukamy `cloudmachine-agent` w `.build/*/{release,debug}/` obok binarki GUI.
  public static var agentBinaryPath: URL? {
    let selfURL = URL(fileURLWithPath: CommandLine.arguments[0])
    if selfURL.lastPathComponent == "cloudmachine-agent" {
      return selfURL.standardizedFileURL
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
