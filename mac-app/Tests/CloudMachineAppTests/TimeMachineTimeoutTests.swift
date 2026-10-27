import XCTest

@testable import CloudMachineCore

/// What happens when `tmutil` DOES NOT ANSWER.
///
/// Until 23.09.2026 the answer was "nothing": `tmutil` calls had no time
/// limit, so with a dead destination (the ENXIO incident of 22.09)
/// `destinationinfo` entered uninterruptible I/O and `BackupHealth.
/// currentReport()` never returned. launchd with `StartInterval` does not
/// start a second instance while the first one is alive - the watchdog went
/// silent PERMANENTLY, while the `BackupHealth` header declared exactly the
/// opposite.
final class TimeMachineTimeoutTests: XCTestCase {

  /// The limit MUST exist and MUST fit within the watchdog's run window.
  ///
  /// `ProcessRunner` gives up only after `timeout + 10` s (SIGTERM, SIGKILL,
  /// and finally abandoning the process, because SIGKILL does not work on a
  /// process stuck in the kernel). That number, not `timeout` alone, is the
  /// real waiting time, and it is that number that must fit within the
  /// watchdog's `StartInterval` (1800 s), otherwise the limit would only
  /// postpone the hang instead of breaking it.
  func testTmutilTimeLimitExistsAndFitsWithinTheWatchdogWindow() {
    XCTAssertGreaterThan(TimeMachineStatus.commandTimeout, 0, "No limit is that very failure.")
    let longestWait = TimeMachineStatus.commandTimeout + 10
    XCTAssertLessThan(
      longestWait, 1800,
      "Waiting longer than the watchdog's StartInterval (1800 s) eats up its own run window.")
    // The margin over the healthy case (a fraction of a second) has to be
    // large, because the project already has one slip with a limit chosen for
    // a CLEAN start: 120 s was enough after a restart, and after a failure it
    // was 10 s short.
    XCTAssertGreaterThanOrEqual(
      TimeMachineStatus.commandTimeout, 60,
      "A limit chosen 'for a healthy system' will fail at the first serious failure.")
  }

  /// No answer from tmutil is a FAILURE, not "destination changed".
  ///
  /// This distinction is the whole point of the time limit. If a hung tmutil
  /// reported itself as `destinationRegistered: false`, the watchdog would
  /// send the person off to change a destination that is set correctly - and
  /// the real cause (a hung destination) would be left untouched.
  func testNoTmutilAnswerIsASeparateFailure() {
    let now = Date(timeIntervalSince1970: 1_758_000_000)

    let unknown = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: true, destinationRegistered: nil,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertFalse(unknown.healthy, "Unknown = not healthy.")
    XCTAssertTrue(
      unknown.problems.contains { $0.summary.contains("tmutil is not responding") },
      "A hung tmutil must be called by its name.")
    XCTAssertFalse(
      unknown.problems.contains { $0.summary == "Time Machine does not point to CloudMachine" },
      "This is NOT a changed destination - such a message sends the person the wrong way.")
  }

  /// The answer "the destination is changed" must still read as before -
  /// without this test the fix could have swapped one message for the other.
  func testChangedDestinationIsStillReportedSeparately() {
    let now = Date(timeIntervalSince1970: 1_758_000_000)

    let changed = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: true,
      destinationRegistered: false,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertTrue(
      changed.problems.contains { $0.summary == "Time Machine does not point to CloudMachine" })
    XCTAssertFalse(changed.problems.contains { $0.summary.contains("tmutil is not responding") })
  }

  /// A correctly set destination reports neither of these two problems.
  func testCorrectlySetDestinationReportsNothing() {
    let now = Date(timeIntervalSince1970: 1_758_000_000)

    let fine = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertTrue(fine.healthy)
  }

  // MARK: - The machine: no answer is not "stopped"

  /// The reference point for this group: everything working.
  private func healthy(
    machineRunning: Bool? = true, servicesHealthy: Bool? = true
  ) -> BackupHealth.Report {
    let now = Date(timeIntervalSince1970: 1_758_000_000)
    return BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: machineRunning, servicesHealthy: servicesHealthy,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true)
  }

  func testUnknownMachineIsNotSilence() {
    let unknown = healthy(machineRunning: nil, servicesHealthy: nil)
    XCTAssertFalse(unknown.healthy, "Unknown = not healthy. Silence is not allowed here.")
    XCTAssertTrue(
      unknown.problems.contains {
        $0.summary == "Unknown whether the CloudMachine machine is running"
      })
  }

  /// "Is not running" sends a person off to start a machine that may run.
  func testUnknownMachineSoundsDifferentFromStoppedMachine() {
    let unknown = healthy(machineRunning: nil, servicesHealthy: nil)
    let stopped = healthy(machineRunning: false, servicesHealthy: nil)
    XCTAssertFalse(
      unknown.problems.contains { $0.summary == "The CloudMachine machine is not running" })
    XCTAssertTrue(
      stopped.problems.contains { $0.summary == "The CloudMachine machine is not running" })
    XCTAssertFalse(
      stopped.problems.contains { $0.summary.hasPrefix("Unknown whether") },
      "A stopped machine is a FACT, not an unknown.")
  }

  /// Running, but nothing inside answered: its own problem, not "a service is down".
  func testSilentMachineSoundsDifferentFromAServiceDown() {
    let silent = healthy(servicesHealthy: nil)
    let down = healthy(servicesHealthy: false)
    XCTAssertTrue(
      silent.problems.contains { $0.summary == "The CloudMachine machine does not answer" })
    XCTAssertFalse(silent.problems.contains { $0.summary.hasPrefix("A service") })
    XCTAssertTrue(
      down.problems.contains {
        $0.summary == "A service in the CloudMachine machine is not running"
      })
  }

  /// `runningState()` exists so that "not in progress" and "unknown" can be
  /// told apart. `isRunning()` stays as a shortcut for purely informational
  /// places, and there it may merge the two cases.
  func testStatusParsingHasNotChanged() {
    XCTAssertTrue(TimeMachineStatus.isRunning(statusOutput: "Running = 1;"))
    XCTAssertFalse(TimeMachineStatus.isRunning(statusOutput: "Running = 0;"))
    XCTAssertFalse(TimeMachineStatus.isRunning(statusOutput: ""))
  }
}
