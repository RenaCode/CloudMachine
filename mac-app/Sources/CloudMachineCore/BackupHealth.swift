import Foundation

/// Odpowiada na jedno pytanie: czy cykl godzinowy NADAL dziala.
///
/// Reszta tego projektu mierzy stan chwilowy - czy montowanie stoi, czy obraz
/// jest podpiety, ile czeka w kolejce. Zaden z tych pomiarow nie wykrywa
/// najgrozniejszej awarii tego systemu: wszystko wyglada na zamontowane
/// i podpiete, a Time Machine od dwoch dni nie dokonczyl ani jednego backupu.
/// Interfejs pokazuje wtedy zielony znaczek i napis "Gotowe".
///
/// Dlatego zrodlem prawdy jest tutaj DATA OSTATNIEJ UDANEJ kopii, a nie stan
/// urzadzen. Licznik, ktory rosnie tylko przy sukcesie, bierzemy od samego
/// macOS: `SnapshotDates` w `/Library/Preferences/com.apple.TimeMachine.plist`
/// dostaje wpis dopiero po ZAKONCZONYM backupie. `AttemptDates` obok niego
/// liczy proby - w tym te, ktore padly - wiec roznica miedzy nimi jest
/// dokladnie tym, czego szukamy.
///
/// Czytamy plik lokalny, a nie `tmutil latestbackup`. To nie jest optymalizacja:
/// `tmutil latestbackup` montuje migawke na wolumenie lezacym na Google Drive
/// i przy chorym montowaniu potrafi wisiec w nieprzerywalnym I/O. Czujka, ktora
/// zawiesza sie dokladnie wtedy, gdy ma zaalarmowac, jest gorsza niz jej brak.
public enum BackupHealth {

  public static let preferencesPath = "/Library/Preferences/com.apple.TimeMachine.plist"

  /// Po tylu godzinach bez UDANEJ kopii uznajemy cykl za zerwany.
  ///
  /// Cykl jest godzinowy, wiec trzy godziny to trzy pominiete przebiegi z rzedu
  /// - za duzo na przypadek. Jednoczesnie zostawia zapas na backup, ktory
  /// trwa dlugo, i na dozorce bufora, ktory celowo wstrzymuje Time Machine
  /// na czas nadganiania wysylki.
  public static let maxAgeHours = 3.0

  /// Pojedyncza rzecz, ktora poszla nie tak. Tekst jest gotowy do pokazania
  /// uzytkownikowi - to jedyna forma, w jakiej ktokolwiek to zobaczy.
  public struct Problem: Equatable {
    public var summary: String
    public var detail: String

    public init(summary: String, detail: String) {
      self.summary = summary
      self.detail = detail
    }
  }

  public struct Report: Equatable {
    public var problems: [Problem]
    public var lastSuccess: Date?
    public var lastAttempt: Date?
    public var healthy: Bool { problems.isEmpty }

    public init(problems: [Problem], lastSuccess: Date?, lastAttempt: Date?) {
      self.problems = problems
      self.lastSuccess = lastSuccess
      self.lastAttempt = lastAttempt
    }
  }

  // MARK: - Odczyt licznika udanych kopii

  /// Daty z preferencji Time Machine dla celu pod wskazanym punktem
  /// montowania. Czysta funkcja - bierze juz odczytany slownik, zeby dalo sie
  /// ja sprawdzic testem bez pliku systemowego i bez Time Machine.
  ///
  /// `result` to pole `RESULT` z tego samego bloku: 0 znaczy, ze ostatni
  /// przebieg skonczyl sie dobrze, cokolwiek innego - ze nie.
  public static func dates(
    inPreferences plist: [String: Any], volumeNamed volumeName: String
  ) -> (lastSuccess: Date?, lastAttempt: Date?, result: Int?) {
    guard let destinations = plist["Destinations"] as? [[String: Any]] else {
      return (nil, nil, nil)
    }
    // Cel wybieramy po nazwie wolumenu, nie po indeksie 0 - Mac moze miec
    // zarejestrowanych kilka celow Time Machine, a nas obchodzi wylacznie ten.
    let destination =
      destinations.first { ($0["LastKnownVolumeName"] as? String) == volumeName }
      ?? (destinations.count == 1 ? destinations[0] : nil)
    guard let destination else { return (nil, nil, nil) }

    let snapshots = (destination["SnapshotDates"] as? [Date]) ?? []
    let attempts = (destination["AttemptDates"] as? [Date]) ?? []
    let result = (destination["RESULT"] as? NSNumber)?.intValue

    return (snapshots.max(), attempts.max(), result)
  }

