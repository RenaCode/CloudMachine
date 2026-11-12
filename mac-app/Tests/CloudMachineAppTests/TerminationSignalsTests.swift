import XCTest

@testable import CloudMachineCore

/// What turns launchd's SIGTERM into `TerminationLatch.fire()`, and what it
/// must not do to the processes `vm-hold` starts.
final class TerminationSignalsTests: XCTestCase {

  // MARK: - TerminationLatch

  func testWaitReturnsAfterFire() async {
    let latch = TerminationLatch()
    Task {
      try? await Task.sleep(nanoseconds: 50_000_000)
      latch.fire()
    }
    await latch.wait()
    XCTAssertTrue(latch.hasArrived)
  }

  func testWaitReturnsAtOnceWhenAlreadyFired() async {
    let latch = TerminationLatch()
    latch.fire()
    await latch.wait()
  }

  func testEveryWaiterIsReleased() async {
    let latch = TerminationLatch()
    async let a: Void = latch.wait()
    async let b: Void = latch.wait()
    try? await Task.sleep(nanoseconds: 50_000_000)
    latch.fire()
    _ = await (a, b)
  }

  /// Without this a race between "the start finished" and "SIGTERM" would hang
  /// the job: the waiter that lost the race has to end when it is cancelled.
  func testWaitEndsWhenTheWaiterIsCancelled() async {
    let latch = TerminationLatch()
    let task = Task { await latch.wait() }
    try? await Task.sleep(nanoseconds: 50_000_000)
    task.cancel()
    await task.value
    XCTAssertFalse(latch.hasArrived, "cancelling is not a termination")
  }

  // MARK: - Signals

  /// A caught signal fires the latch.
  func testSignalFiresTheLatch() async throws {
    let signals = TerminationSignals(signals: [SIGUSR2])
    defer { signals.uninstall() }
    XCTAssertFalse(signals.latch.hasArrived)
    kill(getpid(), SIGUSR2)
    let latch = signals.latch
    let waited = Task { await latch.wait() }
    let timeout = Task {
      try await Task.sleep(nanoseconds: 5_000_000_000)
      waited.cancel()
    }
    await waited.value
    timeout.cancel()
    XCTAssertTrue(latch.hasArrived, "the signal did not arrive within 5 s")
  }

  /// Ignoring a signal (`SIG_IGN`) is inherited through fork AND exec: the
  /// first version of `vm-hold` ignored SIGTERM, so `limactl` and its host
  /// agent ignored it too and `Process.terminate()` did nothing to them. The
  /// handler must be a real handler, which exec resets to the default.
  func testChildProcessesDoNotInheritAnIgnoredSignal() async throws {
    // Detector first: with SIG_IGN the child DOES inherit it and survives.
    let previous = signal(SIGUSR2, SIG_IGN)
    let ignoring = try childSurvivesSIGUSR2()
    signal(SIGUSR2, previous)
    XCTAssertTrue(ignoring, "the check cannot see an inherited SIG_IGN")

    let signals = TerminationSignals(signals: [SIGUSR2])
    defer { signals.uninstall() }
    let survives = try childSurvivesSIGUSR2()
    XCTAssertFalse(survives, "a child inherited an ignored SIGUSR2")
  }

  /// A fresh child sends itself SIGUSR2 (default action: terminate). It prints
  /// "survived" only if the signal was ignored. Spawned with plain
  /// `posix_spawn` and no signal attributes: Foundation's `Process` happens to
  /// reset dispositions itself, which would hide the inheritance this test is
  /// about (macOS `ps` has no ignored-mask column to look at instead).
  private func childSurvivesSIGUSR2() throws -> Bool {
    let out = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-sig-\(UUID().uuidString)").path
    defer { try? FileManager.default.removeItem(atPath: out) }
    var actions: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&actions)
    defer { posix_spawn_file_actions_destroy(&actions) }
    posix_spawn_file_actions_addopen(&actions, 1, out, O_WRONLY | O_CREAT | O_TRUNC, 0o600)
    // Only the signal MASK is cleared (a worker thread may have signals blocked,
    // which a child would inherit and which would look like "ignored");
    // dispositions are left as they are.
    var attrs: posix_spawnattr_t?
    posix_spawnattr_init(&attrs)
    defer { posix_spawnattr_destroy(&attrs) }
    var empty = sigset_t()
    sigemptyset(&empty)
    posix_spawnattr_setsigmask(&attrs, &empty)
    posix_spawnattr_setflags(&attrs, Int16(POSIX_SPAWN_SETSIGMASK))
    var pid: pid_t = 0
    let argv: [String] = ["sh", "-c", "kill -USR2 $$; echo survived"]
    var cArgs: [UnsafeMutablePointer<CChar>?] = argv.map { strdup($0) } + [nil]
    defer { for p in cArgs { free(p) } }
    guard posix_spawn(&pid, "/bin/sh", &actions, &attrs, &cArgs, environ) == 0 else {
      throw XCTSkip("posix_spawn failed")
    }
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return (try? String(contentsOfFile: out, encoding: .utf8))?.contains("survived") == true
  }

  // MARK: - Cancelling a running process

  /// `limactl start` can run for up to 50 minutes; SIGTERM must end it. A
  /// cancelled task terminates the child instead of waiting for it.
  func testCancellingTheTaskTerminatesTheProcess() async {
    let began = Date()
    let task = Task { try await ProcessRunner.run("/bin/sleep", ["60"]) }
    try? await Task.sleep(nanoseconds: 300_000_000)
    task.cancel()
    let result = try? await task.value
    XCTAssertLessThan(Date().timeIntervalSince(began), 10)
    XCTAssertNotEqual(result?.exitCode, 0, "the process was ended by the signal")
  }

  /// A process that ignores SIGTERM must not hold the job past launchd's
  /// ExitTimeOut: after `cancelKillDelay` it gets SIGKILL.
  func testCancellingEscalatesToKillForAProcessThatIgnoresSIGTERM() async {
    let began = Date()
    let task = Task {
      try await ProcessRunner.run("/bin/sh", ["-c", "trap '' TERM; exec /bin/sleep 60"])
    }
    try? await Task.sleep(nanoseconds: 500_000_000)
    task.cancel()
    let result = try? await task.value
    let took = Date().timeIntervalSince(began)
    XCTAssertLessThan(took, ProcessRunner.cancelKillDelay + 10)
    XCTAssertNotEqual(result?.exitCode, 0)
    XCTAssertGreaterThanOrEqual(took, 0.5)
  }
}
