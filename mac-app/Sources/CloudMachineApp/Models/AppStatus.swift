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
  /// `tmutil` NIE ODPOWIEDZIAL w limicie czasu, wiec o celu nie wiemy nic.
  ///
  /// Osobny stan z tego samego powodu, co `TimeMachineStatus.DestinationReading.noAnswer`
  /// i `BufferStatus.queueKnown`: brak odpowiedzi nie ma prawa udawac wyniku.
  /// Panel wyswietlal tu do 25.09.2026 "Time Machine nie wskazuje na
  /// CloudMachine" - zdanie prawdziwie brzmiace i falszywe, ktore wysyla
  /// czlowieka rejestrowac cel na nowo, podczas gdy cel jest caly, a zawiesil
  /// sie odczyt (`tmutil destinationinfo` siega na montowanie na Google Drive).
  case noAnswer
  case registered(mountPoint: String)
}

extension TimeMachineState {
  /// Przeklada odpowiedz `tmutil` na stan panelu.
  ///
  /// Wydzielone z `CloudMachineController.refreshTimeMachine()` i czyste,
  /// zeby dalo sie testem pokazac, ze TRZY odpowiedzi daja TRZY stany.
  /// Wczesniej kontroler pytal `currentDestinationMountPoint()`, ktora zwraca
  /// `nil` i przy braku celu, i przy braku odpowiedzi - obie sciezki
  /// konczyly sie wiec tym samym `.notRegistered`. Czujka `backup-health`
  /// rozrozniala je od 23.09.2026 (`destinationReading()`), panel nie.
  static func from(_ reading: TimeMachineStatus.DestinationReading, target: String)
    -> TimeMachineState
  {
    switch reading {
    case .mountPoint(let path):
      return path == target ? .registered(mountPoint: path) : .notRegistered
    case .none: return .notRegistered
    case .noAnswer: return .noAnswer
    }
  }
}

/// Stan bufora miedzy Time Machine a Google Drive.
struct BufferStatus: Equatable {
  var mounted: Bool = false
  var imageAttached: Bool = false
  var sizeGB: Int = 0
  /// `nil` = pomiaru NIE BYLO (statfs zawiodl), a nie "zero gigabajtow" -
  /// patrz `BufferGuardService.freeGB()`. To samo rozroznienie, co
  /// `queueKnown` nizej.
  var freeDiskGB: Int?
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

/// Czy cykl backupu NADAL dziala - mierzone data ostatniej UDANEJ kopii.
///
/// Do 23.09.2026 interfejs nie zadawal tego pytania ani razu: `grep -rn
/// "BackupHealth" Sources/CloudMachineApp/` nie dawal ani jednego trafienia.
/// Panel liczyl zdrowie wylacznie ze stanu URZADZEN - montowanie, obraz, cel
/// Time Machine, kolejka - czyli ze stanu CHWILOWEGO. Awaria opisana
/// w naglowku `BackupHealth` jako najgrozniejsza wyglada dokladnie odwrotnie:
/// wszystko zamontowane, obraz podpiety, kolejka pusta, a Time Machine od
/// dwoch dni nie dokonczyl kopii. Panel swiecil wtedy "Sprawny / Gotowe".
struct BackupCycleStatus: Equatable {
  /// Czy udalo sie w ogole odczytac preferencje Time Machine.
  ///
  /// Domyslnie `false` i to jest wazniejsze, niz wyglada - tak samo jak przy
  /// `queueKnown`: swiezo utworzony stan nie jest pomiarem, a brak Pelnego
  /// dostepu do dysku (najczestsza przyczyna nieczytelnego pliku preferencji)
  /// nie moze uchodzic za brak problemu.
  var known: Bool = false
  /// Data ostatniej ZAKONCZONEJ kopii. `nil` = nie ma ani jednej.
  var lastSuccess: Date?
  /// Gotowe zdania z `BackupHealth.Report` - do pokazania bez tlumaczenia.
  var problems: [String] = []
  /// Kiedy ostatnio pytalismy (czujka chodzi rzadziej niz odswiezanie panelu).
  var checkedAt: Date?

  func age(now: Date = Date()) -> TimeInterval? {
    lastSuccess.map { now.timeIntervalSince($0) }
  }

  /// Czy ostatnia UDANA kopia jest dostatecznie swieza.
  ///
  /// Brak odczytu i brak kopii daja `false` - jedno i drugie znaczy, ze nikt
  /// nie potwierdzil, ze backup dziala, a zielony znaczek jest wlasnie takim
  /// potwierdzeniem.
  func isFresh(now: Date = Date(), maxAgeHours: Double = BackupHealth.maxAgeHours) -> Bool {
    guard known, let age = age(now: now) else { return false }
    return age <= maxAgeHours * 3600
  }