  /// Ocena stanu. Czysta funkcja - kazde wejscie podaje sie wprost, wiec
  /// wstrzykniecie ZNANEJ ZLEJ probki (stara data, niezerowy RESULT, martwe
  /// montowanie) jest jednym wywolaniem w tescie, a nie psuciem produkcji.
  public static func evaluate(
    lastSuccess: Date?,
    lastAttempt: Date?,
    result: Int?,
    now: Date,
    mounted: Bool,
    attached: Bool,
    destinationRegistered: Bool,
    erroredFiles: Int,
    outOfSpace: Bool,
    queueReadable: Bool,
    driveFreeBytes: UInt64? = nil,
    localFreeGB: Int? = nil,
    maxAgeHours: Double = BackupHealth.maxAgeHours
  ) -> Report {
    var problems: [Problem] = []

    // Kolejnosc od przyczyny do skutku: jesli montowanie lezy, wiek kopii
    // i tak bedzie rosl, ale to montowanie trzeba naprawic.
    if !mounted {
      problems.append(
        Problem(
          summary: "Montowanie Google Drive nie dziala",
          detail: "Bez niego obraz backupu jest nieosiagalny i Time Machine nie ma gdzie pisac."))
    }
    if !attached {
      problems.append(
        Problem(
          summary: "Obraz backupu nie jest podpiety",
          detail: "Time Machine nie widzi celu \(BackupImageService.targetPath.path)."))
    }
    if !destinationRegistered {
      problems.append(
        Problem(
          summary: "Time Machine nie wskazuje na CloudMachine",
          detail: "Cel backupu zostal przestawiony albo wyrejestrowany - kopie nie powstaja."))
    }

    // TO jest licznik, ktory rosnie wylacznie przy sukcesie.
    if let lastSuccess {
      let age = now.timeIntervalSince(lastSuccess)
      if age > maxAgeHours * 3600 {
        problems.append(
          Problem(
            summary: "Brak udanej kopii od \(formatAge(age))",
            detail:
              "Ostatnia ZAKONCZONA kopia: \(stamp(lastSuccess)). Cykl jest godzinowy, wiec to \(max(1, Int(age / 3600))) pominietych przebiegow."
          ))
      }
    } else {
      problems.append(
        Problem(
          summary: "Nie ma ANI JEDNEJ udanej kopii",
          detail:
            "Preferencje Time Machine nie zawieraja zadnej daty zakonczonego backupu dla tego celu."
        ))
    }

    // Proba bez sukcesu po niej to backup, ktory ruszyl i padl. Sam wiek
    // ostatniego sukcesu tego nie pokaze, dopoki nie przekroczy progu.
    if let lastAttempt, let lastSuccess, lastAttempt > lastSuccess,
      now.timeIntervalSince(lastAttempt) > 3600
    {
      problems.append(
        Problem(
          summary: "Ostatnia proba backupu nie skonczyla sie kopia",
          detail:
            "Proba \(stamp(lastAttempt)) jest nowsza niz ostatnia udana kopia \(stamp(lastSuccess))."
        ))
    }

    if let result, result != 0 {
      problems.append(
        Problem(
          summary: "Time Machine zglasza blad ostatniego przebiegu (RESULT=\(result))",
          detail: "Niezerowy RESULT w preferencjach Time Machine znaczy, ze przebieg sie nie udal.")
      )
    }

    if erroredFiles > 0 {
      problems.append(
        Problem(
          summary: "rclone nie wyslal \(erroredFiles) plikow",
          detail:
            "Te pasma obrazu istnieja tylko lokalnie. Kopia na Google Drive jest NIEPELNA i moze sie nie otworzyc."
        ))
    }
    if outOfSpace {
      problems.append(
        Problem(
          summary: "Bufor pelny samymi niewyslanymi danymi",
          detail: "rclone nie ma juz czego usunac z bufora - wysylka nie nadaza albo stoi."))
    }
    if !queueReadable && mounted {
      problems.append(
        Problem(
          summary: "Interfejs sterujacy rclone nie odpowiada",
          detail:
            "Bez niego nie da sie sprawdzic, czy cokolwiek dolecialo na Dysk - dozorca bufora jest wtedy slepy."
        ))
    }

    // Miejsce na Dysku. Wyczerpanie go jest dla rclone bledem FATALNYM, wiec
    // montowanie znika i Time Machine traci cel - o tym trzeba wiedziec
    // WCZESNIEJ, a nie z awarii. Prog liczony w cyklach, nie w procentach:
    // przy przyroscie ~600 MB na godzine 30 GB to okolo dwoch tygodni zapasu.
    if let driveFreeBytes {
      let freeGB = Int(driveFreeBytes / 1_073_741_824)
      if freeGB < driveFreeWarningGB {
        problems.append(
          Problem(
            summary: "Konczy sie miejsce na Google Drive (\(freeGB) GB)",
            detail:
              "Po wyczerpaniu rclone konczy prace z bledem storageQuotaExceeded, montowanie znika i backupy przestaja powstawac. Przy przyroscie ~600 MB na cykl godzinowy to okolo \(max(1, freeGB * 1024 / 600 / 24)) dni."
          ))
      }
    }

    if let localFreeGB, localFreeGB < localFreeWarningGB {
      problems.append(
        Problem(
          summary: "Konczy sie miejsce na dysku Maca (\(localFreeGB) GB)",
          detail:
            "Bufor wysylki lezy na tym dysku. Gdy sie zapelni, dozorca wstrzyma Time Machine, a przy calkowitym braku miejsca rclone nie ma gdzie odlozyc danych czekajacych na wyslanie."
        ))
    }

    return Report(problems: problems, lastSuccess: lastSuccess, lastAttempt: lastAttempt)
  }

