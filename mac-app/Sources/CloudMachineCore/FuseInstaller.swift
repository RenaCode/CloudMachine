import Foundation

/// Wciaga FUSE-T do CloudMachine, zeby nie bylo osobnej aplikacji w systemie.
///
/// Oficjalny instalator FUSE-T stawia `/Applications/fuse-t.app`, biblioteki
/// w `/usr/local/lib` i serwer w `/Library/Application Support/fuse-t`. Ta
/// aplikacja jest hostem rozszerzenia FSKit (`FskitSrvModule.appex`) - backendu,
/// ktorego u nas i tak nie uzywamy, bo montujemy przez NFS. Zostaje wiec w
/// systemie ikona i pakiet, ktore nic nie robia.
///
/// Potrzebne sa dokladnie dwa pliki, oba zalezne wylacznie od bibliotek
/// systemowych:
///   - `libfuse-t.dylib` - rclone otwiera ja przez dlopen,
///   - `go-nfsv4`        - serwer NFS, ktory faktycznie trzyma montowanie.
///
/// Serwer wskazujemy zmienna `FUSE_NFSSRV_PATH`, wiec moze lezec gdziekolwiek.
/// Biblioteka nie: rclone ma zaszyte sciezki bezwzgledne
/// (`/usr/local/lib/libfuse-t.dylib`, `/usr/local/lib/libfuse.2.dylib`),
/// a `dlopen` na sciezce bezwzglednej ignoruje `DYLD_*`. Dlatego zostawiamy tam
/// DOWIAZANIE do naszej kopii - `/usr/local/lib` nalezy do uzytkownika
/// z grupy admin, wiec nie trzeba do tego roota.
///
/// LICENCJA: FUSE-T nie jest oprogramowaniem otwartym. Binarna dystrybucja jest
/// darmowa do uzytku niekomercyjnego pod warunkiem zachowania noty
/// o prawach autorskich - dlatego kopiujemy `LICENSE.rtf` obok binariow.
/// Bundlowanie z oprogramowaniem komercyjnym wymaga osobnej licencji od
/// autorow FUSE-T.
public enum FuseInstaller {

  private static let releasesAPI =
    "https://api.github.com/repos/macos-fuse-t/fuse-t/releases/latest"

  /// Sciezka, pod ktora rclone szuka biblioteki. Nie da sie jej zmienic.
  static let systemLibLink = "/usr/local/lib/libfuse-t.dylib"

  public static var isInstalled: Bool {
    FileManager.default.isExecutableFile(atPath: CMTooling.bundledNfsServer.path)
      && FileManager.default.fileExists(atPath: systemLibLink)
  }

  /// Odtwarza dowiazanie w `/usr/local/lib`, jesli zniknelo.
  ///
  /// Potrzebne, bo deinstalator FUSE-T kasuje wszystko pod ta sciezka - razem
  /// z naszym dowiazaniem. Bez tego usuniecie osobnej aplikacji fuse-t
  /// zabieraloby ze soba montowanie, mimo ze nasza kopia biblioteki lezy
  /// nietknieta na swoim miejscu.
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
      CMLogger.log("Odtworzono dowiazanie \(systemLibLink) do kopii w CloudMachine")
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
      return CMActionResult(succeeded: false, message: "Nie udalo sie ustalic wersji FUSE-T.")
    }

    let pkgPath = workDir.appendingPathComponent("fuse-t.pkg")
    guard
      let download = try? await ProcessRunner.run(
        "/usr/bin/curl", ["-fsSL", "-o", pkgPath.path, pkgURL], timeout: 600),
      download.succeeded
    else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie pobrac pakietu FUSE-T.")
    }

    let expanded = workDir.appendingPathComponent("expanded")
    guard
      let expand = try? await ProcessRunner.run(
        "/usr/sbin/pkgutil", ["--expand-full", pkgPath.path, expanded.path], timeout: 300),
      expand.succeeded
    else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie rozpakowac pakietu FUSE-T.")
    }

    guard
      let dylib = findFile(under: expanded, matching: { $0.hasPrefix("libfuse-t") && $0.hasSuffix(".dylib") }),
      let server = findFile(under: expanded, matching: { $0.hasPrefix("go-nfsv4") })
    else {
      return CMActionResult(
        succeeded: false, message: "W pakiecie FUSE-T nie ma spodziewanych plikow.")
    }

    let destination = CMTooling.bundledFuseDir
    try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

    do {
      try copy(dylib, to: CMTooling.bundledFuseLib)
      try copy(server, to: CMTooling.bundledNfsServer)
      // Licencja wymaga zachowania noty o prawach autorskich przy redystrybucji.
      if let license = findFile(under: expanded, matching: { $0 == "LICENSE.rtf" }) {
        try? copy(license, to: destination.appendingPathComponent("LICENSE.rtf"))
      }
      try linkSystemLibrary()
    } catch {
      return CMActionResult(
        succeeded: false, message: "Instalacja FUSE-T nie powiodla sie: \(error.localizedDescription)")
    }

    return CMActionResult(
      succeeded: true,
      message: """
        Zainstalowano FUSE-T \(version) wewnatrz CloudMachine (\(destination.path)).
        Osobna aplikacja fuse-t nie jest juz potrzebna - mozesz ja usunac:
          sudo "/Library/Application Support/fuse-t/uninstall.sh"
        """)
  }

  // MARK: - Szczegoly

  /// Podmienia `/usr/local/lib/libfuse-t.dylib` na dowiazanie do naszej kopii.
  ///
  /// Nie wymaga roota: `/usr/local/lib` nalezy do uzytkownika i grupy admin.
  /// Jesli lezy tam prawdziwy plik z oficjalnego instalatora, usuwamy go -
  /// nasza kopia jest bit w bit taka sama, bo pochodzi z tego samego pakietu.
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

  /// Wersja i adres pakietu z ostatniego wydania na GitHubie.
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
