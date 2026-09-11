import XCTest

@testable import CloudMachineCore

/// Testy warstwy Google Drive. Pokrywaja parsowanie i decyzje - czyli te
/// miejsca, gdzie bledy byly ciche i kosztowne, a nie widac ich po tym, ze
/// "backup sie robi".
final class DriveLayerTests: XCTestCase {

  // MARK: - Parsowanie hdiutil info

  /// `hdiutil info` grupuje wpisy w bloki: po linii `image-path` naleza
  /// wszystkie kolejne linie `/dev/diskN`, az do nastepnego `image-path`.
  private let hdiutilInfo = """
    framework       : 595.100.2
    driver          : 595.100.2
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/other.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/other.sparsebundle
    shadow-path     : <none>
    /dev/disk4\tGUID_partition_scheme\t
    /dev/disk4s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/Other
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    shadow-path     : <none>
    /dev/disk7\tEF57347C-0000-11AA-AA11-00306543ECAC\t
    /dev/disk7s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/CloudMachine
    """

  func testParseDevicesFindsOnlyMatchingImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/mac-studio.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk7"])
  }

  func testParseDevicesIgnoresOtherImages() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/other.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk4"])
  }

  /// Regresja: gdy obraz nie jest podpiety, nie wolno zwrocic cudzych
  /// urzadzen - odpiecie ich zabiloby czyjs wolumen.
  func testParseDevicesReturnsNothingForUnknownImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo, imagePath: "/Users/x/nieistniejacy.sparsebundle")
    XCTAssertTrue(devices.isEmpty)
  }

  func testParseDevicesHandlesEmptyInput() {
    XCTAssertTrue(BackupImageService.parseDevices(hdiutilInfo: "", imagePath: "/x").isEmpty)
  }

  // MARK: - Suma kontrolna rclone

  private let sums = """
    3a1f0000000000000000000000000000000000000000000000000000000000aa  rclone-v1.75.1-osx-amd64.zip
    c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f  rclone-v1.75.1-osx-arm64.zip
    9b2c0000000000000000000000000000000000000000000000000000000000bb  rclone-v1.75.1-linux-amd64.zip
    """

  func testExpectedChecksumPicksTheRightArchive() {
    XCTAssertEqual(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v1.75.1-osx-arm64.zip"),
      "c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f")
  }

  /// Brak wpisu MUSI dac nil, a nie dowolna inna sume - inaczej instalator
  /// porownalby archiwum z suma innego pliku i albo odrzucil poprawne
  /// pobranie, albo (gorzej) przepuscil niepoprawne.
  func testExpectedChecksumReturnsNilWhenArchiveMissing() {
    XCTAssertNil(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v9.9.9-osx-arm64.zip"))
  }

  // MARK: - Argumenty montowania

  func testMountArgumentsCarryTheNonObviousFlags() {
    let args = DriveBufferService.mountArguments()

    // Bez tego skasowane pasma ida do kosza Dysku i dalej licza sie do limitu.
    XCTAssertTrue(args.contains("--drive-use-trash=false"))

    // Po przekroczeniu dobowego limitu 750 GB rclone ma stanac, a nie kreci
    // sie w 403.
    XCTAssertTrue(args.contains("--drive-stop-on-upload-limit"))

    // Bez pelnego cache zapis nie jest buforowany, czyli cala obietnica
    // nieprzerywalnosci znika.
    XCTAssertTrue(args.contains("--vfs-cache-mode"))
    XCTAssertEqual(args[(args.firstIndex(of: "--vfs-cache-mode")! + 1)], "full")

    // Interfejs rc jest jedynym zrodlem stanu kolejki - bez niego dozorca
    // bufora jest slepy.
    XCTAssertTrue(args.contains("--rc"))
  }

  /// Rozmiar pasma zostal wybrany pomiarem (patrz gdrive/README.md). Zmiana
  /// dziala tylko przy tworzeniu obrazu, wiec nie wolno jej przeoczyc.
  func testBandSizeIs32MB() {
    XCTAssertEqual(BackupImageService.bandSectors * 512, 32 * 1024 * 1024)
  }

  // MARK: - Progi dozorcy

  func testGuardThresholdsAreOrdered() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(
      t.lowGB, t.highGB,
      "Prog wznowienia musi byc nizszy niz prog pauzy, inaczej dozorca wpadnie w oscylacje.")
  }

  /// Wolne miejsce musi byc liczone pesymistycznie, jak `df`. Miara
  /// "important usage" wliczala miejsce zajete przez migawki i pokazywala
  /// 1202 GB tam, gdzie `df` mowilo 427 GB - dozorca spoznilby sie z pauza.
  func testFreeSpaceMatchesStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let expected = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BufferGuardService.freeGB(), expected)
  }
}
