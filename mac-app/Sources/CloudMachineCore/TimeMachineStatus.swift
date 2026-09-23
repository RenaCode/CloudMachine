import Foundation

/// Parsowanie tekstowego wyjscia `tmutil status`/`tmutil destinationinfo` -
/// oba to wlasciwie "plist-jak" tekst, nie prawdziwy JSON/plist, wiec
/// najprosciej i najbezpieczniej parsowac linia po linii, tak jak robily to
/// oryginalne `awk` w bash.
/// Postep aktywnego backupu, wyciagniety z bloku `Progress = { ... }` w
/// `tmutil status`. Wszystkie pola opcjonalne - macOS nie zawsze wypelnia
/// caly blok (np. w fazach innych niz "Copying" czesc pol moze brakowac).
public struct TimeMachineProgress: Equatable {
  public var phase: String?
  public var percent: Double?
  public var bytes: Double?
  public var totalBytes: Double?
  public var files: Int?
  public var totalFiles: Int?
  public var timeRemainingSeconds: Double?
}

public enum TimeMachineStatus {

  /// Limit czasu dla KAZDEGO wywolania `tmutil` w tym pliku.
  ///
  /// Do 23.09.2026 nie bylo tu zadnego limitu i to byla awaria czekajaca na
  /// swoj dzien. `tmutil destinationinfo` siega do celu backupu, czyli na
  /// montowanie FUSE-T lezace na Google Drive. Przy martwym montowaniu
  /// (incydent ENXIO z 22.09) odczyt wchodzi w nieprzerywalne I/O i nie wraca
  /// NIGDY. Czujka `backup-health` wisi wtedy na `currentReport()`, a launchd
  /// ze `StartInterval` nie uruchamia drugiej instancji, dopoki zyje pierwsza
  /// - czyli czujka milknie NA STALE, dokladnie w chwili, w ktorej ma mowic.
  ///
  /// Dobor liczby, a nie "jakis limit z palca":
  ///   - na zdrowym systemie `tmutil status` i `destinationinfo` odpowiadaja
  ///     grubo ponizej sekundy (mierzone recznie na tej maszynie),
  ///   - na montowaniu, ktore jeszcze zyje, ale odpowiada wolno, ten sam
  ///     odczyt potrafi trwac dziesiatki sekund, bo idzie przez siec,
  ///   - projekt ma juz jedna wpadke z limitem dobranym dla CZYSTEGO startu:
  ///     120 s wystarczalo po restarcie, a po awarii zabraklo 10 s. Dlatego
  ///     90 s to nie jest "tyle, ile zwykle trwa", tylko dwa rzedy wielkosci
  ///     zapasu nad przypadkiem zdrowym i spory zapas nad wolnym.
  ///
  /// Gorna granica CZEKANIA jest wyzsza niz ta liczba: `ProcessRunner` przy
  /// `timeout` wysyla SIGTERM, po +5 s SIGKILL, a po +10 s poddaje sie
  /// i zwraca blad (SIGKILL nie dziala na proces w stanie "U"). Realne
  /// maksimum to wiec 100 s na jedno wywolanie. `backup-health` robi ich na
  /// przebieg jedno, przy `StartInterval` 1800 s - zapas 18-krotny, wiec
  /// limit nie moze zjesc okna uruchomienia.
  public static let commandTimeout: TimeInterval = 90

  /// Surowe wyjscie `tmutil`. `nil` znaczy DOKLADNIE jedno: tmutil NIE
  /// ODPOWIEDZIAL (limit czasu albo nie dalo sie go uruchomic) - a nie
  /// "odpowiedzial, ze nie". Kazdy wolajacy musi te dwie rzeczy rozroznic
  /// sam, bo zlanie ich w `false`/`nil` to wlasnie ten rodzaj cichej awarii,
  /// przed ktorym ostrzega naglowek `BackupHealth`.
  private static func output(_ arguments: [String]) async -> String? {
    do {
      let result = try await ProcessRunner.run(
        "/usr/bin/tmutil", arguments, timeout: commandTimeout)
      return result.stdout
    } catch {
      CMLogger.log(
        "tmutil \(arguments.joined(separator: " ")): BRAK ODPOWIEDZI - \(error.localizedDescription)"
      )
      return nil
    }
  }

