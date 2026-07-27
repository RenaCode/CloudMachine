import XCTest
@testable import CloudMachineCore

final class MountWatchdogServiceTests: XCTestCase {
    func testDecide_mountedAndResponsive_isHealthy() {
        let (decision, streak) = MountWatchdogService.decide(nfsListed: true, isResponsive: true, isBusyDraining: false, currentStreak: 2)
        XCTAssertEqual(decision, .healthy)
        XCTAssertEqual(streak, 0)
    }

    func testDecide_mountedButUnresponsive_belowThreshold_waitsForConfirmation() {
        let (decision, streak) = MountWatchdogService.decide(nfsListed: true, isResponsive: false, isBusyDraining: false, currentStreak: 0)
        XCTAssertEqual(decision, .waitingForConfirmation(streak: 1))
        XCTAssertEqual(streak, 1)
    }

    func testDecide_mountedButUnresponsive_reachesThreshold_needsRepair() {
        // slowStreakThreshold = 3 - trzeci kolejny nieudany probe (currentStreak
        // startuje od 2, +1 = 3) musi przelaczyc na naprawe, NIE kolejne
        // czekanie - pojedynczy wolny probe nie powinien wywalac zdrowego
        // mountu, ale trzy pod rzad powinny.
        let (decision, streak) = MountWatchdogService.decide(nfsListed: true, isResponsive: false, isBusyDraining: false, currentStreak: 2)
        XCTAssertEqual(decision, .needsRepair)
        XCTAssertEqual(streak, 0)
    }

    func testDecide_notMountedButRcloneBusyDraining_waits() {
        // rclone celowo nie uruchamia serwera NFS, dopoki nie dogoni zaleglej
        // kolejki uploadow po przerwanym backupie - watchdog NIE MOZE tego
        // przerwac, bo kazdy restart zaczyna liczenie od zera.
        let (decision, streak) = MountWatchdogService.decide(nfsListed: false, isResponsive: false, isBusyDraining: true, currentStreak: 0)
        XCTAssertEqual(decision, .waitingForRcloneDraining)
        XCTAssertEqual(streak, 0)
    }

    func testDecide_notMountedAndRcloneIdle_needsRepairImmediately() {
        // Brak montowania i rclone bezczynny (nie dogania zadnej kolejki) -
        // naprawa od razu, BEZ czekania na streak (w przeciwienstwie do
        // przypadku "zamontowane, ale nie odpowiada").
        let (decision, streak) = MountWatchdogService.decide(nfsListed: false, isResponsive: false, isBusyDraining: false, currentStreak: 0)
        XCTAssertEqual(decision, .needsRepair)
        XCTAssertEqual(streak, 0)
    }
}
