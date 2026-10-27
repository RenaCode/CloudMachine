import XCTest

@testable import CloudMachineCore

/// When a mount without its rclone gets unmounted - and when it must not.
final class OrphanMountTests: XCTestCase {

  private let start: TimeInterval = 1_793_000_000

  func testOrphanNeedsSureMountAndSureGone() {
    XCTAssertEqual(
      OrphanMount.orphanedSince(nil, mounted: true, rclone: .gone, now: start), start)
    XCTAssertNil(OrphanMount.orphanedSince(nil, mounted: true, rclone: .running, now: start))
    XCTAssertNil(OrphanMount.orphanedSince(nil, mounted: true, rclone: .unknown, now: start))
    XCTAssertNil(OrphanMount.orphanedSince(nil, mounted: false, rclone: .gone, now: start))
    XCTAssertNil(OrphanMount.orphanedSince(nil, mounted: nil, rclone: .gone, now: start))
  }

  func testOrphanKeepsItsFirstSighting() {
    XCTAssertEqual(
      OrphanMount.orphanedSince(start, mounted: true, rclone: .gone, now: start + 90), start)
  }

  /// Doubt in between starts the wait over instead of counting towards it.
  func testDoubtResetsTheClock() {
    var since = OrphanMount.orphanedSince(nil, mounted: true, rclone: .gone, now: start)
    since = OrphanMount.orphanedSince(since, mounted: true, rclone: .unknown, now: start + 30)
    since = OrphanMount.orphanedSince(since, mounted: true, rclone: .gone, now: start + 60)
    XCTAssertEqual(since, start + 60)
    XCTAssertFalse(OrphanMount.shouldUnmount(orphanedSince: since, now: start + 90))
  }

  /// launchd restarting rclone also leaves the mount listed for a moment.
  func testWaitsOutTheGrace() {
    XCTAssertFalse(OrphanMount.shouldUnmount(orphanedSince: nil, now: start))
    XCTAssertFalse(
      OrphanMount.shouldUnmount(orphanedSince: start, now: start + OrphanMount.grace - 1))
    XCTAssertTrue(OrphanMount.shouldUnmount(orphanedSince: start, now: start + OrphanMount.grace))
  }

  func testExitingAndZombieProcessesDoNotCount() {
    XCTAssertTrue(OrphanMount.anyAlive(psStates: "Ss\n"))
    XCTAssertTrue(OrphanMount.anyAlive(psStates: "UE\nS+\n"))
    XCTAssertFalse(OrphanMount.anyAlive(psStates: "UE\n"))
    XCTAssertFalse(OrphanMount.anyAlive(psStates: "Z\n"))
    XCTAssertFalse(OrphanMount.anyAlive(psStates: ""))
  }

  /// The pattern matches the command line `DriveBufferService` builds.
  func testPatternMatchesTheMountCommandLine() throws {
    let line =
      ([CMTooling.managedRclonePath.path] + DriveBufferService.mountArguments()).joined(
        separator: " ")
    let regex = try NSRegularExpression(pattern: OrphanMount.rclonePattern)
    XCTAssertNotNil(regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)))
    let other = "/opt/homebrew/bin/rclone mount gdrive: /tmp/x"
    XCTAssertNil(regex.firstMatch(in: other, range: NSRange(other.startIndex..., in: other)))
  }
}
