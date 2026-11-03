import Foundation

/// Text shown to people: the menu-bar app, CLI output and alerts.
///
/// The English text is the key, so the source reads naturally and a missing
/// translation falls back to English instead of to an identifier. Polish
/// translations live in the `L10nPolish+*.swift` tables, the other languages
/// in `L10nTranslations+<code>.swift`. Logs are NOT localized: a log is read
/// when diagnosing, often by someone else, and a file that switches language
/// with the system setting cannot be searched.
///
/// The language follows the system's preferred languages, matched the way
/// macOS matches them for a localized app. `CM_LANGUAGE` (any code from
/// `Language`) overrides it; tests always run in English, so their expected
/// strings do not depend on the Mac they run on.
///
/// Rules, enforced by `L10nTests`:
/// - the key is a single-line string literal written inline in the call;
/// - placeholders are `%@` only (pass numbers as `"\(n)"`); `String(format:)`
///   with a wrong argument type crashes, and `%@` cannot be mismatched;
/// - every key has an entry in every language with the same placeholders
///   (`%1$@`... when a language needs another order).
public enum L10n {
  /// The 22 languages of the RenaCode games; also `CFBundleLocalizations`.
  public enum Language: String, CaseIterable {
    case ar, da, de, en, es, fi, fr, he, it, ja, ko, ms, nb, nl, pl
    case ptBR = "pt-BR"
    case ru, sv, th, tr
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"

    public var isRightToLeft: Bool { self == .ar || self == .he }
  }

  /// Settable for tests and previews; resolved once otherwise.
  public static var language: Language = detectLanguage()

  static func detectLanguage(
    environment: [String: String] = ProcessInfo.processInfo.environment,
    preferredLanguages: [String] = Locale.preferredLanguages,
    isRunningTests: Bool = NSClassFromString("XCTestCase") != nil
  ) -> Language {
    if let forced = environment["CM_LANGUAGE"], let language = match([forced]) {
      return language
    }
    if isRunningTests { return .en }
    return match(preferredLanguages) ?? .en
  }

  /// The first of `preferences` the app has, matched by Foundation (zh-TW ->
  /// zh-Hant, pt-PT -> pt-BR, no -> nb). Foundation answers "en" when nothing
  /// matches, so English counts only when the preference itself is English.
  private static func match(_ preferences: [String]) -> Language? {
    let codes = Language.allCases.map(\.rawValue)
    for preference in preferences {
      let identifier = preference.replacingOccurrences(of: "_", with: "-")
      guard
        let found = Bundle.preferredLocalizations(from: codes, forPreferences: [identifier]).first
          .flatMap(Language.init(rawValue:))
      else { continue }
      if found != .en || Locale(identifier: identifier).language.languageCode == .english {
        return found
      }
    }
    return nil
  }

  /// Translates `english`; with arguments, fills its `%@` placeholders.
  public static func tr(_ english: String, _ arguments: String...) -> String {
    let template = translations[language]?[english] ?? english
    guard !arguments.isEmpty else { return template }
    return String(format: template, arguments: arguments.map { $0 as NSString })
  }

  /// Every language except English (the keys themselves).
  static let translations: [Language: [String: String]] = [
    .pl: polish,
    .ar: L10nTranslations.ar,
    .da: L10nTranslations.da,
    .de: L10nTranslations.de,
    .es: L10nTranslations.es,
    .fi: L10nTranslations.fi,
    .fr: L10nTranslations.fr,
    .he: L10nTranslations.he,
    .it: L10nTranslations.it,
    .ja: L10nTranslations.ja,
    .ko: L10nTranslations.ko,
    .ms: L10nTranslations.ms,
    .nb: L10nTranslations.nb,
    .nl: L10nTranslations.nl,
    .ptBR: L10nTranslations.ptBR,
    .ru: L10nTranslations.ru,
    .sv: L10nTranslations.sv,
    .th: L10nTranslations.th,
    .tr: L10nTranslations.tr,
    .zhHans: L10nTranslations.zhHans,
    .zhHant: L10nTranslations.zhHant,
  ]

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
    L10nPolish.safety,
    L10nPolish.vm,
    L10nPolish.machine,
  ]
}

/// Namespace for the Polish tables; each `L10nPolish+*.swift` adds one.
enum L10nPolish {}

/// Namespace for the other languages; `L10nTranslations+<code>.swift` each.
enum L10nTranslations {}
