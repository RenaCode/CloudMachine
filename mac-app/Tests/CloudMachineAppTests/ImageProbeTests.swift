import Foundation
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

  func testPrawdziwyOdczytNaKataloguTymczasowym() async throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }

    var werdykt = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(werdykt, .nothingToProbe, "pusty katalog")

    try FileManager.default.createDirectory(
      at: dir.appendingPathComponent("podkatalog"), withIntermediateDirectories: true)
    werdykt = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(werdykt, .nothingToProbe, "sam podkatalog to nie plik")

    try Data("x".utf8).write(to: dir.appendingPathComponent("plik"))
    werdykt = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(werdykt, .readable)
  }

  func testPustyPlikTezJestCzytelny() async throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    try Data().write(to: dir.appendingPathComponent("pusty"))
    let werdykt = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(werdykt, .readable)
  }

  // MARK: - Limit czasu

  /// Sonda na wolumenie FUSE-T potrafi NIGDY nie wrocic - `read()` zaklinowany
  /// w jadrze (stan "U" w `ps`) nie da sie ani anulowac, ani ubic. Te testy
  /// podstawiaja dokladnie taka sonde: zamiast czytac, czeka na semafor, ktory
  /// puszczamy dopiero na koniec testu.
  ///
  /// KAZDY z nich ma WLASNY termin, niezalezny od limitu w sondzie. Gdyby
  /// limit zniknal z kodu, `await` na sondzie nigdy by nie wrocil i test
  /// wisialby do konca calego `swift test` - porazka po dziesiatkach minut
  /// i bez jednego zdania o przyczynie. Z terminem porazka jest szybka
  /// i czytelna: werdykt `nil` znaczy "sonda nie odpowiedziala nawet tyle".
  private func werdykt(
    slot: String,
    timeout: TimeInterval,
    deadline: TimeInterval = 5,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32? = { _ in nil }
  ) async -> ImageProbe.Verdict? {
    let oddany = expectation(description: "sonda \(slot) oddala werdykt")
    let pudelko = VerdictBox()
    Task {
      pudelko.set(
        await ImageProbe.probe(
          slot: slot, timeout: timeout,
          regularFiles: regularFiles, readFirstByte: readFirstByte))
      oddany.fulfill()
    }
    // `XCTWaiter`, a nie `await fulfillment(of:)`: ten drugi sam oblewa test
    // przy przekroczeniu terminu, a my chcemy oblac go WLASNYM zdaniem
    // mowiacym, ze sonda nie ma limitu czasu.
    _ = XCTWaiter().wait(for: [oddany], timeout: deadline)
    return pudelko.value
  }

  /// TO JEST TA POPRAWKA: sonda, ktora nie odpowiada, oddaje werdykt
  /// w skonczonym czasie, a wolajacy przezywa i dziala dalej.
  func testSondaBezOdpowiedziDajeTimedOutAWolajacyIdzieDalej() async throws {
    let zablokowana = DispatchSemaphore(value: 0)
    // Watek sondy siedzi w "read()" do konca testu - tak jak na prawdziwym
    // martwym wolumenie. Puszczamy go na wyjsciu, zeby nie zostal na stale.
    defer { zablokowana.signal() }

    let start = Date()
    let wynik = await werdykt(
      slot: "test-brak-odpowiedzi", timeout: 0.5,
      regularFiles: {
        zablokowana.wait()
        return []
      })
    let czekanie = Date().timeIntervalSince(start)

    XCTAssertEqual(
      wynik, .timedOut,
      "sonda bez odpowiedzi musi oddac .timedOut - inaczej wolajacy wisi razem z nia")
    XCTAssertLessThan(
      czekanie, 3, "limit 0,5 s ma byc GORNYM ograniczeniem czekania, nie sugestia")

    // Wolajacy nie tylko wrocil - NADAL DZIALA, mimo ze tamten watek wciaz
    // siedzi w jadrze. To jest ta czesc, ktorej brak uciszal czujke na stale.
    let katalog = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: katalog) }
    try Data("x".utf8).write(to: katalog.appendingPathComponent("plik"))
    let potem = await ImageProbe.probe(volume: katalog)
    XCTAssertEqual(potem, .readable, "po poddaniu sie na jednym wolumenie sonda musi dalej dzialac")
  }

  /// "Nie wiem" to NIE "obraz nieczytelny". Ta druga rzecz wyzwala w
  /// `attach-image` odpiecie NA SILE, wiec zlanie ich w jeden werdykt
  /// zamienialoby brak wiedzy w operacje nieodwracalna.
  func testTimedOutToNieToSamoCoMartwy() {
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .dead(errno: ENXIO))
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .dead(errno: EIO))
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .readable)
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .nothingToProbe)
  }

  /// Limit czasu nie moze polykac werdyktu sondy, ktora odpowiada WOLNO, ale
  /// odpowiada - inaczej martwy obraz przestalby byc naprawiany.
  func testWolnaAleOdpowiadajacaSondaDajeSwojWerdykt() async {
    let wynik = await werdykt(
      slot: "test-wolna", timeout: 3,
      regularFiles: {
        Thread.sleep(forTimeInterval: 0.3)
        return [self.manifest]
      },
      readFirstByte: { _ in ENXIO })
    XCTAssertEqual(wynik, .dead(errno: ENXIO))
  }

  /// Jedna sonda na wolumen. Bez tego panel odswiezany co 10 s zostawialby na
  /// zaklinowanym wolumenie po jednym wiszacym watku na przebieg.
  func testDrugaSondaTegoSamegoWolumenuNieZakladaDrugiegoWatku() async {
    let zablokowana = DispatchSemaphore(value: 0)
    // Dwa razy, bo gdyby jedno-w-locie przestalo dzialac, zablokowane byly by
    // DWA watki i kazdy potrzebuje wlasnego przebudzenia.
    defer {
      zablokowana.signal()
      zablokowana.signal()
    }
    let slot = "test-jedna-w-locie"
    let pierwszy = await werdykt(
      slot: slot, timeout: 0.5,
      regularFiles: {
        zablokowana.wait()
        return []
      })
    XCTAssertEqual(pierwszy, .timedOut)

    // Pierwszy watek wciaz siedzi w jadrze. Drugi wolajacy ma dostac
    // "nie wiem" OD RAZU - dlatego limit sondy jest tu absurdalnie dlugi
    // (30 s), a termin testu krotki (2 s): jesli czekanie w ogole sie zacznie,
    // test oblewa sie szybko, a nie po pol minuty.
    let start = Date()
    let drugi = await werdykt(
      slot: slot, timeout: 30, deadline: 2,
      regularFiles: {
        zablokowana.wait()
        return []
      })
    XCTAssertEqual(
      drugi, .timedOut,
      "druga sonda tego samego wolumenu ma oddac 'nie wiem' od razu, a nie czekac ani zakladac watku"
    )
    XCTAssertLessThan(Date().timeIntervalSince(start), 1)
  }
}

/// Werdykt przenoszony z `Task`-a do ciala testu. Klasa z zamkiem, a nie
/// zmienna domknieta w zasiegu: zapis i odczyt dzieja sie na roznych watkach.
private final class VerdictBox: @unchecked Sendable {
  private let lock = NSLock()
  private var stored: ImageProbe.Verdict?

  func set(_ value: ImageProbe.Verdict) {
    lock.lock()
    stored = value
    lock.unlock()
  }

  var value: ImageProbe.Verdict? {
    lock.lock()
    defer { lock.unlock() }
    return stored
  }
}
