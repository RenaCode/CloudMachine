import XCTest

@testable import CloudMachineCore

/// `vm-hold`: starts the machine at login and stays alive, so that launchd's
/// SIGTERM at logout/shutdown turns into a clean stop of the machine (which
/// otherwise dies together with the Mac and the guest's ext4 needs recovery).
///
/// Lima's real statuses are Running, Stopped, Broken, Installing,
/// Uninitialized and "" (no `Starting`); the tests use those.
final class VMHoldTests: XCTestCase {

  /// Records the order of events and the timeouts the steps were given.
  private final class Recorder: @unchecked Sendable {
    private let lock = NSLock()
    private var items: [String] = []
    private var limits: [String: TimeInterval] = [:]
    private var slept: TimeInterval = 0
    func add(_ item: String) {
      lock.lock()
      items.append(item)
      lock.unlock()
    }
    func limit(_ name: String, _ value: TimeInterval) {
      lock.lock()
      limits[name] = value
      lock.unlock()
    }
    func sleep(_ t: TimeInterval) {
      lock.lock()
      slept += t
      lock.unlock()
    }
    var events: [String] {
      lock.lock()
      defer { lock.unlock() }
      return items
    }
    var plain: [String] { events.filter { !$0.hasPrefix("log") } }
    var timeouts: [String: TimeInterval] {
      lock.lock()
      defer { lock.unlock() }
      return limits
    }
    var totalSlept: TimeInterval {
      lock.lock()
      defer { lock.unlock() }
      return slept
    }
    func logged(_ needle: String) -> Bool {
      events.contains { $0.hasPrefix("log") && $0.contains(needle) }
    }
  }

  /// Statuses answered one per call, the last one repeats.
  private final class Statuses: @unchecked Sendable {
    private let lock = NSLock()
    private var list: [String?]
    init(_ list: [String?]) { self.list = list }
    func next() -> String? {
      lock.lock()
      defer { lock.unlock() }
      return list.count > 1 ? list.removeFirst() : list[0]
    }
  }

  private func steps(
    _ rec: Recorder, start: Bool = true, statuses: [String?] = ["Running"],
    stop: Bool = true, quiesce: Bool = true, unreachable: Bool = false,
    lastShutdown: String? = nil
  ) -> VMHold.Steps {
    let script = Statuses(statuses)
    return VMHold.Steps(
      start: {
        rec.add("start")
        return start
      },
      status: { timeout in
        rec.add("status")
        rec.limit("status", timeout)
        if unreachable { throw ProcessRunnerError.launchFailed("x") }
        return script.next()
      },
      quiesce: { timeout in
        rec.add("quiesce")
        rec.limit("quiesce", timeout)
        return quiesce
      },
      stop: { timeout in
        rec.add("stop")
        rec.limit("stop", timeout)
        return stop
      },
      lastShutdown: {
        rec.add("lastShutdown")
        return lastShutdown
      },
      log: { rec.add("log: \($0)") },
      sleep: { rec.sleep($0) })
  }

  /// Runs `VMHold.run` and fires the termination latch after `delay` seconds.
  private func run(
    _ steps: VMHold.Steps, terminateAfter delay: TimeInterval = 0.05
  ) async -> Int32 {
    let latch = TerminationLatch()
    Task {
      try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
      latch.fire()
    }
    return await VMHold.run(steps: steps, termination: latch)
  }

  // MARK: - The normal life of the job

  func testStartsThenWaitsThenQuiescesAndStopsOnTermination() async {
    let rec = Recorder()
    let code = await run(steps(rec))
    XCTAssertEqual(code, 0)
    XCTAssertEqual(rec.plain, ["start", "lastShutdown", "status", "quiesce", "stop"])
  }

  /// After a hard stop the next start says so in the log (journal of the
  /// previous boot), and a clean one is confirmed.
  func testReportsHowTheLastShutdownWent() async {
    let rec = Recorder()
    _ = await run(steps(rec, lastShutdown: "previous boot ended cleanly"))
    XCTAssertTrue(rec.logged("previous boot ended cleanly"))
  }

  /// The machine was already stopped (the app's Stop, prepare-shutdown):
  /// `limactl stop` on it would only fail.
  func testDoesNotStopAMachineThatIsStoppedOrMissing() async {
    for status in ["Stopped", nil] as [String?] {
      let rec = Recorder()
      let code = await run(steps(rec, statuses: [status]))
      XCTAssertEqual(code, 0)
      XCTAssertFalse(rec.plain.contains("stop"), "status \(String(describing: status))")
      XCTAssertFalse(rec.plain.contains("quiesce"))
    }
  }

