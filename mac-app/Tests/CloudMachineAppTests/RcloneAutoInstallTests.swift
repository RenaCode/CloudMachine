import XCTest

@testable import CloudMachineApp
@testable import CloudMachineCore

/// A fresh Mac used to show "missing rclone" until someone pressed a button.
/// The app now checks rclone at start and then every hour, installs it by
/// itself when it is missing or too old, and after a failure tries again at
/// the next hourly check - never more often. No button; the window shows the
/// state. The clock is injected, so nothing here sleeps.
@MainActor
final class RcloneAutoInstallTests: XCTestCase {

  // MARK: - Version check

  func testParsesRcloneVersionOutput() {
    XCTAssertEqual(
      RcloneVersion.parse(
        "rclone v1.75.1\n- os/version: darwin 26.1 (64 bit)\n- go/version: go1.25"),
      [1, 75, 1])
    XCTAssertEqual(RcloneVersion.parse("rclone v1.68.0-beta.123.abc"), [1, 68, 0])
  }

  func testGarbageHasNoVersion() {
    XCTAssertNil(RcloneVersion.parse(""))
    XCTAssertNil(RcloneVersion.parse("zsh: bad CPU type in executable"))
  }

  func testOldOrUnreadableVersionNeedsInstall() {
    XCTAssertTrue(RcloneVersion.isAcceptable(output: "rclone v1.75.1"))
    XCTAssertTrue(RcloneVersion.isAcceptable(output: "rclone v2.0.0"))
    XCTAssertFalse(RcloneVersion.isAcceptable(output: "rclone v1.50.2"))
    XCTAssertFalse(RcloneVersion.isAcceptable(output: "rclone v1.2"))
    XCTAssertFalse(RcloneVersion.isAcceptable(output: "no idea"))
  }

  // MARK: - The coordinator

  private final class Fakes: @unchecked Sendable {
    var needs = true
    var result = CMActionResult(succeeded: true, message: "ok")
    var installs = 0
    var checks = 0
    var now = Date(timeIntervalSince1970: 1_000_000)
    func advance(_ seconds: TimeInterval) { now = now.addingTimeInterval(seconds) }
  }

  private func installer(_ fakes: Fakes) -> RcloneAutoInstaller {
    RcloneAutoInstaller(
      needsInstall: {
        fakes.checks += 1
        return fakes.needs
      },
      install: {
        fakes.installs += 1
        if fakes.result.succeeded { fakes.needs = false }
        return fakes.result
      },
      now: { fakes.now })
  }

