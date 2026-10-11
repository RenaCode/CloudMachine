import Foundation

/// Tells the user, by a system notification, that the Drive mount still
/// takes commands on the open TCP port (see
/// `DriveBufferService.legacyPortOpen`).
///
/// Not a `HealthAlert` problem, on purpose. Backups work in this state, so
/// "CloudMachine: backup is not working" would be false, `backup-health`
/// would exit 1 for a working cycle, and the 12-hour reminder would turn a
/// state that lasts until the next restart of the Mac into noise.
///
/// Instead: once at once, then with a growing gap - 1, 2, 4 and then every 7
/// days. A notice that never comes back is forgotten after one dismissal; one
/// that comes back twice a day is muted. A notification that was not
/// delivered is retried at the next watchdog run, as in `HealthAlert`.
public enum OpenPortAlert {

  public static var stateFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("open-port-alert.json")
  }

  struct State: Codable, Equatable {
    /// Notifications delivered so far for this episode.
    var delivered: Int
    var lastAttemptAt: Date
    var lastDelivered: Bool
  }

  /// The gap after the `count`-th delivered notification.
  static func gap(afterDelivered count: Int) -> TimeInterval {
    let days = min(7.0, pow(2.0, Double(max(0, count - 1))))
    return days * 86_400
  }

  static func shouldNotify(_ state: State?, now: Date) -> Bool {
    guard let state else { return true }
    if !state.lastDelivered { return true }
    return now.timeIntervalSince(state.lastAttemptAt) >= gap(afterDelivered: state.delivered)
  }

  /// Reports the open port if it is time to. `open == false` ends the
  /// episode: the state is removed, so a later one is reported at once.
  /// Returns `true` when a notification was delivered.
  ///
  /// `stateFile`, `deliver` and `log` are replaceable for the reason given at
  /// `HealthAlert.report`: tests must not write to the user's directory, show
  /// notifications or add made-up lines to the real log.
  @discardableResult
  public static func report(
    open: Bool,
    now: Date = Date(),
    stateFile: URL = OpenPortAlert.stateFile,
    deliver: @Sendable (String, String) async -> Bool = {
      await HealthAlert.notify(title: $0, message: $1)
    },
    log: @Sendable (String) -> Void = { CMLogger.log($0) }
  ) async -> Bool {
    guard open else {
      try? FileManager.default.removeItem(at: stateFile)
      return false
    }
    let state = load(stateFile)
    guard shouldNotify(state, now: now) else { return false }

    log(
      "SECURITY: rclone remote control is OPEN on \(DriveBufferService.legacyRCAddress) without a password - the mount predates the private socket. Restart the mount (window or restart-mount), or prepare-shutdown and restart the Mac."
    )
    let delivered = await deliver(
      L10n.tr("CloudMachine: Drive remote control is open"),
      L10n.tr(
        "Any web page can send it commands, including deleting the backup. Open CloudMachine and restart the mount, or run prepare-shutdown and restart the Mac."
      ))
    if !delivered {
      log("FAILED to show the open-port notification; will retry at the next check.")
    }
    let next = State(
      delivered: (state?.delivered ?? 0) + (delivered ? 1 : 0), lastAttemptAt: now,
      lastDelivered: delivered)
    if let data = try? JSONEncoder().encode(next) {
      try? data.write(to: stateFile, options: .atomic)
    }
    return delivered
  }

  static func load(_ file: URL) -> State? {
    guard let data = try? Data(contentsOf: file) else { return nil }
    return try? JSONDecoder().decode(State.self, from: data)
  }
}