  /// Everything that is not Stopped is stopped at termination: a machine in a
  /// transitional state would otherwise die hard with the Mac. Only a running
  /// guest can be asked to quiesce.
  func testStopsEveryStateThatIsNotStopped() async {
    for status in ["Running", "Broken", "Installing", "Uninitialized", ""] {
      let rec = Recorder()
      let code = await run(steps(rec, statuses: [status]))
      XCTAssertEqual(code, 0, status)
      XCTAssertTrue(rec.plain.contains("stop"), "status '\(status)' must be stopped")
      XCTAssertEqual(rec.plain.contains("quiesce"), status == "Running", status)
    }
  }

  /// When Lima does not answer about the status we cannot tell, and a machine
  /// left running is worse than a failed `limactl stop`.
  func testUnknownStatusStillQuiescesAndStops() async {
    let rec = Recorder()
    let code = await run(steps(rec, unreachable: true))
    XCTAssertEqual(code, 0)
    XCTAssertTrue(rec.plain.contains("quiesce"))
    XCTAssertTrue(rec.plain.contains("stop"))
  }

  /// `systemctl stop smbd && sync` in the guest is a courtesy: when it fails
  /// (guest slow, Lima's shell busy) the stop still has to happen.
  func testFailedQuiesceDoesNotPreventTheStop() async {
    let rec = Recorder()
    let code = await run(steps(rec, quiesce: false))
    XCTAssertEqual(code, 0)
    XCTAssertTrue(rec.plain.contains("stop"))
    XCTAssertTrue(rec.logged("quiesce"))
    XCTAssertLessThan(
      rec.plain.firstIndex(of: "quiesce")!, rec.plain.firstIndex(of: "stop")!)
  }

  /// A stop that fails must be visible (exit code and log), not swallowed.
  func testFailedStopIsReported() async {
    let rec = Recorder()
    let code = await run(steps(rec, stop: false))
    XCTAssertEqual(code, 1)
    XCTAssertTrue(rec.logged("stop"))
  }

  // MARK: - Time budget after SIGTERM

  /// launchd sends SIGKILL ExitTimeOut seconds after SIGTERM. Status, quiesce
  /// and stop run one after another, so the sum of their limits (each can give
  /// up `ProcessRunner.giveUpSlack` seconds after its limit) must fit.
  func testWorstCaseOfTheStopSequenceFitsInsideExitTimeout() async throws {
    // A cancelled `limactl start` may take `cancelKillDelay` to end before the
    // stop sequence even begins.
    XCTAssertEqual(
      VMHold.shutdownWorstCase, ProcessRunner.cancelKillDelay + VMHold.stopSequenceWorstCase)
    XCTAssertLessThanOrEqual(
      VMHold.shutdownWorstCase, VMHold.exitTimeOut - 5, "keep a margin to the SIGKILL")
    let rec = Recorder()
    _ = await run(steps(rec))
    XCTAssertEqual(rec.timeouts["status"], VMHold.statusTimeout)
    XCTAssertEqual(rec.timeouts["quiesce"], VMHold.quiesceTimeout)
    XCTAssertEqual(rec.timeouts["stop"], VMHold.stopTimeout)

    let root = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent()
    let plist = try String(
      contentsOf: root.appendingPathComponent(
        "launchd/com.renacode.cloudmachine.vm-start.plist.template"), encoding: .utf8)
    XCTAssertTrue(plist.contains("<string>vm-hold</string>"), "the job runs vm-hold")
    XCTAssertTrue(plist.contains("__CM_AGENT_BIN__"))
    XCTAssertFalse(plist.contains("<string>limactl</string>"), "no bare limactl start")
    XCTAssertTrue(
      plist.contains("<key>ExitTimeOut</key>\n  <integer>\(Int(VMHold.exitTimeOut))</integer>"),
      "ExitTimeOut must equal VMHold.exitTimeOut")
  }

  // MARK: - A start that does not finish in time (Mac under load)

  /// 12.11: `limactl start` gave up after 10 min ("did not receive an event
  /// with the `running` status") although the machine came up. A failed start
  /// is not a failed machine: keep asking Lima, do not stop or restart it.
  func testFailedStartIsToleratedWhileTheMachineComesUp() async {
    let rec = Recorder()
    let code = await run(
      steps(rec, start: false, statuses: ["Installing", "Installing", "Broken", "Running"]),
      terminateAfter: 0.3)
    XCTAssertEqual(code, 0)
    XCTAssertGreaterThan(rec.totalSlept, 0, "it waited between checks")
    XCTAssertEqual(rec.plain.filter { $0 == "stop" }.count, 1, "stopped once, at termination")
    XCTAssertTrue(rec.plain.contains("quiesce"))
  }

  func testWaitsLongerThanTenMinutes() async {
    let rec = Recorder()
    let code = await run(
      steps(rec, start: false, statuses: Array(repeating: "Installing", count: 100) + ["Running"]),
      terminateAfter: 1)
    XCTAssertEqual(code, 0)
    XCTAssertGreaterThan(rec.totalSlept, 20 * 60)
  }

