import XCTest

@testable import CloudMachineCore

/// Guards the rules in `L10n`: every key translated, placeholders matching,
/// and no Polish left in the code outside the Polish tables.
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

  func testFollowsFirstPreferredLanguage() {
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: [:], preferredLanguages: ["pl-PL", "en-US"], isRunningTests: false),
      .pl)
    XCTAssertEqual(
      L10n.detectLanguage(
        environment: [:], preferredLanguages: ["en-PL", "pl-PL"], isRunningTests: false),
      .en)
    XCTAssertEqual(
      L10n.detectLanguage(environment: [:], preferredLanguages: ["de-DE"], isRunningTests: false),
      .en)
    XCTAssertEqual(
      L10n.detectLanguage(environment: [:], preferredLanguages: [], isRunningTests: false), .en)
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

  private static func placeholderCount(_ text: String) -> Int {
    text.components(separatedBy: "%@").count - 1
      + (try! NSRegularExpression(pattern: #"%\d+\$@"#))
      .numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text))
  }

  func testEveryKeyIsTranslatedWithMatchingPlaceholders() throws {
    let (keys, problems) = try Self.usedKeys()
    var failures = problems
    for (key, place) in keys.sorted(by: { $0.value < $1.value }) {
      guard let polish = L10n.polish[key] else {
        failures.append("\(place): no Polish translation for \"\(key)\"")
        continue
      }
      if Self.placeholderCount(polish) != Self.placeholderCount(key) {
        failures.append("\(place): placeholder count differs for \"\(key)\" -> \"\(polish)\"")
      }
    }
    XCTAssert(failures.isEmpty, "\n" + failures.joined(separator: "\n"))
  }

  func testNoUnusedPolishEntries() throws {
    let used = Set(try Self.usedKeys().keys.keys)
    let unused = L10n.polish.keys.filter { !used.contains($0) }.sorted()
    XCTAssert(unused.isEmpty, "Polish entries no code uses:\n" + unused.joined(separator: "\n"))
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
      if file.lastPathComponent.hasPrefix("L10nPolish+") { continue }
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
