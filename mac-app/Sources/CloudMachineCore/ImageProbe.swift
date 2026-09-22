import Foundation

/// Czy podpiety obraz NAPRAWDE oddaje dane - a nie tylko figuruje w tablicy
/// montowan.
///
/// DLACZEGO TO ISTNIEJE
///
/// 22 wrz 2026 o 00:17 rclone dostal od Google HTTP 401 na listowaniu pasm,
/// oddal blad we/wy do FUSE-T, a sterownik obrazu uznal urzadzenie za
/// odlaczone. Od tej chwili kazdy odczyt pliku spod `/Volumes/CloudMachine`
/// konczyl sie `errno 6 ENXIO` ("Device not configured") i Time Machine
/// padal co przebieg z `BACKUP_FAILED_DISCONNECTED_DESTINATION`.
///
/// Tymczasem `mount` nadal pokazywal wolumen, `hdiutil info` nadal pokazywal
/// obraz, `ls` katalogu dzialal (z cache jadra), a `statfs` oddawal wolne
/// miejsce. Wszystko, na czym stal `isAttached`, mowilo "OK". Skutek:
/// `drive-status` "Obraz podpiety: OK", GUI "Wszystko wyslane", a agent
/// `gdrive-attach` co 15 minut meldowal "Juz podpiete" i NIE podpinal na nowo.
/// Przez 15 godzin jedynym, co krzyczalo, byl `backup-health` - po fakcie,
/// z wieku ostatniej kopii.
///
/// Zmierzone na martwym urzadzeniu: `open()` katalogu - OK, `listdir` - OK,
/// `statvfs` - OK, `fsync` - OK, **`open`+`read` 1 bajtu zwyklego pliku - ENXIO**.
/// Dlatego sonda czyta bajt. Nic slabszego nie odroznia zywego od martwego.
public enum ImageProbe {

  public enum Verdict: Equatable {
    /// Odczyt sie udal.
    case readable
    /// Urzadzenie nie oddaje danych. `errno` z nieudanego odczytu.
    case dead(errno: Int32)
    /// W katalogu glownym nie ma zwyklego pliku, ktory daloby sie przeczytac -
    /// tak wyglada swiezy wolumen przed pierwsza kopia. Nie da sie stwierdzic
    /// awarii, wiec NIE zglaszamy jej.
    case nothingToProbe
  }

  /// Bledy, ktore znacza "urzadzenie zniklo", a nie "plik jest dziwny".
  ///
  /// EACCES czy EISDIR to wlasciwosc pliku, nie wolumenu - taki plik pomijamy
  /// i probujemy nastepnego. ENXIO/EIO/ENODEV/ENOTCONN to wolumen.
  static let deviceErrors: Set<Int32> = [ENXIO, EIO, ENODEV, ENOTCONN]

  /// Czysta wersja: listowanie i odczyt sa wstrzykiwane, zeby test mogl
  /// podstawic ENXIO bez psucia prawdziwego urzadzenia.
  ///
  /// - `regularFiles`: zwykle pliki w katalogu glownym wolumenu.
  /// - `readFirstByte`: rzuca `POSIXError`-podobny blad z `errno`, gdy odczyt pada.
  public static func probe(
    regularFiles: () throws -> [URL],
    readFirstByte: (URL) -> Int32?
  ) -> Verdict {
    guard let files = try? regularFiles(), !files.isEmpty else { return .nothingToProbe }
    for file in files {
      guard let errno = readFirstByte(file) else { return .readable }
      if deviceErrors.contains(errno) { return .dead(errno: errno) }
      // Blad wlasciwy dla pliku - sprobuj innego.
    }
    return .nothingToProbe
  }

  /// Sonda na zywym wolumenie.
  public static func probe(volume: URL) -> Verdict {
    probe(
      regularFiles: { try regularFiles(in: volume) },
      readFirstByte: { readFirstByteErrno(of: $0) })
  }

  /// Zwykle pliki w katalogu glownym. Listowanie chodzi z cache jadra, wiec
  /// dziala takze na martwym urzadzeniu - to nie jest test, tylko lista
  /// kandydatow do testu.
  static func regularFiles(in volume: URL) throws -> [URL] {
    try FileManager.default.contentsOfDirectory(
      at: volume, includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsSubdirectoryDescendants]
    )
    .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
  }

  /// `nil` = odczyt sie udal (takze pusty plik), inaczej `errno`.
  ///
  /// Przez `open`/`read` z libc, nie przez `Data(contentsOf:)`: Foundation
  /// czyta caly plik, a nas interesuje jeden bajt i surowe errno.
  static func readFirstByteErrno(of file: URL) -> Int32? {
    let fd = open(file.path, O_RDONLY)
    guard fd >= 0 else { return errno }
    defer { close(fd) }
    var byte: UInt8 = 0
    let n = read(fd, &byte, 1)
    return n < 0 ? errno : nil
  }
}
