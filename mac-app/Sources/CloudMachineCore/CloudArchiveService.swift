import Foundation

/// Warstwa archiwizacji w chmurze - drugi z dwoch poziomow architektury
/// (patrz README): lokalny wolumin APFS (`LocalBackupService`) jest szybkim,
/// w pelni trwalym celem Time Machine; ten serwis periodycznie kopiuje
/// ukonczone, "zimne" backupy z lokalnego woluminu na Google Drive przez
/// rclone, dajac retencje wykraczajaca poza lokalny limit.
///
/// Bezpieczenstwo spojnosci: `tmutil listbackups` pokazuje WYLACZNIE w pelni
/// ukonczone backupy (te w trakcie kopiowania widnieja jako `.inProgress` i
/// nie pojawiaja sie na tej liscie), a dodatkowo NIE archiwizujemy, gdy Time
/// Machine aktywnie pisze (`TimeMachineStatus.isRunning()`) - te dwa
/// zabezpieczenia razem gwarantuja, ze kopiowany katalog backupu jest w
/// pelni statyczny podczas kopiowania przez rclone.
public enum CloudArchiveService {
  public struct ArchiveStatus: Equatable {
    public var lastArchivedBackup: String?
    public var lastArchivedDate: Date?
    public var archivedCount: Int
    public var pendingCount: Int
  }

