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
/// zabezpieczenia razem gwarantuja, ze zawartosc backupu jest w pelni
/// statyczna podczas kopiowania przez rclone.
///
/// WAZNE - kazdy lokalny backup na wolumenie APFS jest w rzeczywistosci
/// snapshotem APFS (`com.apple.TimeMachine.<nazwa>.backup`), NIE zwyklym,
/// zawsze dostepnym katalogiem - potwierdzone na zywo: `tmutil listbackups`
/// zwraca sciezke pod `/Volumes/.timemachine/<UUID>/...`, ale zwykle
/// `stat`/`rclone` na tej sciezce dostaja "No such file or directory", bo nic
/// nie zamontowalo tego konkretnego snapshotu do globalnej przestrzeni nazw
/// systemu plikow (`diskutil apfs listSnapshots` pokazuje snapshoty, ale
/// `mount` nie pokazuje ich jako zamontowane, dopoki cos jawnie tego nie
/// zrobi - Finder/Migration Assistant robia to pod maska, generyczne
/// narzedzia jak `rclone` - nie). Dlatego kazda archiwizacja NAJPIERW montuje
/// wlasciwy snapshot tymczasowo (`mount_apfs -s`, bez potrzeby sudo - to
/// wolumin wlasny uzytkownika), kopiuje z tego mountu, i odmontowuje zaraz
/// po (patrz `mountSnapshot`/`unmountSnapshot`).
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

  /// Katalog, pod ktorym tymczasowo montujemy dokladnie JEDEN snapshot na
  /// raz do kopiowania - staly, nie unikalny per-proba, bo `archivePending`
  /// i tak trzyma wylaczna blokade `withCMLock` przez caly czas dzialania
  /// (patrz nizej), wiec nie ma ryzyka dwoch rownoleglych montowan tutaj.
  private static var snapshotMountDir: URL {
    CMPaths.appSupportDir.appendingPathComponent("archive-snapshot-mount")
  }

  /// Montuje snapshot APFS danego backupu (`com.apple.TimeMachine.<name>`)
  /// pod `snapshotMountDir`, zeby jego zawartosc byla widoczna dla zwyklych
  /// operacji na plikach (patrz uzasadnienie w komentarzu na gorze pliku).
  /// Zwraca sciezke do faktycznej zawartosci backupu wewnatrz mountu, albo
  /// `nil` przy niepowodzeniu (np. snapshot juz zostal usuniety przez
  /// automatyczne przycinanie Time Machine miedzy `tmutil listbackups` a tym
  /// wywolaniem - lokalny wolumin moze byc pod duza presja miejsca).
  private static func mountSnapshot(backupName: String, volumeMountPoint: String) async
    -> String?
  {
    let mountDir = snapshotMountDir
    try? FileManager.default.removeItem(at: mountDir)
    guard
      (try? FileManager.default.createDirectory(
        at: mountDir, withIntermediateDirectories: true)) != nil
    else { return nil }

    let snapshotName = "com.apple.TimeMachine.\(backupName)"
    let result = try? await ProcessRunner.run(
      "/sbin/mount_apfs", ["-s", snapshotName, volumeMountPoint, mountDir.path], timeout: 30)
    guard result?.succeeded == true else {
      try? FileManager.default.removeItem(at: mountDir)
      return nil
    }
    return mountDir.appendingPathComponent(backupName).path
  }

  /// Odmontowuje i sprzata katalog zamontowany przez `mountSnapshot` -
  /// wywolywane BEZWARUNKOWO po probie kopiowania (sukces czy porazka), zeby
  /// nie zostawic osieroconego mountu snapshotu na kolejny przebieg.
  private static func unmountSnapshot() async {
    let mountDir = snapshotMountDir
    _ = try? await ProcessRunner.run("/usr/sbin/diskutil", ["unmount", mountDir.path], timeout: 30)
    try? FileManager.default.removeItem(at: mountDir)
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
      let result = await withCMLock(
        "archive-watchdog",
        {
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
    // Najnowszy JUZ zarchiwizowany backup (z tego albo poprzedniego przebiegu)
    // - przekazywany do rclone jako `--copy-dest`, zeby pliki niezmienione
    // wzgledem niego trafialy do nowego folderu przez SZYBKA kopie po stronie
    // Google Drive (bez ponownego wysylania tych samych bajtow z Maca).
    // Bez tego kazdy kolejny backup przesylalby caly swoj rozmiar OD NOWA,
    // mimo ze wiekszosc plikow jest identyczna z poprzednim (lokalnie
    // zaoszczedzone dzieki hardlinkom, ktorych `rclone` po prostu nie widzi).
    var previousArchivedName = archived.sorted().last

    for backupPath in backups {
      let name = URL(fileURLWithPath: backupPath).lastPathComponent
      guard !archived.contains(name) else { continue }

      guard let sourcePath = await mountSnapshot(backupName: name, volumeMountPoint: mountPoint)
      else {
        return CMActionResult(
          succeeded: false,
          message:
            "Nie udalo sie zamontowac snapshotu \(name) do archiwizacji (mogl zostac usuniety"
            + " przez Time Machine w miedzyczasie) - przerywam, zeby nie zerwac kolejnosci historii."
        )
      }

      var copyArgs = ["copy", sourcePath, "\(remotePath)/\(name)"] + bwLimitArgs
      if let previousArchivedName {
        copyArgs += ["--copy-dest", "\(remotePath)/\(previousArchivedName)"]
      }
      CMLogger.log("[cloud-archive] Kopiuje \(name) do \(remotePath)...")
      let result = try? await ProcessRunner.runRclone(copyArgs, timeout: 6 * 3600)
      await unmountSnapshot()

      guard result?.succeeded == true else {
        let detail = result?.stderr.isEmpty == false ? result!.stderr : (result?.stdout ?? "")
        return CMActionResult(
          succeeded: false,
          message:
            "Archiwizacja \(name) nie powiodla sie - przerywam, zeby nie zerwac kolejnosci historii."
            + " \(detail)"
        )
      }
      archived.insert(name)
      saveArchivedNames(archived)
      previousArchivedName = name
      copiedCount += 1
      CMLogger.log("[cloud-archive] OK: \(name) zarchiwizowany.")
    }

    guard copiedCount > 0 else {
      return CMActionResult(
        succeeded: true, message: "Wszystko juz zarchiwizowane, nic do zrobienia.")
    }
    return CMActionResult(
      succeeded: true, message: "Zarchiwizowano \(copiedCount) backup(ow) do Google Drive.")
  }
}
