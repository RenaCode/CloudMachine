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

  /// 12 Nov 2026: after the 1.3.28 upgrade the reload did `bootout`, then
  /// every `bootstrap` failed - `backup-health` stayed UNLOADED for two days,
  /// while `brokenAgents` (which skipped agents that are not loaded) and
  /// `vm-status` said "Agents: OK". A plist on disk means the agent was
  /// installed; not being loaded is then a fault to repair.
  func testInstalledButUnloadedAgentIsBroken() async {
    let healthy = "\tstate = not running\n\tlast exit code = 0\n"
    let broken = await AgentRepair.brokenAgents(
      names: ["backup-health", "vm-guard"],
      plistExists: { _ in true },
      lookup: { $0 == "vm-guard" ? .loaded(healthy) : .notFound })
    XCTAssertEqual(broken, ["backup-health"])
  }

  /// A `launchctl print` that timed out, or ran where there is no GUI domain
  /// (SSH, sudo), says nothing about the agent. Reloading on that would
  /// `bootout` a healthy agent - possibly the very `backup-health` running
  /// the check, which launchd then kills before it can bootstrap itself.
  func testUnknownLaunchdAnswerIsNotBroken() async {
    let broken = await AgentRepair.brokenAgents(
      names: ["backup-health", "vm-guard"], plistExists: { _ in true },
      lookup: { _ in .unknown })
    XCTAssertEqual(broken, [])
  }

  /// Without a plist the agent was never installed - that is setup, not repair.
  func testAgentThatWasNeverInstalledIsNotBroken() async {
    let broken = await AgentRepair.brokenAgents(
      names: ["backup-health"], plistExists: { _ in false }, lookup: { _ in .notFound })
    XCTAssertEqual(broken, [])
  }

  /// `vm-start` is reloaded only when launchd cannot START it: loading it
  /// starts the machine, which someone may have stopped on purpose.
  func testUnloadedMachineStartIsNotReloaded() async {
    let broken = await AgentRepair.brokenAgents(
      names: ["vm-start"], plistExists: { _ in true }, lookup: { _ in .notFound })
    XCTAssertEqual(broken, [])
  }

  func testSpawnFailedLoadedAgentIsStillBroken() async {
    let failed = "\tstate = not running\n\tjob state = spawn failed\n"
    let broken = await AgentRepair.brokenAgents(
      names: ["vm-start"], plistExists: { _ in true }, lookup: { _ in .loaded(failed) })
    XCTAssertEqual(broken, ["vm-start"])
  }

  /// Copied from `launchctl print` on 14 Nov 2026 (macOS 27.2): an unknown
  /// label exits 113 with "Could not find service" on stderr.
  func testOnlyLaunchdsOwnNotFoundCountsAsUnloaded() {
    XCTAssertEqual(
      AgentRepair.jobLookup(
        exitCode: 113, stdout: "",
        stderr:
          "Bad request.\nCould not find service \"com.renacode.cloudmachine.backup-health\" in domain for user gui: 501\n"
      ), .notFound)
    XCTAssertEqual(
      AgentRepair.jobLookup(exitCode: 0, stdout: "\tstate = running\n", stderr: ""),
      .loaded("\tstate = running\n"))
    XCTAssertEqual(
      AgentRepair.jobLookup(
        exitCode: 125, stdout: "", stderr: "Domain does not support specified action"),
      .unknown)
    XCTAssertEqual(AgentRepair.jobLookup(exitCode: 1, stdout: "", stderr: ""), .unknown)
  }

  // MARK: - Reloading

  /// Records a reload without launchd. `bootstrap` behaves like
  /// `ProcessRunner` does: in a cancelled task the process is terminated at
  /// once, so the call fails.
  private final class FakeLaunchctl: @unchecked Sendable {
    let lock = NSLock()
    var calls: [String] = []
    var logs: [String] = []
    var bootstrapSucceeds = true

    private func record(_ call: String) {
      lock.lock()
      calls.append(call)
      lock.unlock()
    }

    var steps: AgentRepair.ReloadSteps {
      AgentRepair.ReloadSteps(
        plistExists: { _ in true },
        bootout: { self.record("bootout \($0)") },
        bootstrap: {
          self.record("bootstrap \($0)")
          return self.bootstrapSucceeds && !Task.isCancelled
        },
        pause: {},
        log: { message in
          self.lock.lock()
          self.logs.append(message)
          self.lock.unlock()
        })
    }
  }

  /// 12 Nov 2026 14:53: the dashboard and the menu bar both called
  /// `startAutoRefresh`, the second call cancelled the first task right after
  /// its `bootout`, and all ten `bootstrap` attempts failed within ONE second
  /// (`Task.sleep` returns at once in a cancelled task, `ProcessRunner` kills
  /// the process). backup-health and vm-guard were left unloaded.
  func testReloadFinishesEvenWhenTheCallerIsCancelled() async {
    let fake = FakeLaunchctl()
    let task = Task { await AgentRepair.reload("backup-health", steps: fake.steps) }
    task.cancel()
    let reloaded = await task.value
    XCTAssertTrue(reloaded)
    XCTAssertEqual(fake.calls, ["bootout backup-health", "bootstrap backup-health"])
  }

  func testReloadGivesUpAfterTenFailedBootstraps() async {
    let fake = FakeLaunchctl()
    fake.bootstrapSucceeds = false
    let reloaded = await AgentRepair.reload("vm-guard", steps: fake.steps)
    XCTAssertFalse(reloaded)
    XCTAssertEqual(fake.calls.filter { $0.hasPrefix("bootstrap") }.count, 10)
    XCTAssertTrue(fake.logs.contains { $0.contains("bootstrap kept failing") })
  }

  /// The stamp says "the agents run this version". Written after a failed
  /// reload, it stopped every later launch from trying again.
  func testUpgradeStampOnlyAfterEveryReloadSucceeded() async {
    var tried: [String] = []
    let allOK = await AgentRepair.reloadAfterUpgrade(["backup-health", "vm-guard"]) {
      tried.append($0)
      return $0 == "vm-guard"
    }
    XCTAssertFalse(allOK)
    XCTAssertEqual(tried, ["backup-health", "vm-guard"], "one failure must not skip the rest")
    let fine = await AgentRepair.reloadAfterUpgrade(["backup-health"]) { _ in true }
    XCTAssertTrue(fine)
  }

  /// The whole upgrade step: no stamp after a failed reload (the next launch
  /// tries again), a stamp after a good one, nothing at all when the version
  /// did not change.
  func testUpgradeStepWritesTheStampOnlyWhenTheReloadWorked() async {
    var written: [String] = []
    var reloaded: [String] = []
    await AgentRepair.reloadIfUpgraded(
      current: "1.3.29 (211) e2eb360", stamp: "1.3.28 (210) aca535e",
      installed: ["backup-health", "vm-guard"],
      reload: {
        reloaded.append($0)
        return false
      },
      writeStamp: { written.append($0) })
    XCTAssertEqual(reloaded, ["backup-health", "vm-guard"])
    XCTAssertEqual(written, [])

    await AgentRepair.reloadIfUpgraded(
      current: "1.3.29 (211) e2eb360", stamp: "1.3.28 (210) aca535e",
      installed: ["backup-health"], reload: { _ in true }, writeStamp: { written.append($0) })
    XCTAssertEqual(written, ["1.3.29 (211) e2eb360"])

    reloaded = []
    await AgentRepair.reloadIfUpgraded(
      current: "1.3.29 (211) e2eb360", stamp: "1.3.29 (211) e2eb360\n",
      installed: ["backup-health"],
      reload: {
        reloaded.append($0)
        return true
      },
      writeStamp: { written.append($0) })
    XCTAssertEqual(reloaded, [])
    XCTAssertEqual(written.count, 1)
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
