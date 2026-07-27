import Foundation

enum DependencyState: Equatable {
  case unknown
  case checking
  case missing([String])
  case ready
}

enum MountState: Equatable {
  case unknown
  case mounting
  case mounted
  case notMounted
  case failed(String)
}

enum TimeMachineState: Equatable {
  case unknown
  case notRegistered
  case registered
}

struct QuotaStatus: Equatable {
  var usedGB: Double = 0
  var limitGB: Int = 0
  var lastChecked: Date? = nil

  var fraction: Double {
    guard limitGB > 0 else { return 0 }
    return min(usedGB / Double(limitGB), 1.0)
  }

  var isNearLimit: Bool { fraction >= 0.9 }
}

/// Realne zajecie calego konta Google Drive (nie tylko folderu tej maszyny) -
/// z `rclone about`. Uzywane do tego, zeby limit per Mac dalo sie ustawic
/// wzgledem faktycznie dostepnego miejsca, a nie recznie zgadywanej liczby.
struct DriveInfo: Equatable {
  var totalGB: Double = 0
  var usedGB: Double = 0
  var freeGB: Double = 0
  var lastChecked: Date? = nil
}

struct LastRunResult: Equatable {
  var succeeded: Bool
  var message: String
  var date: Date
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

/// Ostatnia aktywnosc watchdogow dzialajacych w tle przez launchd (NIE akcji
/// klikanych recznie w GUI - te sa w `lastBackup`/`lastVerify` ponizej).
/// Kazde pole to surowa linia z cloudmachine.log (juz ma swoj znacznik czasu
/// z `cm_log`), albo `nil`, jesli dany watchdog jeszcze nigdy tego nie zrobil.
struct BackgroundActivity: Equatable {
  var lastMountRepair: String?
  var lastVerify: String?
  var lastBackupResume: String?
}

@MainActor
final class AppStatus: ObservableObject {
  @Published var dependencyState: DependencyState = .unknown
  @Published var remoteConfigured: Bool = false
  @Published var mountState: MountState = .unknown
  @Published var timeMachineState: TimeMachineState = .unknown
  @Published var quota: QuotaStatus = QuotaStatus()
  @Published var driveInfo: DriveInfo?
  @Published var lastBackup: LastRunResult?
  @Published var lastVerify: LastRunResult?
  @Published var backupProgress: BackupProgressInfo?
  @Published var backgroundActivity = BackgroundActivity()
  @Published var watchdogInstalled: Bool = false
  /// Osobny od `watchdogInstalled` (ktory pilnuje limitu miejsca) - ten
  /// pilnuje, zeby samo montowanie dysku nie wisialo/nie zawieszalo sie.
  @Published var mountWatchdogInstalled: Bool = false
  @Published var hasFullDiskAccess: Bool = false
  @Published var currentMachineKey: String = ""
  @Published var isBusy: Bool = false
  @Published var busyLabel: String = ""
  @Published var logTail: String = ""
  /// Ostatni blad do pokazania uzytkownikowi w banerze (Status + menu bar) -
  /// bez tego bledy z akcji jak mount/unmount byly widoczne tylko w logu.
  @Published var errorMessage: String?
}
