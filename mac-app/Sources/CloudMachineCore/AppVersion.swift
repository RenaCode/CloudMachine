import Foundation

/// Z czego dokladnie zbudowano to, co wlasnie dziala.
///
/// Numer wersji sam w sobie nie odpowiada na pytanie "czy zainstalowane jest
/// to, co w repozytorium" - `1.1.0` stoi w pliku VERSION miesiacami, a numer
/// budowy (liczba commitow) powtarza sie miedzy galeziami. Dlatego nosimy tez
/// SHA commitu i informacje, czy drzewo bylo brudne.
///
/// Powod jest konkretny: 13 wrz 2026 nie dalo sie odpowiedziec na pytanie
/// "czy zainstalowana jest najnowsza wersja" inaczej niz porownujac daty
/// plikow i diffujac drzewo git wzgledem zgadnietego commitu.
public struct AppVersion: Equatable {
  public let shortVersion: String
  public let build: String
  public let commit: String
  public let dirty: Bool

  public init(shortVersion: String, build: String, commit: String, dirty: Bool) {
    self.shortVersion = shortVersion
    self.build = build
    self.commit = commit
    self.dirty = dirty
  }

  /// Wartosc wstawiana przy budowaniu poza repozytorium git.
  public static let unknownCommit = "nieznany"

  /// Jedna linia do logu i do `--version`.
  public var summary: String {
    var text = "\(shortVersion) (\(build))"
    if commit != Self.unknownCommit {
      text += " \(commit)"
    }
    if dirty {
      text += " BRUDNE-DRZEWO"
    }
    return text
  }

  /// Czy da sie z tego jednoznacznie wskazac commit w repozytorium.
  ///
  /// Brudne drzewo znaczy, ze w binarce siedzi kod, ktorego nie ma w zadnym
  /// commicie - numer wersji wtedy KLAMIE i nie wolno go traktowac jako
  /// dowodu, ze zainstalowane jest to samo, co na galezi.
  public var isTraceable: Bool {
    commit != Self.unknownCommit && !dirty
  }
}

public enum AppVersionReader {

  static let commitKey = "CMGitCommit"
  static let dirtyKey = "CMGitDirty"

  /// Czysta wersja - odczyt ze slownika, zeby dalo sie sprawdzic testem bez
  /// budowania bundla.
  public static func parse(infoPlist: [String: Any]) -> AppVersion {
    let dirtyRaw = infoPlist[dirtyKey]
    let dirty: Bool
    switch dirtyRaw {
    case let flag as Bool: dirty = flag
    case let text as String: dirty = (text == "true" || text == "YES" || text == "1")
    default: dirty = false
    }
    return AppVersion(
      shortVersion: infoPlist["CFBundleShortVersionString"] as? String ?? "?",
      build: infoPlist["CFBundleVersion"] as? String ?? "?",
      commit: infoPlist[commitKey] as? String ?? AppVersion.unknownCommit,
      dirty: dirty)
  }

  /// Wersja binarki, ktora WLASNIE dziala.
  ///
  /// Szukamy `Contents/Info.plist` obok wykonywalnego pliku, a nie przez
  /// `Bundle.main`: agent to zwykly plik wykonywalny w `Contents/MacOS`, a nie
  /// aplikacja, wiec `Bundle.main` potrafi wskazac katalog zamiast bundla.
  /// Przy `swift run` zadnego bundla nie ma i to nie jest blad - zwracamy
  /// `nil`, a wolajacy mowi wprost, ze to build z drzewa roboczego.
  public static func current(
    executable: URL = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
  ) -> AppVersion? {
    let infoPlist =
      executable
      .deletingLastPathComponent()  // Contents/MacOS
      .deletingLastPathComponent()  // Contents
      .appendingPathComponent("Info.plist")
    guard let data = try? Data(contentsOf: infoPlist),
      let plist = try? PropertyListSerialization.propertyList(
        from: data, options: [], format: nil) as? [String: Any]
    else { return nil }
    return parse(infoPlist: plist)
  }
}
