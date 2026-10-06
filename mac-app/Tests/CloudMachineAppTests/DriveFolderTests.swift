import XCTest

@testable import CloudMachineCore

/// The cases that matter are the ones that would orphan a backup: a Mac that
/// already backs up somewhere must never be moved to another folder, whatever
/// is passed on the command line.
final class DriveFolderTests: XCTestCase {

  func testNewMacGetsItsMachineKey() {
    XCTAssertEqual(
      DriveFolder.decide(
        existing: nil, requested: nil, legacyEvidence: false, machineKey: "macbook-pro"),
      .assign("macbook-pro"))
  }

  func testNewMacCanChooseItsFolder() {
    XCTAssertEqual(
      DriveFolder.decide(
        existing: nil, requested: "office-imac", legacyEvidence: false, machineKey: "imac"),
      .assign("office-imac"))
  }

  func testInstallationFromBeforeFoldersKeepsTheLegacyFolder() {
    XCTAssertEqual(
      DriveFolder.decide(
        existing: nil, requested: nil, legacyEvidence: true, machineKey: "mac-studio-2"),
      .assign(DriveFolder.legacyName))
  }

  func testInstallationFromBeforeFoldersCannotBeMovedByAccident() {
    guard
      case .refuse = DriveFolder.decide(
        existing: nil, requested: "new-name", legacyEvidence: true, machineKey: "x")
    else { return XCTFail("a legacy installation was moved to a new, empty folder") }
  }

  func testStoredFolderIsKept() {
    XCTAssertEqual(
      DriveFolder.decide(
        existing: "macbook-pro", requested: nil, legacyEvidence: true, machineKey: "other"),
      .keep("macbook-pro"))
    XCTAssertEqual(
      DriveFolder.decide(
        existing: "macbook-pro", requested: "macbook-pro", legacyEvidence: false,
        machineKey: "other"),
      .keep("macbook-pro"))
  }

  func testStoredFolderCannotBeChanged() {
    guard
      case .refuse = DriveFolder.decide(
        existing: "macbook-pro", requested: "imac", legacyEvidence: false, machineKey: "x")
    else { return XCTFail("a Mac with a backup was moved to a new, empty folder") }
  }

  func testInvalidNamesAreRefused() {
    for name in [
      "", "-leading-dash", "Upper", "with space", "a/b", "..", String(repeating: "a", count: 64),
    ] {
      guard
        case .refuse = DriveFolder.decide(
          existing: nil, requested: name, legacyEvidence: false, machineKey: "x")
      else { return XCTFail("accepted invalid folder name '\(name)'") }
    }
  }

  func testUnusableMachineKeyFallsBackToAValidName() {
    XCTAssertEqual(
      DriveFolder.decide(existing: nil, requested: nil, legacyEvidence: false, machineKey: ""),
      .assign("this-mac"))
  }

  func testStoredFileIsReadAndAMissingOrBrokenOneIsIgnored() throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("drive-folder-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let file = dir.appendingPathComponent("drive-folder")

    XCTAssertNil(DriveFolder.stored(in: file))
    try "macbook-pro\n".write(to: file, atomically: true, encoding: .utf8)
    XCTAssertEqual(DriveFolder.stored(in: file), "macbook-pro")
    try "../../etc".write(to: file, atomically: true, encoding: .utf8)
    XCTAssertNil(DriveFolder.stored(in: file))
  }
}
