import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// Three answers of `tmutil destinationinfo` MUST give three different panel
/// states.
///
/// Until 25.09.2026 the panel asked
/// `TimeMachineStatus.currentDestinationMountPoint()`, which returns `nil` both
/// when there is no destination and when tmutil does not answer - both paths
/// ended in the same `.notRegistered`, i.e. the text "Time Machine does not
/// point to CloudMachine". The direction of the mistake was safe (a false
/// alarm), but the sentence is false and tells the person to do the wrong
/// thing: register a destination that is intact. The `backup-health` watchdog
/// has told these two cases apart since 23.09.2026 (`destinationReading()`);
/// the panel was the last place that merged them.
@MainActor
final class TimeMachineDestinationStateTests: XCTestCase {

  private let target = "/Volumes/CloudMachine"

  // MARK: - Translating the tmutil answer into a panel state

  func testRegisteredDestinationIsOurImage() {
    XCTAssertEqual(
      TimeMachineState.from(.mountPoint(target), target: target),
      .registered(mountPoint: target))
  }

  /// A destination exists, but points elsewhere - there is NO backup on the
  /// Drive.
  func testDestinationPointingElsewhereIsNotRegistered() {
    XCTAssertEqual(
      TimeMachineState.from(.mountPoint("/Volumes/SomeOtherDisk"), target: target),
      .notRegistered)
  }

  /// tmutil answered and there is no destination - THAT is "does not point".
  func testNoDestinationIsNotRegistered() {
    XCTAssertEqual(TimeMachineState.from(.none, target: target), .notRegistered)
  }

  /// THAT defect. tmutil not answering has no right to look like a changed
  /// destination. `tmutil destinationinfo` reaches the mount living on Google
  /// Drive and with a sick mount does not answer at all - and then we know
  /// nothing about the destination, which is different information from
  /// "there is no destination".
  func testNoTmutilAnswerIsNotNotRegistered() {
    let state = TimeMachineState.from(.noAnswer, target: target)
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
    let status = AppStatus()
    status.dependencyState = .ready
    status.remoteConfigured = true
    var buffer = BufferStatus()
    buffer.mounted = true
    buffer.imageAttached = true
    buffer.queueKnown = true
    buffer.freeDiskGB = 400
    status.buffer = buffer
    status.backupCycle = BackupCycleStatus(
      known: true, lastSuccess: Date().addingTimeInterval(-1800), problems: [],
      checkedAt: Date())
    status.timeMachineState = timeMachine
    return status
  }
}
