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

  // MARK: - Listowanie tez umie pasc

  /// ZMIANA wzgledem poprzedniej wersji tego testu, ktora nazywala sie
  /// `testNieczytelneListowanieToBrakProbki` i sprawdzala, ze KAZDY blad
  /// listowania daje `.nothingToProbe`. Kodowala stan, ktory okazal sie
  /// dziura: `BackupImageService.attachment` mapuje `.nothingToProbe` na
  /// `.attached`, wiec martwy obraz uchodzil za zywy, a agent `gdrive-attach`
  /// nie podpinal go przez godziny. Rozstrzyga teraz ZRODLO bledu, nie sam
  /// fakt bledu: blad bez rozpoznanego errno urzadzenia nadal nie dowodzi
  /// niczego o wolumenie i zostaje `.nothingToProbe`.
  func testListowanieZBledemBezErrnoUrzadzeniaToBrakProbki() {
    struct Boom: Error {}
    let verdict = ImageProbe.probe(regularFiles: { throw Boom() }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  /// Po wygasnieciu `--dir-cache-time 5m` listowanie przestaje chodzic z cache
  /// jadra i pada tym samym ENXIO, co odczyt. Wtedy jest juz dowodem smierci.
  func testENXIONaListowaniuZnaczyMartwy() {
    let verdict = ImageProbe.probe(
      regularFiles: { throw POSIXError(.ENXIO) }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  /// Tak wyglada ten sam blad, gdy rzuca go Foundation: `contentsOfDirectory`
  /// opakowuje errno w `NSCocoaErrorDomain` i chowa oryginal pod
  /// `NSUnderlyingErrorKey`. Sonda musi rozpoznac obie postacie, bo zywa
  /// sciezka (`regularFiles(in:)`) chodzi wlasnie przez Foundation.
  func testENXIOOpakowaneDoNSErrorTezZnaczyMartwy() {
    let underlying = NSError(domain: NSPOSIXErrorDomain, code: Int(ENXIO))
    let cocoa = NSError(
      domain: NSCocoaErrorDomain, code: 256,
      userInfo: [NSUnderlyingErrorKey: underlying])
    let verdict = ImageProbe.probe(
      regularFiles: { throw cocoa }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  /// Brak uprawnien do katalogu to wlasciwosc katalogu, nie awaria wolumenu.
  func testEACCESNaListowaniuToBrakProbki() {
    let verdict = ImageProbe.probe(
      regularFiles: { throw POSIXError(.EACCES) }, readFirstByte: { _ in nil })
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
