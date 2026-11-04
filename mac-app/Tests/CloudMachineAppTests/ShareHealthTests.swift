import CloudMachineCore
import XCTest

@testable import CloudMachineApp

/// What the watchdog, `vm-status` and the panel say about the share - the
/// readers of the two probes. The rule they share: only a CONFIRMED readable
/// share and an SMB answer are fine; "no answer" is never shown as OK.
final class ShareHealthTests: XCTestCase {

  private let now = Date(timeIntervalSince1970: 1_757_700_000)

  private func evaluate(
    shareRead: ShareReadProbe.Verdict?, smb: SMBProbe.Verdict?,
    services: Bool? = true, grace: Bool = false
  ) -> BackupHealth.Report {
    BackupHealth.evaluate(
      lastSuccess: now.addingTimeInterval(-1800), lastAttempt: now.addingTimeInterval(-1800),
      result: 0, now: now, machineRunning: true, servicesHealthy: services,
      destinationRegistered: true, erroredFiles: 0, outOfSpace: false, queueReadable: true,
      withinStartupGrace: grace, shareRead: shareRead, smb: smb, smbAddress: "192.168.64.10")
  }

  private func codes(_ report: BackupHealth.Report) -> [String] { report.problems.map(\.code) }

  // MARK: - backup-health

  func testReadableShareThatAnswersIsHealthy() {
    XCTAssertTrue(evaluate(shareRead: .readable, smb: .answers).healthy)
    XCTAssertTrue(evaluate(shareRead: .noImage, smb: .answers).healthy)
  }

  /// Not asked (older callers, tests) stays silent; the live report always asks.
  func testNotAskedIsSilent() {
    XCTAssertTrue(evaluate(shareRead: nil, smb: nil).healthy)
  }

  func testDeadShareAlarms() {
    let report = evaluate(shareRead: .dead(reason: "ENXIO"), smb: .answers)
    XCTAssertEqual(codes(report), ["share-unreadable"])
    XCTAssertTrue(report.problems[0].detail.contains("ENXIO"), report.problems[0].detail)
  }

  func testOtherReadErrorAlarmsTheSameWay() {
    XCTAssertEqual(
      codes(evaluate(shareRead: .failed(reason: "Permission denied"), smb: .answers)),
      ["share-unreadable"])
  }

  /// The case the old layout got wrong: "I do not know" read as "fine".
  func testHungReadAlarmsAsUnknownNotAsFine() {
    let report = evaluate(shareRead: .noAnswer(hungSeconds: 120), smb: .answers)
    XCTAssertEqual(codes(report), ["share-read-no-answer"])
    XCTAssertTrue(report.problems[0].detail.contains("120"), report.problems[0].detail)
    XCTAssertEqual(
      codes(evaluate(shareRead: .noAnswer(hungSeconds: nil), smb: .answers)),
      ["share-read-no-answer"])
  }

  /// Startup grace defers "not up yet" states only - an unknown read and a
  /// dead one alarm from the first second, like every other "unknown".
  func testGraceDoesNotSilenceTheShare() {
    XCTAssertEqual(
      codes(evaluate(shareRead: .noAnswer(hungSeconds: 30), smb: .answers, grace: true)),
      ["share-read-no-answer"])
    XCTAssertEqual(
      codes(evaluate(shareRead: .dead(reason: "EIO"), smb: .answers, grace: true)),
      ["share-unreadable"])
  }

  func testSambaRefusingAlarms() {
    let report = evaluate(shareRead: .readable, smb: .refused(reason: "EHOSTUNREACH"))
    XCTAssertEqual(codes(report), ["smb-no-connection"])
    XCTAssertTrue(report.problems[0].detail.contains("192.168.64.10"))
    XCTAssertTrue(report.problems[0].detail.contains("EHOSTUNREACH"))
    XCTAssertEqual(codes(evaluate(shareRead: .readable, smb: .notSMB)), ["smb-no-connection"])
  }

  /// Samba refusing right after startup is "not up yet" - deferred, not lost.
  func testSambaRefusingRightAfterStartupIsDeferred() {
    let report = evaluate(shareRead: .readable, smb: .refused(reason: "ECONNREFUSED"), grace: true)
    XCTAssertTrue(report.healthy)
    XCTAssertEqual(report.deferred.map(\.code), ["smb-no-connection"])
  }

