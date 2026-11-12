import XCTest

@testable import CloudMachineCore

/// `vm-hold`: starts the machine at login and stays alive, so that launchd's
/// SIGTERM at logout/shutdown turns into a clean `limactl stop` (the machine
/// otherwise dies together with the Mac and the guest's ext4 needs recovery).
final class VMHoldTests: XCTestCase {

  /// Records the order of events.
  private final class Recorder: @unchecked Sendable {
    private let lock = NSLock()
    private var items: [String] = []
    func add(_ item: String) { lock.lock(); items.append(item); lock.unlock() }
    var events: [String] { lock.lock(); defer { lock.unlock() }; return items }
  }

  private func steps(
    _ rec: Recorder, start: Bool = true, status: String? = "Running", stop: Bool = true
  ) -> VMHold.Steps {
    VMHold.Steps(
      start: { rec.add("start"); return start },
      status: { rec.add("status"); return status },
      stop: { rec.add("stop"); return stop },
      log: { rec.add("log: \($0)") })
  }

  func testStartsThenWaitsThenStopsOnTermination() async {
    let rec = Recorder()
    let code = await VMHold.run(
      steps: steps(rec), awaitTermination: { rec.add("wait") })
    XCTAssertEqual(code, 0)
    let order = rec.events.filter { !$0.hasPrefix("log") }
    XCTAssertEqual(order, ["start", "wait", "status", "stop"])
  }

  /// A failed start is a failure of the job, and there is nothing to stop.
  func testFailedStartExitsNonZeroWithoutWaitingOrStopping() async {
    let rec = Recorder()
    let code = await VMHold.run(
      steps: steps(rec, start: false, status: "Stopped"), awaitTermination: { rec.add("wait") })
    XCTAssertEqual(code, 1)
    // Start failed, Lima says the machine is not there: not slow, failed.
    XCTAssertEqual(rec.events.filter { !$0.hasPrefix("log") }, ["start", "status"])
  }

  /// The machine was already stopped (the app's Stop, prepare-shutdown):
  /// `limactl stop` on it would only fail.
  func testDoesNotStopAMachineThatIsNotRunning() async {
    for status in ["Stopped", nil] as [String?] {
      let rec = Recorder()
      let code = await VMHold.run(
        steps: steps(rec, status: status), awaitTermination: {})
      XCTAssertEqual(code, 0)
      XCTAssertFalse(rec.events.contains("stop"), "status \(String(describing: status))")
    }
  }

  /// A stop that fails must be visible (exit code and log), not swallowed.
  func testFailedStopIsReported() async {
    let rec = Recorder()
    let code = await VMHold.run(steps: steps(rec, stop: false), awaitTermination: {})
    XCTAssertEqual(code, 1)
    XCTAssertTrue(rec.events.contains { $0.hasPrefix("log") && $0.contains("stop") })
  }

  /// When Lima does not answer about the status we still try to stop: a
  /// machine left running is worse than a failed `limactl stop`.
  func testUnknownStatusStillStops() async {
    let rec = Recorder()
    let steps = VMHold.Steps(
      start: { true }, status: { throw ProcessRunnerError.launchFailed("x") },
      stop: { rec.add("stop"); return true }, log: { _ in })
    let code = await VMHold.run(steps: steps, awaitTermination: {})
    XCTAssertEqual(code, 0)
    XCTAssertTrue(rec.events.contains("stop"))
  }

  // MARK: - Slow start (Mac under load)

  /// Statuses answered one per call; the last one repeats. Records sleeps.
  private final class Script: @unchecked Sendable {
    private let lock = NSLock()
    private var statuses: [String?]
    private(set) var slept: TimeInterval = 0
    private(set) var stopCalls = 0
    init(_ statuses: [String?]) { self.statuses = statuses }
    func next() -> String? {
      lock.lock(); defer { lock.unlock() }
      return statuses.count > 1 ? statuses.removeFirst() : statuses[0]
    }
    func sleep(_ t: TimeInterval) { lock.lock(); slept += t; lock.unlock() }
    func stopped() { lock.lock(); stopCalls += 1; lock.unlock() }
  }

  private func slowSteps(_ script: Script, startSucceeds: Bool) -> VMHold.Steps {
    VMHold.Steps(
      start: { startSucceeds },
      status: { script.next() },
      stop: { script.stopped(); return true },
      log: { _ in },
      sleep: { script.sleep($0) })
  }

  /// 12.11: `limactl start` gave up after 10 min ("did not receive an event
  /// with the `running` status") although the machine came up. A failed start
  /// is not a failed machine: keep asking Lima, do not stop or restart it.
  func testFailedStartIsToleratedWhileTheMachineComesUp() async {
    let script = Script(["Starting", "Starting", "Starting", "Running"])
    let code = await VMHold.run(
      steps: slowSteps(script, startSucceeds: false), awaitTermination: {})
    XCTAssertEqual(code, 0)
    XCTAssertGreaterThan(script.slept, 0, "it waited between checks")
    // 3 "Starting" + 1 "Running" while waiting, then the status at shutdown.
    XCTAssertEqual(script.stopCalls, 1, "stopped once, at termination - never during the wait")
  }

  func testWaitsLongerThanTenMinutes() async {
    let script = Script(Array(repeating: "Starting", count: 100) + ["Running"])
    let code = await VMHold.run(
      steps: slowSteps(script, startSucceeds: false), awaitTermination: {})
    XCTAssertEqual(code, 0)
    XCTAssertGreaterThan(script.slept, 20 * 60)
  }

  /// A machine that never comes up within the grace period is a failure of
  /// the job - but even then the machine is left alone (no stop, no kill).
  func testNeverRunningFailsAfterGraceWithoutStopping() async {
    let script = Script(["Starting"])
    let code = await VMHold.run(
      steps: slowSteps(script, startSucceeds: false), awaitTermination: {})
    XCTAssertEqual(code, 1)
    XCTAssertEqual(script.stopCalls, 0)
    XCTAssertGreaterThanOrEqual(script.slept, VMHold.startGrace)
  }

  /// A SIGTERM during the wait ends it at once.
  func testTerminationDuringStartEndsTheWait() async {
    let script = Script(["Starting"])
    let code = await VMHold.run(
      steps: slowSteps(script, startSucceeds: false), awaitTermination: {},
      terminated: { true })
    XCTAssertEqual(script.slept, 0)
    XCTAssertEqual(code, 0)
    XCTAssertEqual(script.stopCalls, 0, "not Running: nothing to stop")
  }

  /// launchd sends SIGKILL ExitTimeOut seconds after SIGTERM: the stop's own
  /// limit must fit inside it, and the plist must ask for that much.
  func testStopLimitFitsInsideLaunchdExitTimeout() throws {
    XCTAssertGreaterThanOrEqual(VMHold.exitTimeOut, VMHold.stopTimeout + 10)
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
}
