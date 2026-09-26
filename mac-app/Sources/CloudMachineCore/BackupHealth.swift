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
///
/// To zdanie bylo do 23.09.2026 deklaracja, a nie faktem: `currentReport()`
/// wola `tmutil destinationinfo` (po cel Time Machine), a ten odczyt siega
/// na montowanie i BEZ LIMITU CZASU wisial w nieprzerywalnym I/O dokladnie
/// tak, jak `latestbackup`, przed ktorym ten komentarz ostrzega. Od tej daty
/// kazde wywolanie tmutil ma twardy limit (`TimeMachineStatus.commandTimeout`),
/// a brak odpowiedzi jest zglaszany jako AWARIA - nie jako "cel przestawiony"
/// i nie jako cisza.
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
    /// Czy licznik udanych kopii w ogole dalo sie ODCZYTAC.
    ///
    /// Bez tego pola `lastSuccess == nil` znaczylo dwie zupelnie rozne rzeczy:
    /// "Time Machine nie zrobil ani jednej kopii" i "nie mamy dostepu do
    /// pliku, wiec nic nie wiemy". Kto czyta ten raport (np. panel GUI), musi
    /// je rozroznic, zeby nie pokazac braku wiedzy jako faktu.
    public var preferencesReadable: Bool
    public var healthy: Bool { problems.isEmpty }

    public init(
      problems: [Problem], lastSuccess: Date?, lastAttempt: Date?,
      preferencesReadable: Bool = true
    ) {
      self.problems = problems
      self.lastSuccess = lastSuccess
      self.lastAttempt = lastAttempt
      self.preferencesReadable = preferencesReadable
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
    mounted: Bool?,
    attached: Bool?,
    destinationRegistered: Bool?,
    erroredFiles: Int,
    outOfSpace: Bool,
    queueReadable: Bool,
    driveFreeBytes: UInt64? = nil,
    localFreeGB: Int? = nil,
    imageDeadErrno: Int32? = nil,
    // Obraz JEST w tablicy montowan, ale sonda czytelnosci nie wrocila.
    // Chodzi w parze z `attached: nil` i sluzy WYLACZNIE do tego, by
    // powiedziec czlowiekowi, czego dokladnie nie wiemy - decyzja jest ta sama.
    imageProbeTimedOut: Bool = false,
    maxAgeHours: Double = BackupHealth.maxAgeHours
  ) -> Report {
    var problems: [Problem] = []

    // Kolejnosc od przyczyny do skutku: jesli montowanie lezy, wiek kopii
    // i tak bedzie rosl, ale to montowanie trzeba naprawic.
    //
    // `mounted` i `attached` sa TROJSTANOWE z tego samego powodu, co
    // `destinationRegistered` nizej: odczyt tablicy montowan moze sie nie
    // udac, a wtedy nie wiemy ani ze jest, ani ze nie ma. Zlanie tego
    // w `Bool` konczylo sie dwojako i oba sposoby byly zle - `?? false`
    // dawalo alarm o odmontowanym Dysku, ktory moze byc zamontowany,
    // a `!= .detached` dawalo CISZE o obrazie, o ktorym nie wiemy nic.
    switch mounted {
    case .some(true):
      break
    case .some(false):
      problems.append(
        Problem(
          summary: "Montowanie Google Drive nie dziala",
          detail: "Bez niego obraz backupu jest nieosiagalny i Time Machine nie ma gdzie pisac."))
    case .none:
      problems.append(
        Problem(
          summary: "Nie wiadomo, czy montowanie Google Drive dziala",
          detail:
            "Nie udalo sie odczytac tablicy montowan. To nie znaczy, ze Dysk jest odmontowany - znaczy, ze nikt tego nie sprawdzil. Bez tej odpowiedzi nie da sie stwierdzic, czy kopie maja gdzie powstawac."
        ))
    }

    switch attached {
    case .some(true):
      if let errno = imageDeadErrno {
        // Podpiety, ale martwy - stan, ktory do 22 wrz 2026 nie istnial dla
        // zadnego czujnika i przez to trwal 15 godzin. Patrz `ImageProbe`.
        problems.append(
          Problem(
            summary: "Obraz backupu jest podpiety, ale MARTWY (errno \(errno))",
            detail:
              "Urzadzenie obrazu przestalo oddawac dane - Time Machine widzi to jako odlaczony dysk. "
              + "Naprawa: cloudmachine-agent attach-image (odpina na sile i podpina na nowo)."))
      }
    case .some(false):
      problems.append(
        Problem(
          summary: "Obraz backupu nie jest podpiety",
          detail: "Time Machine nie widzi celu \(BackupImageService.targetPath.path)."))
    case .none:
      // TA cisza. Do 23.09.2026 wolajacy przekazywal tu `attachment !=
      // .detached`, wiec nowy przypadek `.unknown` ("tablicy montowan nie
      // udalo sie odczytac") wpadal na `true` - czyli "podpiety". Czujka,
      // ktorej JEDYNYM zadaniem jest nie twierdzic rzeczy, ktorych nie wie,
      // milczala o stanie, ktorego nie znala. Komunikat musi byc INNY niz
      // przy realnym odpieciu: "nie jest podpiety" wysyla czlowieka do
      // podpinania obrazu, ktory moze byc podpiety poprawnie.
      // Dwie przyczyny "nie wiem" i DWA rozne komunikaty, bo wysylaja czlowieka
      // w dwa rozne miejsca. Trzeci moment, w ktorym to samo rozroznienie
      // ratuje ten raport - patrz `mounted` wyzej i `destinationRegistered`
      // nizej.
      if imageProbeTimedOut {
        problems.append(
          Problem(
            summary: "Nie wiadomo, czy obraz backupu oddaje dane",
            detail:
              "Obraz \(BackupImageService.targetPath.path) figuruje w tablicy montowan, ale sonda czytelnosci nie odpowiedziala w \(Int(ImageProbe.probeTimeout)) s - tak zachowuje sie odczyt zablokowany na martwym montowaniu FUSE-T. To NIE jest dowod, ze obraz jest martwy, wiec NIE odpinaj go na sile: `attach-image` swiadomie nic wtedy nie robi, bo odpiecie zywego urzadzenia porzuca dane czekajace na wysylke. Sprawdz najpierw, czy rclone odpowiada (cloudmachine-agent drive-status) i czy agent gdrive-buffer zyje."
          ))
      } else {
        problems.append(
          Problem(
            summary: "Nie wiadomo, czy obraz backupu jest podpiety",
            detail:
              "Nie udalo sie odczytac tablicy montowan, wiec stan obrazu \(BackupImageService.targetPath.path) jest NIEZNANY. Nie podpinaj go na oslepe - najpierw sprawdz, czy `mount` w ogole odpowiada (przy martwym montowaniu FUSE-T potrafi wisiec)."
          ))
      }
    }
    // `nil` to NIE to samo co `false`. Od 23.09.2026 `tmutil` ma limit czasu
    // (patrz `TimeMachineStatus.commandTimeout`), wiec przy martwym montowaniu
    // czujka wraca z brakiem odpowiedzi zamiast wisiec. Brak odpowiedzi jest
    // AWARIA - ale inna niz przestawiony cel, i musi brzmiec inaczej, zeby nie
    // wyslac czlowieka do przestawiania czegos, co jest ustawione dobrze.
    switch destinationRegistered {
    case .some(true):
      break
    case .some(false):
      problems.append(
        Problem(
          summary: "Time Machine nie wskazuje na CloudMachine",
          detail: "Cel backupu zostal przestawiony albo wyrejestrowany - kopie nie powstaja."))
    case .none:
      problems.append(
        Problem(
          summary: "tmutil nie odpowiada - nie wiadomo, gdzie idzie backup",
          detail:
            "Odczyt celu Time Machine nie wrocil w \(Int(TimeMachineStatus.commandTimeout)) s. Tak zachowuje sie tmutil zablokowany na martwym montowaniu Google Drive. Naprawa: cloudmachine-agent attach-image, a gdy to nie pomoze - restart agenta gdrive-buffer."
        ))
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
    // `mounted == true`, nie `mounted != false`: gdy montowania nie ma ALBO
    // nie wiadomo, czy jest, mowia o tym juz twardsze komunikaty wyzej, a
    // drugi komunikat o tym samym tylko rozmywa ten pierwszy.
    if !queueReadable && mounted == true {
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

  /// Czy plik, z ktorego czytamy historie kopii, DA SIE PRZECZYTAC.
  ///
  /// To jest jednoczesnie jedyna uczciwa odpowiedz na pytanie "czy mamy Pelny
  /// dostep do dysku": TCC nie ma interfejsu do zapytania o uprawnienie, wiec
  /// sprawdza sie je PROBUJAC.
  ///
  /// Interfejs robil to do 25.09.2026 przez
  /// `FileManager.isReadableFile(atPath:)` na
  /// `~/Library/Application Support/com.apple.TCC`. Dwa bledy w jednej linii:
  /// to KATALOG, a nie plik z historia kopii, a `isReadableFile` sprowadza sie
  /// do `access(R_OK)`, ktory patrzy tylko na prawa POSIX i o TCC nie wie nic.
  /// Odpowiedz wychodzila wiec twierdzaca niezaleznie od stanu uprawnien -
  /// a panel mowil "dostep jest" w chwili, w ktorej czujka nie mogla odczytac
  /// ani jednej daty kopii. Czlowiek szukal potem awarii wszedzie poza
  /// miejscem, w ktorym siedziala.
  ///
  /// `preferencesFile` podmienialny z tego samego powodu, co w `currentReport`.
  public static func preferencesReadable(
    preferencesFile: String = BackupHealth.preferencesPath
  ) -> Bool {
    (try? Data(contentsOf: URL(fileURLWithPath: preferencesFile))) != nil
  }

  /// `preferencesFile` da sie podmienic, zeby dalo sie PRZEJSC CALA sciezke
  /// czujki na znanej zlej probce - odczyt pliku, parsowanie, wybor celu,
  /// ocena, zgloszenie, kod wyjscia - bez psucia dzialajacego backupu. Test
  /// jednostkowy na `evaluate` nie pokrywa tego, co dzieje sie miedzy plikiem
  /// a decyzja, a wlasnie tam siedzialy w tym projekcie ciche awarie.
  public static func currentReport(
    now: Date = Date(), maxAgeHours: Double = BackupHealth.maxAgeHours,
    preferencesFile: String = BackupHealth.preferencesPath
  ) async -> Report {
    let plist =
      (try? Data(contentsOf: URL(fileURLWithPath: preferencesFile)))
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
              "\(preferencesFile) jest nieczytelny - najczesciej brak Pelnego dostepu do dysku. Bez tego pliku NIE WIADOMO, kiedy ostatnio powstala kopia, wiec traktujemy to jak awarie, a nie jak brak problemu."
          )
        ], lastSuccess: nil, lastAttempt: nil, preferencesReadable: false)
    }

    let (lastSuccess, lastAttempt, result) = dates(
      inPreferences: plist, volumeNamed: BackupImageService.volumeName)

    let stats = await DriveBufferService.queueStats()
    // `attachmentReading()`, nie `attachment()`: sonda czytelnosci ma limit
    // czasu i po jego przekroczeniu oddaje `.unknown`. Czujka DOKANCZA wtedy
    // przebieg i zglasza brak wiedzy - to jest cala roznica wzgledem stanu do
    // 26.09.2026, w ktorym ten odczyt nie mial limitu, a `StartInterval 1800`
    // bez `KeepAlive` znaczy, ze launchd NIE uruchomi drugiej instancji,
    // dopoki zyje pierwsza. Jedno zawieszenie uciszalo wiec czujke NA STALE,
    // a cisza w tym systemie wyglada identycznie jak zdrowie.
    let reading = await BackupImageService.attachmentReading()
    let attachment = reading.attachment
    var deadErrno: Int32?
    if case .dead(let errno) = attachment { deadErrno = errno }

    // Trzy stany, tak samo jak przy celu Time Machine nizej.
    //
    // Wyliczamy je z `attachment`, a nie drugim wywolaniem
    // `BackupImageService.attachedState()` - ten sam odczyt tablicy montowan
    // dal juz `deadErrno` powyzej, a dwa osobne odczyty moglyby sie
    // rozjechac i dac raport opisujacy dwie rozne chwile.
    let attached: Bool?
    switch attachment {
    // `.dead` to nadal PODPIETY obraz - tylko martwy, i to osobny problem
    // zglaszany przez `imageDeadErrno`.
    case .attached, .dead: attached = true
    case .detached: attached = false
    case .unknown: attached = nil
    }
    // Trzy stany, nie dwa: `noAnswer` (zawieszony tmutil) nie ma prawa
    // udawac "cel przestawiony" - patrz `evaluate`.
    let registered: Bool?
    switch await TimeMachineStatus.destinationReading() {
    case .mountPoint(let path): registered = (path == BackupImageService.targetPath.path)
    case .none: registered = false
    case .noAnswer: registered = nil
    }

    // Pomiar wolnego miejsca moze sie NIE UDAC (statfs zwraca blad) i wtedy
    // `freeGB()` oddaje `nil`, a nie zmyslone zero - patrz komentarz przy niej.
    let localFree = BufferGuardService.freeGB()

    var report = evaluate(
      lastSuccess: lastSuccess,
      lastAttempt: lastAttempt,
      result: result,
      now: now,
      // `mountedState()`, a NIE `isMounted` - to drugie jest
      // `mountedState() ?? false`, czyli zamienia "nie wiem" w "nie dziala"
      // i kaze czlowiekowi naprawiac montowanie, ktore moze byc sprawne.
      mounted: DriveBufferService.mountedState(),
      attached: attached,
      destinationRegistered: registered,
      erroredFiles: stats?.erroredFiles ?? 0,
      outOfSpace: stats?.outOfSpace ?? false,
      queueReadable: stats != nil,
      // Nieczytelna pojemnosc Dysku NIE jest tu osobnym alarmem: gdy rclone
      // nie odpowiada, mowia o tym juz twardsze sygnaly powyzej, a drugi
      // komunikat o tym samym tylko rozmywa ten pierwszy.
      driveFreeBytes: (await DriveBufferService.remoteQuota())?.free,
      localFreeGB: localFree,
      imageDeadErrno: deadErrno,
      imageProbeTimedOut: reading.probeTimedOut,
      maxAgeHours: maxAgeHours)

    report.problems.append(contentsOf: unmeasuredLocalDiskProblems(localFreeGB: localFree))
    return report
  }

  /// Problem zglaszany, gdy pomiaru wolnego miejsca NIE DA SIE wykonac.
  ///
  /// `evaluate` traktuje `localFreeGB: nil` jako "nie pytano" (taki jest jego
  /// kontrakt od poczatku i opiera sie na nim kilkanascie testow), ale
  /// `currentReport` WIE, ze pytalo i nie wyszlo. To osobna awaria: dozorca
  /// bufora podejmuje decyzje o wstrzymaniu Time Machine wlasnie na tej
  /// liczbie, wiec gdy jej nie ma, nie chroni juz dysku przed zapelnieniem.
  ///
  /// Wydzielone z `currentReport()` WYLACZNIE po to, zeby dalo sie sprawdzic
  /// testem: `currentReport()` dotyka rclone, tmutil i hdiutil, wiec ta galaz
  /// bylaby inaczej niesprawdzalna - a galaz "nie wiem", ktorej nikt nie
  /// sprawdzil, to dokladnie ten rodzaj martwego kodu, o ktory pytal przeglad
  /// (kompilator ostrzegal wczesniej, ze `Int` porownywany do `nil` zawsze
  /// daje falsz, czyli ze galaz jest martwa).
  static func unmeasuredLocalDiskProblems(localFreeGB: Int?) -> [Problem] {
    guard localFreeGB == nil else { return [] }
    return [
      Problem(
        summary: "Nie da sie zmierzyc wolnego miejsca na dysku Maca",
        detail:
          "statfs('/System/Volumes/Data') zwrocil blad. Dozorca bufora nie wstrzyma wtedy Time Machine przed zapelnieniem dysku, bo nie zna liczby, na ktorej opiera ta decyzje."
      )
    ]
  }

  // MARK: - Formatowanie

  /// Wiek slowami. Minuty ponizej dwoch godzin - inaczej przy niskim progu
  /// komunikat brzmi "Brak udanej kopii od 0 h", co nie znaczy nic.
  public static func formatAge(_ seconds: TimeInterval) -> String {
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
