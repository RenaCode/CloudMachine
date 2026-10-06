import XCTest

@testable import CloudMachineCore

/// The states below are copied from `launchctl print` on 6 Oct 2026, after
/// `brew upgrade` replaced the app: the watchdog had stopped starting and
/// nothing said so.
final class AgentRepairTests: XCTestCase {

  func testSpawnFailedAfterUpgradeIsBroken() {
    let output = """
      \tstate = not running
      \truns = 27
      \tlast exit reason = OS_REASON_CODESIGNING
      \tspawn type = daemon (3)
      \tjob state = spawn failed
      """
    XCTAssertTrue(AgentRepair.cannotStart(printOutput: output))
  }

  func testCodesigningExitWithoutSpawnFailedLineIsStillBroken() {
    let output = """
      \tstate = not running
      \tlast exit reason = OS_REASON_CODESIGNING
      """
    XCTAssertTrue(AgentRepair.cannotStart(printOutput: output))
  }

  func testRunningMountIsLeftAlone() {
    // gdrive-buffer keeps running the old process after an upgrade; reloading
    // it would drop the Google Drive mount.
    let output = """
      \tstate = running
      \truns = 1
      \tlast exit code = (never exited)
      \tjob state = running
      """
    XCTAssertFalse(AgentRepair.cannotStart(printOutput: output))
  }

  func testIdlePeriodicAgentIsHealthy() {
    let output = """
      \tstate = not running
      \truns = 2
      \tlast exit code = 0
      """
    XCTAssertFalse(AgentRepair.cannotStart(printOutput: output))
  }

  func testVersionChangeTriggersReload() {
    XCTAssertTrue(
      AgentRepair.versionChanged(current: "1.3.2 (130) abc1234", stamp: "1.3.1 (125) def5678"))
    XCTAssertTrue(AgentRepair.versionChanged(current: "1.3.2 (130) abc1234", stamp: nil))
    XCTAssertFalse(
      AgentRepair.versionChanged(current: "1.3.2 (130) abc1234", stamp: "1.3.2 (130) abc1234\n"))
  }

  func testMountAgentIsNeverReloadedPreemptively() {
    XCTAssertFalse(AgentRepair.safeToReload.contains("gdrive-buffer"))
    XCTAssertTrue(AgentRepair.all.contains("gdrive-buffer"))
  }
}