  private static var stateFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("archived-backups.json")
  }

  /// Nazwy (ostatni segment sciezki, np. "2026-07-28-160440.backup") backupow
  /// juz skopiowanych do chmury.
  static func loadArchivedNames() -> Set<String> {
    guard let data = try? Data(contentsOf: stateFile),
      let names = try? JSONDecoder().decode([String].self, from: data)
    else { return [] }
    return Set(names)
  }

  private static func saveArchivedNames(_ names: Set<String>) {
    guard let data = try? JSONEncoder().encode(Array(names).sorted()) else { return }
    try? data.write(to: stateFile, options: .atomic)
  }

  private static func archiveStateModifiedDate() -> Date? {
    (try? FileManager.default.attributesOfItem(atPath: stateFile.path))?[.modificationDate]
      as? Date
  }

  /// Konwertuje limit predkosci wysylania z `MachinesConfig.bwLimitMbps`
  /// (Mbps - megabity/s, jak u dostawcow internetu) na argumenty `rclone
  /// --bwlimit`, ktore oczekuje megaBAJTOW/s (`8 Mbps = 1 MB/s`). `0` = bez
  /// limitu, wiec bez tego argumentu w ogole.
  static func bwLimitArgs(forMbps mbps: Int) -> [String] {
    guard mbps > 0 else { return [] }
    let megabytesPerSecond = Double(mbps) / 8
    return ["--bwlimit", String(format: "%.2fM", megabytesPerSecond)]
  }

  /// Pelne sciezki lokalnych backupow (posortowane od najstarszego przez
  /// `tmutil`), albo `[]` przy bledzie/braku backupow.
  public static func localBackups(mountPoint: String) async -> [String] {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["listbackups", "-d", mountPoint], timeout: 60),
      result.succeeded
    else { return [] }
    return result.stdout.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
  }

  public static func currentStatus(config: MachinesConfig, machineKey: String) async
    -> ArchiveStatus
  {
    let volume = await LocalBackupService.currentStatus()
    let archived = loadArchivedNames()
    guard let mountPoint = volume.mountPoint, volume.exists else {
      return ArchiveStatus(
        lastArchivedBackup: nil, lastArchivedDate: nil, archivedCount: archived.count,
        pendingCount: 0)
    }
    let backups = await localBackups(mountPoint: mountPoint)
    let pendingCount = backups.reduce(0) { count, path in
      archived.contains(URL(fileURLWithPath: path).lastPathComponent) ? count : count + 1
    }
    return ArchiveStatus(
      lastArchivedBackup: archived.sorted().last,
      lastArchivedDate: archiveStateModifiedDate(),
      archivedCount: archived.count,
      pendingCount: pendingCount
    )
  }

  /// Kopiuje wszystkie jeszcze nie zarchiwizowane backupy do Google Drive, w
  /// kolejnosci od najstarszego. PRZERYWA (nie pomija) przy pierwszym
  /// bledzie rclone zamiast probowac kolejny - kazdy nastepny backup jest
  /// hardlinkowany do poprzedniego, wiec pomijanie zerwałoby ciaglosc
  /// historii po stronie chmury bez wyraznego ostrzezenia.
  ///
  /// Blokada `withCMLock` jest TUTAJ (nie tylko w `ArchiveWatchdogService`),
  /// zeby chronic przed KAZDYM wywolujacym rownolegle - GUI ("Archiwizuj
  /// teraz"), `cloudmachine-agent archive-now` i sam watchdog moga wystartowac
  /// w tej samej chwili z osobnych procesow; bez wspolnej blokady dwa
  /// rownlegle przebiegi scigalyby sie o niezablokowany odczyt-modyfikacje-
  /// zapis `archived-backups.json`, mogac zgubic wpisy albo odpalic
  /// zdublowane, wielogodzinne kopiowanie tego samego backupu.
  @discardableResult
  public static func archivePending(config: MachinesConfig, machineKey: String) async
    -> CMActionResult
  {
    guard
      let result = await withCMLock("archive-watchdog", {
        await archivePendingLocked(config: config, machineKey: machineKey)
      })
    else {
      return CMActionResult(
        succeeded: false,
        message: "Inna archiwizacja juz trwa (z innego procesu) - pomijam ten przebieg.")
    }
    return result
  }

  private static func archivePendingLocked(config: MachinesConfig, machineKey: String) async
    -> CMActionResult
  {
    let volume = await LocalBackupService.currentStatus()
    guard let mountPoint = volume.mountPoint, volume.exists else {
      return CMActionResult(
        succeeded: false, message: "Lokalny wolumin backupu jeszcze nie istnieje.")
    }
    guard !(await TimeMachineStatus.isRunning()) else {
      return CMActionResult(
        succeeded: false,
        message: "Time Machine aktywnie zapisuje - pomijam archiwizacje do nastepnego przebiegu.")
    }

    let backups = await localBackups(mountPoint: mountPoint)
    guard !backups.isEmpty else {
      return CMActionResult(succeeded: true, message: "Brak lokalnych backupow do zarchiwizowania.")
    }

    var archived = loadArchivedNames()
    let remotePath = config.remotePath(forMachineKey: machineKey)
    var copiedCount = 0
    let bwLimitArgs = bwLimitArgs(forMbps: config.bwLimitMbps)

    for backupPath in backups {
      let name = URL(fileURLWithPath: backupPath).lastPathComponent
      guard !archived.contains(name) else { continue }

      CMLogger.log("[cloud-archive] Kopiuje \(name) do \(remotePath)...")
      let result = try? await ProcessRunner.runRclone(
        ["copy", backupPath, "\(remotePath)/\(name)"] + bwLimitArgs, timeout: 6 * 3600)
      guard result?.succeeded == true else {
        let detail = result?.stderr.isEmpty == false ? result!.stderr : (result?.stdout ?? "")
        return CMActionResult(
          succeeded: false,
          message:
            "Archiwizacja \(name) nie powiodla sie - przerywam, zeby nie zerwac kolejnosci historii. \(detail)"
        )
      }
      archived.insert(name)
      saveArchivedNames(archived)
      copiedCount += 1
      CMLogger.log("[cloud-archive] OK: \(name) zarchiwizowany.")
    }

    guard copiedCount > 0 else {
      return CMActionResult(succeeded: true, message: "Wszystko juz zarchiwizowane, nic do zrobienia.")
    }
    return CMActionResult(
      succeeded: true, message: "Zarchiwizowano \(copiedCount) backup(ow) do Google Drive.")
  }
}