  /// A machine that never comes up within the grace period: the job does NOT
  /// exit (nobody would hold the machine if it came up at minute 61); it keeps
  /// holding, and at termination stops whatever is not Stopped. The exit code
  /// still says that the start failed.
  func testNeverRunningKeepsHoldingAfterGraceAndStopsAtTermination() async {
    let rec = Recorder()
    let latch = TerminationLatch()
    let finished = FlagBox()
    let task = Task { () -> Int32 in
      let code = await VMHold.run(
        steps: self.steps(rec, start: false, statuses: ["Installing"]), termination: latch)
      finished.set()
      return code
    }
    while !rec.logged("holding") { try? await Task.sleep(nanoseconds: 20_000_000) }
    try? await Task.sleep(nanoseconds: 100_000_000)
    XCTAssertFalse(finished.value, "the job must not exit after the grace period")
    XCTAssertGreaterThanOrEqual(rec.totalSlept, VMHold.startGrace)
    XCTAssertFalse(rec.plain.contains("stop"), "nothing is stopped before termination")
    latch.fire()
    let code = await task.value
    XCTAssertEqual(code, 1, "the machine never came up")
    XCTAssertTrue(rec.plain.contains("stop"), "Installing is not Stopped: stopped at termination")
  }

  /// A machine that is simply Stopped after a failed start is not coming up:
  /// no point polling for an hour, but the job still holds.
  func testStoppedAfterFailedStartStopsPollingButKeepsHolding() async {
    let rec = Recorder()
    let code = await run(steps(rec, start: false, statuses: ["Stopped"]), terminateAfter: 0.2)
    XCTAssertEqual(code, 1)
    XCTAssertEqual(rec.totalSlept, 0)
    XCTAssertFalse(rec.plain.contains("stop"), "nothing to stop")
    XCTAssertTrue(rec.logged("holding"))
  }

  // MARK: - SIGTERM during the start and the waiting

  /// SIGTERM while `limactl start` runs (up to 50 minutes under load): the
  /// start is cancelled at once and the machine is stopped, not left to boot
  /// into a dying session.
  func testTerminationDuringStartCancelsTheStartAndStops() async {
    let rec = Recorder()
    let cancelled = FlagBox()
    let base = steps(rec, statuses: ["Running"])
    let hanging = VMHold.Steps(
      start: {
        rec.add("start")
        while !Task.isCancelled { try? await Task.sleep(nanoseconds: 10_000_000) }
        cancelled.set()
        return false
      },
      status: base.status, quiesce: base.quiesce, stop: base.stop,
      lastShutdown: base.lastShutdown, log: base.log, sleep: base.sleep)
    let code = await run(hanging, terminateAfter: 0.1)
    XCTAssertTrue(cancelled.value, "the start was cancelled")
    XCTAssertEqual(code, 0)
    XCTAssertEqual(rec.plain, ["start", "status", "quiesce", "stop"])
  }

  /// The waiting between status checks must not delay the stop by its length.
  func testTerminationInterruptsTheWaitBetweenChecks() async {
    let rec = Recorder()
    let base = steps(rec, start: false, statuses: ["Installing", "Running"])
    let longSleep = VMHold.Steps(
      start: base.start, status: base.status, quiesce: base.quiesce, stop: base.stop,
      lastShutdown: base.lastShutdown, log: base.log,
      sleep: { _ in try? await Task.sleep(nanoseconds: 3_600_000_000_000) })
    let began = Date()
    let code = await run(longSleep, terminateAfter: 0.1)
    XCTAssertLessThan(Date().timeIntervalSince(began), 5, "not a whole check interval")
    XCTAssertEqual(code, 0)
    XCTAssertTrue(rec.plain.contains("stop"))
  }

  /// A termination that arrived BEFORE `run` looked (the latch is a state,
  /// not an event) still counts.
  func testTerminationBeforeRunIsNotLost() async {
    let rec = Recorder()
    let latch = TerminationLatch()
    latch.fire()
    let code = await VMHold.run(steps: steps(rec), termination: latch)
    XCTAssertEqual(code, 0)
    XCTAssertTrue(rec.plain.contains("stop"))
  }

  /// The guest-side commands (their effect was tried on a throwaway machine).
  func testGuestScripts() {
    XCTAssertEqual(VMLayout.quiesceScript, "systemctl stop smbd; sync")
    // The kernel's "recovery required" decides first: a boot killed early leaves
    // no journal, and the previous journal alone then calls it clean.
    let script = VMLayout.lastShutdownScript
    XCTAssertTrue(script.contains("recovery required"))
    XCTAssertTrue(script.contains("Journal stopped"))
    XCTAssertLessThan(
      script.range(of: "recovery required")!.lowerBound,
      script.range(of: "Journal stopped")!.lowerBound)
  }

  private final class FlagBox: @unchecked Sendable {
    private let lock = NSLock()
    private var flag = false
    func set() {
      lock.lock()
      flag = true
      lock.unlock()
    }
    var value: Bool {
      lock.lock()
      defer { lock.unlock() }
      return flag
    }
  }
}