  /// Ponizej tylu GB wolnych na Google Drive zglaszamy problem.
  public static let driveFreeWarningGB = 30
  /// Ponizej tylu GB wolnych lokalnie zglaszamy problem. Wyzej niz prog pauzy
  /// dozorcy bufora - czujka ma ostrzegac, zanim dozorca zacznie hamowac.
  public static let localFreeWarningGB = 120

  // MARK: - Odczyt na zywo

  public static func currentReport(
    now: Date = Date(), maxAgeHours: Double = BackupHealth.maxAgeHours
  ) async -> Report {
    let plist =
      (try? Data(contentsOf: URL(fileURLWithPath: preferencesPath)))
      .flatMap {
        try? PropertyListSerialization.propertyList(from: $0, format: nil) as? [String: Any]
      }
      ?? nil

    guard let plist else {
      return Report(
        problems: [
          Problem(
            summary: "Nie da sie odczytac preferencji Time Machine",
            detail:
              "\(preferencesPath) jest nieczytelny - najczesciej brak Pelnego dostepu do dysku. Bez tego pliku NIE WIADOMO, kiedy ostatnio powstala kopia, wiec traktujemy to jak awarie, a nie jak brak problemu."
          )
        ], lastSuccess: nil, lastAttempt: nil)
    }

    let (lastSuccess, lastAttempt, result) = dates(
      inPreferences: plist, volumeNamed: BackupImageService.volumeName)

    let stats = await DriveBufferService.queueStats()
    let registered =
      await TimeMachineStatus.currentDestinationMountPoint() == BackupImageService.targetPath.path

    return evaluate(
      lastSuccess: lastSuccess,
      lastAttempt: lastAttempt,
      result: result,
      now: now,
      mounted: DriveBufferService.isMounted,
      attached: BackupImageService.isAttached,
      destinationRegistered: registered,
      erroredFiles: stats?.erroredFiles ?? 0,
      outOfSpace: stats?.outOfSpace ?? false,
      queueReadable: stats != nil,
      // Nieczytelna pojemnosc Dysku NIE jest tu osobnym alarmem: gdy rclone
      // nie odpowiada, mowia o tym juz twardsze sygnaly powyzej, a drugi
      // komunikat o tym samym tylko rozmywa ten pierwszy.
      driveFreeBytes: (await DriveBufferService.remoteQuota())?.free,
      localFreeGB: BufferGuardService.freeGB(),
      maxAgeHours: maxAgeHours)
  }

  // MARK: - Formatowanie

  /// Wiek slowami. Minuty ponizej dwoch godzin - inaczej przy niskim progu
  /// komunikat brzmi "Brak udanej kopii od 0 h", co nie znaczy nic.
  static func formatAge(_ seconds: TimeInterval) -> String {
    let hours = Int(seconds / 3600)
    if hours < 2 { return "\(Int(seconds / 60)) min" }
    if hours < 48 { return "\(hours) h" }
    return "\(hours / 24) dni"
  }

  public static func stamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
  }
}
