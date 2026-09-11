import Foundation

/// Rozwiazuje zewnetrzne narzedzia potrzebne warstwie Google Drive i sprawdza,
/// czy w ogole nadaja sie do uzycia.
///
/// Istnieje, bo `ProcessRunner.runRclone` wola `/usr/bin/env rclone`, a to
/// trafia w rclone z Homebrew - zbudowane BEZ obslugi FUSE. Przy probie
/// montowania odmawia wprost:
///
///     rclone mount is not supported on MacOS when rclone is installed via Homebrew
///
/// Potrzebna jest oficjalna binarka z rclone.org. Trzymamy ja we wlasnym
/// katalogu, zeby nie kolidowac z instalacja Homebrew, z ktorej korzystaja
/// pozostale, niemontujace sciezki kodu.
public enum CMTooling {

  // MARK: - rclone

  /// Katalog na narzedzia zarzadzane przez CloudMachine.
  public static var toolsDir: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine/bin")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  /// Oficjalna binarka rclone z obsluga montowania.
  public static var managedRclonePath: URL {
    toolsDir.appendingPathComponent("rclone")
  }

  public static var hasManagedRclone: Bool {
    FileManager.default.isExecutableFile(atPath: managedRclonePath.path)
  }

  /// Uruchamia rclone, ktore NA PEWNO umie montowac. Kazda sciezka kodu
  /// dotykajaca montowania musi isc tedy, nie przez `ProcessRunner.runRclone`.
  public static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws
    -> ProcessResult
  {
    try await ProcessRunner.run(managedRclonePath.path, args, timeout: timeout)
  }

  // MARK: - FUSE

  /// Nasza kopia FUSE-T - zeby nie trzymac w systemie osobnej aplikacji.
  /// Patrz `FuseInstaller`.
  public static var bundledFuseDir: URL {
    let dir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cloudmachine/fuse")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }

  public static var bundledFuseLib: URL { bundledFuseDir.appendingPathComponent("libfuse-t.dylib") }

  /// Serwer NFS, ktory faktycznie trzyma montowanie. Jego sciezke da sie
  /// wskazac zmienna `FUSE_NFSSRV_PATH`, wiec moze lezec u nas.
  public static var bundledNfsServer: URL { bundledFuseDir.appendingPathComponent("go-nfsv4") }

  /// Sciezki, pod ktorymi moze siedziec FUSE. Wystarczy jedna.
  private static let fuseCandidates = [
    "/usr/local/lib/libfuse-t.dylib",
    "/usr/local/lib/libfuse.2.dylib",
    "/usr/local/lib/libfuse.dylib",
    "/Library/Filesystems/fuse-t.fs",
  ]

  /// Czy FUSE jest zainstalowane.
  ///
  /// UWAGA na pulapke, ktora juz raz zadzialala: pierwsza wersja tej kontroli
  /// w bashu robila `ls a b c` i sprawdzala kod wyjscia. `ls` zwraca blad, gdy
  /// brakuje KTOREJKOLWIEK ze sciezek, a nie gdy brakuje wszystkich - wiec
  /// odmawiala startu przy poprawnie zainstalowanym FUSE-T. Sprawdzamy po kolei.
  public static var hasFuse: Bool {
    // Wlasna kopia liczy sie tak samo jak instalacja systemowa: dowiazanie
    // w /usr/local/lib potrafimy odtworzyc sami (FuseInstaller.ensureSystemLink),
    // wiec jego chwilowy brak nie znaczy, ze FUSE nie ma. Deinstalator FUSE-T
    // kasuje to dowiazanie przy usuwaniu osobnej aplikacji - bez tego warunku
    // status melduje wtedy brak FUSE, mimo ze montowanie dziala.
    if FileManager.default.fileExists(atPath: bundledFuseLib.path) { return true }
    return fuseCandidates.contains { FileManager.default.fileExists(atPath: $0) }
  }

  // MARK: - Diagnostyka gotowosci

  public struct Readiness {
    public var ready: Bool { missing.isEmpty }
    /// Czego brakuje, w kolejnosci, w jakiej trzeba to naprawic.
    public var missing: [String]
    /// Polecenia, ktore to naprawiaja - gotowe do pokazania uzytkownikowi.
    public var remedies: [String]
  }

  public static func checkReadiness() -> Readiness {
    // Sprawdzenie jest tez okazja do naprawy - dowiazanie bywa kasowane przez
    // deinstalator FUSE-T i nie ma powodu czekac z tym do nastepnego startu.
    FuseInstaller.ensureSystemLink()

    var missing: [String] = []
    var remedies: [String] = []

    if !hasManagedRclone {
      missing.append("rclone z obsluga montowania")
      remedies.append("cloudmachine-agent install-rclone")
    }
    if !hasFuse {
      missing.append("FUSE")
      remedies.append("cloudmachine-agent install-fuse")
    }
    return Readiness(missing: missing, remedies: remedies)
  }
}
