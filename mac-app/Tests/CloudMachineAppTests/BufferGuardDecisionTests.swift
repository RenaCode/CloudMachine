import XCTest

@testable import CloudMachineCore

/// Buffer watchdog decisions walked through the WHOLE path - via `step()`,
/// state change included - and not only through the pure helper functions.
///
/// Reason: all three failures fixed on 23.09.2026 (the discarded `stopbackup`
/// result, the shared resume branch for lack of space on Drive, the made-up
/// zero from a failed `statfs`) lived in a SEQUENCE of steps, not in a single
/// expression. A test of the pure predicate would have passed for each of
/// them. That is why `BufferGuardService` now has injectable `Probes` - the
/// same trick as `preferencesFile` in `BackupHealth.currentReport`.
///
/// The five failures fixed on 25.09.2026 (the buffer measure, the third state
/// of the size, dead disk protection during a pause, a pause for one run, an
/// unreadable log read as "no problem") lived in the same place and also
/// needed the whole sequence: each of them shows up only in the SECOND or
/// THIRD step, after a state change.
final class BufferGuardDecisionTests: XCTestCase {

  /// Records what the watchdog did and lets us control what it "sees".
  /// A class, not a struct, because several closures read and change the same values.
  private final class Fake: @unchecked Sendable {
    private let lock = NSLock()

    /// UNSENT BACKLOG in GB. The fake translates it into queue ITEMS, because
    /// that is exactly how the watchdog sees it (`backlogGB` estimates gigabytes
    /// from the number of 32 MiB items). Giving it directly in GB let the fake
    /// pretend that rclone reports bytes - and it does not.
    private var _backlogGB = 0
    /// rclone cache size. Kept SEPARATE from the backlog, because the whole fix
    /// rests on that distinction: with `--vfs-cache-max-age 9999h` the cache sits
    /// at the limit permanently (281 measurements in production, minimum 99 GB),
    /// regardless of how much is left to upload. Hence 100 by default.
    private var _cacheGB: Int? = 100
    /// Whether rclone's remote control answers. `false` = `vfs/stats` returns
    /// `nil`, i.e. the production run of 23.09.2026.
    private var _statsAvailable = true
    private var _outOfSpace = false
    private var _freeGB: Int? = 500
    private var _running: Bool? = true
    /// `nil` = the rclone log CANNOT BE READ (`-rw-r-----` permissions, moved to
    /// `.1` at start-up).
    private var _quotaHit: Bool? = false
    private var _stalled: Bool? = false
    private var _driveFreeBytes: UInt64? = 1_000 * 1_073_741_824
    private var _stopSucceeds = true
    private var _stopCalls = 0
    private var _startCalls = 0
    private var _log: [String] = []
    /// What the watchdog reported about the jam. `Bool?`, because "I do not
    /// know" MUST reach the report as "I do not know" - otherwise it clears the
    /// jam marker.
    private var _stallReports: [Bool?] = []

    private func read<T>(_ body: () -> T) -> T {
      lock.lock()
      defer { lock.unlock() }
      return body()
    }
    private func write(_ body: () -> Void) {
      lock.lock()
      defer { lock.unlock() }
      body()
    }

    var backlogGB: Int {
      get { read { _backlogGB } }
      set { write { _backlogGB = newValue } }
    }
    var cacheGB: Int? {
      get { read { _cacheGB } }
      set { write { _cacheGB = newValue } }
    }
    var statsAvailable: Bool {
      get { read { _statsAvailable } }
      set { write { _statsAvailable = newValue } }
    }
    var outOfSpace: Bool {
      get { read { _outOfSpace } }
      set { write { _outOfSpace = newValue } }
    }
    var freeGB: Int? {
      get { read { _freeGB } }
      set { write { _freeGB = newValue } }
    }
    var running: Bool? {
      get { read { _running } }
      set { write { _running = newValue } }
    }
    var quotaHit: Bool? {
      get { read { _quotaHit } }
      set { write { _quotaHit = newValue } }
    }
    var stalled: Bool? {
      get { read { _stalled } }
      set { write { _stalled = newValue } }
    }
    var driveFreeBytes: UInt64? {
      get { read { _driveFreeBytes } }
      set { write { _driveFreeBytes = newValue } }
    }
    var stopSucceeds: Bool {
      get { read { _stopSucceeds } }
      set { write { _stopSucceeds = newValue } }
    }
    var stopCalls: Int { read { _stopCalls } }
    var startCalls: Int { read { _startCalls } }
    var log: [String] { read { _log } }
    var stallReports: [Bool?] { read { _stallReports } }

