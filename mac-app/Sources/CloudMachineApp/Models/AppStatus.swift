import CloudMachineCore
import Foundation

/// Gotowosc narzedzi, bez ktorych nic nie ruszy.
enum DependencyState: Equatable {
  case unknown
  case checking
  /// Czego brakuje i czym to naprawic - pary (brak, polecenie).
  case missing([String], [String])
  case ready
}

enum TimeMachineState: Equatable {
  case unknown
  /// Time Machine nie wskazuje na nasz obraz - backupu realnie nie ma.
  case notRegistered
  case registered(mountPoint: String)
}

/// Stan bufora miedzy Time Machine a Google Drive.
struct BufferStatus: Equatable {
  var mounted: Bool = false
  var imageAttached: Bool = false
  var sizeGB: Int = 0
  var freeDiskGB: Int = 0
  /// Ile plikow czeka na wyslanie. Ta liczba jest wazniejsza od rozmiaru
  /// bufora: jesli rosnie i nie wraca do zera miedzy backupami, wysylka nie
  /// nadaza za zapisem.
  var uploadsQueued: Int = 0
  var uploadsInProgress: Int = 0
  var erroredFiles: Int = 0
  /// Dobowy limit uploadu Google Drive wyczerpany - do odnowienia trzeba czekac.
  var dailyQuotaHit: Bool = false
  /// rclone nie ma gdzie odlozyc danych - bufor pelny samymi niewyslanymi.
  var outOfSpace: Bool = false

  var draining: Bool { uploadsInProgress > 0 || uploadsQueued > 0 }
}

struct LastRunResult: Equatable {
  var succeeded: Bool
  var message: String
  var date: Date
}

/// Zywy postep trwajacego backupu (`tmutil status`). `nil`, gdy nic sie nie
/// kopiuje. `transferRateMBs` liczymy sami z roznicy bajtow miedzy
/// odswiezeniami - `tmutil` tego nie podaje.
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
  @Published var buffer = BufferStatus()
  @Published var timeMachineState: TimeMachineState = .unknown
  @Published var backupProgress: BackupProgressInfo?
  @Published var lastAction: LastRunResult?
  @Published var hasFullDiskAccess: Bool = false
  @Published var isBusy: Bool = false
  @Published var busyLabel: String = ""
  @Published var logTail: String = ""
  @Published var errorMessage: String?
  /// Kiedy ostatnio udalo sie odczytac stan. Pokazywane w interfejsie, bo
  /// zamrozony widok wyglada dokladnie jak awaria - a to dwie rozne rzeczy
  /// i uzytkownik musi je odroznic bez zagladania do logow.
  @Published var lastRefresh: Date?

  /// Jednozdaniowa odpowiedz na pytanie "czy moje dane sa bezpieczne".
  var headline: String {
    if case .missing(let what, _) = dependencyState {
      return "Brakuje: \(what.joined(separator: ", "))"
    }
    if !remoteConfigured { return "Google Drive niepolaczony" }
    if !buffer.mounted { return "Bufor nie dziala" }
    if !buffer.imageAttached { return "Obraz backupu niepodpiety" }
    if case .notRegistered = timeMachineState { return "Time Machine nie wskazuje na CloudMachine" }
    if buffer.dailyQuotaHit { return "Dobowy limit Google Drive wyczerpany" }
    // Pliki, ktorych rclone nie wyslal, istnieja WYLACZNIE na tym Macu -
    // czyli dokladnie tam, gdzie backup nie ma prawa byc jedyna kopia. To nie
    // jest szczegol do karty nizej, tylko odpowiedz "nie" na pytanie, czy
    // dane sa bezpieczne.
    if buffer.erroredFiles > 0 {
      return "Nie wyslano \(buffer.erroredFiles) plikow na Google Drive"
    }
    if buffer.outOfSpace { return "Bufor pelny - wysylka nie nadaza" }
    if backupProgress != nil { return "Backup w toku" }
    if buffer.draining { return "Wysylanie na Google Drive" }
    return "Gotowe"
  }

  /// Czy stan jest naprawde dobry.
  ///
  /// UWAGA: `erroredFiles` i `outOfSpace` MUSZA tu byc. Bez nich pasek menu
  /// pokazywal zielony znaczek i "Gotowe", podczas gdy czesc pasm obrazu nigdy
  /// nie doleciala na Dysk - a taka kopia moze sie nie otworzyc. Zepsute
  /// wygladalo dokladnie tak samo jak sprawne.
  var healthy: Bool {
    guard case .ready = dependencyState, remoteConfigured, buffer.mounted, buffer.imageAttached,
      case .registered = timeMachineState, !buffer.dailyQuotaHit,
      buffer.erroredFiles == 0, !buffer.outOfSpace
    else { return false }
    return true
  }
}
