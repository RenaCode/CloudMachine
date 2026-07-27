import XCTest

@testable import CloudMachineCore

final class CooldownGateTests: XCTestCase {
  func testIsWithinCooldown_neverAttempted_isFalse() {
    XCTAssertFalse(CooldownGate.isWithinCooldown(lastEpoch: nil, cooldown: 180))
  }

  func testIsWithinCooldown_recentAttempt_isTrue() {
    let now = Date(timeIntervalSince1970: 1_000_000)
    let lastEpoch = now.timeIntervalSince1970 - 60  // 60s temu
    XCTAssertTrue(CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, now: now, cooldown: 180))
  }

  func testIsWithinCooldown_exactlyAtThreshold_isFalse() {
    // Granica jest wylaczna (`<`, nie `<=`) - dokladnie w momencie uplywu
    // cooldownu juz WOLNO probowac ponownie, zgodnie z oryginalnym bash
    // (`[ $((now - last)) -lt "$COOLDOWN" ]`).
    let now = Date(timeIntervalSince1970: 1_000_000)
    let lastEpoch = now.timeIntervalSince1970 - 180
    XCTAssertFalse(CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, now: now, cooldown: 180))
  }

  func testIsWithinCooldown_oldAttempt_isFalse() {
    let now = Date(timeIntervalSince1970: 1_000_000)
    let lastEpoch = now.timeIntervalSince1970 - 3600
    XCTAssertFalse(CooldownGate.isWithinCooldown(lastEpoch: lastEpoch, now: now, cooldown: 180))
  }

  func testParseStateFile_missingFile_returnsNil() {
    let missing = URL(fileURLWithPath: "/tmp/cloudmachine-cooldown-test-\(UUID().uuidString)")
    XCTAssertNil(CooldownGate.parseStateFile(missing))
  }

  func testWriteAndParseStateFile_roundTrips() throws {
    let file = FileManager.default.temporaryDirectory
      .appendingPathComponent("cloudmachine-cooldown-test-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: file) }

    let now = Date(timeIntervalSince1970: 1_700_000_000)
    CooldownGate.writeStateFile(file, now: now)

    let parsed = try XCTUnwrap(CooldownGate.parseStateFile(file))
    XCTAssertEqual(parsed, now.timeIntervalSince1970, accuracy: 0.001)
  }
}
