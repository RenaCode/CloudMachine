import Foundation

/// Downloads the official rclone binary - port of `gdrive/install-rclone.sh`.
///
/// Installed in our own directory (`CMTooling.managedRclonePath`), without
/// touching Homebrew: the Mac's rclone signs in to Google Drive, writes the
/// `rclone.conf` that `vm-setup` copies into the machine, and measures usage.
/// The machine has its own rclone (`vm/cmsmb.yaml`).
public enum RcloneInstaller {

  /// The version the machine runs too (`RCLONE_VERSION` in `vm/cmsmb.yaml`;
  /// a test keeps the two equal). Pinned instead of "latest": an unattended
  /// install must not move to a build nobody has looked at.
  ///
  /// Only an install that is NEEDED (missing, too old, unreadable) uses it -
  /// a working rclone at or above `RcloneVersion.minimum` is never replaced,
  /// so a Mac that already has a newer one is not downgraded.
  public static let pinnedVersion = "v1.75.1"

  /// SHA256 of the release zips, from
  /// https://downloads.rclone.org/v1.75.1/SHA256SUMS. In the code, not
  /// downloaded: a checksum fetched from the same server as the archive proves
  /// nothing about a compromised server.
  public static let pinnedChecksums: [String: String] = [
    "osx-arm64": "c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f",
    "osx-amd64": "29253d0288b8fbbac46baad6e5f6add6cb01d462c79f10805bbd4631c4cdf82c",
  ]

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

    let version = pinnedVersion
    let arch = currentArch()
    let zipName = "rclone-\(version)-\(arch).zip"
    let zipURL = "https://downloads.rclone.org/\(version)/\(zipName)"
    let zipPath = workDir.appendingPathComponent(zipName)

    guard await download(zipURL, to: zipPath) else {
      return CMActionResult(succeeded: false, message: L10n.tr("Could not download %@.", zipName))
    }

    // Verifying the checksum is not decoration: we are downloading an
    // executable binary that will have access to the whole Google Drive.
    guard let expected = pinnedChecksums[arch] else {
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
    do {
      try swapIn(source: extracted, destination: destination)
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

  /// Copies `source` beside `destination` and swaps it in atomically: a failed
  /// copy leaves the old binary untouched, and two installs finishing together
  /// (the app and `install-rclone`) cannot fail with "file exists" - the loser
  /// of the race simply replaces the winner's file.
  static func swapIn(source: URL, destination: URL) throws {
    let fm = FileManager.default
    let staged = destination.deletingLastPathComponent()
      .appendingPathComponent(".rclone-new-\(UUID().uuidString)")
    do {
      try fm.copyItem(at: source, to: staged)
      try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: staged.path)
      if fm.fileExists(atPath: destination.path) {
        _ = try fm.replaceItemAt(destination, withItemAt: staged)
      } else {
        do {
          try fm.moveItem(at: staged, to: destination)
        } catch {
          // Someone created it between the check and the move.
          guard fm.fileExists(atPath: destination.path) else { throw error }
          _ = try fm.replaceItemAt(destination, withItemAt: staged)
        }
      }
      // `replaceItemAt` can keep the old file's mode; the binary must run.
      try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destination.path)
    } catch {
      try? fm.removeItem(at: staged)
      throw error
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
