import XCTest

@testable import CloudMachineCore

/// Operacje na obrazie backupu: wzajemne wykluczenie i te werdykty, ktore
/// wczesniej klamaly - "wszystko wyslane" przy porzuconych pasmach i "obraz
/// NIESPOJNY" po wyrwaniu urzadzenia spod `fsck`.
final class BackupImageServiceTests: XCTestCase {

  // MARK: - Wzajemne wykluczenie

  /// Blokada nazwana `BackupImageService.lockName` lezy w prawdziwym katalogu
  /// logow, bo to tej samej blokady uzywaja `attach`/`detach`/`verify`/`create`.
  /// Trzymamy ja przez ulamek sekundy i tylko po to, zeby sprawdzic, ze
  /// operacje jej PRZESTRZEGAJA - zadna z nich nie dochodzi wtedy do `hdiutil`.
  private func withHeldImageLock(_ body: () async -> Void) async throws {
    let lock = CMLock(name: BackupImageService.lockName)
    try XCTSkipUnless(
      lock.acquire(),
      "blokade '\(BackupImageService.lockName)' trzyma cos innego na tej maszynie")
    defer { lock.release() }
    await body()
  }

  /// Sedno poprawki: do 23 wrzesnia 2026 `withCMLock` nie bylo wolane z ani
  /// jednego miejsca w repo, wiec kazda z tych czterech operacji szla przy
  /// trzymanej blokadzie tak samo jak bez niej. Test sprawdza nie tylko
  /// `succeeded == false` (to akurat wychodzilo juz wczesniej, bo bufor nie
  /// jest zamontowany), ale takze tresc i - co wazniejsze - `disposition`:
  /// operacja ma rozpoznac zajetosc, a nie odbic sie od czegos innego po drodze.
  func testOperacjeNaObrazieNieWchodzaSobieWDroge() async throws {
    try await withHeldImageLock {
      for (nazwa, wynik) in [
        ("create", await BackupImageService.create(sizeGB: 100)),
        ("attach", await BackupImageService.attach()),
        ("detach", await BackupImageService.detach()),
        ("verify", await BackupImageService.verify()),
      ] {
        XCTAssertFalse(wynik.succeeded, "\(nazwa) przy zajetym obrazie nie moze meldowac sukcesu")
        XCTAssertTrue(
          wynik.message.contains("inna operacja na obrazie"),
          "\(nazwa) ma powiedziec, ze NIE zrobilo nic - dostalem: \(wynik.message)")
        XCTAssertEqual(
          wynik.disposition, .skipped,
          "\(nazwa): zajetosc ma byc rozpoznawalna po TYPIE wyniku, nie po tresci komunikatu")
      }
    }
  }

  /// `attach-image` chodzi pod launchd co 900 s i jego kod wyjscia laduje w
  /// `launchd-gdrive-attach.err.log`. Zajetosc obrazu nie moze sie tam
  /// zapisywac jako awaria - ale prawdziwa porazka MUSI, inaczej schowalibysmy
  /// realny blad za kodem 0.
  func testZajeteToNieAwariaAlePorazkaNadalJestPorazka() {
    XCTAssertEqual(
      CMActionResult(succeeded: true, message: "Podpiete").disposition, .ok)
    XCTAssertEqual(
      CMActionResult(succeeded: false, message: "zajete", didNotRun: true).disposition,
      .skipped)
    XCTAssertEqual(
      CMActionResult(succeeded: false, message: "Nie udalo sie podpiac obrazu").disposition,
      .failed,
      "brak `didNotRun` ma znaczyc realna porazke - domyslna wartosc nie moze uciszac bledow")
  }

  // MARK: - Werdykt o odpieciu

  private func stats(queued: Int = 0, inProgress: Int = 0, errored: Int = 0)
    -> DriveBufferService.QueueStats
  {
    DriveBufferService.QueueStats(
      uploadsInProgress: inProgress, uploadsQueued: queued, files: 10,
      erroredFiles: errored, bytesUsed: 1024, outOfSpace: false)
  }

  func testPustaKolejkaBezBledowToWszystkoWyslane() {
    let wynik = BackupImageService.detachVerdict(settled: stats())
    XCTAssertTrue(wynik.succeeded)
    XCTAssertTrue(wynik.message.contains("wszystko wyslane"))
  }

  /// Pasma porzucone przez rclone wypadaja z kolejki tak samo jak wyslane,
  /// wiec sama pusta kolejka meldowala "Odpiete, wszystko wyslane na Google
  /// Drive" przy danych istniejacych TYLKO na tym Macu.
  func testPorzuconePasmaNieSaWyslane() {
    let wynik = BackupImageService.detachVerdict(settled: stats(errored: 7))
    XCTAssertFalse(wynik.succeeded)
    XCTAssertFalse(wynik.message.contains("wszystko wyslane"))
    XCTAssertTrue(wynik.message.contains("7"))
  }

  /// Brak odczytu to nie sukces - patrz `UploadState.queueUnknown`.
  func testBrakOdczytuKolejkiToNieSukces() {
    let wynik = BackupImageService.detachVerdict(settled: nil)
    XCTAssertFalse(wynik.succeeded)
  }

  // MARK: - Tablica montowan

