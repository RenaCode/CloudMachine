import XCTest

@testable import CloudMachineCore

/// Finding 15b: the result of `backupCorruptFile()` was ignored.
///
/// That function returns `nil` when copying fails, and its own comment calls
/// this copy the ONLY safety net between "the file did not parse" and "an
/// auto-save silently overwrote it with an empty configuration".
/// `loadOrInitialize()` called it via `backupCorruptFile()` without checking
/// the result and returned `(.empty, error)`, and the CLI logged "original
/// kept on disk with a backup copy next to it" - a sentence that was false
/// exactly in the case where the only copy of the data was about to be lost on
/// the next write.
final class ConfigStoreTests: XCTestCase {

  private var directory: URL!
  private var file: URL!

  override func setUpWithError() throws {
    directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-config-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    file = directory.appendingPathComponent("machines.json")
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: directory)
  }

  private struct Corrupt: Error {
    var localizedDescription: String { "unexpected character at position 12" }
  }

  // MARK: - A missing copy aborts

  /// The CORE of the fix. Without a copy there is no configuration to work
  /// with - `config` is `nil`, not "empty". So the caller has nothing to save
  /// and cannot overwrite a corrupt-but-recoverable file.
  func testMissingCopyGivesNoConfigurationToWorkWith() {
    let result = ConfigStore.decideAfterCorruption(backup: nil, error: Corrupt())
    XCTAssertNil(
      result.config,
      "a missing copy must ABORT, not hand over an empty configuration that overwrites the original"
    )
    XCTAssertNotNil(result.corruption, "the reason for the corruption must reach a person")
  }

  /// When the copy WAS MADE, working on an empty configuration is safe - the
  /// original can be recovered from the file next to it. Without this test a
  /// "fix" that always aborts would go unnoticed, and a config corrupted by a
  /// manual edit would block the whole tool.
  func testSuccessfulCopyAllowsWorkToContinue() {
    let copy = directory.appendingPathComponent("machines.json.corrupt-1")
    let result = ConfigStore.decideAfterCorruption(backup: copy, error: Corrupt())
    XCTAssertNotNil(result.config)
    XCTAssertNotNil(result.corruption, "the corruption must still be visible")
    guard case .corruptButBackedUp(_, let location, _) = result else {
      return XCTFail("expected .corruptButBackedUp, got \(result)")
    }
    XCTAssertEqual(location, copy, "the message must say WHERE the copy is")
  }

  /// A healthy file is not a corruption.
  func testHealthyConfigurationReportsNoCorruption() {
    XCTAssertNil(ConfigInitialization.ready(.empty).corruption)
    XCTAssertNotNil(ConfigInitialization.ready(.empty).config)
  }

  // MARK: - The copy itself

  func testCopyOfCorruptFileIsMadeNextToIt() throws {
    try "{ this is not json".write(to: file, atomically: true, encoding: .utf8)

    let copy = try XCTUnwrap(ConfigStore.backupCorruptFile(configPath: file))
    XCTAssertTrue(FileManager.default.fileExists(atPath: copy.path))
    XCTAssertEqual(try String(contentsOf: copy, encoding: .utf8), "{ this is not json")
    XCTAssertTrue(
      FileManager.default.fileExists(atPath: file.path),
      "the copy must not take the original away - it is a copy, not a move")
    XCTAssertTrue(copy.lastPathComponent.contains("corrupt-"), copy.lastPathComponent)
  }

  /// A failed copy MUST be recognizable from the result - here via a path in a
  /// directory that does not exist.
  func testFailedCopyReturnsNil() {
    let missing = directory.appendingPathComponent("no-such-directory")
      .appendingPathComponent("machines.json")
    XCTAssertNil(ConfigStore.backupCorruptFile(configPath: missing))
  }
}
