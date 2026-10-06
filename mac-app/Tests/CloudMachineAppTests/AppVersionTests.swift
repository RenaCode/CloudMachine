import XCTest

@testable import CloudMachineCore

/// Tests for reading the version.
///
/// The question this code is meant to answer is "is what is running the same
/// as what is in the repository". So every test injects a plist that WOULD LIE
/// if only the version number were read.
final class AppVersionTests: XCTestCase {

  private func plist(
    version: String = "1.1.0", build: String = "67",
    commit: String? = "abc1234", dirty: Any? = nil
  ) -> [String: Any] {
    var dict: [String: Any] = [
      "CFBundleShortVersionString": version,
      "CFBundleVersion": build,
    ]
    if let commit { dict[AppVersionReader.commitKey] = commit }
    if let dirty { dict[AppVersionReader.dirtyKey] = dirty }
    return dict
  }

  func testReadsVersionBuildAndCommit() {
    let version = AppVersionReader.parse(infoPlist: plist())
    XCTAssertEqual(version.shortVersion, "1.1.0")
    XCTAssertEqual(version.build, "67")
    XCTAssertEqual(version.commit, "abc1234")
    XCTAssertFalse(version.dirty)
  }

  /// `build-app` writes "true"/"false" as a STRING (substitution in the XML
  /// template), but a manually edited plist may have <true/>. Both must mean
  /// the same, otherwise a dirty build would report itself as clean.
  func testDirtyTreeRecognizedFromStringAndFromBool() {
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist(dirty: "true")).dirty)
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist(dirty: true)).dirty)
    XCTAssertFalse(AppVersionReader.parse(infoPlist: plist(dirty: "false")).dirty)
    XCTAssertFalse(AppVersionReader.parse(infoPlist: plist(dirty: false)).dirty)
  }

  /// An old bundle, built before these keys were added, must not pretend to
  /// know what it was built from.
  func testOldBundleWithoutCommitDoesNotPretendToKnow() {
    let version = AppVersionReader.parse(infoPlist: plist(commit: nil))
    XCTAssertEqual(version.commit, AppVersion.unknownCommit)
    XCTAssertFalse(version.isTraceable, "Without a commit the source cannot be pointed at")
  }

  /// The core: a dirty tree means the binary contains code from outside the
  /// commit, so the commit number does NOT prove it matches the branch.
  func testDirtyBuildIsNotTraceableDespiteKnownCommit() {
    let version = AppVersionReader.parse(infoPlist: plist(commit: "abc1234", dirty: "true"))
    XCTAssertEqual(version.commit, "abc1234")
    XCTAssertFalse(version.isTraceable, "A dirty tree invalidates the commit as proof")
  }

  func testCleanBuildWithCommitIsTraceable() {
    XCTAssertTrue(AppVersionReader.parse(infoPlist: plist()).isTraceable)
  }

  func testSummaryCarriesCommitAndWarning() {
    XCTAssertEqual(AppVersionReader.parse(infoPlist: plist()).summary, "1.1.0 (67) abc1234")
    XCTAssertTrue(
      AppVersionReader.parse(infoPlist: plist(dirty: "true")).summary.contains("DIRTY-TREE"))
    XCTAssertFalse(
      AppVersionReader.parse(infoPlist: plist(commit: nil)).summary.contains(
        AppVersion.unknownCommit),
      "A missing commit must not clutter the one-liner with the word 'unknown'")
  }
}