  /// Czy backup trwa. `nil` = tmutil nie odpowiedzial, czyli NIE WIADOMO.
  ///
  /// Rozroznienie jest tu istotne dla dozorcy bufora: "nie trwa" kaze mu
  /// przejsc w czuwanie i zapomniec, ze nadzorowal backup, a "nie wiadomo"
  /// musi zostawic stan bez zmiany.
  public static func runningState() async -> Bool? {
    guard let out = await output(["status"]) else { return nil }
    return isRunning(statusOutput: out)
  }

  /// Skrot dla miejsc CZYSTO INFORMACYJNYCH (wydruk stanu, podglad w GUI),
  /// gdzie brak odpowiedzi i "nie trwa" wygladaja tak samo i nic z tego nie
  /// wynika. Wszedzie, gdzie z odpowiedzi wynika DECYZJA, uzywaj
  /// `runningState()` i obsluz `nil` osobno.
  public static func isRunning() async -> Bool {
    await runningState() ?? false
  }

  /// Czysta funkcja parsujaca - wydzielona z `isRunning()`, zeby dalo sie ja
  /// przetestowac bez `tmutil` na prawdziwym Maku (patrz `CooldownGate` dla
  /// tego samego wzorca w tym projekcie). Cala logika parsujaca w tym pliku
  /// wczesniej nie miala ani jednego testu, mimo ze to wlasnie tutaj (blednie
  /// zgadywana nazwa wolumenu, kolizje mountowania) siedzialy realne bugi.
  static func isRunning(statusOutput: String) -> Bool {
    for line in statusOutput.split(separator: "\n") {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      if trimmed.hasPrefix("Running") {
        return trimmed.contains("= 1")
      }
    }
    return false
  }

  /// Parsuje `tmutil status` linia po linii (ten sam styl co reszta pliku) -
  /// klucze wewnatrz bloku `Progress` (`bytes`, `files`, `TimeRemaining`...)
  /// sa unikalne w calym wyjsciu, wiec nie trzeba osobno sledzic zagniezdzenia
  /// nawiasow klamrowych. Zwraca `nil`, jesli aktualnie nic nie kopiuje.
  ///
  /// `nil` znaczy tu takze "tmutil nie odpowiedzial" i to jedyne miejsce
  /// w tym pliku, gdzie zlanie tych dwoch przypadkow jest w porzadku: postep
  /// sluzy WYLACZNIE do pokazania paska w interfejsie i zadna decyzja z niego
  /// nie wynika. Kto pyta o postep, i tak wczesniej pyta `runningState()`.
  public static func currentProgress() async -> TimeMachineProgress? {
    guard let out = await output(["status"]) else { return nil }
    return currentProgress(statusOutput: out)
  }

