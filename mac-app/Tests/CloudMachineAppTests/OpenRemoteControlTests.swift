import XCTest

@testable import CloudMachineCore

/// N-K1 (second audit, 10.10.2026): after `brew upgrade` the old mount keeps
/// listening on 127.0.0.1:5572 without a password, for as long as the Mac is
/// not restarted. Only one line of `drive-status` said so; the window and the
/// watchdog were silent. These tests cover the detection, the notification,
/// and the restart that closes the port without a restart of the Mac.
final class OpenRemoteControlTests: XCTestCase {

  // MARK: - Detection

  func testOldMountOnTheOpenPortIsDetected() {
    XCTAssertTrue(
      DriveBufferService.legacyPortOpen(transport: .legacyTCP, mounted: true, portAnswers: { true })
    )
  }

  func testEveryConditionIsNeeded() {
    // A mount of this version: the socket is there.
    XCTAssertFalse(
      DriveBufferService.legacyPortOpen(transport: .socket, mounted: true, portAnswers: { true }))
    // No mount, or not known: nothing to warn about here (other alarms say so).
    XCTAssertFalse(
      DriveBufferService.legacyPortOpen(
        transport: .legacyTCP, mounted: false, portAnswers: { true }))
    XCTAssertFalse(
      DriveBufferService.legacyPortOpen(transport: .legacyTCP, mounted: nil, portAnswers: { true }))
    // The socket removed under a new mount: nothing listens on TCP.
    XCTAssertFalse(
      DriveBufferService.legacyPortOpen(
        transport: .legacyTCP, mounted: true, portAnswers: { false }))
  }

