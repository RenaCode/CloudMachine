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
      steps: steps(rec, start: false), awaitTermination: { rec.add("wait") })
    XCTAssertEqual(code, 1)
    XCTAssertEqual(rec.events.filter { !$0.hasPrefix("log") }, ["start"])
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
