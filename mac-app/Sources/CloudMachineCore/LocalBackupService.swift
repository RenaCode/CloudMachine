import Foundation

/// Odczytuje stan lokalnego celu Time Machine w architekturze "local-first":
/// prawdziwy lokalny wolumin APFS jako cel backupu (bez montowania
/// sieciowego/sparsebundle - patrz legacy `MountService`/`UnmountService`
/// usuniete razem z ta zmiana). Tworzenie woluminu i rejestrowanie go jako
/// cel Time Machine NIE jest juz zadaniem tej apki - uzytkownik robi to sam
/// (System Settings -> Time Machine), ta warstwa tylko CZYTA, gdziekolwiek
/// wskazuje aktualnie zarejestrowany cel, zeby archiwizacja do chmury
/// (`CloudArchiveService`) i weryfikacja sum kontrolnych (`BackupVerifier`/
/// `VerifyWatchdogService`) mialy skad kopiowac/co sprawdzac.
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
}