  /// The port probe itself, against a listener of our own - never 5572.
  func testPortProbeSeesAListenerAndItsAbsence() throws {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    XCTAssertGreaterThanOrEqual(fd, 0)
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = 0
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    var length = socklen_t(MemoryLayout<sockaddr_in>.size)
    let bound = withUnsafeMutablePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.bind(fd, $0, length) == 0 && Darwin.listen(fd, 1) == 0
          && getsockname(fd, $0, &length) == 0
      }
    }
    XCTAssertTrue(bound)
    let port = UInt16(bigEndian: address.sin_port)

    XCTAssertTrue(DriveBufferService.tcpPortAnswers(port: port))
    close(fd)
    XCTAssertFalse(DriveBufferService.tcpPortAnswers(port: port))
  }

  /// N2: a mount table that could not be read is not "the mount is not running".
  func testUnknownMountIsNotReportedAsStopped() {
    let line = StatusLines.remoteControl(.legacyTCP, mounted: nil)
    XCTAssertFalse(line.contains("is not running"), line)
    XCTAssertTrue(line.contains("UNKNOWN"), line)
    XCTAssertTrue(StatusLines.remoteControl(.legacyTCP, mounted: true).contains("restart-mount"))
  }

  // MARK: - Notification

  private func stateFile() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("cm-open-port-\(UUID().uuidString).json")
  }

  private final class Deliveries: @unchecked Sendable {
    var count = 0
    var succeed = true
  }

  private func report(
    _ open: Bool, at now: Date, file: URL, _ deliveries: Deliveries
  ) async -> Bool {
    await OpenPortAlert.report(
      open: open, now: now, stateFile: file,
      deliver: { _, _ in
        deliveries.count += 1
        return deliveries.succeed
      }, log: { _ in })
  }

  /// Once at once, then after 1, 2, 4 days, then weekly - never twice a day.
  func testNotifiesOnceThenWithAGrowingGap() async {
    let file = stateFile()
    defer { try? FileManager.default.removeItem(at: file) }
    let deliveries = Deliveries()
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    let day: TimeInterval = 86_400
    // The watchdog runs every 30 minutes; walk 30 days of runs.
    var times: [TimeInterval] = []
    var now = start
    while now < start.addingTimeInterval(30 * day) {
      if await report(true, at: now, file: file, deliveries) {
        times.append(now.timeIntervalSince(start) / day)
      }
      now = now.addingTimeInterval(1800)
    }
    XCTAssertEqual(times.first, 0)
    let gaps = zip(times.dropFirst(), times).map { $0 - $1 }
    XCTAssertEqual(gaps.prefix(4).map { Int($0.rounded()) }, [1, 2, 4, 7])
    XCTAssertTrue(gaps.dropFirst(3).allSatisfy { Int($0.rounded()) == 7 })
  }

  func testUndeliveredNotificationIsRetriedAtTheNextRun() async {
    let file = stateFile()
    defer { try? FileManager.default.removeItem(at: file) }
    let deliveries = Deliveries()
    let now = Date()
    deliveries.succeed = false
    let first = await report(true, at: now, file: file, deliveries)
    XCTAssertFalse(first)
    deliveries.succeed = true
    let retried = await report(true, at: now.addingTimeInterval(1800), file: file, deliveries)
    XCTAssertTrue(retried)
    let quiet = await report(true, at: now.addingTimeInterval(3600), file: file, deliveries)
    XCTAssertFalse(quiet)
    XCTAssertEqual(deliveries.count, 2)
  }

  func testClosedPortEndsTheEpisode() async {
    let file = stateFile()
    defer { try? FileManager.default.removeItem(at: file) }
    let deliveries = Deliveries()
    let now = Date()
    _ = await report(true, at: now, file: file, deliveries)
    _ = await report(false, at: now.addingTimeInterval(60), file: file, deliveries)
    XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    // Open again (say, a downgrade): told at once, not after the old gap.
    let again = await report(true, at: now.addingTimeInterval(120), file: file, deliveries)
    XCTAssertTrue(again)
    XCTAssertEqual(deliveries.count, 2)
  }

  // MARK: - Restarting the mount

  private final class Calls: @unchecked Sendable {
    var log: [String] = []
  }

  private func steps(
    _ calls: Calls, backupRunning: Bool? = false, mounted: Bool? = true,
    drained: Bool = true, stopped: Bool = true, cameBack: Bool = true
  ) -> MountRestart.Steps {
    MountRestart.Steps(
      backupRunning: { backupRunning },
      mounted: { mounted },
      detachAndDrain: {
        calls.log.append("drain")
        return CMActionResult(succeeded: drained, message: drained ? "drained" : "not drained")
      },
      stopMount: {
        calls.log.append("stop")
        return stopped
      },
      waitForNewMount: {
        calls.log.append("wait")
        return cameBack
      },
      attach: {
        calls.log.append("attach")
        return CMActionResult(succeeded: true, message: "attached")
      })
  }

  func testRestartRunsTheShutdownPathInOrder() async {
    let calls = Calls()
    let result = await MountRestart.run(steps(calls))
    XCTAssertTrue(result.succeeded, result.message)
    XCTAssertEqual(calls.log, ["drain", "stop", "wait", "attach"])
  }

  /// Nothing is touched while Time Machine writes, or when that is unknown.
  func testRestartRefusesDuringABackupOrWithoutAnAnswer() async {
    for running in [true, nil] as [Bool?] {
      let calls = Calls()
      let result = await MountRestart.run(steps(calls, backupRunning: running))
      XCTAssertFalse(result.succeeded)
      XCTAssertTrue(result.didNotRun, "a refusal touched nothing - AttachStall must not count it")
      XCTAssertEqual(calls.log, [])
    }
    let calls = Calls()
    let result = await MountRestart.run(steps(calls, mounted: nil))
    XCTAssertFalse(result.succeeded)
    XCTAssertEqual(calls.log, [])
  }

  /// THE rule: the mount is stopped only after everything reached Drive.
  /// A drain that did not finish leaves the mount alone and the image back.
  func testUnfinishedDrainNeverStopsTheMount() async {
    let calls = Calls()
    let result = await MountRestart.run(steps(calls, drained: false))
    XCTAssertFalse(result.succeeded)
    XCTAssertEqual(calls.log, ["drain", "attach"])
    XCTAssertTrue(result.message.contains("not drained"))
  }

  func testRefusedStopPutsTheImageBack() async {
    let calls = Calls()
    let result = await MountRestart.run(steps(calls, stopped: false))
    XCTAssertFalse(result.succeeded)
    XCTAssertEqual(calls.log, ["drain", "stop", "attach"])
  }

  func testMountThatDoesNotComeBackIsReported() async {
    let calls = Calls()
    let result = await MountRestart.run(steps(calls, cameBack: false))
    XCTAssertFalse(result.succeeded)
    XCTAssertEqual(calls.log, ["drain", "stop", "wait"])
  }
}
