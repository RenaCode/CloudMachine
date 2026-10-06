import XCTest

@testable import CloudMachineCore

/// What happens when `tmutil` DOES NOT ANSWER.
///
/// Until 23.09.2026 the answer was "nothing": `tmutil` calls had no time
/// limit, so with a dead FUSE-T mount (the ENXIO incident of 22.09)
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
  /// the real cause (a dead mount) would be left untouched.
  func testNoTmutilAnswerIsASeparateFailure() {
    let now = Date(timeIntervalSince1970: 1_758_000_000)

    let unknown = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: nil,
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
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: false,
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
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true)

    XCTAssertTrue(fine.healthy)
  }

  // MARK: - Unread mount table

  /// The reference point for this group: everything working.
  private func healthy(
    mounted: Bool? = true, attached: Bool? = true, imageDeadErrno: Int32? = nil
  ) -> BackupHealth.Report {
    let now = Date(timeIntervalSince1970: 1_758_000_000)
    return BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, mounted: mounted, attached: attached, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, imageDeadErrno: imageDeadErrno)
  }

  /// THAT silence. `BackupImageService.Attachment` got a fourth case
  /// `.unknown` ("the mount table could not be read"), and the caller passed
  /// `attachment != .detached` to the watchdog - i.e. `.unknown` went in as
  /// `true`, "attached". The watchdog, whose ONLY job is not to claim things
  /// it does not know, stayed silent about a state it did not know. This was
  /// the only place in this round where "I do not know" went towards silence
  /// rather than an alarm.
  func testUnreadImageStateIsNotSilence() {
    let unknown = healthy(attached: nil)

    XCTAssertFalse(unknown.healthy, "Unknown = not healthy. Silence is not allowed here.")
    XCTAssertTrue(
      unknown.problems.contains {
        $0.summary == "Unknown whether the backup image is attached"
      })
  }

  /// ...and it is not the same as a real detachment. The message "is not
  /// attached" would send the person off to attach an image that may be
  /// attached correctly - the same principle as with a changed destination.
  func testUnreadImageStateSoundsDifferentFromDetachment() {
    let unknown = healthy(attached: nil)
    let detached = healthy(attached: false)

    XCTAssertFalse(
      unknown.problems.contains { $0.summary == "The backup image is not attached" },
      "Not reading is NOT a detachment.")
    XCTAssertTrue(detached.problems.contains { $0.summary == "The backup image is not attached" })
    XCTAssertFalse(
      detached.problems.contains { $0.summary.hasPrefix("Unknown whether the backup image") },
      "A real detachment is a FACT, not an unknown.")
  }

  /// The same for the mount. `isMounted` is `mountedState() ?? false`, so an
  /// unread mount table reported itself as "mount is not working" - an alarm
  /// about a state nobody measured, sending the person off to fix something
  /// that may be fine.
  func testUnreadMountSoundsDifferentFromMissingMount() {
    let unknown = healthy(mounted: nil)
    let missing = healthy(mounted: false)

    XCTAssertFalse(unknown.healthy)
    XCTAssertTrue(
      unknown.problems.contains {
        $0.summary == "Unknown whether the Google Drive mount is working"
      })
    XCTAssertFalse(
      unknown.problems.contains { $0.summary == "Google Drive mount is not working" })
    XCTAssertTrue(missing.problems.contains { $0.summary == "Google Drive mount is not working" })
  }

  /// An attached but DEAD image must still be reported - rebuilding the
  /// `attached` branch into three states must not lose this case, because it
  /// has already cost 15 hours without a backup.
  func testDeadImageIsStillReported() {
    let dead = healthy(attached: true, imageDeadErrno: 6)
    XCTAssertTrue(dead.problems.contains { $0.summary.contains("DEAD (errno 6)") })
    // With an unknown state we do NOT guess that the image is alive.
    XCTAssertFalse(healthy(attached: nil).problems.contains { $0.summary.contains("DEAD") })
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
