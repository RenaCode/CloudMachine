import Foundation

/// Pulls FUSE-T into CloudMachine, so that there is no separate application in
/// the system.
///
/// The official FUSE-T installer puts down `/Applications/fuse-t.app`,
/// libraries in `/usr/local/lib` and a server in
/// `/Library/Application Support/fuse-t`. That application hosts the FSKit
/// extension (`FskitSrvModule.appex`) - a backend we do not use anyway,
/// because we mount over NFS. So an icon and a package that do nothing are
/// left in the system.
///
/// Exactly two files are needed, both depending only on system libraries:
///   - `libfuse-t.dylib` - rclone opens it via dlopen,
///   - `go-nfsv4`        - the NFS server that actually holds the mount.
///
/// We point at the server via the `FUSE_NFSSRV_PATH` variable, so it can live
/// anywhere. The library cannot: rclone has absolute paths baked in
/// (`/usr/local/lib/libfuse-t.dylib`, `/usr/local/lib/libfuse.2.dylib`), and
/// `dlopen` on an absolute path ignores `DYLD_*`. That is why we leave a
/// SYMLINK to our copy there - `/usr/local/lib` belongs to a user in the admin
/// group, so root is not needed for that.
///
/// LICENSE: FUSE-T is not open-source software. The binary distribution is free
/// for non-commercial use provided the copyright notice is kept - that is why
/// we copy `LICENSE.rtf` next to the binaries. Bundling with commercial
/// software requires a separate license from the FUSE-T authors.
public enum FuseInstaller {

  private static let releasesAPI =
    "https://api.github.com/repos/macos-fuse-t/fuse-t/releases/latest"

  /// Path where rclone looks for the library. It cannot be changed.
  static let systemLibLink = "/usr/local/lib/libfuse-t.dylib"

  public static var isInstalled: Bool {
    FileManager.default.isExecutableFile(atPath: CMTooling.bundledNfsServer.path)
      && FileManager.default.fileExists(atPath: systemLibLink)
  }

  /// Recreates the symlink in `/usr/local/lib` if it has disappeared.
  ///
  /// Needed because the FUSE-T uninstaller deletes everything under that path
  /// - including our symlink. Without this, removing the separate fuse-t
  /// application would take the mount down with it, even though our copy of
  /// the library lies untouched in its place.
  @discardableResult
  public static func ensureSystemLink() -> Bool {
    guard FileManager.default.fileExists(atPath: CMTooling.bundledFuseLib.path) else {
      return false
    }
    if let target = try? FileManager.default.destinationOfSymbolicLink(atPath: systemLibLink),
      target == CMTooling.bundledFuseLib.path
    {
      return true
    }
    do {
      try linkSystemLibrary()
      CMLogger.log("Recreated the symlink \(systemLibLink) to the copy in CloudMachine")
      return true
    } catch {
      return false
    }
  }

  public static func install() async -> CMActionResult {
    let workDir = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cloudmachine-fuse-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: workDir) }
    try? FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)

    guard let (version, pkgURL) = await latestPackage() else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not determine the FUSE-T version."))
    }

    let pkgPath = workDir.appendingPathComponent("fuse-t.pkg")
    guard
      let download = try? await ProcessRunner.run(
        "/usr/bin/curl", ["-fsSL", "-o", pkgPath.path, pkgURL], timeout: 600),
      download.succeeded
    else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not download the FUSE-T package."))
    }

    let expanded = workDir.appendingPathComponent("expanded")
    guard
      let expand = try? await ProcessRunner.run(
        "/usr/sbin/pkgutil", ["--expand-full", pkgPath.path, expanded.path], timeout: 300),
      expand.succeeded
    else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not unpack the FUSE-T package."))
    }

    guard
      let dylib = findFile(
        under: expanded, matching: { $0.hasPrefix("libfuse-t") && $0.hasSuffix(".dylib") }),
      let server = findFile(under: expanded, matching: { $0.hasPrefix("go-nfsv4") })
    else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("The FUSE-T package does not contain the expected files."))
    }

    let destination = CMTooling.bundledFuseDir
    try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

    do {
      try copy(dylib, to: CMTooling.bundledFuseLib)
      try copy(server, to: CMTooling.bundledNfsServer)
      // The license requires keeping the copyright notice on redistribution.
      if let license = findFile(under: expanded, matching: { $0 == "LICENSE.rtf" }) {
        try? copy(license, to: destination.appendingPathComponent("LICENSE.rtf"))
      }
      try linkSystemLibrary()
    } catch {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Installing FUSE-T failed: %@", error.localizedDescription))
    }

    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "Installed FUSE-T %@ inside CloudMachine (%@).\nThe separate fuse-t application is no longer needed - you can remove it:\n  sudo \"/Library/Application Support/fuse-t/uninstall.sh\"",
        version, destination.path))
  }

  // MARK: - Details

  /// Replaces `/usr/local/lib/libfuse-t.dylib` with a symlink to our copy.
  ///
  /// Does not need root: `/usr/local/lib` belongs to the user and the admin
  /// group. If a real file from the official installer lies there, we remove
  /// it - our copy is bit-for-bit identical, because it comes from the same
  /// package.
  private static func linkSystemLibrary() throws {
    let fm = FileManager.default
    let linkURL = URL(fileURLWithPath: systemLibLink)
    try? fm.createDirectory(
      at: linkURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    if fm.fileExists(atPath: systemLibLink) || isSymlink(systemLibLink) {
      try fm.removeItem(at: linkURL)
    }
    try fm.createSymbolicLink(at: linkURL, withDestinationURL: CMTooling.bundledFuseLib)
  }

  private static func isSymlink(_ path: String) -> Bool {
    (try? FileManager.default.attributesOfItem(atPath: path)[.type] as? FileAttributeType)
      == FileAttributeType.typeSymbolicLink
  }

  private static func copy(_ source: URL, to destination: URL) throws {
    try? FileManager.default.removeItem(at: destination)
    try FileManager.default.copyItem(at: source, to: destination)
    try FileManager.default.setAttributes(
      [.posixPermissions: 0o755], ofItemAtPath: destination.path)
  }

  private static func findFile(under root: URL, matching: (String) -> Bool) -> URL? {
    guard let enumerator = FileManager.default.enumerator(atPath: root.path) else { return nil }
    for case let relative as String in enumerator {
      let name = (relative as NSString).lastPathComponent
      if matching(name) { return root.appendingPathComponent(relative) }
    }
    return nil
  }

  /// Version and URL of the package from the latest release on GitHub.
  static func latestPackage() async -> (version: String, url: String)? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/curl", ["-fsSL", releasesAPI], timeout: 60),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let tag = json["tag_name"] as? String,
      let assets = json["assets"] as? [[String: Any]]
    else { return nil }

    let pkg = assets.first {
      ($0["name"] as? String)?.hasSuffix(".pkg") == true
    }
    guard let url = pkg?["browser_download_url"] as? String else { return nil }
    return (tag, url)
  }
}
