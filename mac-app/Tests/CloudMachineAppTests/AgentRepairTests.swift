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

  /// A reload of `vm-start` starts the machine - not after an upgrade, when
  /// someone may have stopped it on purpose; only when launchd cannot start it.
  func testMachineStartIsNeverReloadedPreemptively() {
    XCTAssertFalse(AgentRepair.safeToReload.contains("vm-start"))
    XCTAssertTrue(AgentRepair.all.contains("vm-start"))
    XCTAssertTrue(Set(AgentRepair.all).isDisjoint(with: AgentRepair.retired))
  }

  // MARK: - The retired layout

  /// Records what the migration did, without launchd.
  private final class Fake: @unchecked Sendable {
    var onDisk: Set<String>
    var loaded: Set<String>
    var bootedOut: [String] = []
    var removed: [String] = []
    var logs: [String] = []
    var deletable = true

    init(onDisk: Set<String>, loaded: Set<String>) {
      self.onDisk = onDisk
      self.loaded = loaded
    }

    var probes: AgentRepair.RetiredProbes {
      AgentRepair.RetiredProbes(
        plistExists: { self.onDisk.contains($0) },
        isLoaded: { self.loaded.contains($0) },
        bootout: {
          self.bootedOut.append($0)
          self.loaded.remove($0)
        },
        removePlist: {
          guard self.deletable else { return false }
          self.removed.append($0)
          self.onDisk.remove($0)
          return true
        },
        leftovers: { ["~/.cloudmachine/cache"] },
        log: { self.logs.append($0) })
    }
  }

  func testRetiredAgentsAreUnloadedAndDeleted() async {
    let fake = Fake(
      onDisk: ["gdrive-buffer", "gdrive-attach", "buffer-guard"], loaded: ["gdrive-buffer"])
    let removed = await AgentRepair.removeRetiredAgents(fake.probes)
    XCTAssertEqual(removed, ["gdrive-buffer", "gdrive-attach", "buffer-guard"])
    XCTAssertEqual(fake.bootedOut, ["gdrive-buffer"], "only a loaded agent is booted out")
    XCTAssertEqual(fake.removed, ["gdrive-buffer", "gdrive-attach", "buffer-guard"])
    XCTAssertTrue(
      fake.logs.contains { $0.contains("remove by hand") && $0.contains(".cloudmachine/cache") },
      "what is left must be listed, not deleted: \(fake.logs)")
  }

  /// The second run - and every launch after it - finds nothing and says nothing.
  func testMigrationIsIdempotent() async {
    let fake = Fake(onDisk: ["buffer-guard"], loaded: ["buffer-guard"])
    _ = await AgentRepair.removeRetiredAgents(fake.probes)
    fake.logs = []
    let again = await AgentRepair.removeRetiredAgents(fake.probes)
    XCTAssertEqual(again, [])
    XCTAssertEqual(fake.logs, [])
  }

  /// A Mac whose old agents were moved away by hand but are still loaded.
  func testLoadedAgentWithoutPlistIsStillBootedOut() async {
    let fake = Fake(onDisk: [], loaded: ["gdrive-attach"])
    let removed = await AgentRepair.removeRetiredAgents(fake.probes)
    XCTAssertEqual(removed, ["gdrive-attach"])
    XCTAssertEqual(fake.bootedOut, ["gdrive-attach"])
    XCTAssertEqual(fake.removed, [])
  }

  func testUndeletablePlistIsNotReportedAsRemoved() async {
    let fake = Fake(onDisk: ["gdrive-buffer"], loaded: [])
    fake.deletable = false
    let removed = await AgentRepair.removeRetiredAgents(fake.probes)
    XCTAssertEqual(removed, [])
    XCTAssertTrue(fake.logs.contains { $0.contains("could not be deleted") })
  }

  func testLeftoversNameTheMountsAndNeverTheManagedRclone() {
    let home = URL(fileURLWithPath: "/Users/someone")
    let lines = AgentRepair.retiredLeftovers(
      home: home, mounted: ["/Volumes/CloudMachine"], exists: { _ in true })
    XCTAssertTrue(lines.first?.contains("/Volumes/CloudMachine is still mounted") == true)
    XCTAssertTrue(lines.contains("/Users/someone/.cloudmachine/cache"))
    XCTAssertFalse(lines.contains { $0.contains(".cloudmachine/bin") }, "rclone is still used")
    XCTAssertFalse(lines.contains { $0.contains(".cloudmachine/vm") }, "the machine's state")
  }
}
