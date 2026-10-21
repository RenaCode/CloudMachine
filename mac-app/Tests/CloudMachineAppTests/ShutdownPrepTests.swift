import XCTest

@testable import CloudMachineCore

/// The marker left by preparing for a restart: it must hold the attach agent
/// back until the restart, and never beyond it.
final class ShutdownPrepTests: XCTestCase {

  private let boot: TimeInterval = 1_792_500_000.4
  private var prepared: ShutdownPrep.Marker {
    ShutdownPrep.Marker(bootTime: 1_792_500_000, preparedAt: 1_792_560_000)
  }

  /// KNOWN BAD SAMPLE: five minutes after the preparation, in the same boot
  /// session, the agent attached the image again and undid it.
  func testHoldsTheAgentBackInTheSameBootSession() {
    XCTAssertTrue(ShutdownPrep.isActive(prepared, bootTime: boot, now: 1_792_560_300))
  }

  /// After the restart the agents must bring the image up as usual.
  func testDoesNotHoldAfterARestart() {
    XCTAssertFalse(ShutdownPrep.isActive(prepared, bootTime: 1_792_563_000, now: 1_792_563_100))
  }

  /// A preparation without a restart must not leave Time Machine without a
  /// destination for good.
  func testExpiresAfterTheWindow() {
    let end = prepared.preparedAt + ShutdownPrep.window
    XCTAssertTrue(ShutdownPrep.isActive(prepared, bootTime: boot, now: end - 1))
    XCTAssertFalse(ShutdownPrep.isActive(prepared, bootTime: boot, now: end))
  }

  /// A clock set back must not stretch the hold into the past.
  func testDoesNotHoldBeforeThePreparation() {
    XCTAssertFalse(ShutdownPrep.isActive(prepared, bootTime: boot, now: prepared.preparedAt - 60))
  }

  /// No marker, or no boot time - never hold: a doubt goes to attaching,
  /// because a missing destination is the louder failure.
  func testNoMarkerOrNoBootTimeNeverHolds() {
    XCTAssertFalse(ShutdownPrep.isActive(nil, bootTime: boot, now: 1_792_560_300))
    XCTAssertFalse(ShutdownPrep.isActive(prepared, bootTime: nil, now: 1_792_560_300))
  }

  func testMarkerTextRoundTrips() {
    XCTAssertEqual(ShutdownPrep.Marker(text: prepared.text), prepared)
    XCTAssertNil(ShutdownPrep.Marker(text: "garbage"))
    XCTAssertNil(ShutdownPrep.Marker(text: ""))
  }

  /// The boot time read live is a real moment in the past.
  func testReadsTheBootTime() throws {
    let boot = try XCTUnwrap(ShutdownPrep.bootTime())
    XCTAssertLessThan(boot, Date().timeIntervalSince1970)
    XCTAssertGreaterThan(boot, Date().timeIntervalSince1970 - 400 * 86_400)
  }
}
