import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Three answers of `tmutil destinationinfo` MUST give three different panel
/// states: the machine's share, no share of ours, and NO ANSWER. A missing
/// answer read as "does not point" tells the person to register a destination
/// that is intact.
@MainActor
final class TimeMachineDestinationStateTests: XCTestCase {

  private let ours = TimeMachineStatus.Destination(
    name: "CloudMachine", kind: "Network", url: "smb://tm@192.168.64.10/CloudMachine", id: "ID-1")

  // MARK: - Translating the tmutil answer into a panel state

  func testRegisteredDestinationIsTheMachine() {
    XCTAssertEqual(
      TimeMachineState.from([ours], address: "192.168.64.10"),
      .registered(url: "smb://tm@192.168.64.10/CloudMachine"))
  }

  /// The machine got a new address and Time Machine still points at the old
  /// one: that is not a backup to this machine.
  func testDestinationAtAnotherAddressIsNotRegistered() {
    XCTAssertEqual(TimeMachineState.from([ours], address: "192.168.64.11"), .notRegistered)
  }

  /// `192.168.64.1` must not match `192.168.64.10`.
  func testAddressPrefixDoesNotMatch() {
    XCTAssertEqual(TimeMachineState.from([ours], address: "192.168.64.1"), .notRegistered)
  }

  /// Without the machine's address (it did not answer) any CloudMachine share counts.
  func testWithoutAddressAnyMachineShareCounts() {
    XCTAssertEqual(
      TimeMachineState.from([ours], address: nil),
      .registered(url: "smb://tm@192.168.64.10/CloudMachine"))
  }

  func testOtherDestinationIsNotRegistered() {
    let disk = TimeMachineStatus.Destination(
      name: "Backup", kind: "Local", mountPoint: "/Volumes/Backup", id: "ID-2")
    XCTAssertEqual(TimeMachineState.from([disk], address: nil), .notRegistered)
  }

  /// tmutil answered and there is no destination - THAT is "does not point".
  func testNoDestinationIsNotRegistered() {
    XCTAssertEqual(TimeMachineState.from([], address: nil), .notRegistered)
  }

  func testNoTmutilAnswerIsNotNotRegistered() {
    let state = TimeMachineState.from(nil, address: nil)
    XCTAssertNotEqual(
      state, .notRegistered,
      "tmutil not answering must not pretend to be a changed destination")
    XCTAssertEqual(state, .noAnswer)
  }

  // MARK: - The sentence a person READS

  /// The headline is the only form in which anyone will see this, so it is the
  /// headline that must express the distinction, not just the internal type.
  func testHeadlineOnNoAnswerDoesNotBlameTheDestination() {
    let status = statusApartFrom(timeMachine: .noAnswer)
    XCTAssertNotEqual(
      status.headline, "Time Machine does not point to CloudMachine",
      "this sentence tells the person to register the destination again - needless when the destination is intact"
    )
    XCTAssertTrue(
      status.headline.contains("UNKNOWN"), "got: \(status.headline)")
    XCTAssertFalse(
      status.healthy,
      "not knowing about the destination is NOT a green badge - nobody confirmed the backup arrives"
    )
  }

  /// The other side of the same thing: a TRULY changed destination must still
  /// say so plainly. Otherwise the "fix" would consist of silencing the
  /// message.
  func testHeadlineForATrulyChangedDestinationDidNotSoften() {
    let status = statusApartFrom(timeMachine: .notRegistered)
    XCTAssertEqual(status.headline, "Time Machine does not point to CloudMachine")
    XCTAssertFalse(status.healthy)
  }

  /// A state in which everything except the Time Machine destination is fine -
  /// so that the headline talks about the destination, not about something
  /// earlier.
  private func statusApartFrom(timeMachine: TimeMachineState) -> AppStatus {
    let status = AppStatus.healthyForTests()
    status.timeMachineState = timeMachine
    return status
  }
}
