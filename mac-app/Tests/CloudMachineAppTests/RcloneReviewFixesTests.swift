import XCTest

@testable import CloudMachineApp
@testable import CloudMachineCore

/// Second review of the automatic rclone install.
@MainActor
final class RcloneReviewFixesTests: XCTestCase {

  // MARK: - Version boundary

  func testMinimumVersionIsAcceptedAndOneBelowIsNot() {
    XCTAssertTrue(RcloneVersion.isAcceptable(output: "rclone v1.65.0"))
    XCTAssertFalse(RcloneVersion.isAcceptable(output: "rclone v1.64.2"))
    XCTAssertTrue(RcloneVersion.isAcceptable(output: "rclone v1.65.1"))
  }

  // MARK: - Swapping the binary in

  private func tempDir() throws -> URL {
    let dir = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("rclone-swap-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    addTeardownBlock { try? FileManager.default.removeItem(at: dir) }
    return dir
  }

  func testSwapInReplacesAnExistingBinaryAndLeavesNoTemporaryFile() throws {
    let dir = try tempDir()
    let source = dir.appendingPathComponent("new")
    let destination = dir.appendingPathComponent("rclone")
    try "new".write(to: source, atomically: true, encoding: .utf8)
    try "old".write(to: destination, atomically: true, encoding: .utf8)
    try RcloneInstaller.swapIn(source: source, destination: destination)
    XCTAssertEqual(try String(contentsOf: destination, encoding: .utf8), "new")
    let attrs = try FileManager.default.attributesOfItem(atPath: destination.path)
    XCTAssertEqual(attrs[.posixPermissions] as? Int, 0o755)
    let left = try FileManager.default.contentsOfDirectory(atPath: dir.path).sorted()
    XCTAssertEqual(left, ["new", "rclone"])
  }

  func testSwapInCreatesTheBinaryWhenThereIsNone() throws {
    let dir = try tempDir()
    let source = dir.appendingPathComponent("new")
    let destination = dir.appendingPathComponent("rclone")
    try "new".write(to: source, atomically: true, encoding: .utf8)
    try RcloneInstaller.swapIn(source: source, destination: destination)
    XCTAssertEqual(try String(contentsOf: destination, encoding: .utf8), "new")
  }

  func testSwapInFailureKeepsTheOldBinary() throws {
    let dir = try tempDir()
    let destination = dir.appendingPathComponent("rclone")
    try "old".write(to: destination, atomically: true, encoding: .utf8)
    XCTAssertThrowsError(
      try RcloneInstaller.swapIn(
        source: dir.appendingPathComponent("missing"), destination: destination))
    XCTAssertEqual(try String(contentsOf: destination, encoding: .utf8), "old")
    XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: dir.path), ["rclone"])
  }

  func testConcurrentSwapsIntoAMissingBinaryBothSucceed() async throws {
    // The app and `cloudmachine-agent install-rclone` can finish together on a
    // fresh Mac: neither may fail with "file exists".
    for _ in 0..<20 {
      let dir = try tempDir()
      let destination = dir.appendingPathComponent("rclone")
      let a = dir.appendingPathComponent("a")
      let b = dir.appendingPathComponent("b")
      try "a".write(to: a, atomically: true, encoding: .utf8)
      try "b".write(to: b, atomically: true, encoding: .utf8)
      async let r1: Bool = Task.detached {
        (try? RcloneInstaller.swapIn(source: a, destination: destination)) != nil
      }.value
      async let r2: Bool = Task.detached {
        (try? RcloneInstaller.swapIn(source: b, destination: destination)) != nil
      }.value
      let results = await [r1, r2]
      XCTAssertEqual(results, [true, true])
      XCTAssertTrue(FileManager.default.fileExists(atPath: destination.path))
    }
  }

  // MARK: - Error banner ownership

  func testRcloneSuccessDoesNotClearAnotherError() {
    var slot = RcloneErrorSlot()
    var message: String? = "Set up the machine first"
    slot.apply(.installed, to: &message)
    XCTAssertEqual(message, "Set up the machine first")
    slot.apply(.installing, to: &message)
    XCTAssertEqual(message, "Set up the machine first")
  }

  func testRcloneErrorIsShownAndThenCleared() {
    var slot = RcloneErrorSlot()
    var message: String? = nil
    slot.apply(.failed("offline", retryAt: Date()), to: &message)
    XCTAssertEqual(message, "offline")
    slot.apply(.installing, to: &message)
    XCTAssertNil(message)
  }

  func testRcloneErrorIsNotClearedAfterSomethingElseReplacedIt() {
    var slot = RcloneErrorSlot()
    var message: String? = nil
    slot.apply(.failed("offline", retryAt: Date()), to: &message)
    message = "Set up the machine failed"
    slot.apply(.installed, to: &message)
    XCTAssertEqual(message, "Set up the machine failed")
  }

  // MARK: - Headline versus the card

  func testHeadlineSaysInstallingWhileIdleToo() {
    let status = AppStatus()
    status.dependencyState = .missing(["rclone"], ["cloudmachine-agent install-rclone"])
    status.rcloneInstall = .idle
    XCTAssertEqual(status.headline, "Installing rclone")
  }

  func testHeadlineDoesNotSayInstallingAfterAFailure() {
    let status = AppStatus()
    status.dependencyState = .missing(["rclone"], ["cloudmachine-agent install-rclone"])
    status.rcloneInstall = .failed("offline", retryAt: Date())
    XCTAssertEqual(status.headline, "Missing: rclone")
  }

  // MARK: - Pinned version

  func testPinnedVersionMatchesTheMachine() throws {
    let yaml = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("vm/cmsmb.yaml")
    let text = try String(contentsOf: yaml, encoding: .utf8)
    func value(_ key: String) -> String? {
      text.components(separatedBy: .newlines)
        .first { $0.trimmingCharacters(in: .whitespaces).hasPrefix(key + "=") }?
        .split(separator: "=", maxSplits: 1).last.map { String($0) }
    }
    XCTAssertEqual(value("RCLONE_VERSION"), RcloneInstaller.pinnedVersion)
  }

  func testEveryMacArchitectureHasAPinnedChecksum() {
    XCTAssertEqual(RcloneInstaller.pinnedVersion, "v1.75.1")
    for arch in ["osx-arm64", "osx-amd64"] {
      let sum = RcloneInstaller.pinnedChecksums[arch]
      XCTAssertEqual(sum?.count, 64, arch)
      XCTAssertTrue(sum?.allSatisfy { $0.isHexDigit } ?? false, arch)
    }
  }

  func testPinnedChecksumMatchesThePublishedSumsFile() {
    // Real lines of https://downloads.rclone.org/v1.75.1/SHA256SUMS.
    let sums = """
      29253d0288b8fbbac46baad6e5f6add6cb01d462c79f10805bbd4631c4cdf82c  rclone-v1.75.1-osx-amd64.zip
      c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f  rclone-v1.75.1-osx-arm64.zip
      """
    for arch in ["osx-arm64", "osx-amd64"] {
      XCTAssertEqual(
        RcloneInstaller.expectedChecksum(
          sumsContent: sums, zipName: "rclone-\(RcloneInstaller.pinnedVersion)-\(arch).zip"),
        RcloneInstaller.pinnedChecksums[arch])
    }
  }
}
