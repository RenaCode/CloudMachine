import Foundation

/// `vm-hold`: the launchd job behind the machine.
///
/// Before, the job was `limactl start`, which exits once the machine is up.
/// Nothing then stopped the machine when the Mac logged out or shut down: the
/// Lima host agent died with the session, the guest lost power, and ext4 (and
/// the Time Machine image on top of it) had to recover from a hard stop.
///
/// Now the job starts the machine and stays alive, whatever happens to the
/// start. launchd sends SIGTERM when the job is stopped (logout, shutdown,
/// `launchctl bootout`) and waits `ExitTimeOut` seconds before SIGKILL; on
/// SIGTERM this stops EVERYTHING that is not already Stopped: it asks the
/// guest to stop smbd and sync (Lima's vz driver waits for the guest only 30 s
/// in `limactl stop`, which is too little for a Samba with open files and a
/// dirty cache disk), then `limactl stop` (RequestStop, never a forced stop)
/// so systemd stops punchfs and rclone in order.
public enum VMHold {
  // The stop sequence after SIGTERM is status, quiesce, stop, one after
  // another. Each limit is that of its `ProcessRunner` call, which can give up
  // `ProcessRunner.giveUpSlack` seconds later; `stopSequenceWorstCase` adds it
  // up and a test keeps it inside `exitTimeOut`.
  public static let statusTimeout: TimeInterval = 10
  public static let quiesceTimeout: TimeInterval = 15
  public static let stopTimeout: TimeInterval = 55
  /// `ExitTimeOut` in the launchd template. A test keeps the template and this
  /// value together.
  public static let exitTimeOut: TimeInterval = 120
  public static var stopSequenceWorstCase: TimeInterval {
    [statusTimeout, quiesceTimeout, stopTimeout].reduce(0) {
      $0 + $1 + ProcessRunner.giveUpSlack
    }
  }

  /// A start cancelled by SIGTERM may take `cancelKillDelay` seconds to end
  /// (SIGTERM, then SIGKILL) before the stop sequence begins.
  public static var shutdownWorstCase: TimeInterval {
    ProcessRunner.cancelKillDelay + stopSequenceWorstCase
  }

  /// How long a machine that `limactl start` gave up on may still take to
  /// come up. The Mac often runs under a load of ~100-200 (renders); on 12.11
  /// `limactl start` failed with "did not receive an event with the `running`
  /// status" after 10 min and the machine was up a little later.
  public static let startGrace: TimeInterval = 60 * 60
  static let checkInterval: TimeInterval = 30
  /// The status check while waiting for a start is not on the SIGTERM clock.
  static let waitStatusTimeout: TimeInterval = 60

  /// The effects, injected so the order of events is testable.
  public struct Steps: Sendable {
    /// `limactl start`; ends (false) when its task is cancelled.
    public var start: @Sendable () async -> Bool
    /// Lima's status of the instance (Running, Stopped, Broken, Installing,
    /// Uninitialized, "") or `nil` when there is none; throws when Lima does
    /// not answer within the given time.
    public var status: @Sendable (TimeInterval) async throws -> String?
    /// In the guest: stop smbd and sync, so that nothing is open and nothing
    /// is dirty when the power goes.
    public var quiesce: @Sendable (TimeInterval) async -> Bool
    public var stop: @Sendable (TimeInterval) async -> Bool
    /// After a start: how did the previous boot end? (one line for the log)
    public var lastShutdown: @Sendable () async -> String?
    public var log: @Sendable (String) -> Void
    public var sleep: @Sendable (TimeInterval) async -> Void

    public init(
      start: @escaping @Sendable () async -> Bool,
      status: @escaping @Sendable (TimeInterval) async throws -> String?,
      quiesce: @escaping @Sendable (TimeInterval) async -> Bool = { _ in true },
      stop: @escaping @Sendable (TimeInterval) async -> Bool,
      lastShutdown: @escaping @Sendable () async -> String? = { nil },
      log: @escaping @Sendable (String) -> Void,
      sleep: @escaping @Sendable (TimeInterval) async -> Void = {
        try? await Task.sleep(nanoseconds: UInt64($0 * 1_000_000_000))
      }
    ) {
      self.start = start
      self.status = status
      self.quiesce = quiesce
      self.stop = stop
      self.lastShutdown = lastShutdown
      self.log = log
      self.sleep = sleep
    }
  }

  /// The result of `op`, or `nil` when termination came first (and `op` was
  /// cancelled, which for a process kills it).
  static func interruptible<T: Sendable>(
    _ latch: TerminationLatch, _ op: @escaping @Sendable () async -> T
  ) async -> T? {
    await withTaskGroup(of: T?.self) { group in
      group.addTask { await op() }
      group.addTask {
        await latch.wait()
        return nil
      }
      let first = await group.next() ?? nil
      group.cancelAll()
      return first
    }
  }

