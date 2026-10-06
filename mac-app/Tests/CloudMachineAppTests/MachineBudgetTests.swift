import XCTest

@testable import CloudMachineCore

/// The budget decides when Time Machine deletes old backups (through the
/// quota) and when the watchdog raises an alarm, so the numbers are pinned.
final class MachineBudgetTests: XCTestCase {
  private let gib: UInt64 = 1_073_741_824

  func testQuotaIsSeventyPercentOfTheLimit() {
    // 29 Sep 2026: 417 GiB of data took 589 GiB of bands on Drive (71%).
    XCTAssertEqual(MachineBudget.timeMachineQuotaGB(forLimitGB: 1500), 1050)
    XCTAssertEqual(MachineBudget.timeMachineQuotaGB(forLimitGB: 1), 1)
  }

  func testQuotaCommand() {
    XCTAssertEqual(
      MachineBudget.setQuotaCommand(destinationID: "ABC-123", limitGB: 1000),
      "sudo tmutil setquota ABC-123 700")
  }

  func testQuotaMatchOnlyForTheExpectedValue() {
    XCTAssertTrue(MachineBudget.quotaMatches(currentQuotaGB: 700, limitGB: 1000))
    XCTAssertFalse(MachineBudget.quotaMatches(currentQuotaGB: 1000, limitGB: 1000))
    XCTAssertFalse(MachineBudget.quotaMatches(currentQuotaGB: nil, limitGB: 1000))
  }

  func testLevels() {
    XCTAssertEqual(MachineBudget.level(usageBytes: 899 * gib, limitGB: 1000), .ok)
    XCTAssertEqual(MachineBudget.level(usageBytes: 900 * gib, limitGB: 1000), .near)
    XCTAssertEqual(MachineBudget.level(usageBytes: 1000 * gib, limitGB: 1000), .near)
    XCTAssertEqual(MachineBudget.level(usageBytes: 1001 * gib, limitGB: 1000), .over)
  }

  func testProblemsCarryStableCodes() {
    let now = Date()
    let near = MachineBudget.problems(
      usage: .init(bytes: 950 * gib, measuredAt: now), limitGB: 1000)
    XCTAssertEqual(near.map(\.code), ["drive-budget-near"])
    let over = MachineBudget.problems(
      usage: .init(bytes: 1200 * gib, measuredAt: now), limitGB: 1000)
    XCTAssertEqual(over.map(\.code), ["drive-budget-exceeded"])
    XCTAssertTrue(
      MachineBudget.problems(usage: .init(bytes: 10 * gib, measuredAt: now), limitGB: 1000)
        .isEmpty)
  }

  func testNoLimitOrNoMeasurementRaisesNothing() {
    XCTAssertTrue(MachineBudget.problems(usage: nil, limitGB: 1000).isEmpty)
    XCTAssertTrue(
      MachineBudget.problems(usage: .init(bytes: 5000 * gib, measuredAt: Date()), limitGB: nil)
        .isEmpty)
  }

  func testLimitIsStoredUnderThisMacsFolderAndKeepsOtherMacs() {
    var config = MachinesConfig.empty
    config.machines = [MachineEntry(key: "imac-home", displayName: "iMac", limitGB: 800)]
    config = MachineBudget.withLimit(1500, folder: "mac-studio", in: config)
    XCTAssertEqual(MachineBudget.limitGB(in: config, folder: "mac-studio"), 1500)
    XCTAssertEqual(MachineBudget.limitGB(in: config, folder: "imac-home"), 800)
    config = MachineBudget.withLimit(1200, folder: "mac-studio", in: config)
    XCTAssertEqual(config.machines.count, 2)
    XCTAssertEqual(MachineBudget.limitGB(in: config, folder: "mac-studio"), 1200)
  }

  func testZeroLimitCountsAsUnset() {
    var config = MachinesConfig.empty
    config.machines = [MachineEntry(key: "mac-studio", displayName: "x", limitGB: 0)]
    XCTAssertNil(MachineBudget.limitGB(in: config, folder: "mac-studio"))
  }

  func testRcloneSizeOutputIsParsed() {
    XCTAssertEqual(
      MachineBudget.bytes(fromSizeJSON: #"{"count":18860,"bytes":632431263744,"sizeless":0}"#),
      632_431_263_744)
    XCTAssertNil(MachineBudget.bytes(fromSizeJSON: "Failed to size: directory not found"))
  }

  func testSummary() {
    XCTAssertEqual(MachineBudget.summary(limitGB: nil, usage: nil), "not set")
    XCTAssertEqual(
      MachineBudget.summary(limitGB: 1000, usage: .init(bytes: 589 * gib, measuredAt: Date())),
      "589 of 1000 GB used (59%)")
  }
}
