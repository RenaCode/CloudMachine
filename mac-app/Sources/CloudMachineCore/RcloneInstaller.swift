import Foundation

/// Downloads the official rclone binary - port of `gdrive/install-rclone.sh`.
///
/// It exists because rclone from Homebrew is built without FUSE support and,
/// when asked to mount, refuses outright:
///
///     rclone mount is not supported on MacOS when rclone is installed via Homebrew
///
/// We install it alongside, in our own directory
/// (`CMTooling.managedRclonePath`), without touching the Homebrew installation
/// - the remaining, non-mounting code paths can keep using it.
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
        succeeded: false,
        message: L10n.tr("Cannot create the working directory: %@", error.localizedDescription))
    }

    guard let version = await latestVersion() else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not read the rclone version number."))
    }

    let arch = currentArch()
    let zipName = "rclone-\(version)-\(arch).zip"
    let zipURL = "https://downloads.rclone.org/\(version)/\(zipName)"
    let sumsURL = "https://downloads.rclone.org/\(version)/SHA256SUMS"
    let zipPath = workDir.appendingPathComponent(zipName)
    let sumsPath = workDir.appendingPathComponent("SHA256SUMS")

    guard await download(zipURL, to: zipPath), await download(sumsURL, to: sumsPath) else {
      return CMActionResult(succeeded: false, message: L10n.tr("Could not download %@.", zipName))
    }

    // Verifying the checksum is not decoration: we are downloading an
    // executable binary that will have access to the whole Google Drive.
    guard let expected = expectedChecksum(sumsFile: sumsPath, zipName: zipName) else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("No entry for %@ in SHA256SUMS.", zipName))
    }
    guard let actual = await checksum(of: zipPath) else {
      return CMActionResult(succeeded: false, message: L10n.tr("Could not compute the checksum."))
    }
    guard expected == actual else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@",
          expected, actual))
    }

    guard
      let unzip = try? await ProcessRunner.run(
        "/usr/bin/unzip", ["-oq", zipPath.path, "-d", workDir.path], timeout: 300),
      unzip.succeeded
    else {
      return CMActionResult(succeeded: false, message: L10n.tr("Could not unpack the archive."))
    }

    let extracted =
      workDir
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
        succeeded: false,
        message: L10n.tr("Could not install the binary: %@", error.localizedDescription))
    }

    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "Installed rclone %@ in %@ (SHA256 checksum matches).", version, destination.path))
  }

  // MARK: - Details

  static func currentArch() -> String {
    #if arch(arm64)
      return "osx-arm64"
    #else
      return "osx-amd64"
    #endif
  }

  /// Extracts the expected checksum for the given archive from the SHA256SUMS
  /// file. Pure function - testable without the network.
  public static func expectedChecksum(sumsContent: String, zipName: String) -> String? {
    for line in sumsContent.components(separatedBy: .newlines) {
      let parts = line.split(separator: " ", omittingEmptySubsequences: true)
      guard parts.count >= 2 else { continue }
      let name = parts.last.map(String.init)?.trimmingCharacters(
        in: CharacterSet(charactersIn: "*"))
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