  /// Dotad ta lista powstawala z parsowania wydruku `/sbin/mount` (`" on "` …
  /// `" ("`) wewnatrz `unmountBrowsedSnapshots()`, wiec nie bylo do czego
  /// podstawic probki. Migawka backupu montuje sie pod
  /// `/Volumes/.timemachine/<host>/<data>.backup/<wolumen>` i trzyma
  /// urzadzenie obrazu zajete, przez co `hdiutil detach` odmawia.
  func testWybieraTylkoPrzegladaneMigawkiBackupu() {
    let punkty = [
      "/",
      "/Volumes/CloudMachine",
      "/Users/mbeczynski/.cloudmachine/drive",
      "/Volumes/.timemachine/mac-studio/2026-09-23-101500.backup/CloudMachine",
      "/Volumes/.timemachine/mac-studio/2026-09-22-231500.backup/CloudMachine",
      // Pulapka: podobna nazwa, ale NIE pod katalogiem migawek.
      "/Volumes/timemachine-kopia",
    ]
    XCTAssertEqual(
      BackupImageService.browsedSnapshotMounts(punkty),
      [
        "/Volumes/.timemachine/mac-studio/2026-09-23-101500.backup/CloudMachine",
        "/Volumes/.timemachine/mac-studio/2026-09-22-231500.backup/CloudMachine",
      ])
  }

  func testBrakMigawekToPustaLista() {
    XCTAssertEqual(BackupImageService.browsedSnapshotMounts(["/", "/Volumes/CloudMachine"]), [])
  }

  /// Tablica montowan czytana z jadra, nie z `/sbin/mount`. Sprawdzamy na
  /// zywo, bo cala poprawka polega na tym, ze ten odczyt NIE uruchamia procesu
  /// i NIE dotyka systemu plikow - czego atrapa by nie pokazala.
  func testTablicaMontowanJestCzytelnaIZawieraKorzen() throws {
    let punkty = try XCTUnwrap(
      DriveBufferService.mountPoints(), "getmntinfo nie oddal tablicy montowan")
    XCTAssertTrue(punkty.contains("/"), "kazdy system ma zamontowany korzen - dostalem: \(punkty)")
  }

  // MARK: - Stan podpiecia

  /// `.unknown` to NIE `.detached`. `.detached` jest twierdzeniem
  /// („sprawdzilem, nie ma"), a przy nieodczytanej tablicy montowan nie bylo
  /// czego sprawdzic. Rozroznienie ma znaczenie, bo `attach` na podstawie
  /// `.detached` robi `purgeStaleDevices()`, czyli `detach -force` na
  /// urzadzeniu, ktore moze byc w tym czasie zywe.
  func testNieznanyStanToNiePodpietyIleczNieodpiety() {
    let nieznany = BackupImageService.Attachment.unknown
    XCTAssertNotEqual(nieznany, .detached)
    XCTAssertNotEqual(nieznany, .attached)
    XCTAssertFalse(
      nieznany.isUsable,
      "na niewiadomej nie wolno polegac - Time Machine nie ma tu gwarancji celu")
  }

  /// Kazdy stan ma dawac inne zdanie. Wspolny opis dla `.detached`
  /// i `.unknown` przywrocilby zlanie, ktore ta poprawka usuwa - tyle ze
  /// w warstwie, ktora czyta czlowiek.
  func testKazdyStanPodpieciaMaWlasnyOpis() {
    let opisy = [
      BackupImageService.describe(.attached),
      BackupImageService.describe(.detached),
      BackupImageService.describe(.dead(errno: ENXIO)),
      BackupImageService.describe(.unknown),
    ]
    XCTAssertEqual(Set(opisy).count, opisy.count, "opisy sie powtarzaja: \(opisy)")
    XCTAssertTrue(BackupImageService.describe(.unknown).contains("NIE WIADOMO"))
  }

  // MARK: - Urzadzenie nadrzedne

  /// `fsck_apfs` dostaje partycje, `hdiutil info` wypisuje urzadzenie
  /// nadrzedne - bez tego przeliczenia sprawdzenie "czy urzadzenie przezylo"
  /// odpowiadaloby "nie" zawsze.
  func testUrzadzenieNadrzedneZPartycji() {
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk7s1"), "/dev/disk7")
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk12s3"), "/dev/disk12")
    XCTAssertEqual(BackupImageService.parentDevice(of: "/dev/disk7"), "/dev/disk7")
    XCTAssertEqual(BackupImageService.parentDevice(of: "cos-innego"), "cos-innego")
  }

  // MARK: - Obraz na zdalnym

  private let listing = """
    inne-dane/
    mac-studio.sparsebundle/
    """

  func testWypisZdalnegoZObrazem() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(succeeded: true, stdout: listing, stderr: ""),
      .present)
  }

  func testPustyWypisZdalnegoToBrakObrazu() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(succeeded: true, stdout: "", stderr: ""),
      .absent)
  }

  /// Pierwsze uruchomienie: zdalnego katalogu jeszcze nie ma. To jest
  /// ODPOWIEDZ ("nie ma tam nic"), a nie jej brak - inaczej straznik
  /// blokowalby `create` dokladnie w tym jedynym przypadku, dla ktorego
  /// `create` istnieje.
  func testBrakKataloguNaZdalnymToBrakObrazu() {
    XCTAssertEqual(
      BackupImageService.classifyRemoteListing(
        succeeded: false, stdout: "",
        stderr: "2026/09/23 10:00:00 ERROR : : error listing: directory not found"),
      .absent)
  }

  /// Zerwane lacze to NIE dowod nieobecnosci obrazu. Tworzenie obrazu jest
  /// nieodwracalne, wiec brak pewnosci musi je przerwac.
  func testBrakLaczaToNieDowodNieobecnosci() {
    let wynik = BackupImageService.classifyRemoteListing(
      succeeded: false, stdout: "",
      stderr: "Failed to lsf with 2 errors: couldn't connect to Google Drive")
    guard case .unknown = wynik else {
      return XCTFail("brak odpowiedzi ma byc .unknown, dostalem \(wynik)")
    }
  }
}
