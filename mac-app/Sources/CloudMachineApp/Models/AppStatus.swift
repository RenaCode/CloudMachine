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
  /// Czy powyzsze liczniki w ogole pochodza z odczytu.
  ///
  /// Domyslnie `false` i to jest wazniejsze niz wyglada: swiezo utworzony
  /// `BufferStatus` ma same zera, ktore nie sa pomiarem. Domyslne `true`
  /// znaczyloby "pusta kolejka" i pasek menu swiecilby na zielono, zanim
  /// cokolwiek zostalo sprawdzone.
  var queueKnown: Bool = false
  var erroredFiles: Int = 0
  /// Na Google Drive nie ma miejsca. NIE minie samo.
  var driveFull: Bool = false
  /// Dobowy limit ZAPISU Google (750 GB) wyczerpany. Mija sam.
  ///
  /// Trzymane osobno od `driveFull`, bo to sa dwie rozne sytuacje o tym samym
  /// objawie: jedna znaczy "poczekaj", druga "zwolnij miejsce". Wczesniej byly
  /// jednym polem i interfejs nie mogl ich rozroznic.
  var dailyQuotaExhausted: Bool = false
  /// rclone nie ma gdzie odlozyc danych - bufor pelny samymi niewyslanymi.
  var outOfSpace: Bool = false

  var draining: Bool { uploadsInProgress > 0 || uploadsQueued > 0 }

  /// Jedno zrodlo prawdy o tym, czy kopia dolatuje na Dysk - i dlaczego nie.
  var uploadState: UploadState {
    UploadState.from(
      mounted: mounted,
      queueKnown: queueKnown,
      queued: uploadsQueued,
      inProgress: uploadsInProgress,
      failedFiles: erroredFiles,
      bufferOutOfSpace: outOfSpace,
      driveFull: driveFull,
      dailyQuotaExhausted: dailyQuotaExhausted)
  }
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
    // O wysylce mowi JEDNO zrodlo - inaczej pasek menu i karta stanu potrafily
    // twierdzic co innego. Pliki, ktorych rclone nie wyslal, istnieja WYLACZNIE
    // na tym Macu, czyli dokladnie tam, gdzie backup nie ma prawa byc jedyna
    // kopia; `UploadState` stawia je przed limitem dobowym wlasnie dlatego.
    let upload = buffer.uploadState
    if !upload.isNominal { return upload.headline }
    if backupProgress != nil { return "Backup w toku" }
    if upload.isMovingData { return upload.headline }
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
      case .registered = timeMachineState, buffer.uploadState.isNominal
    else { return false }
    return true
  }
}
