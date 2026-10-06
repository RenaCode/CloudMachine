import XCTest

@testable import CloudMachineCore

/// Tests of the backup cycle watchdog.
///
/// Each of them INJECTS A KNOWN BAD SAMPLE and checks that the watchdog
/// REPORTS it. A detector's silence proves nothing - previously all the
/// "monitoring" of this project consisted of nobody seeing a warning, and that
/// passed for proof that everything worked.
final class BackupHealthTests: XCTestCase {

  private let now = Date(timeIntervalSince1970: 1_757_700_000)

  /// Everything working - the reference point. Without it a "detects a
  /// failure" test would also pass for a watchdog that always screams.
  private func healthyInput(
    lastSuccess: Date? = nil,
    lastAttempt: Date? = nil,
    result: Int? = 0,
    mounted: Bool = true,
    attached: Bool? = true,
    destinationRegistered: Bool = true,
    erroredFiles: Int = 0,
    outOfSpace: Bool = false,
    queueReadable: Bool = true,
    imageProbeTimedOut: Bool = false
  ) -> BackupHealth.Report {
    BackupHealth.evaluate(
      lastSuccess: lastSuccess ?? now.addingTimeInterval(-1800),
      lastAttempt: lastAttempt ?? now.addingTimeInterval(-1800),
      result: result,
      now: now,
      mounted: mounted,
      attached: attached,
      destinationRegistered: destinationRegistered,
      erroredFiles: erroredFiles,
      outOfSpace: outOfSpace,
      queueReadable: queueReadable,
      imageProbeTimedOut: imageProbeTimedOut)
  }

