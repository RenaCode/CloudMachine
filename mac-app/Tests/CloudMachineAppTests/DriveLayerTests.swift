import XCTest

@testable import CloudMachineCore

/// Tests of the Google Drive layer. They cover parsing and decisions - i.e.
/// the places where bugs were silent and costly, and cannot be seen from the
/// fact that "the backup is being made".
final class DriveLayerTests: XCTestCase {

  // MARK: - Parsing hdiutil info

  /// `hdiutil info` groups entries into blocks: all `/dev/diskN` lines after an
  /// `image-path` line belong to it, up to the next `image-path`.
  private let hdiutilInfo = """
    framework       : 595.100.2
    driver          : 595.100.2
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/other.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/other.sparsebundle
    shadow-path     : <none>
    /dev/disk4\tGUID_partition_scheme\t
    /dev/disk4s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/Other
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    shadow-path     : <none>
    /dev/disk7\tEF57347C-0000-11AA-AA11-00306543ECAC\t
    /dev/disk7s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/CloudMachine
    """

  func testParseDevicesFindsOnlyMatchingImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/mac-studio.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk7"])
  }

  func testParseDevicesIgnoresOtherImages() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/other.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk4"])
  }

  /// Regression: when the image is not attached, other images' devices must
  /// not be returned - detaching them would kill someone's volume.
  func testParseDevicesReturnsNothingForUnknownImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo, imagePath: "/Users/x/nonexistent.sparsebundle")
    XCTAssertTrue(devices.isEmpty)
  }

  func testParseDevicesHandlesEmptyInput() {
    XCTAssertTrue(BackupImageService.parseDevices(hdiutilInfo: "", imagePath: "/x").isEmpty)
  }

  // MARK: - rclone checksum

  private let sums = """
    3a1f0000000000000000000000000000000000000000000000000000000000aa  rclone-v1.75.1-osx-amd64.zip
    c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f  rclone-v1.75.1-osx-arm64.zip
    9b2c0000000000000000000000000000000000000000000000000000000000bb  rclone-v1.75.1-linux-amd64.zip
    """

  func testExpectedChecksumPicksTheRightArchive() {
    XCTAssertEqual(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v1.75.1-osx-arm64.zip"),
      "c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f")
  }

  /// A missing entry MUST give nil, not some other checksum - otherwise the
  /// installer would compare the archive with another file's checksum and
  /// either reject a correct download or (worse) let an incorrect one through.
  func testExpectedChecksumReturnsNilWhenArchiveMissing() {
    XCTAssertNil(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v9.9.9-osx-arm64.zip"))
  }

  // MARK: - Mount arguments

  func testMountArgumentsCarryTheNonObviousFlags() {
    let args = DriveBufferService.mountArguments()

    // Without this, deleted bands go to Drive's trash and keep counting towards the limit.
    XCTAssertTrue(args.contains("--drive-use-trash=false"))

    // After exceeding the daily 750 GB limit rclone is to stop, not spin in
    // 403s.
    XCTAssertTrue(args.contains("--drive-stop-on-upload-limit"))

    // Without the full cache writes are not buffered, i.e. the whole promise
    // of not being interrupted disappears.
    XCTAssertTrue(args.contains("--vfs-cache-mode"))
    XCTAssertEqual(args[(args.firstIndex(of: "--vfs-cache-mode")! + 1)], "full")

    // The rc interface is the only source of the queue state - without it the
    // buffer watchdog is blind.
    XCTAssertTrue(args.contains("--rc"))
  }

  /// 02.10.2026: change notifications from Drive (every minute by default)
  /// invalidated the `bands` directory after every upload of our own, and
  /// reloading it held the lock for ~42 s - the whole mount stood still every
  /// minute.
  func testMountDoesNotInvalidateTheDirectoryAfterOwnUploads() {
    let args = DriveBufferService.mountArguments()
    func value(_ flag: String) -> String? {
      args.firstIndex(of: flag).map { args[$0 + 1] }
    }
    XCTAssertEqual(value("--poll-interval"), "0")
    XCTAssertEqual(value("--dir-cache-time"), "9999h")
  }

  /// The band size was chosen by measurement (see gdrive/README.md). A change
  /// only takes effect when the image is created, so it must not be missed.
  func testBandSizeIs32MB() {
    XCTAssertEqual(BackupImageService.bandSectors * 512, 32 * 1024 * 1024)
  }

  // MARK: - Watchdog thresholds

  func testGuardThresholdsAreOrdered() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(
      t.lowGB, t.highGB,
      "The resume threshold has to be lower than the pause threshold, otherwise the watchdog will oscillate."
    )
  }

  /// Free space has to be counted pessimistically, like `df`. The "important
  /// usage" measure included space taken by snapshots and showed 1202 GB where
  /// `df` said 427 GB - the watchdog would have paused too late.
  func testFreeSpaceMatchesStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let expected = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BufferGuardService.freeGB(), expected)
  }
}

