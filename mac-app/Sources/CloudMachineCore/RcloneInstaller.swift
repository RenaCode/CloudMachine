import Foundation

/// Pobiera oficjalna binarke rclone - port `gdrive/install-rclone.sh`.
///
/// Istnieje, bo rclone z Homebrew jest zbudowane bez obslugi FUSE i przy
/// probie montowania odmawia wprost:
///
///     rclone mount is not supported on MacOS when rclone is installed via Homebrew
///
/// Instalujemy obok, we wlasnym katalogu (`CMTooling.managedRclonePath`), nie
/// ruszajac instalacji Homebrew - pozostale, niemontujace sciezki kodu moga
/// z niej dalej korzystac.
public enum RcloneInstaller {

  private static let versionURL = "https://downloads.rclone.org/version.txt"

  public static func install() async -> CMActionResult {
    let workDir = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cloudmachine-rclone-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: workDir) }

    do {
      try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
    } catch {
      return CMActionResult(
        succeeded: false, message: "Nie moge utworzyc katalogu roboczego: \(error.localizedDescription)")
    }

    guard let version = await latestVersion() else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie odczytac numeru wersji rclone.")
    }

    let arch = currentArch()
    let zipName = "rclone-\(version)-\(arch).zip"
    let zipURL = "https://downloads.rclone.org/\(version)/\(zipName)"
    let sumsURL = "https://downloads.rclone.org/\(version)/SHA256SUMS"
    let zipPath = workDir.appendingPathComponent(zipName)
    let sumsPath = workDir.appendingPathComponent("SHA256SUMS")

    guard await download(zipURL, to: zipPath), await download(sumsURL, to: sumsPath) else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie pobrac \(zipName).")
    }

    // Weryfikacja sumy nie jest ozdoba: sciagamy wykonywalna binarke, ktora
    // bedzie miala dostep do calego Dysku Google.
    guard let expected = expectedChecksum(sumsFile: sumsPath, zipName: zipName) else {
      return CMActionResult(succeeded: false, message: "Brak wpisu dla \(zipName) w SHA256SUMS.")
    }
    guard let actual = await checksum(of: zipPath) else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie policzyc sumy kontrolnej.")
    }
    guard expected == actual else {
      return CMActionResult(
        succeeded: false,
        message: "Suma SHA256 sie nie zgadza - NIE instaluje.\n  oczekiwana: \(expected)\n  policzona : \(actual)")
    }

    guard
      let unzip = try? await ProcessRunner.run(
        "/usr/bin/unzip", ["-oq", zipPath.path, "-d", workDir.path], timeout: 300),
      unzip.succeeded
    else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie rozpakowac archiwum.")
    }

    let extracted = workDir
      .appendingPathComponent("rclone-\(version)-\(arch)")
      .appendingPathComponent("rclone")
    let destination = CMTooling.managedRclonePath
    try? FileManager.default.removeItem(at: destination)
    do {
      try FileManager.default.copyItem(at: extracted, to: destination)
      try FileManager.default.setAttributes(
        [.posixPermissions: 0o755], ofItemAtPath: destination.path)
    } catch {
      return CMActionResult(
        succeeded: false, message: "Nie udalo sie zainstalowac binarki: \(error.localizedDescription)")
    }

    return CMActionResult(
      succeeded: true, message: "Zainstalowano rclone \(version) w \(destination.path) (suma SHA256 zgodna).")
  }

  // MARK: - Szczegoly

  static func currentArch() -> String {
    #if arch(arm64)
      return "osx-arm64"
    #else
      return "osx-amd64"
    #endif
  }

  /// Wyciaga oczekiwana sume dla danego archiwum z pliku SHA256SUMS.
  /// Czysta funkcja - testowalna bez sieci.
  public static func expectedChecksum(sumsContent: String, zipName: String) -> String? {
    for line in sumsContent.components(separatedBy: .newlines) {
      let parts = line.split(separator: " ", omittingEmptySubsequences: true)
      guard parts.count >= 2 else { continue }
      let name = parts.last.map(String.init)?.trimmingCharacters(in: CharacterSet(charactersIn: "*"))
      if name == zipName { return String(parts[0]) }
    }
    return nil
  }

  private static func expectedChecksum(sumsFile: URL, zipName: String) -> String? {
    guard let content = try? String(contentsOf: sumsFile, encoding: .utf8) else { return nil }
    return expectedChecksum(sumsContent: content, zipName: zipName)
  }

  private static func latestVersion() async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/curl", ["-fsSL", versionURL], timeout: 60),
      result.succeeded
    else { return nil }
    // Format: "rclone v1.75.1"
    return result.stdout.split(separator: " ").last.map {
      String($0).trimmingCharacters(in: .whitespacesAndNewlines)
    }
  }

  private static func download(_ url: String, to path: URL) async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/curl", ["-fsSL", "-o", path.path, url], timeout: 600)
    return result?.succeeded == true
  }

  private static func checksum(of path: URL) async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/shasum", ["-a", "256", path.path], timeout: 300),
      result.succeeded
    else { return nil }
    return result.stdout.split(separator: " ").first.map(String.init)
  }
}
