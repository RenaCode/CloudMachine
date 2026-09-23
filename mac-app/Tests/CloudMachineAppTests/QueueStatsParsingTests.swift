import XCTest

@testable import CloudMachineCore

/// Parsowanie odpowiedzi interfejsu sterujacego rclone. Kazdy przypadek tutaj
/// to inny sposob, na jaki "nie wiem" zamienialo sie w "zero" - a "zero"
/// czytalo sie na ekranie jako "Wszystko wyslane na Google Drive".
final class QueueStatsParsingTests: XCTestCase {

  // MARK: - vfs/stats

  private let pelnaOdpowiedz = """
    {
      "diskCache": {
        "bytesUsed": 12345678,
        "erroredFiles": 3,
        "files": 40,
        "outOfSpace": false,
        "uploadsInProgress": 2,
        "uploadsQueued": 386
      },
      "metadataCache": { "dirs": 1, "files": 40 }
    }
    """

  func testPelnaOdpowiedzDajeLiczniki() throws {
    let stats = try XCTUnwrap(DriveBufferService.parseQueueStats(pelnaOdpowiedz))
    XCTAssertEqual(stats.uploadsInProgress, 2)
    XCTAssertEqual(stats.uploadsQueued, 386)
    XCTAssertEqual(stats.files, 40)
    XCTAssertEqual(stats.erroredFiles, 3)
    XCTAssertEqual(stats.bytesUsed, 12_345_678)
    XCTAssertFalse(stats.outOfSpace)
  }

  /// Sedno poprawki. Odpowiedz bez sekcji `diskCache` wpadala na `?? json`,
  /// gdzie zadnego z licznikow nie ma, a brakujacy klucz dawal 0 - wychodzil
  /// z tego komplet zer, czyli `queueKnown == true` i "Wszystko wyslane".
  func testOdpowiedzBezDiskCacheToBrakWiedzy() {
    let bezSekcji = """
      { "metadataCache": { "dirs": 1, "files": 40 } }
      """
    XCTAssertNil(DriveBufferService.parseQueueStats(bezSekcji))
  }

  /// Ten sam blad o jeden poziom nizej: sekcja jest, ale licznika w niej nie ma.
  func testBrakujacyLicznikToBrakWiedzy() {
    let bezBledow = """
      {
        "diskCache": {
          "bytesUsed": 1, "files": 40,
          "uploadsInProgress": 0, "uploadsQueued": 0
        }
      }
      """
    XCTAssertNil(
      DriveBufferService.parseQueueStats(bezBledow),
      "brak erroredFiles nie znaczy 'zero bledow'")
  }

  func testPustaOdpowiedzToBrakWiedzy() {
    XCTAssertNil(DriveBufferService.parseQueueStats(""))
    XCTAssertNil(DriveBufferService.parseQueueStats("connection refused"))
  }

  /// `outOfSpace` to jedyne pole, ktorego brak wolno nadrobic domyslna
  /// wartoscia - to flaga, a nie licznik.
  func testBrakFlagiOutOfSpaceNiePsujeOdczytu() throws {
    let bezFlagi = """
      {
        "diskCache": {
          "bytesUsed": 1, "erroredFiles": 0, "files": 2,
          "uploadsInProgress": 0, "uploadsQueued": 0
        }
      }
      """
    let stats = try XCTUnwrap(DriveBufferService.parseQueueStats(bezFlagi))
    XCTAssertFalse(stats.outOfSpace)
  }

  // MARK: - Cisza kontra bezczynnosc

  func testPustaKolejkaZPorzuconymiPasmamiNieJestCisza() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 0, uploadsQueued: 0, files: 40,
      erroredFiles: 5, bytesUsed: 1024, outOfSpace: false)
    XCTAssertTrue(stats.isIdle, "rclone faktycznie nic nie robi - hdiutil moze dzialac")
    XCTAssertFalse(
      stats.isQuiet,
      "ale 5 pasm nie dolecialo na Dysk, wiec 'wszystko wyslane' byloby klamstwem")
  }

  func testPustaKolejkaBezBledowJestCisza() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 0, uploadsQueued: 0, files: 40,
      erroredFiles: 0, bytesUsed: 1024, outOfSpace: false)
    XCTAssertTrue(stats.isIdle)
    XCTAssertTrue(stats.isQuiet)
  }

  func testTrwajacaWysylkaToAniCiszaAniBezczynnosc() {
    let stats = DriveBufferService.QueueStats(
      uploadsInProgress: 1, uploadsQueued: 12, files: 40,
      erroredFiles: 0, bytesUsed: 1024, outOfSpace: false)
    XCTAssertFalse(stats.isIdle)
    XCTAssertFalse(stats.isQuiet)
  }

  // MARK: - vfs/queue

  func testKolejkaPomijaPozycjeJuzWysylane() throws {
    let odpowiedz = """
      {
        "queue": [
          { "id": 1, "name": "bands/0001", "uploading": false, "expiry": 480.2 },
          { "id": 2, "name": "bands/0002", "uploading": true, "expiry": -1 },
          { "id": 3, "name": "bands/0003", "uploading": false, "expiry": 512.9 }
        ]
      }
      """
    let ids = try XCTUnwrap(DriveBufferService.parseQueueIDs(odpowiedz))
    XCTAssertEqual(ids, [1, 3], "pozycji juz wysylanej rclone i tak nie przyspieszy")
  }

  /// Pusta kolejka i brak odpowiedzi to DWIE ROZNE RZECZY - obie wychodzily
  /// wczesniej z `expireQueuedUploads()` jako `0`, wiec log milczal dokladnie
  /// wtedy, gdy terminow NIE przesunieto i drenaz mogl potrwac 10 minut.
  func testPustaKolejkaToNieToSamoCoBrakOdpowiedzi() {
    XCTAssertEqual(DriveBufferService.parseQueueIDs(#"{ "queue": [] }"#), [])
    XCTAssertNil(DriveBufferService.parseQueueIDs(""))
    XCTAssertNil(DriveBufferService.parseQueueIDs("{}"))
  }
}