  /// The readability probe did not answer in time. This is NOT "the image is
  /// not attached" (the image is in the mount table) and NOT "the image is
  /// DEAD" (the device did not answer at all, rather than with an error). The
  /// first message would send the person to attach something that is
  /// attached; the second - to FORCE-detach a device that may be alive and
  /// holding unsent data.
  ///
  /// Most important, though, is that the watchdog gets here AT ALL: before the
  /// fix this read had no time limit, and `StartInterval 1800` without
  /// `KeepAlive` means a single hang silenced the watchdog PERMANENTLY.
  func testUnansweredProbeIsReportedAsLackOfKnowledge() {
    let report = healthyInput(attached: nil, imageProbeTimedOut: true)
    XCTAssertFalse(report.healthy, "silence about a state we do not know is a failure here")
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("returns data") },
      "the watchdog must FINISH the run and report the lack of knowledge: \(report.problems)")
    XCTAssertFalse(report.problems.contains { $0.summary.contains("is not attached") })
    XCTAssertFalse(report.problems.contains { $0.summary.contains("DEAD") })
  }

  /// Two causes of "I do not know" send the person to two different places,
  /// so they must not get the same sentence.
  func testTwoCausesOfUnknownImageStateHaveDifferentMessages() {
    let probe = healthyInput(attached: nil, imageProbeTimedOut: true).problems
    let table = healthyInput(attached: nil).problems
    XCTAssertNotEqual(probe, table)
    XCTAssertFalse(probe.isEmpty)
    XCTAssertFalse(table.isEmpty)
  }

  /// The image is in the mount table, but reading fails - on 22 Sep 2026 for
  /// 15 h no sensor had a name for this state. Now it does.
  func testDeadImageAlarms() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, imageDeadErrno: ENXIO)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("DEAD") })
    XCTAssertFalse(
      report.problems.contains { $0.summary.contains("is not attached") },
      "Dead is a different state from detached - one alarm, not two.")
  }

  func testWorkingCycleDoesNotAlarm() {
    XCTAssertTrue(healthyInput().healthy, "A watchdog that always alarms carries no information.")
  }

  // MARK: - Known bad samples

  /// THIS is the failure the whole previous system did NOT detect: the mount
  /// is up, the image attached, the destination registered - and no backup
  /// has been made for two days. The interface showed a green badge then.
  func testSilentCycleFailureIsReported() {
    let report = healthyInput(
      lastSuccess: now.addingTimeInterval(-48 * 3600),
      lastAttempt: now.addingTimeInterval(-48 * 3600))
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("No successful backup") },
      "The age of the last SUCCESSFUL backup is the only counter that grows only on success.")
  }

  /// An attempt newer than the success = the backup started and failed. The
  /// age threshold alone will not catch that until it passes - and this signal
  /// is available right away.
  func testAttemptWithoutSuccessIsReported() {
    let report = healthyInput(
      lastSuccess: now.addingTimeInterval(-2 * 3600),
      lastAttempt: now.addingTimeInterval(-90 * 60))
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("did not end in a backup") })
  }

  func testNonZeroResultIsReported() {
    let report = healthyInput(result: 27)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("RESULT=27") })
  }

  /// Bands rclone did not upload exist only on this Mac. The backup on the
  /// Drive is then INCOMPLETE and may not open.
  func testUnsentFilesAreReported() {
    let report = healthyInput(erroredFiles: 12)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("12 files") })
  }

  func testMissingMountIsReported() {
    XCTAssertTrue(
      healthyInput(mounted: false).problems.contains { $0.summary.contains("mount") })
  }

  func testDetachedImageIsReported() {
    XCTAssertTrue(
      healthyInput(attached: false).problems.contains { $0.summary.contains("is not attached") })
  }

  func testChangedTimeMachineDestinationIsReported() {
    XCTAssertTrue(
      healthyInput(destinationRegistered: false).problems.contains {
        $0.summary.contains("does not point")
      })
  }

  func testFullBufferIsReported() {
    XCTAssertTrue(
      healthyInput(outOfSpace: true).problems.contains { $0.summary.contains("Buffer") })
  }

  /// Failing to read the queue state must NOT pass for "all good" - when the
  /// question is data safety, silence must mean "I do not know", and we treat
  /// "I do not know" as a failure.
  func testUnreadableQueueIsReported() {
    XCTAssertTrue(
      healthyInput(queueReadable: false).problems.contains { $0.summary.contains("rclone") })
  }

  /// The absence of ANY successful backup is not the same as a fresh backup -
  /// and with a naive date comparison `nil` easily falls into "threshold not
  /// exceeded".
  func testAbsenceOfAnyBackupIsReported() {
    let report = BackupHealth.evaluate(
      lastSuccess: nil, lastAttempt: nil, result: 0, now: now, mounted: true, attached: true,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("NOT A SINGLE") })
  }

  // MARK: - Reading the Time Machine preferences

  /// The shape mirrored from the real
  /// `/Library/Preferences/com.apple.TimeMachine.plist` on a working
  /// installation: `SnapshotDates` gets an entry only after a COMPLETED
  /// backup, `AttemptDates` also counts the ones that failed.
  private func preferences(volumeName: String = "CloudMachine") -> [String: Any] {
    [
      "Destinations": [
        [
          "LastKnownVolumeName": "SomeOtherDisk",
          "SnapshotDates": [Date(timeIntervalSince1970: 1)],
          "AttemptDates": [Date(timeIntervalSince1970: 1)],
          "RESULT": NSNumber(value: 5),
        ],
        [
          "LastKnownVolumeName": volumeName,
          "SnapshotDates": [
            Date(timeIntervalSince1970: 1_757_600_000),
            Date(timeIntervalSince1970: 1_757_698_000),
          ],
          "AttemptDates": [Date(timeIntervalSince1970: 1_757_699_000)],
          "RESULT": NSNumber(value: 0),
        ],
      ]
    ]
  }

  func testReadingTakesTheNEWESTBackup() {
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "CloudMachine")
    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1_757_698_000))
    XCTAssertEqual(lastAttempt, Date(timeIntervalSince1970: 1_757_699_000))
    XCTAssertEqual(result, 0)
  }

  /// A Mac can have more than one registered Time Machine destination. Taking
  /// whichever comes first would read someone else's dates - and show someone
  /// else's success as ours.
  func testReadingPicksTheRightDestinationByVolumeName() {
    let (lastSuccess, _, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "SomeOtherDisk")
    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1))
    XCTAssertEqual(result, 5)
  }

  func testReadingDoesNotGuessWhenOurDestinationIsMissing() {
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: preferences(), volumeNamed: "SomethingElseEntirely")
    XCTAssertNil(lastSuccess)
    XCTAssertNil(lastAttempt)
    XCTAssertNil(result)
  }

  /// Closes the gap between the FILE and the assessment: writing to a file,
  /// reading it the same way `currentReport` does, and only then `dates`. Tests
  /// on `evaluate` alone do not cover serialization, and that is exactly where
  /// "the watchdog is silent" looks identical to "all good".
  func testReadingThroughARealPlistFileGivesTheSameDates() throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-health-\(UUID().uuidString).plist")
    defer { try? FileManager.default.removeItem(at: url) }

    let data = try PropertyListSerialization.data(
      fromPropertyList: preferences(), format: .binary, options: 0)
    try data.write(to: url)

    let raw = try Data(contentsOf: url)
    let parsed = try XCTUnwrap(
      PropertyListSerialization.propertyList(from: raw, format: nil) as? [String: Any])
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: parsed, volumeNamed: "CloudMachine")

    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1_757_698_000))
    XCTAssertEqual(lastAttempt, Date(timeIntervalSince1970: 1_757_699_000))
    XCTAssertEqual(result, 0)
  }

  /// An unreadable file must NOT look like a healthy cycle.
  func testUnreadableFileDoesNotPassForSuccess() async {
    let report = await BackupHealth.currentReport(
      preferencesFile: "/no/such/file.plist")
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("Time Machine preferences") })
  }

  // MARK: - Reporting

  /// A message with a quote must get through AppleScript without breaking the
  /// script - otherwise the alarm vanishes silently, i.e. behaves exactly like
  /// the failure it was meant to report. rclone messages do contain quotes.
  func testQuoteInTheMessageDoesNotBreakTheNotification() {
    XCTAssertEqual(
      HealthAlert.appleScriptLiteral("Post \"https://x\" canceled"),
      "\"Post \\\"https://x\\\" canceled\"")
  }

  func testBackslashIsEscapedToo() {
    XCTAssertEqual(HealthAlert.appleScriptLiteral("a\\b"), "\"a\\\\b\"")
  }

  func testNewlineDoesNotBreakTheNotification() {
    XCTAssertFalse(HealthAlert.appleScriptLiteral("a\nb").contains("\n"))
  }

  // MARK: - Finding 15c: Full Disk Access is checked by TRYING

  /// KNOWN BAD SAMPLE: a directory. `FileManager.isReadableFile(atPath:)` -
  /// i.e. `access(R_OK)` - calls a directory "readable", yet it cannot be read
  /// as a file at all. The interface asked exactly this way and about exactly
  /// a directory (`~/Library/Application Support/com.apple.TCC`), so it
  /// answered "Full Disk Access granted" regardless of the permission state -
  /// including at a moment when the watchdog could not read a single backup
  /// date.
  ///
  /// There is no question to ask TCC, only an attempt. This test compares both
  /// approaches on the same path.
  func testDirectoryDoesNotProveFileReadability() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-fda-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    XCTAssertTrue(
      FileManager.default.isReadableFile(atPath: directory.path),
      "access(R_OK) on a directory says 'readable' - and that was the whole old check")
    XCTAssertFalse(
      BackupHealth.preferencesReadable(preferencesFile: directory.path),
      "a real read must say NO - a directory is not a plist with the backup history")
  }

  /// A file that does not exist means no access to its content - not silence.
  func testMissingFileMeansNoAccess() {
    XCTAssertFalse(
      BackupHealth.preferencesReadable(
        preferencesFile: "/no-such-path/com.apple.TimeMachine.plist"))
  }

  /// And the opposite bug: a readable file MUST come out as readable, otherwise
  /// the panel would scare people with missing permissions on a working
  /// machine.
  func testReadableFileComesOutAsReadable() throws {
    let file = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-fda-\(UUID().uuidString).plist")
    try Data("anything".utf8).write(to: file)
    defer { try? FileManager.default.removeItem(at: file) }
    XCTAssertTrue(BackupHealth.preferencesReadable(preferencesFile: file.path))
  }

  // MARK: - Startup grace period

  /// KNOWN BAD SAMPLE from 21.09, 25.09 and 01.10.2026: the watchdog starts
  /// together with the session, a few seconds after rclone starts - nothing is
  /// up yet.
  private func rightAfterStartup(grace: Bool, lastSuccessAgo: TimeInterval = 1800)
    -> BackupHealth.Report
  {
    BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-lastSuccessAgo),
      lastAttempt: now.addingTimeInterval(-lastSuccessAgo),
      result: 0, now: now, mounted: false, attached: false, destinationRegistered: false,
      erroredFiles: 0, outOfSpace: false, queueReadable: false,
      withinStartupGrace: grace)
  }

  func testRightAfterStartupDevicesNotReadyAreNotAFailure() {
    let report = rightAfterStartup(grace: true)
    XCTAssertTrue(report.healthy, "\(report.problems)")
    XCTAssertEqual(report.deferred.count, 3, "deferred, not lost: \(report.deferred)")
  }

  /// The same state AFTER the grace period must alarm - otherwise the previous
  /// test would also pass for a watchdog that is always silent.
  func testAfterTheGracePeriodTheSameStateAlarms() {
    let report = rightAfterStartup(grace: false)
    XCTAssertEqual(report.problems.count, 3, "\(report.problems)")
    XCTAssertTrue(report.deferred.isEmpty)
  }

  /// The grace period does NOT silence an old backup: a Mac switched off for
  /// the night is an age the watchdog must report from the first second.
  func testGracePeriodDoesNotSilenceAnOldBackup() {
    let report = rightAfterStartup(grace: true, lastSuccessAgo: 5 * 3600)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("No successful backup") })
  }

  /// "I do not know" (a hung tmutil) is not a normal startup state.
  func testGracePeriodDoesNotSilenceLackOfKnowledge() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: nil,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, withinStartupGrace: true)
    XCTAssertFalse(report.healthy)
  }

  func testUptimeCanBeRead() {
    let uptime = BackupHealth.systemUptime()
    XCTAssertNotNil(uptime)
    XCTAssertGreaterThan(uptime ?? -1, 0)
  }

  // MARK: - Run in progress

  private func attemptTwoHoursAgo(running: Bool?) -> BackupHealth.Report {
    BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-2.5 * 3600),
      lastAttempt: now.addingTimeInterval(-2 * 3600),
      result: 0, now: now, mounted: true, attached: true, destinationRegistered: true,
      erroredFiles: 0, outOfSpace: false, queueReadable: true, backupRunning: running)
  }

  /// KNOWN BAD SAMPLE from 01.10.2026 17:02: walking the whole disk after a
  /// restart takes hours, and the watchdog reported an attempt that was still
  /// in progress.
  func testRunInProgressIsNotAFailedAttempt() {
    XCTAssertTrue(attemptTwoHoursAgo(running: true).healthy)
  }

  /// The same attempt when Time Machine is NO longer working (or it is
  /// unknown) - that is a real failed run and must alarm.
  func testFinishedAttemptWithoutBackupAlarms() {
    for running in [false, nil] as [Bool?] {
      XCTAssertTrue(
        attemptTwoHoursAgo(running: running).problems.contains {
          $0.summary.contains("did not end in a backup")
        }, "running=\(String(describing: running))")
    }
  }

  // MARK: - Problem codes

  /// `HealthAlert` recognizes "the same failure" by `code`, so every problem
  /// `evaluate` can produce must carry its own stable code - not the
  /// translated summary it falls back to.
  func testEveryProblemHasALanguageIndependentCode() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-5 * 3600), lastAttempt: nil, result: 3, now: now,
      mounted: false, attached: nil, destinationRegistered: nil, erroredFiles: 2,
      outOfSpace: true, queueReadable: false, driveFreeBytes: 1_073_741_824, localFreeGB: 1)
    XCTAssertFalse(report.problems.isEmpty)
    for problem in report.problems {
      XCTAssertNotEqual(problem.code, problem.summary, "no own code: \(problem.summary)")
    }
    XCTAssertEqual(
      Set(report.problems.map(\.code)).count, report.problems.count,
      "two different problems must not share a code: \(report.problems.map(\.code))")
  }
}