  enum StartOutcome { case up, neverCameUp, terminated }

  private enum Answer: Sendable {
    case status(String?)
    case unreachable(String)
  }

  private static func ask(_ steps: Steps, timeout: TimeInterval) async -> Answer {
    do { return .status(try await steps.status(timeout)) } catch { return .unreachable("\(error)") }
  }

  /// After a failed `limactl start`: is the machine coming up anyway? Waits
  /// while Lima says anything but Stopped/missing, or does not answer. Never
  /// touches the machine.
  static func waitForStart(steps: Steps, termination: TerminationLatch) async -> StartOutcome {
    var waited: TimeInterval = 0
    while true {
      guard
        let answer = await interruptible(
          termination, { await ask(steps, timeout: waitStatusTimeout) })
      else { return .terminated }
      var seen = "not answering"
      switch answer {
      case .status("Running"): return .up
      case .status(nil), .status("Stopped"): return .neverCameUp  // nothing is coming up
      case .status(let status?): seen = status.isEmpty ? "in an unknown state" : status
      case .unreachable: break  // Lima busy or slow under load: ask again
      }
      if waited >= startGrace { return .neverCameUp }
      steps.log("vm-hold: limactl start did not finish; the machine is \(seen); waiting")
      guard await interruptible(termination, { await steps.sleep(checkInterval) }) != nil
      else { return .terminated }
      waited += checkInterval
    }
  }

  /// The exit code of the job: 0 when the machine was started and then
  /// stopped (or was already stopped), 1 when it never came up or did not stop.
  public static func run(steps: Steps, termination: TerminationLatch) async -> Int32 {
    var neverCameUp = false
    if let started = await interruptible(termination, { await steps.start() }) {
      var outcome = StartOutcome.up
      if !started {
        steps.log("vm-hold: limactl start failed; checking whether the machine comes up anyway")
        outcome = await waitForStart(steps: steps, termination: termination)
      }
      switch outcome {
      case .up:
        if let line = await interruptible(termination, { await steps.lastShutdown() }), let line {
          steps.log("vm-hold: \(line)")
        }
        steps.log("vm-hold: the machine is up, waiting for the job to be stopped")
        await termination.wait()
      case .neverCameUp:
        // Do not exit: nobody would hold the machine if it came up later, and
        // an exit would leave a half-started one to die hard with the Mac.
        neverCameUp = true
        steps.log(
          "vm-hold: the machine did not come up; holding anyway, whatever runs is stopped at termination"
        )
        await termination.wait()
      case .terminated:
        break
      }
    } else {
      steps.log("vm-hold: terminated during limactl start; stopping whatever started")
    }

    let stopped = await stopMachine(steps: steps)
    return stopped && !neverCameUp ? 0 : 1
  }

  /// After SIGTERM. Everything that is not Stopped gets stopped, a machine in
  /// a state we do not know included (Lima's statuses: Running, Stopped,
  /// Broken, Installing, Uninitialized, ""): one that is left alone dies hard
  /// with the Mac. Returns false only when the stop itself failed.
  static func stopMachine(steps: Steps) async -> Bool {
    var guestMayAnswer = true
    switch await ask(steps, timeout: statusTimeout) {
    case .status(nil):
      steps.log("vm-hold: the machine is missing, nothing to stop")
      return true
    case .status("Stopped"):
      steps.log("vm-hold: the machine is stopped, nothing to stop")
      return true
    case .status("Running"):
      break
    case .status(let other?):
      steps.log("vm-hold: the machine is '\(other)'; stopping it anyway")
      guestMayAnswer = false
    case .unreachable(let why):
      // A machine left running is worse than a failed `limactl stop`.
      steps.log("vm-hold: Lima did not answer about the status (\(why)), stopping anyway")
    }
    if guestMayAnswer {
      if await steps.quiesce(quiesceTimeout) {
        steps.log("vm-hold: smbd stopped and the guest synced")
      } else {
        steps.log("vm-hold: could not quiesce the guest (smbd, sync); stopping it regardless")
      }
    }
    steps.log("vm-hold: stopping the machine")
    guard await steps.stop(stopTimeout) else {
      steps.log("vm-hold: limactl stop failed or ran out of time")
      return false
    }
    steps.log("vm-hold: the machine is stopped")
    return true
  }

  /// The real effects.
  public static var live: Steps {
    Steps(
      start: { await VMLayout.start().succeeded },
      status: { try await VMLayout.instanceStatus(timeout: $0) },
      quiesce: { await VMLayout.quiesceGuest(timeout: $0) },
      stop: { timeout in
        let result = try? await VMLayout.limactl(
          ["stop", VMLayout.instanceName], timeout: timeout)
        return result?.succeeded == true
      },
      lastShutdown: { await VMLayout.lastShutdownSummary() },
      log: { CMLogger.log($0) })
  }
}
