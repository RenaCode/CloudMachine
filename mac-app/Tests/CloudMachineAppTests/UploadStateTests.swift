import XCTest

@testable import CloudMachineCore

/// Stan wysylki pokazywany uzytkownikowi.
///
/// Sedno tych testow to jedno rozroznienie: **limit dobowy mija sam, brak
/// miejsca nie**. Oba wygladaja tak samo w kazdym liczniku i znacza cos
/// zupelnie innego dla czlowieka, ktory patrzy na ekran.
final class UploadStateTests: XCTestCase {

  private func state(
    mounted: Bool = true, queued: Int = 0, inProgress: Int = 0, failedFiles: Int = 0,
    bufferOutOfSpace: Bool = false, driveFull: Bool = false, dailyQuotaExhausted: Bool = false
  ) -> UploadState {
    UploadState.from(
      mounted: mounted, queued: queued, inProgress: inProgress, failedFiles: failedFiles,
      bufferOutOfSpace: bufferOutOfSpace, driveFull: driveFull,
      dailyQuotaExhausted: dailyQuotaExhausted)
  }

  /// TO jest ta roznica. Limit dobowy: nie rob nic, ale nie udawaj, ze jest
  /// dobrze. Brak miejsca: zrob cos.
  func testLimitDobowyNieWymagaReakcjiAleNieJestNominalny() {
    let s = state(queued: 800, dailyQuotaExhausted: true)
    XCTAssertEqual(s, .dailyQuotaExhausted)
    XCTAssertFalse(s.needsAttention, "limit dobowy mija sam - nie ma o co prosic uzytkownika")
    XCTAssertFalse(s.isNominal, "ale pasma leza tylko lokalnie, wiec nie jest to stan nominalny")
  }

  func testBrakMiejscaWymagaReakcji() {
    let s = state(queued: 800, driveFull: true)
    XCTAssertEqual(s, .driveFull)
    XCTAssertTrue(s.needsAttention)
    XCTAssertFalse(s.isNominal)
  }

  /// "rclone odpuscil" znaczy, ze kopia jest niekompletna TERAZ. Limit znaczy
  /// tylko, ze poczeka. Dlatego bledy wyprzedzaja limit.
  func testPlikiPorzuconeWyprzedzajaLimitDobowy() {
    let s = state(queued: 800, failedFiles: 3, dailyQuotaExhausted: true)
    XCTAssertEqual(s, .failedFiles(3))
    XCTAssertTrue(s.needsAttention)
  }

  /// Brak montowania przykrywa wszystko - bez niego pozostale liczniki nie
  /// opisuja niczego sensownego.
  func testBrakMontowaniaPrzykrywaWszystko() {
    let s = state(mounted: false, queued: 800, failedFiles: 3, driveFull: true)
    XCTAssertEqual(s, .mountDown)
  }

  func testTrwajacaWysylkaJestNominalna() {
    let s = state(queued: 120, inProgress: 8)
    XCTAssertEqual(s, .flowing(queued: 128))
    XCTAssertTrue(s.isNominal)
    XCTAssertTrue(s.isMovingData)
    XCTAssertFalse(s.needsAttention)
  }

  func testPustaKolejkaToWszystkoWyslane() {
    let s = state()
    XCTAssertEqual(s, .upToDate)
    XCTAssertTrue(s.isNominal)
    XCTAssertFalse(s.isMovingData)
  }

  /// Kazdy stan musi umiec sie wytlumaczyc. Pusty tekst na karcie to dokladnie
  /// ten rodzaj cichej awarii, ktory ten projekt juz raz mial.
  func testKazdyStanMaTrescDlaCzlowieka() {
    let wszystkie: [UploadState] = [
      .mountDown, .driveFull, .failedFiles(2), .bufferFull, .dailyQuotaExhausted,
      .flowing(queued: 5), .upToDate,
    ]
    for s in wszystkie {
      XCTAssertFalse(s.headline.isEmpty, "brak naglowka dla \(s)")
      XCTAssertGreaterThan(s.explanation.count, 20, "wyjasnienie za krotkie dla \(s)")
    }
  }

  /// Przy wyczerpanym limicie uzytkownik ma zobaczyc, ze NIE musi nic robic -
  /// inaczej bedzie szukal awarii tam, gdzie jej nie ma.
  func testWyjasnienieLimituUspokajaZamiastStraszyc() {
    let tekst = UploadState.dailyQuotaExhausted.explanation
    XCTAssertTrue(tekst.contains("750 GB"), "ma podac, o jaki limit chodzi")
    XCTAssertTrue(tekst.contains("sam"), "ma powiedziec, ze mija sam")
    XCTAssertTrue(tekst.contains("Nie trzeba nic robić"), "ma wprost zwolnic z dzialania")
  }
}
