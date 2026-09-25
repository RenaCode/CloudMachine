import Foundation

/// Znacznik "czujka NAPRAWDE przebiegla", czyli nadzor nad samym nadzorem.
///
/// `backup-health` chodzi z `StartInterval 1800` i BEZ `KeepAlive`. Jesli
/// agent zostanie wyladowany (`launchctl bootout`, nieudana instalacja, zmiana
/// nazwy binarki) albo zawisnie w nieprzerywalnym I/O na montowaniu Google
/// Drive, to jedynym objawem jest CISZA - a cisza jest tu domyslnym,
/// oczekiwanym stanem. README mowi wprost: "Empty logs after a fresh install
/// are normal - the agents only write when something happens". Czyli dokladnie
/// tak samo wyglada czujka, ktora dziala i nie ma o czym donosic, jak czujka,
/// ktorej nie ma.
///
/// Dlatego kazdy przebieg zostawia po sobie PLIK z data. Brak alarmu przestaje
/// znaczyc "wszystko dobrze" i zaczyna znaczyc "czujka przebiegla o 14:32 i nie
/// miala o czym donosic" - albo "czujka nie przebiegla od trzech dni", co jest
/// zupelnie inna informacja.
///
/// Znacznik NIE jest kanalem alarmu. Zewnetrzny kanal (poczta, push) to
/// decyzja wlasciciela o architekturze, nie poprawka - tutaj tylko odkladamy
/// fakt, ktory `drive-status` i panel POKAZUJA, gdy czlowiek zaglada sam.
///
/// Plik lezy w `appSupportDir`, obok stanu alarmu (`health-alert.json`), a nie
/// w buforze ani w obrazie - czujka nie moze dzielic losu tego, co nadzoruje.
public enum WatchdogHeartbeat {

  /// Znacznik czujki `backup-health`.
  ///
  /// Zwykly tekst, nie JSON: to plik, ktory czlowiek `cat`-uje w trakcie
  /// diagnozy, i ma byc czytelny bez narzedzi.
  public static var backupHealthFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("backup-health-last-run")
  }

  /// Po tylu godzinach ciszy uznajemy, ze czujka NIE CHODZI.
  ///
  /// `StartInterval` czujki to 1800 s, wiec godzina to dwa pominiete przebiegi
  /// z rzedu - za duzo na przypadek, a jednoczesnie z zapasem na przebieg,
  /// ktory trwa dlugo (kazde wywolanie tmutil ma limit czasu i czujka potrafi
  /// go wykorzystac).
  public static let maxSilenceHours = 1.0

  /// Co wiemy o ostatnim przebiegu czujki.
  ///
  /// Trzy stany, nie dwa, z tego samego powodu co `DestinationReading` i
  /// `queueKnown`: "czujka nie zapisala ani jednego przebiegu" to inna
  /// informacja niz "ostatni przebieg byl dawno". Pierwsze zdarza sie na
  /// swiezej instalacji i po aktualizacji, ktora dodala ten znacznik.
  public enum Freshness: Equatable {
    case fresh(lastRun: Date, age: TimeInterval)
    case stale(lastRun: Date, age: TimeInterval)
    /// Nie ma znacznika w ogole.
    case never
  }

  /// Odklada fakt "czujka przebiegla teraz".
  ///
  /// Wolane ZANIM czujka cokolwiek wypisze i zanim zdecyduje o kodzie wyjscia:
  /// przebieg, ktory znalazl awarie, jest tak samo przebiegiem jak ten, ktory
  /// nic nie znalazl. Gdyby znacznik powstawal tylko na zdrowej sciezce,
  /// zepsuty backup wygladalby jak nieczynna czujka i odwrotnie.
  ///
  /// Zwraca `false`, gdy zapis sie NIE UDAL - wtedy znacznik bedzie stary,
  /// czyli pomyli sie w bezpieczna strone ("czujka moze nie chodzic").
  @discardableResult
  public static func record(now: Date = Date(), file: URL = WatchdogHeartbeat.backupHealthFile)
    -> Bool
  {
    let formatter = ISO8601DateFormatter()
    let text = formatter.string(from: now) + "\n"
    guard let data = text.data(using: .utf8) else { return false }
    return (try? data.write(to: file, options: .atomic)) != nil
  }

  /// Data ostatniego przebiegu albo `nil`, gdy znacznika nie ma (albo jest
  /// nieczytelny - jedno i drugie znaczy tu "nie wiem, kiedy czujka chodzila").
  public static func lastRun(file: URL = WatchdogHeartbeat.backupHealthFile) -> Date? {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return nil }
    return ISO8601DateFormatter().date(from: text.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  /// Czysta ocena wieku znacznika - osobno od odczytu pliku, zeby dalo sie ja
  /// sprawdzic testem bez dotykania dysku.
  public static func freshness(
    lastRun: Date?, now: Date = Date(),
    maxSilenceHours: Double = WatchdogHeartbeat.maxSilenceHours
  ) -> Freshness {
    guard let lastRun else { return .never }
    let age = now.timeIntervalSince(lastRun)
    // Ujemny wiek (znacznik z przyszlosci - przestawiony zegar, kopia z innej
    // maszyny) NIE jest swiezoscia: nie wiemy, kiedy czujka chodzila.
    guard age >= 0, age <= maxSilenceHours * 3600 else {
      return .stale(lastRun: lastRun, age: age)
    }
    return .fresh(lastRun: lastRun, age: age)
  }

  public static func current(
    now: Date = Date(), file: URL = WatchdogHeartbeat.backupHealthFile,
    maxSilenceHours: Double = WatchdogHeartbeat.maxSilenceHours
  ) -> Freshness {
    freshness(lastRun: lastRun(file: file), now: now, maxSilenceHours: maxSilenceHours)
  }
}