    func probes() -> BufferGuardService.Probes {
      BufferGuardService.Probes(
        queueStats: { [self] in
          guard statsAvailable else { return nil }
          return DriveBufferService.QueueStats(
            uploadsInProgress: 0,
            // 1 GiB of backlog is 32 bands of 32 MiB - the same way
            // `BufferGuardService.backlogGB` computes it.
            uploadsQueued: max(0, backlogGB) * 32,
            files: 0, erroredFiles: 0,
            bytesUsed: UInt64(max(0, cacheGB ?? 0)) * 1_073_741_824,
            outOfSpace: outOfSpace)
        },
        cacheSizeGB: { [self] _ in cacheGB },
        freeGB: { [self] in freeGB },
        backupRunning: { [self] in running },
        progressPercent: { 0 },
        hitStorageQuota: { [self] in quotaHit },
        uploadStalled: { [self] in stalled },
        driveFreeBytes: { [self] in driveFreeBytes },
        stopBackup: { [self] in
          write { _stopCalls += 1 }
          return stopSucceeds
        },
        startBackup: { [self] in
          write { _startCalls += 1 }
          return true
        },
        // Reporting a jam touches a marker file in the user's directory and shows
        // a notification - in the test we only record WHAT it heard.
        reportStall: { [self] value in write { _stallReports.append(value) } },
        log: { [self] line in write { _log.append(line) } })
    }
  }

  /// Thresholds as in production after 25.09.2026: computed from the UNSENT
  /// backlog and lying BELOW the cache size (100 GB).
  private let thresholds = BufferGuardService.Thresholds(
    highGB: 50, lowGB: 10, minFreeGB: 80, minDriveFreeGB: 30)

