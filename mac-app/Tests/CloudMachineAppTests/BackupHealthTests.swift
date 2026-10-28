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
    machineRunning: Bool? = true,
    servicesHealthy: Bool? = true,
    destinationRegistered: Bool = true,
    erroredFiles: Int = 0,
    outOfSpace: Bool = false,
    queueReadable: Bool = true,
    machineFreeGB: Int? = nil,
    punchfsNearFileLimit: Bool = false,
    remoteControlOpen: Bool = false
  ) -> BackupHealth.Report {
    BackupHealth.evaluate(
      lastSuccess: lastSuccess ?? now.addingTimeInterval(-1800),
      lastAttempt: lastAttempt ?? now.addingTimeInterval(-1800),
      result: result,
      now: now,
      machineRunning: machineRunning,
      servicesHealthy: servicesHealthy,
      destinationRegistered: destinationRegistered,
      erroredFiles: erroredFiles,
      outOfSpace: outOfSpace,
      queueReadable: queueReadable,
      machineFreeGB: machineFreeGB,
      punchfsNearFileLimit: punchfsNearFileLimit,
      remoteControlOpen: remoteControlOpen)
  }

  func testWorkingCycleDoesNotAlarm() {
    XCTAssertTrue(healthyInput().healthy, "A watchdog that always alarms carries no information.")
  }

  // MARK: - Known bad samples

  /// THIS is the failure device checks do NOT detect: the machine runs, the
  /// destination is registered - and no backup has been made for two days.
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

  /// Bands rclone did not upload exist only in the machine. The backup on the
  /// Drive is then INCOMPLETE and may not open.
  func testUnsentFilesAreReported() {
    let report = healthyInput(erroredFiles: 12)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("12 files") })
  }

  func testStoppedMachineIsReported() {
    XCTAssertTrue(
      healthyInput(machineRunning: false, servicesHealthy: nil).problems.contains {
        $0.code == "machine-stopped"
      })
  }

  func testServiceDownIsReported() {
    XCTAssertTrue(
      healthyInput(servicesHealthy: false).problems.contains { $0.code == "machine-service-down" })
  }

  /// A queue nobody could read in a machine that does not answer at all is
  /// ONE problem (the machine), not two.
  func testSilentMachineIsNotAlsoReportedAsSilentRclone() {
    let report = healthyInput(servicesHealthy: nil, queueReadable: false)
    XCTAssertTrue(report.problems.contains { $0.code == "machine-no-answer" })
    XCTAssertFalse(report.problems.contains { $0.code == "rclone-rc-no-answer" })
  }

  func testMachineLowOnSpaceIsReportedBeforeTheGuardBrakes() {
    XCTAssertGreaterThan(BackupHealth.machineFreeWarningGB, VMGuard.Thresholds().minFreeGiB)
    XCTAssertTrue(
      healthyInput(machineFreeGB: BackupHealth.machineFreeWarningGB - 1).problems.contains {
        $0.code == "machine-low-space"
      })
    XCTAssertTrue(healthyInput(machineFreeGB: BackupHealth.machineFreeWarningGB).healthy)
  }

  func testPunchfsNearItsFileLimitIsReported() {
    XCTAssertTrue(
      healthyInput(punchfsNearFileLimit: true).problems.contains {
        $0.code == "punchfs-file-limit"
      })
  }

  /// Any web page can delete the backup through it - a failure even on a day
  /// when every backup completes.
  func testOpenRemoteControlIsReported() {
    let report = healthyInput(remoteControlOpen: true)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.code == "rc-port-open" })
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
      lastSuccess: nil, lastAttempt: nil, result: 0, now: now, machineRunning: true,
      servicesHealthy: true, destinationRegistered: true, erroredFiles: 0, outOfSpace: false,
      queueReadable: true)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("NOT A SINGLE") })
  }

  // MARK: - Reading the Time Machine preferences

  /// The shape mirrored from the real
  /// `/Library/Preferences/com.apple.TimeMachine.plist` on a working
  /// installation: `SnapshotDates` gets an entry only after a COMPLETED
  /// backup, `AttemptDates` also counts the ones that failed. The machine's
  /// destination carries its `NetworkURL`.
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
          "NetworkURL": "smb://tm@192.168.64.10/CloudMachine",
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

  /// The machine's share is found by its URL, whatever its volume is called.
  func testReadingFindsTheMachineByItsURL() {
    let (lastSuccess, _, result) = BackupHealth.dates(
      inPreferences: preferences(volumeName: "Renamed"))
    XCTAssertEqual(lastSuccess, Date(timeIntervalSince1970: 1_757_698_000))
    XCTAssertEqual(result, 0)
  }

  func testReadingDoesNotGuessWhenOurDestinationIsMissing() {
    var plist = preferences()
    plist["Destinations"] = (plist["Destinations"] as! [[String: Any]]).map {
      $0.filter { $0.key != "NetworkURL" }
    }
    let (lastSuccess, lastAttempt, result) = BackupHealth.dates(
      inPreferences: plist, volumeNamed: "SomethingElseEntirely")
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
      preferencesFile: "/no/such/file.plist", preferencesRetryPause: 0)
    XCTAssertFalse(report.healthy)
    XCTAssertTrue(
      report.problems.contains { $0.summary.contains("Time Machine preferences") })
  }

  // MARK: - Confirming an unreadable file

  /// REGRESSION 08.10.2026 19:52: one failed read during a backup gave "most
  /// often Full Disk Access is missing", with the permission in place.
  func testOneFailedReadIsNotAnAlarm() async {
    var reads = 0
    var pauses = 0
    let plist = await BackupHealth.readPreferences(
      {
        reads += 1
        return reads == 1 ? nil : ["ok": true]
      }, pause: { pauses += 1 })
    XCTAssertNotNil(plist)
    XCTAssertEqual(reads, 2)
    XCTAssertEqual(pauses, 1)
  }

  /// A missing permission fails every read - the alarm still comes, after the
  /// same number of attempts every time.
  func testEveryReadFailingIsStillAnAlarm() async {
    var reads = 0
    let plist = await BackupHealth.readPreferences(
      {
        reads += 1
        return nil
      }, pause: {})
    XCTAssertNil(plist)
    XCTAssertEqual(reads, BackupHealth.preferencesReadAttempts)
    XCTAssertGreaterThan(BackupHealth.preferencesReadAttempts, 1)
  }

  func testPanelNeedsTwoFailedReadsInARow() {
    var confirmation = BackupHealth.ReadConfirmation()
    var shown = confirmation.readable(after: true, shown: false)
    XCTAssertTrue(shown)
    shown = confirmation.readable(after: false, shown: shown)
    XCTAssertTrue(shown, "one failed read flipped the panel to 'no Full Disk Access'")
    shown = confirmation.readable(after: true, shown: shown)
    shown = confirmation.readable(after: false, shown: shown)
    XCTAssertTrue(shown, "failures that are not in a row must not add up")
    shown = confirmation.readable(after: false, shown: shown)
    XCTAssertFalse(shown)
  }

  /// At launch nothing has been read yet - a missing permission must show at once.
  func testPanelStartsFromMissing() {
    var confirmation = BackupHealth.ReadConfirmation()
    XCTAssertFalse(confirmation.readable(after: false, shown: false))
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
  /// together with the session - nothing is up yet.
  private func rightAfterStartup(grace: Bool, lastSuccessAgo: TimeInterval = 1800)
    -> BackupHealth.Report
  {
    BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-lastSuccessAgo),
      lastAttempt: now.addingTimeInterval(-lastSuccessAgo),
      result: 0, now: now, machineRunning: true, servicesHealthy: false,
      destinationRegistered: false, erroredFiles: 0, outOfSpace: false, queueReadable: false,
      withinStartupGrace: grace)
  }

  func testRightAfterStartupDevicesNotReadyAreNotAFailure() {
    let report = rightAfterStartup(grace: true)
    XCTAssertTrue(report.healthy, "\(report.problems)")
    XCTAssertEqual(report.deferred.count, 2, "deferred, not lost: \(report.deferred)")
  }

  /// The same state AFTER the grace period must alarm - otherwise the previous
  /// test would also pass for a watchdog that is always silent.
  func testAfterTheGracePeriodTheSameStateAlarms() {
    let report = rightAfterStartup(grace: false)
    XCTAssertEqual(report.problems.count, 2, "\(report.problems)")
    XCTAssertTrue(report.deferred.isEmpty)
  }

  /// The grace period does NOT silence an old backup: a Mac switched off for
  /// the night is an age the watchdog must report from the first second.
  func testGracePeriodDoesNotSilenceAnOldBackup() {
    let report = rightAfterStartup(grace: true, lastSuccessAgo: 5 * 3600)
    XCTAssertTrue(report.problems.contains { $0.summary.contains("No successful backup") })
  }

  /// A machine that has not booted yet is a normal startup state too.
  func testRightAfterStartupAStoppedMachineIsDeferred() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: false, servicesHealthy: nil,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: false,
      withinStartupGrace: true)
    XCTAssertTrue(report.healthy, "\(report.problems)")
    XCTAssertEqual(report.deferred.map(\.code), ["machine-stopped"])
  }

  /// "I do not know" (a hung tmutil) is not a normal startup state.
  func testGracePeriodDoesNotSilenceLackOfKnowledge() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: true,
      destinationRegistered: nil, erroredFiles: 0, outOfSpace: false, queueReadable: true,
      withinStartupGrace: true)
    XCTAssertFalse(report.healthy)
  }

  /// A metadata copy older than an hour is a backup that cannot be restored
  /// after losing the Mac; right after startup it waits for the timer's
  /// first run.
  func testStaleMetadataCopyIsReported() {
    func health(metaSyncAge: TimeInterval?, grace: Bool = false) -> BackupHealth.Report {
      BackupHealth.evaluate(
        lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
        result: 0, now: now, machineRunning: true, servicesHealthy: true,
        destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true,
        metaSyncAge: metaSyncAge, withinStartupGrace: grace)
    }
    XCTAssertTrue(health(metaSyncAge: 900).healthy)
    XCTAssertTrue(health(metaSyncAge: nil).healthy)
    XCTAssertEqual(health(metaSyncAge: 7200).problems.map(\.code), ["metadata-sync-stale"])
    XCTAssertEqual(health(metaSyncAge: .infinity).problems.map(\.code), ["metadata-sync-stale"])
    XCTAssertTrue(
      health(metaSyncAge: .infinity).problems[0].summary.contains("never"))
    let afterBoot = health(metaSyncAge: 10 * 3600, grace: true)
    XCTAssertTrue(afterBoot.healthy)
    XCTAssertEqual(afterBoot.deferred.map(\.code), ["metadata-sync-stale"])
  }

  /// While Google's daily limit holds, backups "succeed" into the machine's
  /// buffer only - every other light is green, so this one must not be.
  func testDailyUploadLimitIsReported() {
    func health(_ age: TimeInterval?) -> BackupHealth.Report {
      BackupHealth.evaluate(
        lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
        result: 0, now: now, machineRunning: true, servicesHealthy: true,
        destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true,
        uploadLimitAge: age)
    }
    XCTAssertTrue(health(nil).healthy)
    XCTAssertTrue(health(0).healthy)
    XCTAssertEqual(health(1200).problems.map(\.code), ["drive-upload-limit"])
  }

  func testHangingUploadIsReported() {
    let report = BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: true,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true,
      uploadStalledFor: 2820)
    XCTAssertEqual(report.problems.map(\.code), ["upload-stalled"])
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
      result: 0, now: now, machineRunning: true, servicesHealthy: true,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true,
      backupRunning: running)
  }

  /// KNOWN BAD SAMPLE from 01.10.2026 17:02: a long run takes hours, and the
  /// watchdog reported an attempt that was still in progress.
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
    var seen: [String: String] = [:]
    for (running, services) in [(true, false), (true, nil), (false, nil), (nil, nil)]
      as [(Bool?, Bool?)]
    {
      let report = BackupHealth.evaluate(
        lastSuccess: now.addingTimeInterval(-5 * 3600), lastAttempt: nil, result: 3, now: now,
        machineRunning: running, servicesHealthy: services, destinationRegistered: nil,
        erroredFiles: 2, outOfSpace: true, queueReadable: false, driveFreeBytes: 1_073_741_824,
        localFreeGB: 1, machineFreeGB: 1, punchfsNearFileLimit: true, remoteControlOpen: true)
      XCTAssertFalse(report.problems.isEmpty)
      XCTAssertEqual(
        Set(report.problems.map(\.code)).count, report.problems.count,
        "two problems in one report share a code: \(report.problems.map(\.code))")
      for problem in report.problems {
        XCTAssertNotEqual(problem.code, problem.summary, "no own code: \(problem.summary)")
        if let earlier = seen[problem.code] {
          XCTAssertEqual(earlier, problem.summary, "one code for two problems: \(problem.code)")
        }
        seen[problem.code] = problem.summary
      }
    }
  }
}
