import XCTest

@testable import CloudMachineCore

/// Testy odczytu wersji.
///
/// Pytanie, na ktore ma odpowiadac ten kod, brzmi "czy dziala to, co w
/// repozytorium". Kazdy test wstrzykuje wiec plist, ktory KLAMALBY, gdyby
/// czytac tylko numer wersji.
final class AppVersionTests: XCTestCase {

  private func plist(
    version: String = "1.1.0", build: String = "67",
    commit: String? = "abc1234", dirty: Any? = nil
  ) -> [String: Any] {
    var dict: [String: Any] = [
      "CFBundleShortVersionString": version,
      "CFBundleVersion": build,
    ]
    if let commit { dict[AppVersionReader.commitKey] = commit }
    if let dirty { dict[AppVersionReader.dirtyKey] = dirty }
    return dict
  }

  func testCzytaWersjeBudoweICommit() {
    let version = AppVersionReader.parse(infoPlist: plist())
    XCTAssertEqual(version.shortVersion, "1.1.0")
    XCTAssertEqual(version.build, "67")
    XCTAssertEqual(version.commit, "abc1234")
    XCTAssertFalse(version.dirty)
  }

  /// `build-app` wpisuje "true"/"false" jako STRING (podstawienie w szablonie
  /// XML), ale recznie poprawiony plist moze miec <true/>. Oba musza znaczyc
  /// to samo, inaczej brudny build zameldowalby sie jako czysty.
  func testBrudneDrzewoRozpoznaneZeStringaIZBoola() {
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist(dirty: "true")).dirty)
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist(dirty: true)).dirty)
    XCTAssertFalse(AppVersionReader.parse(infoPlist: plist(dirty: "false")).dirty)
    XCTAssertFalse(AppVersionReader.parse(infoPlist: plist(dirty: false)).dirty)
  }

  /// Stary bundel, zbudowany przed dodaniem tych kluczy, nie moze udawac, ze
  /// wie, z czego powstal.
  func testStaryBundelBezCommituNieUdajeZeWie() {
    let version = AppVersionReader.parse(infoPlist: plist(commit: nil))
    XCTAssertEqual(version.commit, AppVersion.unknownCommit)
    XCTAssertFalse(version.isTraceable, "Bez commitu nie da sie wskazac zrodla")
  }

  /// Sedno: brudne drzewo znaczy, ze w binarce jest kod spoza commitu, wiec
  /// numer commitu NIE dowodzi zgodnosci z galezia.
  func testBrudnyBuildNieJestIdentyfikowalnyMimoZnanegoCommitu() {
    let version = AppVersionReader.parse(infoPlist: plist(commit: "abc1234", dirty: "true"))
    XCTAssertEqual(version.commit, "abc1234")
    XCTAssertFalse(version.isTraceable, "Brudne drzewo unieważnia commit jako dowod")
  }

  func testCzystyBuildZCommitemJestIdentyfikowalny() {
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist()).isTraceable)
  }

  func testPodsumowanieNiesieCommitIOstrzezenie() {
    XCTAssertEqual(AppVersionReader.parse(infoPlist: plist()).summary, "1.1.0 (67) abc1234")
    XCTAssertTrue(
      AppVersionReader.parse(infoPlist: plist(dirty: "true")).summary.contains("BRUDNE-DRZEWO"))
    XCTAssertFalse(
      AppVersionReader.parse(infoPlist: plist(commit: nil)).summary.contains(
        AppVersion.unknownCommit),
      "Brak commitu nie ma zasmiecac jednolinijkowca slowem 'nieznany'")
  }
}
