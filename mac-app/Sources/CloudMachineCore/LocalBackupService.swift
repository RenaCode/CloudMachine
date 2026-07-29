import Foundation

/// Zarzadza lokalnym celem Time Machine w architekturze "local-first": prawdziwy
/// lokalny wolumin APFS jako cel backupu (bez montowania sieciowego/sparsebundle -
/// patrz legacy `MountService`/`UnmountService` usuniete razem z ta zmiana), z
/// oddzielnym, jeszcze nie zaimplementowanym zadaniem archiwizujacym ukonczone
/// backupy do Google Drive (patrz README - sekcja o architekturze).
public enum LocalBackupService {
  public static let defaultVolumeName = "CloudMachine-Local"

  public struct VolumeStatus: Equatable {
    public var exists: Bool
    public var mountPoint: String?
    public var totalGB: Double?
    public var usedGB: Double?
    public var freeContainerGB: Double?
    public var destinationID: String?
  }

  /// Znajduje kontener APFS dysku rozruchowego (np. "disk3") - tam tworzymy
  /// nowy wolumin lokalnego backupu, dzielacy wolna przestrzen z reszta dysku.
  public static func bootContainerDiskID() async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["info", "-plist", "/"], timeout: 15),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let plist = try? PropertyListSerialization.propertyList(from: data, format: nil)
        as? [String: Any]
    else {
      return nil
    }
    return plist["APFSContainerReference"] as? String
  }

  /// Sprawdza, czy wolumin o danej nazwie juz istnieje w podanym kontenerze.
  public static func currentStatus(volumeName: String = defaultVolumeName) async -> VolumeStatus {
    // Najpierw pytamy Time Machine o RZECZYWISTY zarejestrowany mount point -
    // dziala niezaleznie od tego, jak nazwany jest wolumin. Zgadywanie po
    // `volumeName` to tylko fallback na czas konfiguracji, zanim jakikolwiek
    // cel zostanie zarejestrowany (patrz komentarz w TimeMachineStatus).
    let mountPoint =
      await TimeMachineStatus.currentDestinationMountPoint() ?? "/Volumes/\(volumeName)"
    guard
      let result = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["info", "-plist", mountPoint], timeout: 15),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let plist = try? PropertyListSerialization.propertyList(from: data, format: nil)
        as? [String: Any]
    else {
      return VolumeStatus(
        exists: false, mountPoint: nil, totalGB: nil, usedGB: nil, freeContainerGB: nil,
        destinationID: nil)
    }
    // WAZNE: `diskutil info -plist` NIE ma klucza "VolumeUsedSpace" (ani
    // "ContainerTotalFreeSpace") dla wolumenu APFS - potwierdzone na zywo:
    // te odczyty ZAWSZE zwracaly `nil`, przez co StatusView (ktore wymaga
    // OBU `totalGB` i `usedGB` naraz do pokazania cokolwiek) zawsze
    // pokazywalo "Brak lokalnego woluminu", mimo ze wolumin istnial i
    // dzialal. Faktyczne wykorzystanie TEJ konkretnej objetosci to
    // "CapacityInUse", a realnie wolne miejsce w kontenerze to
    // "APFSContainerFree" - `TotalSize`/`Size` to pojemnosc CALEGO
    // kontenera (dzielona ze wszystkimi wolumenami), nie limit tego
    // wolumenu, wiec dla "total" wolimy limit TM z `tmutil destinationinfo`
    // (Quota), jesli jest dostepny - duzo bardziej znaczacy dla uzytkownika
    // niz surowa pojemnosc calego dysku.
    let usedBytes = plist["CapacityInUse"] as? Double
    let freeBytes = plist["APFSContainerFree"] as? Double
    let quotaGB = await TimeMachineStatus.destinationQuotaGB(forMountPointContaining: mountPoint)
    let totalGB = quotaGB ?? (plist["TotalSize"] as? Double).map { $0 / 1_073_741_824 }
    let destinationID = await TimeMachineStatus.destinationID(
      forMountPointContaining: mountPoint)
    return VolumeStatus(
      exists: true,
      mountPoint: mountPoint,
      totalGB: totalGB,
      usedGB: usedBytes.map { $0 / 1_073_741_824 },
      freeContainerGB: freeBytes.map { $0 / 1_073_741_824 },
      destinationID: destinationID
    )
  }

  /// Tworzy nowy lokalny wolumin APFS z limitem (quota - sufit, NIE gwarancja
  /// faktycznie dostepnego miejsca, ktore zalezy od realnie wolnej przestrzeni
  /// w kontenerze - patrz komentarz w README o roznicy miedzy quota a realnym
  /// wolnym miejscem). Celowo BEZ `-role B`: w testach ten parametr powodowal
  /// blad "-69624: Unable to add a new APFS Volume" - macOS i tak automatycznie
  /// oznacza wolumin rola "Backup" po zarejestrowaniu go w Time Machine.
  public static func createVolume(
    name: String = defaultVolumeName, quotaGB: Int
  ) async -> CMActionResult {
    guard let container = await bootContainerDiskID() else {
      return CMActionResult(
        succeeded: false, message: "Nie udalo sie ustalic kontenera APFS dysku rozruchowego.")
    }
    let result = try? await ProcessRunner.run(
      "/usr/sbin/diskutil",
      ["apfs", "addVolume", container, "APFS", name, "-quota", "\(quotaGB)G"], timeout: 60)
    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: "Nie udalo sie utworzyc woluminu: \(result?.stderr ?? result?.stdout ?? "?")")
    }
    return CMActionResult(succeeded: true, message: "Utworzono wolumin \(name) (\(quotaGB)GB).")
  }

  /// Rejestruje wolumin jako cel Time Machine, usuwajac poprzedni cel (jesli
  /// inny) - w tej architekturze mamy zawsze dokladnie JEDEN aktywny cel
  /// lokalny, w przeciwienstwie do legacy sieciowego podejscia, ktore mogло
  /// tolerowac rotacje wielu celow.
  public static func setAsDestination(volumeName: String = defaultVolumeName) async
    -> CMActionResult
  {
    let mountPoint = "/Volumes/\(volumeName)"
    guard FileManager.default.fileExists(atPath: mountPoint) else {
      return CMActionResult(succeeded: false, message: "Wolumin \(mountPoint) nie istnieje.")
    }
    for old in await TimeMachineStatus.allDestinationIDs() {
      _ = try? await ProcessRunner.run(
        "/usr/bin/sudo", ["-n", "/usr/bin/tmutil", "removedestination", old], timeout: 30)
    }
    let result = try? await ProcessRunner.run(
      "/usr/bin/sudo", ["-n", "/usr/bin/tmutil", "setdestination", "-a", mountPoint], timeout: 30)
    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message:
          "Nie udalo sie zarejestrowac celu Time Machine: \(result?.stderr ?? result?.stdout ?? "?")",
        isSudoAuthFailure: result?.isSudoAuthFailure ?? false
      )
    }
    return CMActionResult(
      succeeded: true, message: "Zarejestrowano \(mountPoint) jako cel Time Machine.")
  }
}
