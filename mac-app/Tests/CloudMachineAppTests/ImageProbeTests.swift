import XCTest

@testable import CloudMachineCore

/// Sonda czytelnosci obrazu. Kazdy werdykt ma probke, ktora go wymusza -
/// inaczej sonda mowiaca zawsze "readable" przeszlaby wszystkie testy.
final class ImageProbeTests: XCTestCase {

  private let manifest = URL(fileURLWithPath: "/Volumes/X/backup_manifest.plist")
  private let other = URL(fileURLWithPath: "/Volumes/X/other.plist")

  func testOdczytBajtuZnaczyZywy() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .readable)
  }

  /// Dokladnie ten przypadek z 22 wrz 2026: listowanie dziala, odczyt daje ENXIO.
  func testENXIOZnaczyMartwy() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in ENXIO })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  func testEIOTezZnaczyMartwy() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in EIO })
    XCTAssertEqual(verdict, .dead(errno: EIO))
  }

  /// Blad wlasciwy dla pliku (brak uprawnien) nie jest awaria wolumenu -
  /// sonda ma sprobowac nastepnego pliku, a nie oglosic smierci.
  func testEACCESNaJednymPlikuNieZnaczyMartwy() {
    let verdict = ImageProbe.probe(
      regularFiles: { [manifest, other] },
      readFirstByte: { $0 == self.manifest ? EACCES : nil })
    XCTAssertEqual(verdict, .readable)
  }

  func testSamePlikiZBledamiPlikuToBrakProbki() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in EACCES })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  /// Swiezy wolumen przed pierwsza kopia - nie ma czego czytac, wiec NIE
  /// alarmujemy. Alarm bez dowodu jest gorszy niz brak alarmu.
  func testPustyKatalogToBrakProbki() {
    let verdict = ImageProbe.probe(regularFiles: { [] }, readFirstByte: { _ in ENXIO })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  func testNieczytelneListowanieToBrakProbki() {
    struct Boom: Error {}
    let verdict = ImageProbe.probe(regularFiles: { throw Boom() }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  // MARK: - Zywa sciezka na prawdziwym katalogu

  func testPrawdziwyOdczytNaKataloguTymczasowym() throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }

    XCTAssertEqual(ImageProbe.probe(volume: dir), .nothingToProbe, "pusty katalog")

    try FileManager.default.createDirectory(
      at: dir.appendingPathComponent("podkatalog"), withIntermediateDirectories: true)
    XCTAssertEqual(ImageProbe.probe(volume: dir), .nothingToProbe, "sam podkatalog to nie plik")

    try Data("x".utf8).write(to: dir.appendingPathComponent("plik"))
    XCTAssertEqual(ImageProbe.probe(volume: dir), .readable)
  }

  func testPustyPlikTezJestCzytelny() throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    try Data().write(to: dir.appendingPathComponent("pusty"))
    XCTAssertEqual(ImageProbe.probe(volume: dir), .readable)
  }
}