  /// No route: the route is gone or Local Network privacy blocks this program.
  func testSambaUnreachableIsUnknownAndNamesLocalNetworkPrivacy() {
    let report = evaluate(shareRead: .readable, smb: .unreachable(reason: "EHOSTUNREACH"))
    XCTAssertEqual(codes(report), ["smb-unreachable"])
    XCTAssertEqual(
      report.problems[0].summary, "Unknown whether Samba in the machine answers this Mac")
    XCTAssertTrue(report.problems[0].detail.contains("Local Network"), report.problems[0].detail)
    XCTAssertTrue(report.problems[0].detail.contains("EHOSTUNREACH"))
  }

  func testSambaSilentIsUnknown() {
    XCTAssertEqual(
      codes(evaluate(shareRead: .readable, smb: .noAnswer(seconds: 5))), ["smb-no-answer"])
    XCTAssertEqual(codes(evaluate(shareRead: .readable, smb: .noAddress)), ["smb-no-address"])
  }

  /// With a service down a harder message already speaks; a second one about
  /// the consequence only dilutes it (same rule as the rc message).
  func testServiceDownSpeaksAlone() {
    let report = evaluate(
      shareRead: .dead(reason: "ENOENT"), smb: .refused(reason: "ECONNREFUSED"), services: false)
    XCTAssertEqual(codes(report), ["machine-service-down"])
  }

  func testCodesAreOwnAndDistinct() {
    let reports = [
      evaluate(shareRead: .dead(reason: "EIO"), smb: .refused(reason: "X")),
      evaluate(shareRead: .noAnswer(hungSeconds: 1), smb: .noAnswer(seconds: 5)),
      evaluate(shareRead: .readable, smb: .noAddress),
    ]
    for report in reports {
      XCTAssertEqual(Set(codes(report)).count, report.problems.count)
      for problem in report.problems { XCTAssertNotEqual(problem.code, problem.summary) }
    }
  }

  // MARK: - vm-status

  func testStatusLines() {
    let fine = VMStatus.shareLines(read: .readable, smb: .answers, address: "192.168.64.10")
    XCTAssertTrue(fine.healthy)
    XCTAssertEqual(fine.lines.count, 2)

    let noImage = VMStatus.shareLines(read: .noImage, smb: .answers, address: "a")
    XCTAssertTrue(noImage.healthy)

    let cases: [(ShareReadProbe.Verdict, SMBProbe.Verdict, String)] = [
      (.dead(reason: "EIO"), .answers, "EIO"),
      (.noAnswer(hungSeconds: 42), .answers, "42"),
      (.readable, .refused(reason: "ECONNREFUSED"), "ECONNREFUSED"),
      (.readable, .noAnswer(seconds: 5), "5"),
      (.readable, .noAddress, "Samba"),
    ]
    for (read, smb, mention) in cases {
      let result = VMStatus.shareLines(read: read, smb: smb, address: "192.168.64.10")
      XCTAssertFalse(result.healthy, "\(read) \(smb)")
      XCTAssertTrue(result.lines.joined().contains(mention), "\(result.lines)")
    }
  }

  // MARK: - The panel

  @MainActor
  func testPanelSambaUnreachableIsAmber() {
    let status = AppStatus.healthyForTests()
    status.machine.smb = .unreachable(reason: "EHOSTUNREACH")
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Unknown whether Samba in the machine answers this Mac")
    XCTAssertEqual(status.overallTone, .warning)
  }

  // MARK: - The machine card in the window

  /// REVIEW 03.11: the card said "All running" in green with the share dead,
  /// and "Not running: " with an empty list for an inactive bind after
  /// `vm-prepare-bundle`.
  func testMachineCardNamesTheInactiveBind() {
    var machine = MachineStatus.healthyForTests
    machine.services["tm-bands-bind"] = "inactive"
    machine.bundlePrepared = true
    XCTAssertEqual(machine.servicesDown, ["tm-bands-bind"])
    XCTAssertEqual(machine.servicesText, "Not running: tm-bands-bind")
    XCTAssertEqual(machine.servicesTone, .danger)
    machine.bundlePrepared = false
    XCTAssertEqual(machine.servicesDown, [])
  }

