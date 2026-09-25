import XCTest

@testable import CloudMachineCore

/// Dwa pytania, ktore dozorca zadaje LOGOWI rclone: czy skonczylo sie miejsce
/// na Dysku Google i czy wysylka stoi. Oba mialy do 25.09.2026 tylko dwie
/// odpowiedzi, a plik ma trzy stany.
///
/// `recentLog` oddaje `nil`, gdy pliku nie da sie otworzyc, a obie funkcje
/// zamienialy to na `false` - czyli na "nie ma problemu". Skutki byly dwa
/// i rozne: dozorca nie wstrzymywal backupu przy braku miejsca na Dysku,
/// a `reportStall(false)` USUWAL znacznik zatoru i zapisywal "Wysylka na Google
/// Drive ruszyla z powrotem". Log rclone ma prawa `-rw-r-----`, a przy starcie
/// jest przenoszony na `.1`, wiec nieczytelny log to stan spodziewany.
///
/// Testy pisza do wlasnego pliku tymczasowego. Produkcyjnego
/// `~/.cloudmachine/rclone.log` nie dotykaja ani do odczytu, ani do zapisu -
/// dlatego obie funkcje przyjmuja sciezke.
final class RcloneLogReadabilityTests: XCTestCase {

  private var katalog: URL!

  override func setUpWithError() throws {
    try super.setUpWithError()
    katalog = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cm-rclone-log-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: katalog, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    // Prawa musza wrocic, inaczej katalogu nie da sie usunac.
    if let pliki = try? FileManager.default.contentsOfDirectory(atPath: katalog.path) {
      for plik in pliki {
        try? FileManager.default.setAttributes(
          [.posixPermissions: 0o600], ofItemAtPath: katalog.appendingPathComponent(plik).path)
      }
    }
    try? FileManager.default.removeItem(at: katalog)
    try super.tearDownWithError()
  }

  private func stempel(_ przesuniecieMinut: Double = 0) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    return formatter.string(from: Date().addingTimeInterval(-przesuniecieMinut * 60))
  }

  private func zapisz(_ tekst: String, prawa: Int? = nil) throws -> URL {
    let plik = katalog.appendingPathComponent("rclone.log")
    try tekst.write(to: plik, atomically: true, encoding: .utf8)
    if let prawa {
      try FileManager.default.setAttributes(
        [.posixPermissions: prawa], ofItemAtPath: plik.path)
    }
    return plik
  }

  // MARK: - Brak miejsca na Google Drive

  func testSwiezyWpisOLimicieToJAWNETAK() throws {
    let plik = try zapisz(
      """
      \(stempel(5)) INFO  : band-1: Copied (replaced existing)
      \(stempel(2)) ERROR : band-2: Failed to copy: googleapi: Error 403: storageQuotaExceeded
      """)
    XCTAssertEqual(DriveBufferService.hitStorageQuotaState(logFile: plik), true)
  }

  func testLogBezSladuLimituToJAWNENIE() throws {
    let plik = try zapisz("\(stempel(2)) INFO  : band-1: Copied (new)")
    XCTAssertEqual(DriveBufferService.hitStorageQuotaState(logFile: plik), false)
  }

  /// TA awaria. Plik jest, ale nie mamy do niego prawa - i to NIE znaczy, ze
  /// na Dysku jest miejsce.
  func testNieczytelnyLogToNieWiemAnieBrakProblemu() throws {
    let plik = try zapisz(
      "\(stempel(2)) ERROR : band-2: googleapi: Error 403: storageQuotaExceeded", prawa: 0o000)
    XCTAssertNil(
      DriveBufferService.hitStorageQuotaState(logFile: plik),
      "Nieotwieralny plik zamieniony na `false` udaje odpowiedz 'nie ma problemu'.")
    XCTAssertNil(
      DriveBufferService.uploadStalledState(logFile: plik),
      "To samo pytanie o zator - ten sam plik i ten sam brak odpowiedzi.")
  }

  /// Log przeniesiony na `.1` przy starcie rclone albo jeszcze nieutworzony po
  /// swiezej instalacji. Brak pliku to brak danych, nie brak problemu.
  func testBrakPlikuLoguToTezNieWiem() {
    let plik = katalog.appendingPathComponent("nie-ma-takiego.log")
    XCTAssertNil(DriveBufferService.hitStorageQuotaState(logFile: plik))
    XCTAssertNil(DriveBufferService.uploadStalledState(logFile: plik))
  }

  // MARK: - Zator wysylki

  func testZatorRozpoznanyZeStosunkuSukcesowDoBledow() throws {
    // Prog `minErrors` to 300, a `maxSuccessRatio` 0,1 - zator to setki bledow
    // przy niemal zerowym ruchu.
    var linie: [String] = []
    for _ in 0..<400 { linie.append("\(stempel(3)) ERROR : band: Received upload limit error") }
    linie.append("\(stempel(3)) INFO  : band: Copied (replaced existing)")
    let plik = try zapisz(linie.joined(separator: "\n"))
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: plik), true)
  }

  func testZwykleDlawienieTempaNieJestZatorem() throws {
    // Tyle samo sukcesow, co bledow - zmierzone 1:1 na dlawieniu z 12.09.2026.
    var linie: [String] = []
    for _ in 0..<400 {
      linie.append("\(stempel(3)) ERROR : band: Received upload limit error")
      linie.append("\(stempel(3)) INFO  : band: Copied (replaced existing)")
    }
    let plik = try zapisz(linie.joined(separator: "\n"))
    XCTAssertEqual(DriveBufferService.uploadStalledState(logFile: plik), false)
  }
}
