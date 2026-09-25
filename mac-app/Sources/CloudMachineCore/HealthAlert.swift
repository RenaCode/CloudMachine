import Foundation

/// Donosi o zerwanym cyklu backupu tam, gdzie uzytkownik to zobaczy BEZ
/// otwierania czegokolwiek.
///
/// Powod istnienia: caly dotychczasowy "monitoring" tego projektu polegal na
/// tym, ze ktos otworzy aplikacje i spojrzy na ikonke. Awaria, ktora nie
/// przeszkadza w codziennej pracy - a taka jest kazda awaria backupu - nie
/// daje zadnego powodu, zeby tam zajrzec. Kopia moze nie powstawac tygodniami
/// i nic tego nie zdradzi.
///
/// Kanalem jest powiadomienie systemowe macOS: nie wymaga serwera pocztowego
/// ani sekretu, ktorego brak bylby kolejna cicha awaria.
public enum HealthAlert {

  /// Plik ze stanem ostatniego zgloszenia. Trzymany OBOK bufora i obrazu,
  /// w katalogu, ktory zyje niezaleznie od nich - czujka nie moze dzielic losu
  /// tego, co nadzoruje.
  public static var stateFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("health-alert.json")
  }

  struct AlertState: Codable {
    /// Ostatnio POKAZANY tekst - trzymany dla czlowieka (`drive-status`,
    /// diagnoza z pliku), nie do porownywania.
    var lastSummary: String
    var lastAlertAt: Date
    /// Tozsamosc problemow, czyli to, po czym poznajemy, ze chodzi o TE SAMA
    /// awarie - patrz `identity(of:)`. Opcjonalne, zeby plik zapisany przed
    /// 23.09.2026 nadal sie czytal; przy `nil` porownujemy po tekscie jak
    /// dawniej (najwyzej jedno powiadomienie wiecej, raz).
    var lastIdentity: String?
    /// Czy powiadomienie FAKTYCZNIE doszlo. `nil` = plik w starym formacie,
    /// czyli sprzed czasow, gdy ktokolwiek to sprawdzal - traktujemy jak
    /// doreczone, bo inaczej po aktualizacji posypalyby sie ponowienia.
    var delivered: Bool?
    /// Dlaczego nie doszlo - do pokazania czlowiekowi.
    var deliveryError: String?
  }

  /// Po tylu godzinach przypominamy o TYM SAMYM problemie jeszcze raz.
  ///
  /// Bez przypomnienia alarm zapala sie raz i gasnie na zawsze - a awaria
  /// backupu trwa, dopoki ktos jej nie naprawi. Bez odstepu zamienia sie
  /// w szum co 15 minut i przestaje cokolwiek znaczyc.
  static let reminderHours = 12.0

  /// Zglasza problemy, jesli sa NOWE albo jesli minal czas przypomnienia.
  /// Zwraca `true`, gdy faktycznie cos zgloszono I DORECZONO.
  ///
  /// `stateFile`, `deliver` i `log` sa podmienialne, zeby dalo sie sprawdzic
  /// testem CALA sciezke - z odmowa doreczenia wlacznie - bez pisania do
  /// prawdziwego katalogu uzytkownika, bez wyswietlania komukolwiek
  /// powiadomien i bez dopisywania zmyslonych awarii do produkcyjnego logu.
  ///
  /// `log` jest wstrzykiwalny z dokladnie tego samego powodu, co
  /// `BufferGuardService.Probes.log`. Dopoki nie byl, kazdy przebieg
  /// `swift test` dopisywal swoje wymyslone "AWARIA BACKUPU" do prawdziwego
  /// `cloudmachine.log` - zmierzone 25.09.2026: 117 linii zawierajacych
  /// slowo "szczegoly", ktore istnieje wylacznie w
  /// `HealthAlertTests.raport(_:)`, wszystkie z jednego dnia. Ten log jest
  /// JEDYNYM sladem po awariach backupu i przestal pozwalac odroznic
  /// zdarzenia, ktore sie staly, od tych, ktore ktos tylko przetestowal -
  /// a po awarii czyta sie go wlasnie po to, zeby ustalic, co sie stalo.
  ///
  /// Odrzucone: globalne przekierowanie `CMLogger` na plik tymczasowy w
  /// `setUp` testu. To wspolny stan procesu, wiec przy testach biegnacych
  /// rownolegle uciszalby rowniez te, ktore maja pisac, a wlaczony przez
  /// pomylke w kodzie produkcyjnym uciszylby produkcje - czyli zamienilby
  /// halas w logu na cisze w logu, co jest zamiana na gorsze. Domyslna
  /// wartosc tego parametru idzie do prawdziwego logu i zaden kod
  /// produkcyjny jej nie podaje.
  @discardableResult
  public static func report(
    _ report: BackupHealth.Report,
    now: Date = Date(),
    stateFile: URL = HealthAlert.stateFile,
    deliver: @Sendable (String, String) async -> Bool = {
      await notify(title: $0, message: $1)
    },
    log: @Sendable (String) -> Void = { CMLogger.log($0) }
  ) async -> Bool {
    guard let first = report.problems.first else {
      // Wyzdrowienie kasuje stan, zeby nastepna awaria zglosila sie od razu,
      // a nie czekala na okno przypomnienia.
      try? FileManager.default.removeItem(at: stateFile)
      return false
    }

    let summary = report.problems.map(\.summary).joined(separator: " | ")
    let identity = self.identity(of: report.problems)
    if !shouldAlert(identity: identity, now: now, stateFile: stateFile) { return false }

    let body = report.problems.map { "\($0.summary): \($0.detail)" }.joined(separator: "\n")
    log("AWARIA BACKUPU: \(body)")
    let delivered = await deliver("CloudMachine: backup nie dziala", first.summary)

    // Stan zapisujemy ZAWSZE, ale z informacja, czy powiadomienie doszlo.
    //
    // Wczesniej zapisywalo sie bezwarunkowo jako sukces, wiec nieudane
    // powiadomienie (odmowa uprawnien dla procesu launchd, brak sesji Aqua,
    // przekroczony limit czasu osascript) zamykalo okno ciszy na 12 godzin.
    // Alarm ginal po cichu - czyli nadzor ginal razem z nadzorowanym, przed
    // czym ostrzega naglowek tego pliku.
    if !delivered {
      log(
        "NIE UDALO SIE pokazac powiadomienia o awarii backupu. Tresc poszla do logu powyzej; sprobuje ponownie przy nastepnym sprawdzeniu."
      )
    }
    let state = AlertState(
      lastSummary: summary, lastAlertAt: now, lastIdentity: identity,
      delivered: delivered,
      deliveryError: delivered
        ? nil : "osascript nie pokazal powiadomienia (uprawnienia albo brak sesji graficznej)")
    if let data = try? JSONEncoder().encode(state) {
      try? data.write(to: stateFile, options: .atomic)
    }
    return delivered
  }

  static func shouldAlert(identity: String, now: Date, stateFile: URL = HealthAlert.stateFile)
    -> Bool
  {
    guard let state = loadState(stateFile) else { return true }
    // Nieudane doreczenie NIE zamyka okna ciszy - inaczej pierwsza nieudana
    // proba uciszalaby alarm na 12 godzin.
    if state.delivered == false { return true }
    if (state.lastIdentity ?? state.lastSummary) != identity { return true }
    return now.timeIntervalSince(state.lastAlertAt) > reminderHours * 3600
  }

  /// Tozsamosc zestawu problemow: te same summary z wycietymi LICZBAMI.
  ///
  /// Porownywanie gotowego tekstu dla uzytkownika nie dziala, bo ten tekst
  /// zawiera zmienne: "Brak udanej kopii od 3 h" zmienia sie w "... od 4 h"
  /// po godzinie. Warunek "inny tekst = nowy problem" byl wiec spelniony przy
  /// KAZDYM przebiegu czujki i powiadomienie wracalo co godzine zamiast raz na
  /// dwanascie - a alarm bez odstepu zamienia sie w szum i przestaje cokolwiek
  /// znaczyc (patrz `reminderHours`). Ta sama awaria musi miec te sama
  /// tozsamosc niezaleznie od tego, jak dlugo trwa.
  ///
  /// Ciag cyfr zastepujemy jednym `#`, zeby "od 9 h" i "od 12 h" dawaly ten
  /// sam odcisk. NOWY problem dokladany do listy zmienia odcisk i alarmuje od
  /// razu - i tak ma byc.
  static func identity(of problems: [BackupHealth.Problem]) -> String {
    problems.map { fingerprint($0.summary) }.joined(separator: " | ")
  }

  static func fingerprint(_ text: String) -> String {
    var out = ""
    var inNumber = false
    for character in text {
      if character.isNumber {
        if !inNumber {
          out.append("#")
          inNumber = true
        }
      } else {
        out.append(character)
        inNumber = false
      }
    }
    return out
  }

  static func loadState(_ file: URL = HealthAlert.stateFile) -> AlertState? {
    guard let data = try? Data(contentsOf: file) else { return nil }
    return try? JSONDecoder().decode(AlertState.self, from: data)
  }

  /// Ostatnie zgloszenie, ktorego NIE udalo sie doreczyc - do pokazania
  /// w `drive-status`. `nil`, gdy ostatnie zgloszenie doszlo albo gdy nie bylo
  /// zadnego. Cichy alarm musi byc widoczny gdzies, gdzie czlowiek zaglada
  /// sam, bo z definicji nie przyjdzie do niego po powiadomieniu.
  public static func lastDeliveryFailure(stateFile: URL = HealthAlert.stateFile) -> (
    at: Date, summary: String, reason: String
  )? {
    guard let state = loadState(stateFile), state.delivered == false else { return nil }
    return (state.lastAlertAt, state.lastSummary, state.deliveryError ?? "nieznany powod")
  }

  /// Powiadomienie systemowe przez `osascript`. Sam tekst wstawiamy jako
  /// literal AppleScript z ucieknietymi cudzyslowami - inaczej komunikat
  /// zawierajacy `"` (a komunikaty rclone je zawieraja) rozwalilby skrypt
  /// i alarm zginalby po cichu, czyli dokladnie tak, jak awaria, ktora ma
  /// zglaszac.
  ///
  /// Zwraca `true` tylko wtedy, gdy `osascript` FAKTYCZNIE zakonczyl sie
  /// powodzeniem. Wynik byl wczesniej wyrzucany przez `_ = try?`, wiec odmowa
  /// uprawnien do powiadomien (typowa dla procesu launchd), brak sesji Aqua
  /// albo przekroczony limit czasu wygladaly dokladnie tak samo, jak
  /// pokazane powiadomienie.
  @discardableResult
  public static func notify(title: String, message: String) async -> Bool {
    let script =
      "display notification \(appleScriptLiteral(message)) with title \(appleScriptLiteral(title))"
    guard let result = try? await ProcessRunner.run("/usr/bin/osascript", ["-e", script], timeout: 30)
    else {
      CMLogger.log("osascript nie odpowiedzial w limicie czasu - powiadomienie nie poszlo.")
      return false
    }
    if !result.succeeded {
      let text = (result.stderr + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
      CMLogger.log("osascript zwrocil kod \(result.exitCode): \(text.isEmpty ? "(bez komunikatu)" : text)")
    }
    return result.succeeded
  }

  static func appleScriptLiteral(_ text: String) -> String {
    let escaped =
      text
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
      .replacingOccurrences(of: "\n", with: " ")
    return "\"\(escaped)\""
  }
}
