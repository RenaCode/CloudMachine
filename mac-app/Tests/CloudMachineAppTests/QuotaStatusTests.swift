import XCTest
@testable import CloudMachineApp

final class QuotaStatusTests: XCTestCase {

    func testFraction_normalUsage() {
        let quota = QuotaStatus(usedGB: 50, limitGB: 200, lastChecked: nil)
        XCTAssertEqual(quota.fraction, 0.25, accuracy: 0.0001)
        XCTAssertFalse(quota.isNearLimit)
    }

    func testFraction_zeroLimitDoesNotDivideByZero() {
        let quota = QuotaStatus(usedGB: 50, limitGB: 0, lastChecked: nil)
        XCTAssertEqual(quota.fraction, 0)
    }

    func testFraction_isClampedAtOne() {
        // Realne uzycie moze chwilowo przekroczyc limit (np. tuz przed tym, jak
        // quota-watchdog.sh zdazy przyciac stare backupy) - UI (pasek postepu)
        // nie moze wtedy dostac wartosci > 1.0.
        let quota = QuotaStatus(usedGB: 250, limitGB: 200, lastChecked: nil)
        XCTAssertEqual(quota.fraction, 1.0, accuracy: 0.0001)
    }

    func testIsNearLimit_atNinetyPercentThreshold() {
        let quota = QuotaStatus(usedGB: 180, limitGB: 200, lastChecked: nil)
        XCTAssertTrue(quota.isNearLimit)
    }
}
