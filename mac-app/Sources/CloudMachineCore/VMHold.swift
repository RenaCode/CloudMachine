import Foundation

/// `vm-hold`: the launchd job behind the machine.
///
/// Before, the job was `limactl start`, which exits once the machine is up.
/// Nothing then stopped the machine when the Mac logged out or shut down: the
/// Lima host agent died with the session, the guest lost power, and ext4 (and
/// the Time Machine image on top of it) had to recover from a hard stop.
///
/// Now the job starts the machine and stays alive. launchd sends SIGTERM when
/// the job is stopped (logout, shutdown, `launchctl bootout`) and waits
/// `ExitTimeOut` seconds before SIGKILL; on SIGTERM this runs `limactl stop`,
/// which asks the guest to power off (Lima's vz driver: RequestStop, up to 30 s,
/// never a forced stop) so systemd stops smbd, punchfs and rclone in order.
public enum VMHold {
  /// Limit of the `limactl stop` itself.
  public static let stopTimeout: TimeInterval = 100
  /// `ExitTimeOut` in the launchd template: the stop plus a margin. A test
  /// keeps the template and this value together.
  public static let exitTimeOut: TimeInterval = 120

  /// The effects, injected so the order of events is testable.
  public struct Steps: Sendable {
    public var start: @Sendable () async -> Bool
    public var status: @Sendable () async throws -> String?
    public var stop: @Sendable () async -> Bool
    public var log: @Sendable (String) -> Void
    public var sleep: @Sendable (TimeInterval) async -> Void

    public init(
      start: @escaping @Sendable () async -> Bool,
      status: @escaping @Sendable () async throws -> String?,
      stop: @escaping @Sendable () async -> Bool,
      log: @escaping @Sendable (String) -> Void,
      sleep: @escaping @Sendable (TimeInterval) async -> Void = {
        try? await Task.sleep(nanoseconds: UInt64($0 * 1_000_000_000))
      }
    ) {
      self.start = start
      self.status = status
      self.stop = stop
      self.log = log
      self.sleep = sleep
    }
  }

  /// How long a machine that `limactl start` gave up on may still take to
  /// come up. The Mac often runs under a load of ~100 (renders); on 12.11
  /// `limactl start` failed with "did not receive an event with the `running`
  /// status" after 10 min and the machine was up a little later.
  public static let startGrace: TimeInterval = 60 * 60
  static let checkInterval: TimeInterval = 30

  enum StartOutcome { case up, failed, terminated }

  /// After a failed `limactl start`: is the machine coming up? Waits while
  /// Lima says anything but gone/stopped/broken, or does not answer. Never
  /// touches the machine.
  static func waitForStart(
    steps: Steps, terminated: @Sendable () -> Bool
  ) async -> StartOutcome {
    var waited: TimeInterval = 0
    var seen = "unknown"
    while true {
      do {
        let status = try await steps.status()
        if status == "Running" { return .up }
        guard let status, !["Stopped", "Broken"].contains(status) else { return .failed }
        seen = status
      } catch {
        seen = "unreachable"  // Lima busy or slow under load: ask again
      }
      if terminated() { return .terminated }
      if waited >= startGrace { return .failed }
      steps.log("vm-hold: start did not finish, the machine is \(seen); waiting")
      await steps.sleep(checkInterval)
      waited += checkInterval
    }
  }

  /// The exit code of the job: 0 when the machine was started and then
  /// stopped (or was already stopped), 1 when it did not start or did not stop.
  public static func run(
    steps: Steps, awaitTermination: @Sendable () async -> Void,
    terminated: @Sendable () -> Bool = { false }
  ) async -> Int32 {
    var outcome = StartOutcome.up
    if await !steps.start() {
      steps.log("vm-hold: limactl start failed; checking whether the machine comes up anyway")
      outcome = await waitForStart(steps: steps, terminated: terminated)
    }
    switch outcome {
    case .failed:
      steps.log("vm-hold: the machine did not start")
      return 1
    case .up:
      steps.log("vm-hold: the machine is up, waiting for the job to be stopped")
      await awaitTermination()
    case .terminated:
      break
    }

    // `nil` = no such instance. When Lima does not answer we cannot tell, and
    // a machine left running is worse than a failed `limactl stop`, so we stop.
    do {
      let status = try await steps.status()
      if status != "Running" {
        steps.log("vm-hold: the machine is \(status ?? "missing"), nothing to stop")
        return 0
      }
    } catch {
      steps.log("vm-hold: Lima did not answer about the status (\(error)), stopping anyway")
    }
    steps.log("vm-hold: stopping the machine")
    guard await steps.stop() else {
      steps.log("vm-hold: limactl stop failed or ran out of time")
      return 1
    }
    steps.log("vm-hold: the machine is stopped")
    return 0
  }

  /// The real effects.
  public static var live: Steps {
    Steps(
      start: { await VMLayout.start().succeeded },
      status: { try await VMLayout.instanceStatus() },
      stop: {
        let result = try? await VMLayout.limactl(
          ["stop", VMLayout.instanceName], timeout: stopTimeout)
        return result?.succeeded == true
      },
      log: { CMLogger.log($0) })
  }
}
