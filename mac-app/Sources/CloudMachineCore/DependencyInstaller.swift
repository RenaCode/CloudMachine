import Foundation

/// Port `install.sh` - instaluje `rclone` przez Homebrew. Zaklada, ze Homebrew
/// jest juz obecny (dla bootstrapowania samego Homebrew z zera - GUI ma
/// wlasny, bardziej rozbudowany krok wymagajacy dialogu autoryzacji, patrz
/// `CloudMachineController.installDependencies`).
///
/// `jq` NIE jest juz wymagane - bylo potrzebne wylacznie do parsowania JSON
/// w bashu; caly config parsuje teraz natywny `JSONDecoder` (patrz
/// `MachinesConfig`), wiec ta zaleznosc odpadla calkowicie przy migracji do Swift.
public enum DependencyInstaller {
  public static let requiredTools = ["rclone"]

  /// Sciezka do binarki brew, jesli Homebrew jest juz zainstalowany (Apple
  /// Silicon: /opt/homebrew, Intel: /usr/local).
  public static func resolvedBrewPath() -> String? {
    ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first {
      FileManager.default.isExecutableFile(atPath: $0)
    }
  }

  public static func missingTools() async -> [String] {
    var missing: [String] = []
    for tool in requiredTools {
      let result = try? await ProcessRunner.run("/usr/bin/which", [tool])
      if result == nil || result?.succeeded != true {
        missing.append(tool)
      }
    }
    return missing
  }

  @discardableResult
  public static func installRclone() async -> CMActionResult {
    guard let brewPath = resolvedBrewPath() else {
      return CMActionResult(
        succeeded: false,
        message: "Homebrew nie jest zainstalowany. Zainstaluj go recznie: https://brew.sh")
    }
    let result = try? await ProcessRunner.run(brewPath, ["install", "rclone"], timeout: 600)
    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: "Instalacja rclone nie powiodla sie: \(result?.stderr ?? "nieznany blad")")
    }
    return CMActionResult(succeeded: true, message: "Zainstalowano rclone.")
  }
}
