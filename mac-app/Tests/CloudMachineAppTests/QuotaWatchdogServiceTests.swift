import XCTest

@testable import CloudMachineCore

final class QuotaWatchdogServiceTests: XCTestCase {
  func testIsLimitSane_belowFloor_isFalse() {
    // To jest zabezpieczenie przed literowka (np. "0" GB), ktora inaczej
    // sprawilaby, ze watchdog uzna, ze ZAWSZE jest nad limitem i zacznie
    // kasowac wszystkie backupy - patrz komentarz przy minSaneLimitGB.
    XCTAssertFalse(QuotaWatchdogService.isLimitSane(0))
    XCTAssertFalse(QuotaWatchdogService.isLimitSane(-50))
    XCTAssertFalse(QuotaWatchdogService.isLimitSane(9))
  }

  func testIsLimitSane_atOrAboveFloor_isTrue() {
    XCTAssertTrue(QuotaWatchdogService.isLimitSane(10))
    XCTAssertTrue(QuotaWatchdogService.isLimitSane(3000))
  }

  func testTriggerGB_isNinetyPercentOfLimit() {
    XCTAssertEqual(QuotaWatchdogService.triggerGB(forLimitGB: 1000), 900)
    XCTAssertEqual(QuotaWatchdogService.triggerGB(forLimitGB: 3000), 2700)
  }
}