  func testInstallsAtStartWhenRcloneIsMissing() async {
    let fakes = Fakes()
    let auto = installer(fakes)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 1)
    XCTAssertEqual(auto.state, .installed)
    XCTAssertFalse(auto.replacementNeeded)
  }

  func testDoesNothingWhenRcloneIsFine() async {
    let fakes = Fakes()
    fakes.needs = false
    let auto = installer(fakes)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 0)
    XCTAssertEqual(auto.state, .idle)
  }

  func testChecksAgainOnlyAfterAnHour() async {
    let fakes = Fakes()
    fakes.needs = false
    let auto = installer(fakes)
    await auto.tick()
    fakes.advance(3599)
    await auto.tick()
    XCTAssertEqual(fakes.checks, 1)
    fakes.advance(1)
    await auto.tick()
    XCTAssertEqual(fakes.checks, 2)
  }

  func testRcloneRemovedLaterIsInstalledAtTheNextHourlyCheck() async {
    let fakes = Fakes()
    fakes.needs = false
    let auto = installer(fakes)
    await auto.tick()
    fakes.needs = true
    fakes.advance(3600)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 1)
  }

  func testFailureShowsMessageAndWhenTheNextAttemptIs() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "no network")
    let auto = installer(fakes)
    await auto.tick()
    XCTAssertEqual(
      auto.state, .failed("no network", retryAt: fakes.now.addingTimeInterval(3600)))
    XCTAssertTrue(auto.replacementNeeded)
  }

  func testFailureIsNotRetriedBeforeTheNextCheck() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "no network")
    let auto = installer(fakes)
    await auto.tick()
    for _ in 0..<10 {
      fakes.advance(300)  // 50 minutes in all
      await auto.tick()
    }
    XCTAssertEqual(fakes.installs, 1, "no loop faster than hourly")
  }

  func testRetriesAtTheNextHourlyCheckAndRecovers() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "bad checksum")
    let auto = installer(fakes)
    await auto.tick()
    fakes.result = CMActionResult(succeeded: true, message: "ok")
    fakes.advance(3600)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 2)
    XCTAssertEqual(auto.state, .installed)
  }

  func testAnotherFailureSchedulesAnotherHour() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "offline")
    let auto = installer(fakes)
    await auto.tick()
    fakes.advance(3600)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 2)
    XCTAssertEqual(auto.state, .failed("offline", retryAt: fakes.now.addingTimeInterval(3600)))
  }

  func testRcloneFixedByHandClearsTheError() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "offline")
    let auto = installer(fakes)
    await auto.tick()
    fakes.needs = false  // someone ran install-rclone
    fakes.advance(3600)
    await auto.tick()
    XCTAssertEqual(auto.state, .idle)
    XCTAssertFalse(auto.replacementNeeded)
    XCTAssertEqual(fakes.installs, 1)
  }

  func testCheckNowBringsTheCheckForwardWhenTheBinaryVanished() async {
    let fakes = Fakes()
    fakes.needs = false
    let auto = installer(fakes)
    await auto.tick()
    fakes.needs = true
    fakes.advance(600)
    await auto.tick()
    XCTAssertEqual(fakes.installs, 0, "not due yet")
    auto.checkNow()
    await auto.tick()
    XCTAssertEqual(fakes.installs, 1)
  }

  func testCheckNowDoesNotSkipTheWaitAfterAFailure() async {
    let fakes = Fakes()
    fakes.result = CMActionResult(succeeded: false, message: "offline")
    let auto = installer(fakes)
    await auto.tick()
    fakes.advance(600)
    auto.checkNow()
    await auto.tick()
    XCTAssertEqual(fakes.installs, 1, "after a failure the next try is still an hour away")
  }

  func testNeverRunsTwoAtOnce() async {
    let fakes = Fakes()
    var seen: [ToolInstallState] = []
    let gate = AsyncGate()
    let auto = RcloneAutoInstaller(
      needsInstall: { true },
      install: {
        fakes.installs += 1
        await gate.wait()
        return CMActionResult(succeeded: true, message: "ok")
      },
      now: { fakes.now })
    auto.onChange = { seen.append($0) }
    let first = Task { await auto.tick() }
    while auto.state != .installing { await Task.yield() }
    fakes.advance(7200)
    // Second tick in its own task: if the guard were missing it would start a
    // second install and park on the gate - the test must FAIL, not hang.
    let second = Task { await auto.tick() }
    for _ in 0..<50 { await Task.yield() }
    XCTAssertEqual(fakes.installs, 1, "a second install must not start while one runs")
    await gate.open()
    await second.value
    await first.value
    XCTAssertEqual(seen, [.installing, .installed])
  }

  func testNeedsInstallPredicateCoversMissingBinaryAndOldVersion() {
    XCTAssertTrue(RcloneAutoInstaller.needsInstall(binaryExists: false, versionOutput: nil))
    XCTAssertTrue(
      RcloneAutoInstaller.needsInstall(binaryExists: true, versionOutput: "rclone v1.40.0"))
    XCTAssertTrue(RcloneAutoInstaller.needsInstall(binaryExists: true, versionOutput: nil))
    XCTAssertFalse(
      RcloneAutoInstaller.needsInstall(binaryExists: true, versionOutput: "rclone v1.75.1"))
  }

  // MARK: - The setup card and the messages

  private func inputs(hasRclone: Bool, install: ToolInstallState) -> SetupPlan.Inputs {
    SetupPlan.Inputs(
      hasRclone: hasRclone, remoteConfigured: false, hasLima: true, machineExists: true,
      machineRunning: true, hasFullDiskAccess: true, agentsInstalled: true,
      timeMachineNotPointingHere: false, bundleNeedsPreparing: false,
      connectCommand: "connect", setDestinationCommand: nil,
      maskedSetDestinationCommand: nil, rcloneInstall: install)
  }

  func testCardShowsProgressWithoutAButtonWhileInstalling() {
    let step = SetupPlan.steps(inputs(hasRclone: false, install: .installing)).first
    XCTAssertEqual(step?.inProgress, true)
    XCTAssertNil(step?.action)
    XCTAssertEqual(step?.title, "Installing rclone - downloading and verifying it")
  }

  func testCardShowsTheErrorAndTheNextAttemptButNoButton() {
    let at = Date(timeIntervalSince1970: 2_000_000)
    let step = SetupPlan.steps(
      inputs(hasRclone: false, install: .failed("no network", retryAt: at))
    )
    .first
    XCTAssertNil(step?.action)
    XCTAssertNil(step?.command)
    XCTAssertEqual(step?.inProgress, false)
    XCTAssertTrue(step?.title.hasPrefix("rclone could not be installed: no network") == true)
    XCTAssertTrue(step?.title.contains("Next attempt: ") == true)
  }

  func testMissingRcloneBeforeTheFirstCheckHasNoButtonEither() {
    let step = SetupPlan.steps(inputs(hasRclone: false, install: .idle)).first
    XCTAssertNil(step?.action)
    XCTAssertEqual(step?.inProgress, true)
  }

  func testNoRcloneStepWhenRcloneIsThere() {
    let steps = SetupPlan.steps(inputs(hasRclone: true, install: .idle))
    XCTAssertTrue(steps.allSatisfy { $0.title.contains("rclone") == false })
  }

  func testHeadlineSaysInstallingInsteadOfMissing() {
    let status = AppStatus()
    status.dependencyState = .missing(["rclone"], ["cloudmachine-agent install-rclone"])
    status.rcloneInstall = .installing
    XCTAssertEqual(status.headline, "Installing rclone")
  }

  func testHeadlineTellsWhereLimaComesFrom() {
    let status = AppStatus()
    status.dependencyState = .missing(["Lima"], ["brew install lima"])
    XCTAssertEqual(status.headline, "Lima is not installed - run in Terminal: brew install lima")
  }

  func testHeadlineKeepsMissingForOtherCombinations() {
    let status = AppStatus()
    status.dependencyState = .missing(["rclone", "Lima"], ["a", "brew install lima"])
    XCTAssertEqual(status.headline, "Missing: rclone, Lima")
  }
}

/// Lets a test hold a fake install open.
private actor AsyncGate {
  private var isOpen = false
  func wait() async { while !isOpen { await Task.yield() } }
  func open() { isOpen = true }
}
