import Foundation

enum DependencyState: Equatable {
  case unknown
  case checking
  case missing([String])
  case ready
}

enum TimeMachineState: Equatable {
  case unknown
  case notRegistered
  case registered
}

/// Stan lokalnego woluminu backupu (architektura local-first - patrz README).
/// W przeciwienstwie do legacy `MountState`, nie ma tu pojec "montowania"
/// sieciowego - wolumin albo istnieje na dysku, albo nie.
struct LocalVolumeStatus: Equatable {
  var exists: Bool = false
  var mountPoint: String? = nil
  var totalGB: Double? = nil
  var usedGB: Double? = nil
  var freeContainerGB: Double? = nil

  var usedFraction: Double {
    guard let total = totalGB, total > 0, let used = usedGB else { return 0 }
    return min(used / total, 1.0)
  }
}

struct LastRunResult: Equatable {
  var succeeded: Bool
  var message: String
  var date: Date
}

/// Stan warstwy archiwizacji w chmurze (patrz `CloudArchiveService` -
/// kopiuje ukonczone lokalne backupy na Google Drive w tle).
struct CloudArchiveStatusInfo: Equatable {
  var lastArchivedBackup: String? = nil
  var lastArchivedDate: Date? = nil
  var archivedCount: Int = 0
  var pendingCount: Int = 0
}

/// Zywy postep aktualnie trwajacego backupu Time Machine (z `tmutil status`),
/// odswiezany cyklicznie przez `refreshAll()` - `nil`, gdy nic sie akurat
/// nie kopiuje. `transferRateMBs` jest liczone lokalnie (delta bajtow miedzy
/// dwoma odswiezeniami), bo `tmutil` samo w sobie tego nie podaje.
struct BackupProgressInfo: Equatable {
  var phase: String?
  var percent: Double?
  var bytesDone: Double?
  var bytesTotal: Double?
  var filesDone: Int?
  var filesTotal: Int?
  var timeRemainingSeconds: Double?
  var transferRateMBs: Double?
}

@MainActor
final class AppStatus: ObservableObject {
  @Published var dependencyState: DependencyState = .unknown
  @Published var remoteConfigured: Bool = false
  @Published var localVolume = LocalVolumeStatus()
  @Published var timeMachineState: TimeMachineState = .unknown
  @Published var lastBackup: LastRunResult?
  @Published var lastVerify: LastRunResult?
  @Published var lastArchive: LastRunResult?
  @Published var cloudArchive = CloudArchiveStatusInfo()
  @Published var backupProgress: BackupProgressInfo?
  @Published var hasFullDiskAccess: Bool = false
  @Published var currentMachineKey: String = ""
  @Published var isBusy: Bool = false
  @Published var busyLabel: String = ""
  @Published var logTail: String = ""
  /// Ostatni blad do pokazania uzytkownikowi w banerze (Status + menu bar) -
  /// bez tego bledy z akcji byly widoczne tylko w logu.
  @Published var errorMessage: String?
}