/// Detection of the Google Drive daily limit. A separate class, because this is
/// the single mistake that stopped a real backup - it deserves its own place.
final class DailyQuotaDetectionTests: XCTestCase {
  private let formatter: DateFormatter = {
    let f = DateFormatter()
    // The sample imitates an rclone log, so it has to look the same on every
    // machine. A literal, NOT `DriveBufferService.rcloneLogLocale`: the sample
    // generator must not depend on the constant whose correctness we are
    // checking - otherwise replacing that constant would switch the generator
    // together with the parser and the test would pass in both states.
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return f
  }()

  private func line(_ minutesAgo: Int, _ message: String, now: Date) -> String {
    let stamp = formatter.string(from: now.addingTimeInterval(-Double(minutesAgo) * 60))
    return "\(stamp) ERROR : \(message)"
  }

  /// THIS is the bug. rclone describes the momentary throttle with the message
  /// "Received upload limit error", indistinguishable by text from the daily
  /// limit - and retries it by itself. Catching it paused the backup after
  /// uploading 109 GiB of the 750 GB allowed per day.
  func testTransientRateLimitIsNotTheDailyQuota() {
    let now = Date()
    let log = [
      line(
        2,
        "Received upload limit error: googleapi: Error 403: User rate limit exceeded., userRateLimitExceeded",
        now: now),
      line(2, "bands/cf9: vfs cache: failed to upload try #1, will retry in 1m0s", now: now),
    ].joined(separator: "\n")
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  func testRealQuotaErrorIsDetected() {
    let now = Date()
    let log = line(
      1,
      "googleapi: Error 403: The user has exceeded their Drive storage quota, storageQuotaExceeded",
      now: now)
    XCTAssertTrue(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  /// Without a time window an alarm once raised would never go out - the entry
  /// stays in the log, so the backup would fall into a pause-resume-pause cycle.
  func testOldQuotaErrorIsIgnored() {
    let now = Date()
    let log = line(120, "googleapi: Error 403: storageQuotaExceeded", now: now)
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  // MARK: - Finding 15a: a person's calendar must not silence the parser

  /// KNOWN BAD CALENDAR - the one `Locale.current` returns on a Thai Mac.
  ///
  /// A `DateFormatter` with a fixed `dateFormat` takes the calendar from the
  /// locale, so "2026/09/25" parses WITHOUT AN ERROR as Buddhist year 2026, i.e.
  /// Gregorian 1483. The date lands 543 years before the window, `stamp < cutoff`
  /// ends the loop on the first line and the real disk limit ceases to exist.
  func testBuddhistCalendarErasedLimitDetection() {
    let now = Date()
    let log = line(
      1,
      "googleapi: Error 403: The user has exceeded their Drive storage quota, storageQuotaExceeded",
      now: now)
    XCTAssertFalse(
      DriveBufferService.logMentionsUploadLimit(
        log, now: now, within: 30, locale: Locale(identifier: "th_TH@calendar=buddhist")),
      "this describes the DEFECT, not an expectation - the fix lives in the default locale")
    XCTAssertTrue(
      DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30),
      "the default parser has to read the same log regardless of the person's settings")
  }

  func testEmptyLogIsNotAQuotaError() {
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit("", now: Date(), within: 30))
  }
}

/// Recognising an upload JAM by rclone's behaviour.
///
/// All ratios below are MEASURED on this machine's production `rclone.log`, not
/// made up. The error text is identical in both cases - if they could be told
/// apart by content, this class would not have to exist.
final class UploadStallDetectionTests: XCTestCase {
  private let formatter: DateFormatter = {
    let f = DateFormatter()
    // The sample imitates an rclone log, so it has to look the same on every
    // machine. A literal, NOT `DriveBufferService.rcloneLogLocale`: the sample
    // generator must not depend on the constant whose correctness we are
    // checking - otherwise replacing that constant would switch the generator
    // together with the parser and the test would pass in both states.
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return f
  }()

  /// Builds a sample with the given ratio of successes to errors, in the window.
  private func sample(errors: Int, successes: Int, minutesAgo: Int, now: Date) -> String {
    let stamp = formatter.string(from: now.addingTimeInterval(-Double(minutesAgo) * 60))
    var lines: [String] = []
    for _ in 0..<errors {
      lines.append(
        "\(stamp) ERROR : Google drive root 'CloudMachine/mac-studio': Received upload limit "
          + "error: googleapi: Error 403: User rate limit exceeded., userRateLimitExceeded")
    }
    for i in 0..<successes {
      lines.append(
        "\(stamp) INFO  : mac-studio.sparsebundle/bands/\(String(i, radix: 16)): "
          + "Copied (replaced existing)")
    }
    return lines.joined(separator: "\n")
  }

  /// KNOWN BAD SAMPLE. 12 September 2026, 10 o'clock: 5467 errors and 59
  /// successful uploads. The upload stood still for three hours then and NOTHING
  /// reported it.
  func testRealStallIsDetected() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 5, now: now)
    XCTAssertTrue(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// The second jam, 15 September 9 o'clock: 8915 errors, 31 successes.
  func testSecondRealStallIsDetected() {
    let now = Date()
    let log = sample(errors: 8915, successes: 31, minutesAgo: 2, now: now)
    XCTAssertTrue(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// KNOWN GOOD SAMPLE. 12 September 9 o'clock, right BEFORE the jam: as many
  /// errors as successes (781 to 833). The upload was moving. This is the
  /// situation that once needlessly paused the backup after 109 GiB.
  func testThrottlingWithUploadsFlowingIsNotAStall() {
    let now = Date()
    let log = sample(errors: 781, successes: 833, minutesAgo: 5, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// 15 September 8 o'clock: 1040 errors, but 2481 successes - rate throttling
  /// with the upload going at full steam. An hour later the same turned into a
  /// jam, and then it has to fire.
  func testHeavyThrottlingWithMoreSuccessesIsNotAStall() {
    let now = Date()
    let log = sample(errors: 1040, successes: 2481, minutesAgo: 10, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// 11 September 14 o'clock: ONE error per 4833 successful uploads. A single
  /// bounce is not a jam, although the success ratio would mean nothing here -
  /// the lower bound on the error count saves us.
  func testSingleErrorIsNotAStall() {
    let now = Date()
    let log = sample(errors: 1, successes: 4833, minutesAgo: 5, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// A jam that came and went must not hold the alarm forever - the entry stays
  /// in the log for good.
  func testStallOutsideTheWindowIsIgnored() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 120, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// Silence is not a jam. A window without traffic has neither errors nor
  /// successes - without the lower bound on the error count the 0/0 ratio would
  /// give a false alarm.
  func testSilenceIsNotAStall() {
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled("", now: Date(), within: 30))
  }

  // MARK: - Finding 15a: a person's calendar must not silence the jam

  /// The same jam that `testRealStallIsDetected` detects disappeared without a
  /// trace on a machine with a non-Gregorian calendar: all lines fell outside the
  /// window, `errors` stayed zero and `uploadStalled()` reported "no jam" - and
  /// on that basis the buffer watchdog does NOT pause Time Machine.
  func testBuddhistCalendarErasedStallDetection() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 5, now: now)
    XCTAssertFalse(
      DriveBufferService.logShowsUploadStalled(
        log, now: now, within: 30, locale: Locale(identifier: "th_TH@calendar=buddhist")),
      "this describes the DEFECT, not an expectation")
    XCTAssertTrue(
      DriveBufferService.logShowsUploadStalled(log, now: now, within: 30),
      "by default we parse with a fixed en_US_POSIX, so a jam stays a jam")
  }

  /// The constant itself - so that a "fix" consisting of reverting it to
  /// `Locale.current` does not go unnoticed on a machine that happens to have
  /// the Gregorian calendar (i.e. this one).
  func testLogParserIsPinnedToPosix() {
    XCTAssertEqual(DriveBufferService.rcloneLogLocale.identifier, "en_US_POSIX")
  }

  /// The upload delay has to go to rclone from one constant - otherwise changing
  /// one place leaves the other with the previous value.
  func testMountUsesConfiguredWriteBack() {
    let args = DriveBufferService.mountArguments()
    guard let index = args.firstIndex(of: "--vfs-write-back") else {
      return XCTFail("no --vfs-write-back in the mount arguments")
    }
    XCTAssertEqual(args[index + 1], "\(DriveBufferService.writeBackSeconds)s")
  }
}

/// Buffer watchdog decisions. The comment at `step()` promised that splitting
/// it out of the loop was for testing - and there was no test. Here it is.
final class BufferGuardThresholdTests: XCTestCase {

  /// The pause threshold MUST lie BELOW the buffer size - and that is a reversal
  /// of the requirement that stood here before.
  ///
  /// The old version demanded a threshold ABOVE the cache size, because the
  /// thresholds referred to `bytesUsed`, i.e. the size of the WHOLE cache. That
  /// quantity by definition sits at the limit (`--vfs-cache-max-size 100G` plus
  /// `max-age 9999h`), measured: 281 measurements, minimum 99 GB. A threshold
  /// below it really would have paused the backup non-stop - so that requirement
  /// was right FOR THAT MEASURE.
  ///
  /// Since 2026-09-25 the thresholds refer to the UNSENT BACKLOG. The backlog is
  /// exactly the part of the cache that rclone CANNOT evict, so when it reaches
  /// `cacheSizeGB`, the limit has no headroom left and every further gigabyte
  /// goes beyond it, into free disk space. So the pause threshold has to act
  /// BEFORE that happens.
  ///
  /// What the old version cost: with a 40 GB resume threshold computed from a
  /// measure that never dropped below 99 GB, the whole journal has one PAUSE line
  /// and ZERO RESUME lines - the watchdog sat paused for 53 hours.
  func testPauseThresholdSitsBelowTheCacheSize() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(
      t.highGB, DriveBufferService.cacheSizeGB,
      "A pause threshold equal to the buffer size means zero headroom: a backlog equal to "
        + "the cache capacity pushes every further gigabyte into free space.")
  }

  /// The resume threshold has to be clearly lower than the pause threshold,
  /// otherwise the watchdog would oscillate between start and stop on every tick.
  func testResumeThresholdLeavesHysteresis() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(t.lowGB, t.highGB)
    XCTAssertLessThanOrEqual(
      t.lowGB, t.highGB / 2,
      "Too narrow a gap between the thresholds gives a pause-resume-pause cycle.")
  }

  /// The thresholds are still DERIVED from the buffer size, not typed in by hand
  /// - that property stays; only the multipliers changed, because the quantity
  /// the thresholds refer to changed (backlog instead of cache size). Typed in by
  /// hand they only worked by accident, for one specific value.
  func testThresholdsFollowTheCacheSize() {
    let t = BufferGuardService.Thresholds()
    XCTAssertEqual(t.highGB, DriveBufferService.cacheSizeGB / 2)
    XCTAssertEqual(t.lowGB, DriveBufferService.cacheSizeGB / 10)
  }

  /// The resume threshold has to be REACHABLE. That is the whole lesson of the
  /// 53 hours of pause: the old 40 GB referred to a quantity that never went below
  /// 99 GB, so the condition for leaving the pause was false in 281 observations
  /// out of 281. The backlog goes down to zero when the queue empties - but only
  /// if the threshold lies within reach of what the queue can give back.
  func testResumeThresholdIsReachable() {
    let t = BufferGuardService.Thresholds()
    XCTAssertGreaterThan(t.lowGB, 0, "A resume threshold of zero requires an empty queue.")
    XCTAssertLessThan(
      t.lowGB, DriveBufferService.cacheSizeGB,
      "A resume threshold above the cache capacity is unreachable by definition.")
  }

  func testExplicitThresholdsAreRespected() {
    let t = BufferGuardService.Thresholds(highGB: 10, lowGB: 2, minFreeGB: 5)
    XCTAssertEqual(t.highGB, 10)
    XCTAssertEqual(t.lowGB, 2)
    XCTAssertEqual(t.minFreeGB, 5)
  }
}
