import XCTest

@testable import CloudMachineCore

/// Guards the rules in `L10n`: every key translated into every language,
/// placeholders matching, and no Polish left in the code outside the tables.
///
/// These tests read the source tree, because the failure they look for is a
/// string that compiles fine and only shows up as English text on a Polish
/// Mac (or Polish text on an English one).
final class L10nTests: XCTestCase {

  // MARK: - Language detection

  func testEnvironmentOverridesSystemLanguage() {
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: ["CM_LANGUAGE": "PL"], preferredLanguages: ["en-US"], isRunningTests: true),
      .pl)
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: ["CM_LANGUAGE": "en"], preferredLanguages: ["pl-PL"], isRunningTests: false),
      .en)
  }

  func testEnvironmentAcceptsEveryLanguageCode() {
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: ["CM_LANGUAGE": "zh-hant"], preferredLanguages: ["en-US"],
        isRunningTests: true),
      .zhHant)
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: ["CM_LANGUAGE": "pt-BR"], preferredLanguages: ["en-US"], isRunningTests: true),
      .ptBR)
  }

  /// Same matching as macOS uses for a localized app: the first preferred
  /// language the app has wins, regional variants fall back to the language.
  func testFollowsPreferredLanguagesLikeTheSystem() {
    let cases: [([String], L10n.Language)] = [
      (["pl-PL", "en-US"], .pl),
      (["en-PL", "pl-PL"], .en),
      (["de-DE"], .de),
      (["de-AT"], .de),
      (["fr-CA", "en-US"], .fr),
      (["ja-JP"], .ja),
      (["ar-SA"], .ar),
      (["he-IL"], .he),
      (["zh-Hans-PL"], .zhHans),
      (["zh-CN"], .zhHans),
      (["zh-TW"], .zhHant),
      (["zh-HK"], .zhHant),
      (["pt-BR"], .ptBR),
      (["pt-PT"], .ptBR),
      (["nb-NO"], .nb),
      (["uk-UA", "pl-PL"], .pl),
      (["uk-UA"], .en),
      ([], .en),
    ]
    for (preferred, expected) in cases {
      XCTAssertEqual(
        L10n.detectLanguage(environment: [:], preferredLanguages: preferred, isRunningTests: false),
        expected, "\(preferred)")
    }
  }

  func testTheSameTwentyTwoLanguagesAsTheGames() {
    XCTAssertEqual(
      L10n.Language.allCases.map(\.rawValue),
      [
        "ar", "da", "de", "en", "es", "fi", "fr", "he", "it", "ja", "ko", "ms", "nb", "nl", "pl",
        "pt-BR", "ru", "sv", "th", "tr", "zh-Hans", "zh-Hant",
      ])
  }

  func testRightToLeftOnlyForArabicAndHebrew() {
    XCTAssertEqual(L10n.Language.allCases.filter(\.isRightToLeft), [.ar, .he])
  }

  /// CFBundleLocalizations makes macOS pick the same language for its own
  /// parts of the app (menus, alerts, mirrored window chrome for ar/he).
  func testInfoPlistDeclaresTheSameLanguages() throws {
    let url = Self.macAppRoot.appendingPathComponent("Resources/Info.plist")
    let plist = try XCTUnwrap(
      PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
        as? [String: Any])
    XCTAssertEqual(
      plist["CFBundleLocalizations"] as? [String], L10n.Language.allCases.map(\.rawValue))
    XCTAssertEqual(plist["CFBundleDevelopmentRegion"] as? String, "en")
  }

  func testTranslatesIntoTheSelectedLanguage() {
    defer { L10n.language = .en }
    L10n.language = .de
    XCTAssertEqual(L10n.tr("Cancel"), "Abbrechen")
    L10n.language = .pl
    XCTAssertEqual(L10n.tr("Cancel"), "Anuluj")  // l10n-polish-ok
    L10n.language = .en
    XCTAssertEqual(L10n.tr("Cancel"), "Cancel")
  }

  func testTestsRunInEnglishWhateverTheSystemSays() {
    XCTAssertEqual(
      L10n.detectLanguage(environment: [:], preferredLanguages: ["pl-PL"], isRunningTests: true),
      .en)
  }

  func testFormatsPlaceholders() {
    XCTAssertEqual(L10n.tr("%@ of %@", "1", "2"), "1 of 2")
    XCTAssertEqual(L10n.tr("no placeholders"), "no placeholders")
  }

  // MARK: - Source scan

  private static let macAppRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // CloudMachineAppTests
    .deletingLastPathComponent()  // Tests
    .deletingLastPathComponent()  // mac-app

  private static func swiftFiles(under directory: String) -> [URL] {
    let root = macAppRoot.appendingPathComponent(directory)
    guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
    else { return [] }
    return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
  }

  private static func relative(_ url: URL) -> String {
    String(url.path.dropFirst(macAppRoot.path.count + 1))
  }

  /// Keys as the compiler sees them, from every `L10n.tr("...")` in Sources.
  private static func usedKeys() throws -> (keys: [String: String], problems: [String]) {
    var keys: [String: String] = [:]
    var problems: [String] = []
    let call = try NSRegularExpression(pattern: #"L10n\.tr\(\s*("(?:[^"\\]|\\.)*")?"#)
    for file in swiftFiles(under: "Sources") {
      let text = try String(contentsOf: file, encoding: .utf8)
      let range = NSRange(text.startIndex..., in: text)
      for match in call.matches(in: text, range: range) {
        let line = text[..<Range(match.range, in: text)!.lowerBound].filter { $0 == "\n" }.count + 1
        let place = "\(relative(file)):\(line)"
        guard let literalRange = Range(match.range(at: 1), in: text) else {
          problems.append("\(place): key is not an inline single-line string literal")
          continue
        }
        let literal = String(text[literalRange].dropFirst().dropLast())
        if literal.contains("\\(") {
          problems.append("\(place): key uses string interpolation; use %@ and arguments")
          continue
        }
        keys[unescape(literal)] = place
      }
    }
    return (keys, problems)
  }

  private static func unescape(_ literal: String) -> String {
    var result = ""
    var iterator = literal.makeIterator()
    while let character = iterator.next() {
      guard character == "\\", let next = iterator.next() else {
        result.append(character)
        continue
      }
      switch next {
      case "n": result.append("\n")
      case "t": result.append("\t")
      default: result.append(next)
      }
    }
    return result
  }

  /// What a translation must keep from its English key, so that
  /// `String(format:)` gets the same arguments and CLI output keeps its shape.
  private static func formatProblems(_ text: String, key: String) -> [String] {
    var problems: [String] = []
    let positional = try! NSRegularExpression(pattern: #"%(\d+)\$@"#)
    let range = NSRange(text.startIndex..., in: text)
    let indices = positional.matches(in: text, range: range).map {
      Int(text[Range($0.range(at: 1), in: text)!])!
    }
    let plain = text.components(separatedBy: "%@").count - 1
    let expected = key.components(separatedBy: "%@").count - 1
    if indices.isEmpty {
      if plain != expected { problems.append("\(plain) placeholders, the key has \(expected)") }
    } else if plain != 0 || indices.sorted() != Array(1...max(expected, 1)) || expected == 0 {
      problems.append("positional placeholders must be exactly %1$@...%\(expected)$@")
    }
    let escaped = { (s: String) in s.components(separatedBy: "%%").count - 1 }
    if escaped(text) != escaped(key) { problems.append("%% count differs") }
    let stripped = positional.stringByReplacingMatches(in: text, range: range, withTemplate: "")
      .replacingOccurrences(of: "%%", with: "").replacingOccurrences(of: "%@", with: "")
    if stripped.contains("%") { problems.append("stray % (write %% for a percent sign)") }
    let lines = { (s: String) in s.components(separatedBy: "\n") }
    if lines(text).count != lines(key).count { problems.append("line count differs") }
    // Width may differ: an indent lines up under a prefix that is translated too.
    let indented = { (s: String) in lines(s).map { $0.hasPrefix(" ") } }
    if indented(text) != indented(key) { problems.append("indented lines differ") }
    return problems
  }

  /// Control characters other than a newline, invisible direction and
  /// zero-width marks (they garble Terminal output), the replacement character.
  private static let forbiddenScalars = CharacterSet.controlCharacters
    .subtracting(CharacterSet(charactersIn: "\n"))
    .union(CharacterSet(charactersIn: "\u{200B}\u{200C}\u{200D}\u{FEFF}\u{FFFD}"))
    .union(CharacterSet(charactersIn: Unicode.Scalar(0x200E)!...Unicode.Scalar(0x200F)!))
    .union(CharacterSet(charactersIn: Unicode.Scalar(0x202A)!...Unicode.Scalar(0x202E)!))
    .union(CharacterSet(charactersIn: Unicode.Scalar(0x2066)!...Unicode.Scalar(0x2069)!))

  /// Letters only Polish uses among the 22 languages: one in another table is
  /// a Polish text copied instead of translated.
  private static let polishOnlyLetters = CharacterSet(
    charactersIn: "\u{0105}\u{0107}\u{0119}\u{0142}\u{0144}\u{015B}\u{017A}\u{017C}"
      + "\u{0104}\u{0106}\u{0118}\u{0141}\u{0143}\u{015A}\u{0179}\u{017B}")

  func testEveryKeyIsTranslatedIntoEveryLanguage() throws {
    let (keys, problems) = try Self.usedKeys()
    var failures = problems
    for language in L10n.Language.allCases where language != .en {
      let table = L10n.translations[language] ?? [:]
      for (key, place) in keys.sorted(by: { $0.value < $1.value }) {
        let label = "\(place) [\(language.rawValue)] \"\(key)\""
        guard let text = table[key], !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
          failures.append("\(label): no translation")
          continue
        }
        failures += Self.formatProblems(text, key: key).map { "\(label): \($0) -> \"\(text)\"" }
        if text.unicodeScalars.contains(where: Self.forbiddenScalars.contains) {
          failures.append("\(label): control, direction or zero-width character")
        }
        if language != .pl, text.unicodeScalars.contains(where: Self.polishOnlyLetters.contains) {
          failures.append("\(label): Polish letters -> \"\(text)\"")
        }
      }
    }
    XCTAssert(
      failures.isEmpty,
      "\(failures.count) problems:\n" + failures.prefix(300).joined(separator: "\n"))
  }

  func testNoUnusedTranslations() throws {
    let used = Set(try Self.usedKeys().keys.keys)
    var unused: [String] = []
    for (language, table) in L10n.translations {
      unused += table.keys.filter { !used.contains($0) }.map { "[\(language.rawValue)] \($0)" }
    }
    XCTAssert(unused.isEmpty, "Entries no code uses:\n" + unused.sorted().joined(separator: "\n"))
  }

  /// A test of the checks themselves: each rule catches what it is for.
  func testFormatChecksCatchBrokenTranslations() {
    XCTAssertEqual(Self.formatProblems("%@ von %@", key: "%@ of %@"), [])
    XCTAssertEqual(Self.formatProblems("%2$@ / %1$@", key: "%@ of %@"), [])
    XCTAssertEqual(Self.formatProblems("90 %%", key: "90%%"), [])
    XCTAssertFalse(Self.formatProblems("%@", key: "%@ of %@").isEmpty)
    XCTAssertFalse(Self.formatProblems("%1$@ %1$@", key: "%@ of %@").isEmpty)
    XCTAssertFalse(Self.formatProblems("%1$@ %@", key: "%@ of %@").isEmpty)
    XCTAssertFalse(Self.formatProblems("90 %", key: "90%%").isEmpty)
    XCTAssertFalse(Self.formatProblems("%d", key: "%@").isEmpty)
    XCTAssertFalse(Self.formatProblems("a b", key: "a\nb").isEmpty)
    XCTAssertFalse(Self.formatProblems("x", key: "   x").isEmpty)
  }

  func testTablesDoNotDisagree() {
    var seen: [String: String] = [:]
    var conflicts: [String] = []
    for table in L10n.polishTables {
      for (key, value) in table {
        if let earlier = seen[key], earlier != value {
          conflicts.append("\"\(key)\": \"\(earlier)\" vs \"\(value)\"")
        }
        seen[key] = value
      }
    }
    XCTAssert(conflicts.isEmpty, "\n" + conflicts.joined(separator: "\n"))
  }

  // MARK: - Polish left in the code

  /// Diacritics (as ICU `\uXXXX` escapes), plus common Polish words that have
  /// no English homograph. The word lines carry the allow marker, because a
  /// list of Polish words is necessarily Polish.
  private static let polishPattern =
    #"[\u0105\u0107\u0119\u0142\u0144\u00F3\u015B\u017A\u017C\u0104\u0106\u0118\u0141\u0143\u00D3\u015A\u0179\u017B]"#
    + #"|\b(?i:"#
    + #"nie|sie|jest|oraz|jesli|gdy|zeby|"#  // l10n-polish-ok
    + #"wiec|juz|moze|tylko|przez|dla|ktory|"#  // l10n-polish-ok
    + #"ktora|ktore|ktorych|blad|bledu|brak|kopia|"#  // l10n-polish-ok
    + #"kopii|obraz|obrazu|dysku|zapis|teraz|wszystko|"#  // l10n-polish-ok
    + #"gotowe|uwaga|przerwano|czujka|dozorca|wysylka|wyslane|"#  // l10n-polish-ok
    + #"zaleglosc|montowanie|podpiecie|odpiecie|wolne"#  // l10n-polish-ok
    + #")\b"#

  /// A line that must stay Polish (a test of the Polish translation, say)
  /// carries this marker, so every exception is visible in review.
  private static let allowMarker = "l10n-polish-ok"

  func testNoPolishOutsideThePolishTables() throws {
    let regex = try NSRegularExpression(pattern: Self.polishPattern)
    var hits: [String] = []
    for file in Self.swiftFiles(under: "Sources") + Self.swiftFiles(under: "Tests") {
      if ["L10nPolish+", "L10nTranslations+"].contains(where: file.lastPathComponent.hasPrefix) {
        continue
      }
      let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: "\n")
      for (index, line) in lines.enumerated() where !line.contains(Self.allowMarker) {
        if regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil {
          hits.append(
            "\(Self.relative(file)):\(index + 1): \(line.trimmingCharacters(in: .whitespaces))")
        }
      }
    }
    XCTAssert(
      hits.isEmpty,
      "\(hits.count) lines still in Polish:\n" + hits.prefix(200).joined(separator: "\n"))
  }
}