  /// Wiek slowami, do wiersza w panelu.
  func ageText(now: Date = Date()) -> String {
    guard known else { return "nie sprawdzono" }
    guard let age = age(now: now) else { return "ani jednej" }
    return "\(BackupHealth.formatAge(age)) temu"
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
  /// Odpowiedz na pytanie "kiedy ostatnio powstala KOPIA" - jedyna miara,
  /// ktora rosnie wylacznie przy sukcesie.
  @Published var backupCycle = BackupCycleStatus()
  @Published var timeMachineState: TimeMachineState = .unknown
  /// Kiedy czujka `backup-health` ostatnio PRZEBIEGLA. `nil` = panel jeszcze
  /// nie pytal (nie: "nie przebiegla nigdy" - to osobny stan `.never`).
  ///
  /// Panel pokazuje to z tego samego powodu, dla ktorego pokazuje wiek ostatniej
  /// kopii: czujka chodzi z `StartInterval 1800` i bez `KeepAlive`, wiec
  /// wyladowana albo zawieszona nie daje zadnego objawu poza cisza - a cisza
  /// jest tu stanem normalnym.
  ///
  /// CELOWO nie wchodzi do `healthy`: swiezosc kopii panel liczy SAM, z tego
  /// samego pliku preferencji, z ktorego liczy ja czujka. Martwa czujka nie
  /// znaczy wiec, ze backup nie dziala - znaczy, ze nikt o awarii nie donosi,
  /// a to inna awaria i ma swoj wlasny, czerwony wiersz.
  @Published var watchdog: WatchdogHeartbeat.Freshness?
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

  /// Czy czujka backupu CHODZI. `false` takze wtedy, gdy panel jeszcze nie
  /// pytal - niesprawdzone nie ma prawa swiecic na zielono, tak samo jak
  /// `queueKnown` i `BackupCycleStatus.known`.
  var watchdogRunning: Bool {
    if case .fresh = watchdog { return true }
    return false
  }

  /// Jednozdaniowa odpowiedz na pytanie "czy moje dane sa bezpieczne".
  var headline: String {
    if case .missing(let what, _) = dependencyState {
      return "Brakuje: \(what.joined(separator: ", "))"
    }
    if !remoteConfigured { return "Google Drive niepolaczony" }
    if !buffer.mounted { return "Bufor nie dziala" }
    if !buffer.imageAttached { return "Obraz backupu niepodpiety" }
    if case .notRegistered = timeMachineState { return "Time Machine nie wskazuje na CloudMachine" }
    // Brak odpowiedzi tmutil MUSI brzmiec inaczej niz przestawiony cel: to
    // pierwsze zdanie, ktore czlowiek czyta, i ono decyduje, co zrobi.
    // "Nie wskazuje" kaze rejestrowac cel na nowo - czynnosc zbedna i myszlaca,
    // gdy cel jest caly, a zawiesil sie odczyt.
    if case .noAnswer = timeMachineState {
      return "NIE WIADOMO, czy Time Machine wskazuje na CloudMachine - tmutil nie odpowiedzial"
    }
    // O wysylce mowi JEDNO zrodlo - inaczej pasek menu i karta stanu potrafily
    // twierdzic co innego. Pliki, ktorych rclone nie wyslal, istnieja WYLACZNIE
    // na tym Macu, czyli dokladnie tam, gdzie backup nie ma prawa byc jedyna
    // kopia; `UploadState` stawia je przed limitem dobowym wlasnie dlatego.
    let upload = buffer.uploadState
    if !upload.isNominal { return upload.headline }
    if backupProgress != nil { return "Backup w toku" }
    // Stan urzadzen moze byc nienaganny, a kopii moze nie byc od dwoch dni.
    // To zdanie musi paść PRZED "Gotowe", bo inaczej naglowek zaprzecza
    // znaczkowi obok (healthy = false, a napis "Gotowe").
    if !backupCycle.isFresh() {
      guard backupCycle.known else { return "Nie wiadomo, kiedy powstała ostatnia kopia" }
      guard let age = backupCycle.age() else { return "Nie ma ani jednej ukończonej kopii" }
      return "Brak ukończonej kopii od \(BackupHealth.formatAge(age))"
    }
    if upload.isMovingData { return upload.headline }
    return "Gotowe"
  }

  /// Czy stan jest naprawde dobry.
  ///
  /// UWAGA: `erroredFiles` i `outOfSpace` MUSZA tu byc. Bez nich pasek menu
  /// pokazywal zielony znaczek i "Gotowe", podczas gdy czesc pasm obrazu nigdy
  /// nie doleciala na Dysk - a taka kopia moze sie nie otworzyc. Zepsute
  /// wygladalo dokladnie tak samo jak sprawne.
  ///
  /// UWAGA DRUGA, z 23.09.2026: `backupCycle` MUSI tu byc z tego samego
  /// powodu. Wszystkie pozostale warunki opisuja stan URZADZEN w tej chwili
  /// i kazdy z nich moze byc spelniony, gdy od dwoch dni nie powstala zadna
  /// kopia. Zielony znaczek ma znaczyc "dane sa bezpieczne", a to wynika
  /// wylacznie z tego, ze kopia POWSTALA - nie z tego, ze dysk jest podpiety.
  var healthy: Bool {
    guard case .ready = dependencyState, remoteConfigured, buffer.mounted, buffer.imageAttached,
      case .registered = timeMachineState, buffer.uploadState.isNominal,
      backupCycle.isFresh()
    else { return false }
    return true
  }
}
