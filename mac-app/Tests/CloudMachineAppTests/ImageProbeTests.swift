import Foundation
import XCTest

@testable import CloudMachineCore

/// The image readability probe. Every verdict has a sample that forces it -
/// otherwise a probe always saying "readable" would pass all the tests.
final class ImageProbeTests: XCTestCase {

  private let manifest = URL(fileURLWithPath: "/Volumes/X/backup_manifest.plist")
  private let other = URL(fileURLWithPath: "/Volumes/X/other.plist")

  func testReadingAByteMeansAlive() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .readable)
  }

  /// Exactly the case of 22 Sep 2026: listing works, reading gives ENXIO.
  func testENXIOMeansDead() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in ENXIO })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  func testEIOAlsoMeansDead() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in EIO })
    XCTAssertEqual(verdict, .dead(errno: EIO))
  }

  /// An error specific to a file (no permission) is not a volume failure -
  /// the probe should try the next file, not declare death.
  func testEACCESOnOneFileDoesNotMeanDead() {
    let verdict = ImageProbe.probe(
      regularFiles: { [manifest, other] },
      readFirstByte: { $0 == self.manifest ? EACCES : nil })
    XCTAssertEqual(verdict, .readable)
  }

  func testOnlyFilesWithFileErrorsMeansNothingToProbe() {
    let verdict = ImageProbe.probe(regularFiles: { [manifest] }, readFirstByte: { _ in EACCES })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  /// A fresh volume before the first backup - there is nothing to read, so we
  /// do NOT alarm. An alarm without proof is worse than no alarm.
  func testEmptyDirectoryMeansNothingToProbe() {
    let verdict = ImageProbe.probe(regularFiles: { [] }, readFirstByte: { _ in ENXIO })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  // MARK: - Listing can fail too

  /// A CHANGE compared with the previous version of this test, which was
  /// called `testNieczytelneListowanieToBrakProbki` and checked that EVERY
  /// listing error gives `.nothingToProbe`. It encoded a state that turned out
  /// to be a hole: `BackupImageService.attachment` maps `.nothingToProbe` to
  /// `.attached`, so a dead image passed for a live one, and the
  /// `gdrive-attach` agent did not reattach it for hours. What decides now is
  /// the SOURCE of the error, not the mere fact of an error: an error without
  /// a recognized device errno still proves nothing about the volume and stays
  /// `.nothingToProbe`.
  func testListingErrorWithoutDeviceErrnoMeansNothingToProbe() {
    struct Boom: Error {}
    let verdict = ImageProbe.probe(regularFiles: { throw Boom() }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  /// After `--dir-cache-time 5m` expires, listing stops running from the
  /// kernel cache and fails with the same ENXIO as reading. Then it is proof
  /// of death.
  func testENXIOOnListingMeansDead() {
    let verdict = ImageProbe.probe(
      regularFiles: { throw POSIXError(.ENXIO) }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  /// This is what the same error looks like when Foundation throws it:
  /// `contentsOfDirectory` wraps the errno in `NSCocoaErrorDomain` and hides
  /// the original under `NSUnderlyingErrorKey`. The probe must recognize both
  /// forms, because the live path (`regularFiles(in:)`) goes exactly through
  /// Foundation.
  func testENXIOWrappedInNSErrorAlsoMeansDead() {
    let underlying = NSError(domain: NSPOSIXErrorDomain, code: Int(ENXIO))
    let cocoa = NSError(
      domain: NSCocoaErrorDomain, code: 256,
      userInfo: [NSUnderlyingErrorKey: underlying])
    let verdict = ImageProbe.probe(
      regularFiles: { throw cocoa }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .dead(errno: ENXIO))
  }

  /// No permission on the directory is a property of the directory, not a
  /// volume failure.
  func testEACCESOnListingMeansNothingToProbe() {
    let verdict = ImageProbe.probe(
      regularFiles: { throw POSIXError(.EACCES) }, readFirstByte: { _ in nil })
    XCTAssertEqual(verdict, .nothingToProbe)
  }

  // MARK: - Live path on a real directory

  func testRealReadOnATemporaryDirectory() async throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }

    var verdict = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(verdict, .nothingToProbe, "empty directory")

    try FileManager.default.createDirectory(
      at: dir.appendingPathComponent("subdirectory"), withIntermediateDirectories: true)
    verdict = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(verdict, .nothingToProbe, "a subdirectory alone is not a file")

    try Data("x".utf8).write(to: dir.appendingPathComponent("file"))
    verdict = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(verdict, .readable)
  }

  func testEmptyFileIsAlsoReadable() async throws {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    try Data().write(to: dir.appendingPathComponent("empty"))
    let verdict = await ImageProbe.probe(volume: dir)
    XCTAssertEqual(verdict, .readable)
  }

  // MARK: - Time limit

  /// A probe on a FUSE-T volume can NEVER return - a `read()` stuck in the
  /// kernel (state "U" in `ps`) can be neither cancelled nor killed. These
  /// tests substitute exactly such a probe: instead of reading, it waits on a
  /// semaphore that we release only at the end of the test.
  ///
  /// EACH of them has its OWN deadline, independent of the limit in the
  /// probe. If the limit disappeared from the code, the `await` on the probe
  /// would never return and the test would hang until the end of the whole
  /// `swift test` - a failure after tens of minutes and without a single
  /// sentence about the cause. With a deadline the failure is fast and
  /// readable: a `nil` verdict means "the probe did not answer even within
  /// this much".
  private func verdict(
    slot: String,
    timeout: TimeInterval,
    deadline: TimeInterval = 5,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32? = { _ in nil }
  ) async -> ImageProbe.Verdict? {
    let delivered = expectation(description: "probe \(slot) delivered a verdict")
    let box = VerdictBox()
    Task {
      box.set(
        await ImageProbe.probe(
          slot: slot, timeout: timeout,
          regularFiles: regularFiles, readFirstByte: readFirstByte))
      delivered.fulfill()
    }
    // `XCTWaiter`, not `await fulfillment(of:)`: the latter fails the test by
    // itself when the deadline passes, and we want to fail it with our OWN
    // sentence saying the probe has no time limit.
    _ = XCTWaiter().wait(for: [delivered], timeout: deadline)
    return box.value
  }

  /// THIS IS THE FIX: a probe that does not answer delivers a verdict in
  /// finite time, and the caller survives and keeps working.
  func testUnansweredProbeGivesTimedOutAndTheCallerMovesOn() async throws {
    let blocked = DispatchSemaphore(value: 0)
    // The probe thread sits in "read()" until the end of the test - just like
    // on a real dead volume. We release it on exit so it does not stay forever.
    defer { blocked.signal() }

    let start = Date()
    let result = await verdict(
      slot: "test-no-answer", timeout: 0.5,
      regularFiles: {
        blocked.wait()
        return []
      })
    let waited = Date().timeIntervalSince(start)

    XCTAssertEqual(
      result, .timedOut,
      "a probe without an answer must deliver .timedOut - otherwise the caller hangs along with it"
    )
    XCTAssertLessThan(
      waited, 3, "the 0.5 s limit must be an UPPER bound on waiting, not a suggestion")

    // The caller not only returned - it STILL WORKS, even though that other
    // thread is still sitting in the kernel. This is the part whose absence
    // silenced the watchdog permanently.
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("ImageProbeTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    try Data("x".utf8).write(to: directory.appendingPathComponent("file"))
    let afterwards = await ImageProbe.probe(volume: directory)
    XCTAssertEqual(
      afterwards, .readable, "after giving up on one volume the probe must keep working")
  }

  /// "I do not know" is NOT "the image is unreadable". The latter triggers a
  /// FORCED detach in `attach-image`, so merging them into one verdict would
  /// turn a lack of knowledge into an irreversible operation.
  func testTimedOutIsNotTheSameAsDead() {
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .dead(errno: ENXIO))
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .dead(errno: EIO))
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .readable)
    XCTAssertNotEqual(ImageProbe.Verdict.timedOut, .nothingToProbe)
  }

  /// The time limit must not swallow the verdict of a probe that answers
  /// SLOWLY, but does answer - otherwise a dead image would stop being fixed.
  func testSlowButAnsweringProbeGivesItsVerdict() async {
    let result = await verdict(
      slot: "test-slow", timeout: 3,
      regularFiles: {
        Thread.sleep(forTimeInterval: 0.3)
        return [self.manifest]
      },
      readFirstByte: { _ in ENXIO })
    XCTAssertEqual(result, .dead(errno: ENXIO))
  }

  /// One probe per volume. Without it, a panel refreshed every 10 s would
  /// leave one hanging thread per run on a stuck volume.
  func testSecondProbeOfTheSameVolumeDoesNotStartASecondThread() async {
    let blocked = DispatchSemaphore(value: 0)
    // Twice, because if one-in-flight stopped working, TWO threads would be
    // blocked and each needs its own wake-up.
    defer {
      blocked.signal()
      blocked.signal()
    }
    let slot = "test-one-in-flight"
    let first = await verdict(
      slot: slot, timeout: 0.5,
      regularFiles: {
        blocked.wait()
        return []
      })
    XCTAssertEqual(first, .timedOut)

    // The first thread is still sitting in the kernel. The second caller must
    // get "I do not know" RIGHT AWAY - that is why the probe limit here is
    // absurdly long (30 s) and the test deadline short (2 s): if waiting
    // starts at all, the test fails quickly, not after half a minute.
    let start = Date()
    let second = await verdict(
      slot: slot, timeout: 30, deadline: 2,
      regularFiles: {
        blocked.wait()
        return []
      })
    XCTAssertEqual(
      second, .timedOut,
      "a second probe of the same volume must return 'I do not know' right away, not wait or start a thread"
    )
    XCTAssertLessThan(Date().timeIntervalSince(start), 1)
  }
}

/// The verdict carried from the `Task` to the test body. A class with a lock
/// rather than a captured variable: the write and the read happen on
/// different threads.
private final class VerdictBox: @unchecked Sendable {
  private let lock = NSLock()
  private var stored: ImageProbe.Verdict?

  func set(_ value: ImageProbe.Verdict) {
    lock.lock()
    stored = value
    lock.unlock()
  }

  var value: ImageProbe.Verdict? {
    lock.lock()
    defer { lock.unlock() }
    return stored
  }
}