  static func currentProgress(statusOutput: String) -> TimeMachineProgress? {
    var running = false
    var progress = TimeMachineProgress()

    for rawLine in statusOutput.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      guard let eqIndex = line.firstIndex(of: "=") else { continue }
      let key = line[line.startIndex..<eqIndex].trimmingCharacters(in: .whitespaces)
      var value = String(line[line.index(after: eqIndex)...]).trimmingCharacters(in: .whitespaces)
      if value.hasSuffix(";") { value.removeLast() }
      value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))

      switch key {
      case "Running": running = (value == "1")
      case "BackupPhase": progress.phase = value
      case "Percent": progress.percent = Double(value)
      case "bytes": progress.bytes = Double(value)
      case "totalBytes": progress.totalBytes = Double(value)
      case "files": progress.files = Int(value)
      case "totalFiles": progress.totalFiles = Int(value)
      case "TimeRemaining": progress.timeRemainingSeconds = Double(value)
      default: break
      }
    }
    return running ? progress : nil
  }

  /// Odpowiednik `tmutil destinationinfo | awk ... -v mp="$SP_MOUNT"` - szuka
  /// bloku, ktorego "Mount Point" zawiera `mountPoint`, i zwraca jego ID.
  public static func destinationID(forMountPointContaining mountPoint: String) async -> String? {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return destinationID(forMountPointContaining: mountPoint, destinationInfoOutput: out)
  }

  static func destinationID(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  )
    -> String?
  {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("ID") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        return parts[1].trimmingCharacters(in: .whitespaces)
      }
    }
    return nil
  }

  /// Limit (GB) skonfigurowany dla celu TM pod danym punktem montowania -
  /// parsuje linie "Quota" (np. "300 GB") z bloku znalezionego tak samo jak
  /// w `destinationID`. `nil`, jesli TM nie raportuje limitu dla tego celu.
  public static func destinationQuotaGB(forMountPointContaining mountPoint: String) async
    -> Double?
  {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return destinationQuotaGB(forMountPointContaining: mountPoint, destinationInfoOutput: out)
  }

  static func destinationQuotaGB(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  ) -> Double? {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("Quota") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        let valueText = parts[1].trimmingCharacters(in: .whitespaces)
        let numberText = valueText.split(separator: " ").first.map(String.init) ?? valueText
        return Double(numberText)
      }
    }
    return nil
  }

  /// Punkt montowania AKTUALNIE zarejestrowanego celu Time Machine
  /// (architektura gwarantuje dokladnie jeden aktywny cel lokalny - patrz
  /// LocalBackupService). Zwraca prawdziwa, zarejestrowana sciezke zamiast
  /// zgadywac ja z domyslnej nazwy wolumenu - uzytkownik moze nazwac lokalny
  /// wolumin dowolnie (np. recznie utworzona partycja "TimeMachine" zamiast
  /// domyslnej "CloudMachine-Local"), a zgadywanie po nazwie bylo realnym
  /// bugiem: po recznej zmianie nazwy wolumenu caly status GUI/watchdogow
  /// pokazywal "brak lokalnego woluminu" / "TimeMachine niezarejestrowany",
  /// mimo poprawnie dzialajacego, zarejestrowanego celu.
  ///
  /// Zwraca `nil` zarowno przy braku celu, jak i przy braku odpowiedzi od
  /// tmutil - kto musi te dwie rzeczy rozroznic (czujka `backup-health`:
  /// jedno znaczy "ktos przestawil cel", drugie "nie wiemy nic"), pyta
  /// `destinationReading()`.
  public static func currentDestinationMountPoint() async -> String? {
    if case .mountPoint(let path) = await destinationReading() { return path }
    return nil
  }

  /// Odpowiedz `tmutil destinationinfo` z jawnym, trzecim stanem: BRAK
  /// ODPOWIEDZI.
  ///
  /// Trzeci stan musi istniec osobno z tego samego powodu, co `queueUnknown`
  /// w `UploadState`: bez niego zawieszony tmutil wygladal dokladnie tak samo
  /// jak wyrejestrowany cel i czujka zglaszalaby "Time Machine nie wskazuje
  /// na CloudMachine" - zdanie prawdziwie brzmiace i falszywe, ktore wysyla
  /// czlowieka w zla strone.
  public enum DestinationReading: Equatable, Sendable {
    case mountPoint(String)
    /// tmutil odpowiedzial, ale zadnego celu nie ma.
    case none
    /// tmutil nie odpowiedzial w limicie czasu.
    case noAnswer
  }

  public static func destinationReading() async -> DestinationReading {
    guard let out = await output(["destinationinfo"]) else { return .noAnswer }
    guard let path = currentDestinationMountPoint(destinationInfoOutput: out) else { return .none }
    return .mountPoint(path)
  }

  static func currentDestinationMountPoint(destinationInfoOutput: String) -> String? {
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("Mount Point") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      return parts[1].trimmingCharacters(in: .whitespaces)
    }
    return nil
  }

  /// Wszystkie zarejestrowane ID celow Time Machine - uzywane przez
  /// `LocalBackupService.setAsDestination` do usuniecia poprzednich celow
  /// przed zarejestrowaniem nowego (ta architektura utrzymuje dokladnie
  /// jeden aktywny lokalny cel, w przeciwienstwie do legacy podejscia).
  ///
  /// Pusta lista przy braku odpowiedzi jest tu BEZPIECZNA i tylko dlatego
  /// zostaje: jedyny wolajacy kasuje po kolei zwrocone cele przed
  /// zarejestrowaniem nowego, wiec "nie wiem" konczy sie nieusunieciem
  /// czegos, a nie usunieciem czegos nie tego.
  public static func allDestinationIDs() async -> [String] {
    guard let out = await output(["destinationinfo"]) else { return [] }
    return allDestinationIDs(destinationInfoOutput: out)
  }

  static func allDestinationIDs(destinationInfoOutput: String) -> [String] {
    var ids: [String] = []
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("ID") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      ids.append(parts[1].trimmingCharacters(in: .whitespaces))
    }
    return ids
  }

  /// `nil` = tmutil nie odpowiedzial. Celowo NIE `false`: "w konfiguracji nie
  /// ma tego napisu" i "nie udalo sie zapytac" to dwie rozne odpowiedzi.
  public static func destinationInfoContains(_ needle: String) async -> Bool? {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return out.contains(needle)
  }
}