  func testMachineCardIsGreenOnlyWithTheShareConfirmed() {
    var machine = MachineStatus.healthyForTests
    XCTAssertEqual(machine.servicesText, "All running")
    XCTAssertEqual(machine.servicesTone, .success)

    machine.shareRead = .dead(reason: "EIO")
    XCTAssertEqual(machine.servicesText, "The machine's share cannot be read")
    XCTAssertEqual(machine.servicesTone, .danger)

    machine.shareRead = .noAnswer(hungSeconds: 40)
    XCTAssertEqual(machine.servicesText, "Unknown whether the machine's share can be read")
    XCTAssertEqual(machine.servicesTone, .warning)

    machine.shareRead = .readable
    machine.smb = .refused(reason: "ECONNREFUSED")
    XCTAssertEqual(machine.servicesText, "Samba in the machine does not answer this Mac")
    XCTAssertEqual(machine.servicesTone, .danger)

    machine.smb = nil
    XCTAssertEqual(machine.servicesTone, .warning, "not asked is not green")
  }

  /// The panel reads the bind's verdict with the image's state from the same
  /// report: inactive after `vm-prepare-bundle` is a service problem.
  func testPanelSeesTheInactiveBindAfterPrepare() {
    var machine = MachineStatus.healthyForTests
    XCTAssertEqual(machine.servicesHealthy, true)
    machine.services["tm-bands-bind"] = "inactive"
    machine.bundlePrepared = true
    XCTAssertEqual(machine.servicesHealthy, false)
    machine.bundlePrepared = false
    XCTAssertEqual(machine.servicesHealthy, true)
  }

  @MainActor
  func testPanelIsGreenOnlyForAConfirmedShare() {
    let status = AppStatus.healthyForTests()
    XCTAssertTrue(status.healthy)
    XCTAssertEqual(status.headline, "Ready")
  }

  @MainActor
  func testPanelDeadShareIsRed() {
    let status = AppStatus.healthyForTests()
    status.machine.shareRead = .dead(reason: "ENXIO")
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "The machine's share cannot be read")
    XCTAssertEqual(status.overallTone, .danger)
  }

  @MainActor
  func testPanelUnknownShareIsNeverGreenNorReady() {
    for verdict in [ShareReadProbe.Verdict.noAnswer(hungSeconds: 30), .noAnswer(hungSeconds: nil)] {
      let status = AppStatus.healthyForTests()
      status.machine.shareRead = verdict
      XCTAssertFalse(status.healthy)
      XCTAssertEqual(status.headline, "Unknown whether the machine's share can be read")
      XCTAssertEqual(status.overallTone, .warning)
    }
    let unread = AppStatus.healthyForTests()
    unread.machine.shareRead = nil
    XCTAssertFalse(unread.healthy, "unread is not readable")
    XCTAssertNotEqual(unread.headline, "Ready")
  }

  @MainActor
  func testPanelSambaRefusingIsRed() {
    let status = AppStatus.healthyForTests()
    status.machine.smb = .refused(reason: "EHOSTUNREACH")
    XCTAssertFalse(status.healthy)
    XCTAssertEqual(status.headline, "Samba in the machine does not answer this Mac")
    XCTAssertEqual(status.overallTone, .danger)
  }

  @MainActor
  func testPanelSambaUnknownIsAmber() {
    for verdict in [SMBProbe.Verdict.noAnswer(seconds: 5), .noAddress] {
      let status = AppStatus.healthyForTests()
      status.machine.smb = verdict
      XCTAssertFalse(status.healthy)
      XCTAssertEqual(status.headline, "Unknown whether Samba in the machine answers this Mac")
      XCTAssertEqual(status.overallTone, .warning)
    }
    let unread = AppStatus.healthyForTests()
    unread.machine.smb = nil
    XCTAssertFalse(unread.healthy)
  }

  /// The button that starts a backup still follows the device checks, not
  /// the probes: an unknown read must not grey out the way to find out.
  @MainActor
  func testUnknownShareStillAllowsBackingUp() {
    let status = AppStatus.healthyForTests()
    status.machine.shareRead = .noAnswer(hungSeconds: 30)
    XCTAssertTrue(status.canStartBackup)
  }
}
