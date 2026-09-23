import XCTest

@testable import CloudMachineCore

/// Stan wysylki pokazywany uzytkownikowi.
///
/// Sedno tych testow to jedno rozroznienie: **limit dobowy mija sam, brak
/// miejsca nie**. Oba wygladaja tak samo w kazdym liczniku i znacza cos
/// zupelnie innego dla czlowieka, ktory patrzy na ekran.
final class UploadStateTests: XCTestCase {

  private func state(
    mounted: Bool = true, queueKnown: Bool = true, queued: Int = 0, inProgress: Int = 0,
    failedFiles: Int = 0, bufferOutOfSpace: Bool = false, driveFull: Bool = false,
    dailyQuotaExhausted: Bool = false
  ) -> UploadState {
    UploadState.from(
      mounted: mounted, queueKnown: queueKnown, queued: queued, inProgress: inProgress,
      failedFiles: failedFiles, bufferOutOfSpace: bufferOutOfSpace, driveFull: driveFull,
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

  /// REGRESJA 23.09.2026. `rclone rc vfs/stats` przekroczyl limit czasu, wiec
  /// `queueStats()` oddal `nil`, a wolajacy podstawil zera - i przy 386 pasmach
  /// w kolejce `drive-status` oraz karta w interfejsie oglosily "Wszystko
  /// wyslane na Google Drive". Brak odpowiedzi ma wygladac jak brak odpowiedzi.
  func testBrakOdczytuKolejkiNieUdajePustejKolejki() {
    let s = state(queueKnown: false)
    XCTAssertEqual(s, .queueUnknown)
    XCTAssertNotEqual(s, .upToDate)
    XCTAssertFalse(s.isNominal, "nieznany stan nie ma prawa swiecic na zielono")
    XCTAssertFalse(s.isMovingData)
    XCTAssertFalse(s.needsAttention, "od trwalosci problemu jest backup-health, nie kolor karty")
    XCTAssertFalse(
      s.headline.contains("Wszystko wysłane"), "to zdanie wlasnie bylo klamstwem")
  }

  /// Twarde fakty, ktore nie pochodza z kolejki, wyprzedzaja niewiedze o niej:
  /// brak montowania i brak miejsca na Dysku wiadomo bez `vfs/stats`.
  func testFaktySpozaKolejkiWyprzedzajaNiewiedze() {
    XCTAssertEqual(state(mounted: false, queueKnown: false), .mountDown)
    XCTAssertEqual(state(queueKnown: false, driveFull: true), .driveFull)
  }

  /// Limit dobowy przepada za to celowo: skoro nie wiadomo, czy rclone czegos
  /// nie porzucil, "poczekaj, minie samo" nie jest uczciwa odpowiedzia.
  func testLimitDobowyNiePrzykrywaNiewiedzyOKolejce() {
    XCTAssertEqual(state(queueKnown: false, dailyQuotaExhausted: true), .queueUnknown)
  }

  func testKazdyStanMaEtykieteDlaCzlowieka() {
    let wszystkie: [UploadState] = [
      .mountDown, .driveFull, .failedFiles(2), .bufferFull, .dailyQuotaExhausted,
      .flowing(queued: 5), .upToDate, .queueUnknown,
    ]
    for s in wszystkie {
      XCTAssertFalse(s.badge.isEmpty, "brak etykiety dla \(s)")
    }
    XCTAssertNotEqual(
      UploadState.queueUnknown.badge, UploadState.upToDate.badge,
      "niewiedza i porzadek nie moga wygladac tak samo")
    XCTAssertNotEqual(
      UploadState.queueUnknown.badge, UploadState.dailyQuotaExhausted.badge,
      "niewiedza to nie jest 'minie samo'")
  }

  /// Kazdy stan musi umiec sie wytlumaczyc. Pusty tekst na karcie to dokladnie
  /// ten rodzaj cichej awarii, ktory ten projekt juz raz mial.
  func testKazdyStanMaTrescDlaCzlowieka() {
    let wszystkie: [UploadState] = [
      .mountDown, .driveFull, .failedFiles(2), .bufferFull, .dailyQuotaExhausted,
      .flowing(queued: 5), .upToDate, .queueUnknown,
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