  /// Brings the watchdog to the `.running` state - the starting point for the rest.
  private func supervising(_ fake: Fake) async -> BufferGuardService {
    let watchdog = BufferGuardService(thresholds: thresholds, probes: fake.probes())
    fake.backlogGB = 2
    fake.running = true
    await watchdog.step()
    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .running, "Starting point: the watchdog has to supervise a running backup.")
    return watchdog
  }

  /// Brings the watchdog to a backlog pause - the starting point for the pause tests.
  private func paused(_ fake: Fake) async -> BufferGuardService {
    let watchdog = await supervising(fake)
    fake.backlogGB = 200
    await watchdog.step()
    let state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForBuffer, "Starting point: the watchdog has to be paused.")
    return watchdog
  }

  // MARK: - Finding 1: the buffer measure and the thresholds

  /// The thresholds MUST lie below the cache size, because they refer to the
  /// unsent backlog - i.e. the part of the cache that rclone cannot evict. The
  /// old pair (150/40) referred to the size of the WHOLE cache, which is why the
  /// pause threshold was unreachable without reaching for another measure, and
  /// the resume threshold unreachable at all.
  func testThresholdsReferToTheBacklogAndLieBelowTheBufferSize() {
    let defaults = BufferGuardService.Thresholds()
    XCTAssertEqual(defaults.highGB, DriveBufferService.cacheSizeGB / 2)
    XCTAssertEqual(defaults.lowGB, DriveBufferService.cacheSizeGB / 10)
    XCTAssertLessThan(
      defaults.highGB, DriveBufferService.cacheSizeGB,
      "A pause threshold above the cache size is reachable only by measuring a DIFFERENT quantity.")
    XCTAssertLessThan(
      defaults.lowGB, defaults.highGB,
      "Without hysteresis the watchdog would switch state on almost every tick.")
  }

  /// The backlog is computed from queue ITEMS, because `vfs/stats` does not
  /// report unsent bytes. Check against a production number: 462 items from
  /// 23.09.2026, which the owner estimated at "about 15 GB".
  func testBacklogEstimateIsComputedFromQueueItems() {
    func stats(queued: Int, inProgress: Int = 0, cacheGB: Int = 100)
      -> DriveBufferService.QueueStats
    {
      DriveBufferService.QueueStats(
        uploadsInProgress: inProgress, uploadsQueued: queued, files: 0, erroredFiles: 0,
        bytesUsed: UInt64(cacheGB) * 1_073_741_824, outOfSpace: false)
    }

    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 462)), 14)
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 32)), 1)
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 0)), 0)
    // An item being uploaded is not on Drive yet either.
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 16, inProgress: 16)), 1)
    // A full cache with an empty queue is ZERO backlog - that is the whole
    // difference between the old and the new measure.
    XCTAssertEqual(BufferGuardService.backlogGB(stats: stats(queued: 0, cacheGB: 100)), 0)
    XCTAssertNil(
      BufferGuardService.backlogGB(stats: nil),
      "No answer from rclone is not zero items.")
  }

  /// THE failure, the one from the journal: ONE PAUSE line and ZERO RESUME lines.
  ///
  /// The 40 GB resume threshold referred to the cache size, and that sits at the
  /// 100 GB limit all the time - also when the queue is already empty, because
  /// rclone keeps long-uploaded data in the cache (`--vfs-cache-max-age 9999h`).
  /// So the resume condition had no way of being met and the watchdog stayed
  /// paused until the process restarted.
  func testResumesWhenTheQueueIsEmptyEvenThoughTheCacheSitsAtTheLimit() async {
    let fake = Fake()
    let watchdog = await paused(fake)

    // The upload caught up: queue empty. The cache is still full - and that is
    // exactly the state in which the old version never resumed.
    fake.backlogGB = 0
    fake.cacheGB = 100
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .running,
      "An empty queue means the upload caught up - a full cache has no right to hold the pause.")
    XCTAssertEqual(fake.startCalls, 1)
  }

  // MARK: - Finding 6: the buffer size needs a third state

  /// THE failure, reproduced from production step by step (23.09.2026 03:34).
  ///
  /// rclone does not answer -> the watchdog falls back to the directory walk ->
  /// the walk returns 155 GB, because it counts DISK SPACE TAKEN (a measure the
  /// cache limit can exceed) -> 155 >= threshold -> irreversible pause. An hour
  /// later the monitor wrote "rclone remote control is not answering", i.e. the
  /// pause rested on a number taken from the fact that there was no measurement.
  ///
  /// After the fix this number may appear in the LOG, but not in the decision.
  func testNoAnswerFromRcloneDoesNotPauseTheBackup() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.statsAvailable = false
    fake.cacheGB = 155  // exactly the number from that single PAUSE line
    fake.freeGB = 300  // the disk is in no danger, so a pause could come ONLY from this number
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .running,
      "No answer from rclone turned into a number from another measure triggered a pause.")
    XCTAssertEqual(fake.stopCalls, 0)
    XCTAssertTrue(
      fake.log.contains { $0.contains("rclone remote control is not answering") },
      "...but staying silent is not allowed either: the watchdog has just lost the ability to pause the backup."
    )
    XCTAssertTrue(
      fake.log.contains { $0.contains("155 GB") && $0.contains("DISK SPACE") },
      "Since we give this number, it has to be named as SOMETHING ELSE than the backlog.")
  }

  /// Reported once per episode - as for `freeGB()`. With a failure lasting
  /// 53 hours a line every 30 seconds would flood the log.
  func testNoAnswerWarningIsLoggedOnce() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.statsAvailable = false
    await watchdog.step()
    await watchdog.step()
    await watchdog.step()

    let warnings = fake.log.filter { $0.contains("rclone remote control is not answering") }
    XCTAssertEqual(warnings.count, 1, "got: \(fake.log)")
  }

  /// The other side of the same lie. When the directory walk FAILED, it returned
  /// `0`, and zero looked like an empty buffer - i.e. it lifted a pause put in
  /// place because the buffer was full.
  func testNoAnswerFromRcloneDoesNotLiftThePause() async {
    let fake = Fake()
    let watchdog = await paused(fake)

    fake.statsAvailable = false
    fake.cacheGB = nil  // the directory walk failed too
    fake.freeGB = 900  // everything else favours resuming
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .pausedForBuffer,
      "Resuming needs proof that the upload caught up - a missing measurement is no proof.")
    XCTAssertEqual(fake.startCalls, 0)
  }

  // MARK: - Finding 1a: disk protection works in EVERY state

  /// THE failure. `stats?.outOfSpace`, the threshold and `lowDisk` sat ONLY in
  /// the `.running` branch. After one pause the watchdog stopped looking at the
  /// disk, and the pause branch checked only the resume condition - so rclone
  /// could shout "I have nowhere to put data", and at the same moment the
  /// watchdog resumed Time Machine because the queue happened to drain.
  func testRcloneOutOfSpaceCannotBeIgnoredDuringAPause() async {
    let fake = Fake()
    let watchdog = await paused(fake)

    fake.backlogGB = 0  // the queue drained, i.e. the resume condition is met
    fake.freeGB = 900
    fake.outOfSpace = true  // ...but rclone has nowhere to put data
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .pausedForBuffer,
      "outOfSpace is a harder fact than our threshold and does not stop being one during a pause.")
    XCTAssertEqual(fake.startCalls, 0)
  }

  /// The same in a pause for lack of space on Google Drive: proof from
  /// `rclone about` has no right to lift the pause when the BUFFER is against the
  /// wall.
  func testRcloneOutOfSpaceCannotBeIgnoredDuringAGoogleDrivePause() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.quotaHit = true
    await watchdog.step()
    var state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForQuota)

    fake.quotaHit = false  // the entries in the rclone log have aged
    fake.backlogGB = 0
    fake.freeGB = 900
    fake.driveFreeBytes = 500 * 1_073_741_824  // space on Drive really did appear
    fake.outOfSpace = true  // but the buffer has nowhere to put data
    await watchdog.step()

    state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForQuota, "Proof about Drive is not proof about the buffer.")
    XCTAssertEqual(fake.startCalls, 0)
  }

  /// Running out of disk space has to pause also when no backup is running at
  /// the moment: macOS starts another one every hour, and the `.idle` branch
  /// used to look only at whether a backup had started.
  func testLowDiskSpacePausesAlsoWhenNoBackupIsRunning() async {
    let fake = Fake()
    let watchdog = BufferGuardService(thresholds: thresholds, probes: fake.probes())
    fake.running = false  // keeping watch, not supervising
    fake.freeGB = 10  // below minFreeGB
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .pausedForBuffer,
      "The disk fills up regardless of whether a backup is running this second.")
    XCTAssertTrue(fake.log.contains { $0.contains("little free disk space") })
    // There is nothing to pause, so `stopbackup` is not sent - and rightly so:
    // its failure would make the watchdog report "Time Machine KEEPS WRITING".
    XCTAssertEqual(fake.stopCalls, 0)
  }

  // MARK: - Finding 2: a pause lasts as long as we keep it up

  /// THE failure. `tmutil stopbackup` cancels the RUNNING backup and does not
  /// touch the schedule, and `stopBackup()` was called only on a state CHANGE.
  /// An hour after the pause macOS started another backup, the watchdog did not
  /// stop it - and the log said "waiting for the upload". The state lasted 53
  /// hours, the pause of writes one run.
  func testPauseIsRepeatedOnEveryTickOfThePause() async {
    let fake = Fake()
    let watchdog = await paused(fake)
    XCTAssertEqual(fake.stopCalls, 1)

    // Time Machine started by itself in its hourly cycle, the backlog is still large.
    fake.running = true
    await watchdog.step()
    XCTAssertEqual(fake.stopCalls, 2, "The next tick MUST repeat the pause.")
    await watchdog.step()
    XCTAssertEqual(fake.stopCalls, 3)

    let state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForBuffer)
    XCTAssertEqual(fake.startCalls, 0)
    XCTAssertTrue(
      fake.log.contains { $0.contains("repeating the pause") },
      "Repeating the pause is an event worth a trace - it means a backup started during the pause.")
  }

  /// ...but we do not repeat without need. When tmutil says plainly that no
  /// backup is running, there is nothing to pause - two processes every 30
  /// seconds for 53 hours is over 12 thousand calls for nothing.
  func testPauseIsNotRepeatedWhenNoBackupIsRunning() async {
    let fake = Fake()
    let watchdog = await paused(fake)
    XCTAssertEqual(fake.stopCalls, 1)

    fake.running = false
    await watchdog.step()
    await watchdog.step()
    XCTAssertEqual(fake.stopCalls, 1)

    // "I do not know" is NOT "not running" - no answer from tmutil counts as
    // a running backup.
    fake.running = nil
    await watchdog.step()
    XCTAssertEqual(fake.stopCalls, 2)
  }

  // MARK: - Finding 7: unreadable rclone log

  /// THE failure, in its most dangerous part. `recentLog` returns `nil` for an
  /// unopenable file, and `uploadStalled()` turned that into `false`; `false`
  /// means "the jam is over", so `reportStall` DELETED the marker and wrote
  /// "Upload to Google Drive has resumed" - about an event nobody checked. The
  /// rclone log has `-rw-r-----` permissions, and at start-up it is moved to
  /// `.1`, so this is not a theoretical case.
  func testIDoNotKnowDoesNotClearTheJamMarker() {
    XCTAssertEqual(
      BufferGuardService.stallAction(stalled: nil, markerExists: true), .doNothing,
      "An unreadable log is no proof that the jam is over.")
    XCTAssertEqual(
      BufferGuardService.stallAction(stalled: nil, markerExists: false), .doNothing)
    // Measured answers work as before - otherwise a "fix" consisting of
    // switching off the reports would go unnoticed.
    XCTAssertEqual(BufferGuardService.stallAction(stalled: true, markerExists: false), .raise)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: false, markerExists: true), .clear)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: true, markerExists: true), .doNothing)
    XCTAssertEqual(BufferGuardService.stallAction(stalled: false, markerExists: false), .doNothing)
  }

  /// "I do not know" has to REACH the report as "I do not know". Substituting
  /// `false` already in the probe closed the matter before anyone had a chance
  /// to think about it.
  func testUnreadableLogReachesTheReportAsIDoNotKnow() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.stalled = nil
    await watchdog.step()

    XCTAssertEqual(fake.stallReports.count, 2)
    XCTAssertEqual(fake.stallReports.first, .some(false))
    XCTAssertNil(
      fake.stallReports.last!, "A failed log read has no right to report 'the jam is over'.")
  }

  /// An unreadable log does not pause the backup (as it is no proof of a
  /// failure), but it must not be kept quiet: the watchdog has just lost the
  /// ability to recognise lack of space on Google Drive.
  func testUnreadableLogNeitherPausesNorStaysSilent() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.quotaHit = nil
    fake.stalled = nil
    await watchdog.step()
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(state, .running)
    XCTAssertEqual(fake.stopCalls, 0)
    let warnings = fake.log.filter { $0.contains("cannot read the rclone log") }
    XCTAssertEqual(warnings.count, 1, "Once per episode - got: \(fake.log)")
  }

  // MARK: - Point 2 of 23.09: a failed pause is NOT a pause

  /// THE failure. `tmutil stopbackup` fails (no permissions or a timeout), and
  /// the watchdog moved to `.pausedForBuffer` anyway. Since the pause is called
  /// only on a state CHANGE, it never retried it: Time Machine kept writing, the
  /// watchdog waited for the drain, the disk filled up completely, and the log
  /// said "PAUSE ... waiting for the upload".
  func testFailedPauseDoesNotChangeTheStateAndIsRetried() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.stopSucceeds = false
    fake.backlogGB = 200  // above the pause threshold
    await watchdog.step()

    var state = await watchdog.currentState()
    XCTAssertEqual(
      state, .running,
      "A failed 'tmutil stopbackup' is NOT a pause - Time Machine is still writing.")
    XCTAssertEqual(fake.stopCalls, 1)
    XCTAssertTrue(
      fake.log.contains { $0.contains("FAILED to pause") },
      "A silent failure is worse than a loud one - there has to be a trace in the log.")

    // The next step MUST try again - without that one failed attempt left the
    // backup unsupervised until the agent restarted.
    await watchdog.step()
    XCTAssertEqual(fake.stopCalls, 2, "The watchdog has to retry the pause on every step.")
    state = await watchdog.currentState()
    XCTAssertEqual(state, .running)

    // When it finally succeeds - only then does the state change.
    fake.stopSucceeds = true
    await watchdog.step()
    state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForBuffer)
    XCTAssertEqual(fake.stopCalls, 3)
  }

  // MARK: - Point 3 of 23.09: a pause for lack of space on Drive needs PROOF

  /// THE failure. `hitStorageQuota()` looks at entries from the last 30 minutes
  /// of the rclone log. After Time Machine is paused no new bands are created,
  /// rclone stops trying, the entries age - and the function starts returning
  /// `false`, even though Drive has as little space as before. The shared resume
  /// branch then looked only at the buffer and LOCAL free space, i.e. at two
  /// numbers that know nothing about Google Drive, and lifted the pause
  /// immediately.
  func testPauseForLackOfSpaceOnDriveDoesNotPassByItself() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.quotaHit = true
    await watchdog.step()
    var state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForQuota)

    // The log entries have aged, the queue drained, the local disk is empty -
    // i.e. EXACTLY the situation in which the old version resumed the backup.
    fake.quotaHit = false
    fake.backlogGB = 1
    fake.freeGB = 900

    // 1. rclone does not answer: "I do not know" is NOT consent to resume.
    fake.driveFreeBytes = nil
    await watchdog.step()
    state = await watchdog.currentState()
    XCTAssertEqual(
      state, .pausedForQuota,
      "No answer about Drive capacity has to KEEP the pause, not lift it.")
    XCTAssertEqual(fake.startCalls, 0)

    // 2. rclone answers, but there is still practically no space.
    fake.driveFreeBytes = 2 * 1_073_741_824
    await watchdog.step()
    state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForQuota, "2 GB is no room for further backups.")
    XCTAssertEqual(fake.startCalls, 0)

    // 3. Space really did appear - only that is proof.
    fake.driveFreeBytes = 500 * 1_073_741_824
    await watchdog.step()
    state = await watchdog.currentState()
    XCTAssertEqual(state, .running)
    XCTAssertEqual(fake.startCalls, 1)
  }

  /// A pause because of the BACKLOG needs nothing from Google Drive - otherwise
  /// an unreachable rclone would block every resume in the system.
  func testBacklogPauseResumesWithoutAskingDrive() async {
    let fake = Fake()
    let watchdog = await paused(fake)

    fake.backlogGB = 2
    fake.driveFreeBytes = nil  // rclone is silent, but this is not that pause
    await watchdog.step()
    let state = await watchdog.currentState()
    XCTAssertEqual(state, .running)
  }

  // MARK: - Point 4 of 23.09: failed free-space measurement

  /// THE failure. `freeGB()` returned `0` when `statfs` failed. Zero met the
  /// pause condition (`free <= minFreeGB`) immediately and NEVER met the resume
  /// condition (`free > minFreeGB`) - the watchdog paused Time Machine based on
  /// a number it did not measure, and never resumed it again.
  func testFailedFreeSpaceMeasurementDoesNotPauseTheBackup() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.freeGB = nil
    fake.backlogGB = 2  // backlog is fine, so the only reason to pause is the disk
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .running,
      "No measurement is not a zero measurement - the backup must not be paused on it.")
    XCTAssertEqual(fake.stopCalls, 0)
    XCTAssertTrue(
      fake.log.contains { $0.contains("cannot measure free disk space") },
      "...but it must not be kept quiet either: this is a failure of the disk protection itself.")
  }

  /// A measured zero is SOMETHING ELSE than no measurement - and it has to pause.
  /// Without this test a "fix" consisting of ignoring free space altogether
  /// would go unnoticed.
  func testMeasuredZeroStillPausesTheBackup() async {
    let fake = Fake()
    let watchdog = await supervising(fake)

    fake.freeGB = 0
    await watchdog.step()

    let state = await watchdog.currentState()
    XCTAssertEqual(state, .pausedForBuffer)
    XCTAssertEqual(fake.stopCalls, 1)
  }

  /// No measurement must not PRETEND to be consent to resume either.
  func testFailedMeasurementDoesNotResumeTheBackup() async {
    let fake = Fake()
    let watchdog = await paused(fake)

    fake.backlogGB = 1
    fake.freeGB = nil
    await watchdog.step()
    let state = await watchdog.currentState()
    XCTAssertEqual(
      state, .pausedForBuffer,
      "Resuming needs proof that the space IS there - a missing measurement is no proof.")
    XCTAssertEqual(fake.startCalls, 0)
  }

  /// `freeGB()` on the real system has to return the same as `df`, and it has to
  /// be an OPTIONAL value. The successful path - the counterpart of the old
  /// `testFreeSpaceMatchesStatfs`, which was the only test of this function.
  func testFreeSpaceMeasurementMatchesStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let expected = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BufferGuardService.freeGB(), expected)
  }

  // MARK: - Pure predicates

  func testResumeNeedsBothConditionsAndAMeasurement() {
    // The upload caught up and there is space - the only case that resumes.
    XCTAssertTrue(
      BufferGuardService.canResumeLocally(backlog: 2, free: 500, thresholds: thresholds))
    // The upload caught up, but the disk is still full.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 2, free: 10, thresholds: thresholds))
    // The disk is empty, but the backlog has not drained yet.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 100, free: 500, thresholds: thresholds))
    // No free-space measurement - unknown, so we do not resume.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: 2, free: nil, thresholds: thresholds))
    // No answer about the backlog - the same.
    XCTAssertFalse(
      BufferGuardService.canResumeLocally(backlog: nil, free: 500, thresholds: thresholds))
  }

  func testDriveSpaceCountsOnlyWhenMeasured() {
    XCTAssertFalse(BufferGuardService.driveHasRoom(freeBytes: nil, minGB: 30))
    XCTAssertFalse(BufferGuardService.driveHasRoom(freeBytes: 0, minGB: 30))
    XCTAssertFalse(
      BufferGuardService.driveHasRoom(freeBytes: 29 * 1_073_741_824, minGB: 30))
    XCTAssertTrue(
      BufferGuardService.driveHasRoom(freeBytes: 30 * 1_073_741_824, minGB: 30))
  }

  /// The "I do not know" branch in the monitor MUST be alive.
  ///
  /// A review caught the moment when `BackupHealth` compared a non-optional
  /// value to `nil` - such a comparison always gives false, so the branch was
  /// dead, and the code still compiled and the tests passed. This test checks
  /// THE BRANCH ITSELF, not the type: with no measurement a problem has to
  /// appear, with a measurement - not.
  func testMissingDiskMeasurementIsReportedByTheMonitor() {
    let problems = BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: nil)
    XCTAssertEqual(
      problems.count, 1, "A failed statfs is a failure of the disk protection, not silence.")
    // `first`, not `[0]`: if this assertion failed, the index would abort the
    // WHOLE run with a fatal error instead of reporting one failed test.
    // The exact wording belongs to `BackupHealth`, so only its presence is checked here.
    XCTAssertFalse(problems.first?.summary.isEmpty ?? true)

    XCTAssertTrue(
      BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: 400).isEmpty,
      "A successful measurement has no right to report anything.")
    // A measured zero is a RESULT, not a lack of one - a low level is reported
    // by a separate threshold in `evaluate`, not by this function.
    XCTAssertTrue(BackupHealth.unmeasuredLocalDiskProblems(localFreeGB: 0).isEmpty)
  }

  /// The Drive free-space threshold is the same one `BackupHealth` treats as a
  /// warning - one source of truth, so that the monitor and the watchdog cannot
  /// claim different things about the same number.
  func testDriveSpaceThresholdMatchesTheMonitor() {
    XCTAssertEqual(
      BufferGuardService.Thresholds().minDriveFreeGB, BackupHealth.driveFreeWarningGB)
  }
}
