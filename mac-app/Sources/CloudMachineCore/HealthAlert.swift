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
  static var stateFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("health-alert.json")
  }

  struct AlertState: Codable {
    var lastSummary: String
    var lastAlertAt: Date
  }

  /// Po tylu godzinach przypominamy o TYM SAMYM problemie jeszcze raz.
  ///
  /// Bez przypomnienia alarm zapala sie raz i gasnie na zawsze - a awaria
  /// backupu trwa, dopoki ktos jej nie naprawi. Bez odstepu zamienia sie
  /// w szum co 15 minut i przestaje cokolwiek znaczyc.
  static let reminderHours = 12.0

  /// Zglasza problemy, jesli sa NOWE albo jesli minal czas przypomnienia.
  /// Zwraca `true`, gdy faktycznie cos zgloszono.
  @discardableResult
  public static func report(_ report: BackupHealth.Report, now: Date = Date()) async -> Bool {
    guard let first = report.problems.first else {
      // Wyzdrowienie kasuje stan, zeby nastepna awaria zglosila sie od razu,
      // a nie czekala na okno przypomnienia.
      try? FileManager.default.removeItem(at: stateFile)
      return false
    }

    let summary = report.problems.map(\.summary).joined(separator: " | ")
    if !shouldAlert(summary: summary, now: now) { return false }

    let body = report.problems.map { "\($0.summary): \($0.detail)" }.joined(separator: "\n")
    CMLogger.log("AWARIA BACKUPU: \(body)")
    await notify(title: "CloudMachine: backup nie dziala", message: first.summary)

    let state = AlertState(lastSummary: summary, lastAlertAt: now)
    if let data = try? JSONEncoder().encode(state) {
      try? data.write(to: stateFile, options: .atomic)
    }
    return true
  }

  static func shouldAlert(summary: String, now: Date) -> Bool {
    guard let data = try? Data(contentsOf: stateFile),
      let state = try? JSONDecoder().decode(AlertState.self, from: data)
    else { return true }
    if state.lastSummary != summary { return true }
    return now.timeIntervalSince(state.lastAlertAt) > reminderHours * 3600
  }

  /// Powiadomienie systemowe przez `osascript`. Sam tekst wstawiamy jako
  /// literal AppleScript z ucieknietymi cudzyslowami - inaczej komunikat
  /// zawierajacy `"` (a komunikaty rclone je zawieraja) rozwalilby skrypt
  /// i alarm zginalby po cichu, czyli dokladnie tak, jak awaria, ktora ma
  /// zglaszac.
  static func notify(title: String, message: String) async {
    let script =
      "display notification \(appleScriptLiteral(message)) with title \(appleScriptLiteral(title))"
    _ = try? await ProcessRunner.run("/usr/bin/osascript", ["-e", script], timeout: 30)
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
