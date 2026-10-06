import Foundation

/// Text shown to people: the menu-bar app, CLI output and alerts.
///
/// The English text is the key, so the source reads naturally and a missing
/// translation falls back to English instead of to an identifier. Polish
/// translations live in the `L10nPolish+*.swift` tables. Logs are NOT
/// localized: a log is read when diagnosing, often by someone else, and a file
/// that switches language with the system setting cannot be searched.
///
/// The language follows the system (first preferred language). `CM_LANGUAGE`
/// (`en` or `pl`) overrides it; tests always run in English, so their expected
/// strings do not depend on the Mac they run on.
///
/// Rules, enforced by `L10nTests`:
/// - the key is a single-line string literal written inline in the call;
/// - placeholders are `%@` only (pass numbers as `"\(n)"`); `String(format:)`
///   with a wrong argument type crashes, and `%@` cannot be mismatched;
/// - every key has a Polish entry with the same number of placeholders.
public enum L10n {
  public enum Language: String {
    case en
    case pl
  }

  /// Settable for tests and previews; resolved once otherwise.
  public static var language: Language = detectLanguage()

  static func detectLanguage(
    environment: [String: String] = ProcessInfo.processInfo.environment,
    preferredLanguages: [String] = Locale.preferredLanguages,
    isRunningTests: Bool = NSClassFromString("XCTestCase") != nil
  ) -> Language {
    if let forced = environment["CM_LANGUAGE"].flatMap({ Language(rawValue: $0.lowercased()) }) {
      return forced
    }
    if isRunningTests { return .en }
    return preferredLanguages.first?.lowercased().hasPrefix("pl") == true ? .pl : .en
  }

  /// Translates `english`; with arguments, fills its `%@` placeholders.
  public static func tr(_ english: String, _ arguments: String...) -> String {
    let template = language == .pl ? (polish[english] ?? english) : english
    guard !arguments.isEmpty else { return template }
    return String(format: template, arguments: arguments.map { $0 as NSString })
  }

  /// All Polish tables merged. Split into files so that parts of the code can
  /// be translated in parallel without editing one shared dictionary.
  static let polish: [String: String] = {
    var merged: [String: String] = [:]
    for table in polishTables {
      merged.merge(table) { first, _ in first }
    }
    return merged
  }()

  static let polishTables: [[String: String]] = [
    L10nPolish.storage,
    L10nPolish.system,
    L10nPolish.app,
    L10nPolish.agent,
  ]
}

/// Namespace for the Polish tables; each `L10nPolish+*.swift` adds one.
enum L10nPolish {}
