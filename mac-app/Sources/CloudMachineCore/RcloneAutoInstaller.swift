import Foundation

/// What `rclone version` says, as numbers.
public enum RcloneVersion {
  /// The oldest rclone CloudMachine is used with. Older builds lack
  /// options the machine's mount and the usage measurement rely on.
  public static let minimum = [1, 65, 0]

  /// `[1, 75, 1]` from `rclone v1.75.1` (the first line of the output;
  /// suffixes such as `-beta.1` are ignored). `nil` when there is no number.
  public static func parse(_ output: String) -> [Int]? {
    guard let line = output.split(separator: "\n").first else { return nil }
    let words = line.split(separator: " ")
    guard words.count >= 2, words[0] == "rclone", words[1].hasPrefix("v") else { return nil }
    let numbers = words[1].dropFirst().split(separator: "-").first ?? ""
    let parts = numbers.split(separator: ".").compactMap { Int($0) }
    guard parts.count == numbers.split(separator: ".").count, parts.count >= 3 else { return nil }
    return Array(parts.prefix(3))
  }

  /// An unreadable answer is not acceptable: a binary that cannot say what
  /// it is (wrong architecture, damaged) is replaced.
  public static func isAcceptable(output: String) -> Bool {
    guard let version = parse(output) else { return false }
    return version.lexicographicallyPrecedes(minimum) == false
  }
}

public enum ToolInstallState: Equatable {
  /// Nothing to report: rclone is fine, or the first check has not run.
  case idle
  case installing
  /// The last install worked.
  case installed
  /// The last install failed; the next attempt is at `retryAt`.
  case failed(String, retryAt: Date)
}

/// Keeps rclone present and recent without anyone clicking: checked at app
/// start and then every hour, installed with the same SHA256-verified
/// `RcloneInstaller.install()` that `install-rclone` uses.
///
/// There is no retry button. A failure (no network, wrong checksum) waits for
/// the next hourly check, so a problem someone has to fix never turns into a
/// loop hammering the download server. The window only shows the state.
@MainActor
public final class RcloneAutoInstaller: ObservableObject {
  public static let checkInterval: TimeInterval = 3600

  @Published public private(set) var state: ToolInstallState = .idle {
    didSet { if state != oldValue { onChange?(state) } }
  }
  /// The binary on disk is missing, too old or unreadable and not yet
  /// replaced - it must not count as "rclone is there".
  public private(set) var replacementNeeded = false
  /// Called on every change of `state`.
  public var onChange: ((ToolInstallState) -> Void)?

  private let needsInstall: () async -> Bool
  private let install: () async -> CMActionResult
  private let now: () -> Date
  private var nextCheck: Date?
  private var checking = false

  public init(
    needsInstall: @escaping () async -> Bool, install: @escaping () async -> CMActionResult,
    now: @escaping () -> Date = Date.init
  ) {
    self.needsInstall = needsInstall
    self.install = install
    self.now = now
  }

  /// The real checks: the managed binary, and the version it reports.
  public static func live() -> RcloneAutoInstaller {
    RcloneAutoInstaller(
      needsInstall: {
        let exists = CMTooling.hasManagedRclone
        var output: String?
        if exists {
          // A single slow or failed probe (machine under load) must not
          // replace a working binary: ask twice.
          for _ in 0..<2 where output == nil {
            output = (try? await CMTooling.runRclone(["version"], timeout: 30))
              .flatMap { $0.succeeded ? $0.stdout : nil }
          }
        }
        return needsInstall(binaryExists: exists, versionOutput: output)
      },
      install: { await RcloneInstaller.install() })
  }

  public nonisolated static func needsInstall(binaryExists: Bool, versionOutput: String?) -> Bool {
    guard binaryExists, let output = versionOutput else { return true }
    return !RcloneVersion.isAcceptable(output: output)
  }

  /// The binary vanished between checks: make the next `tick` check at once.
  /// Not after a failure - that wait stays an hour, so nothing loops.
  public func checkNow() {
    if case .failed = state { return }
    nextCheck = nil
  }

  /// Call as often as you like (the refresh loop does): it acts only when
  /// the hourly check is due, and never while an install runs.
  public func tick() async {
    guard state != .installing, !checking else { return }
    let start = now()
    if let nextCheck, start < nextCheck { return }
    nextCheck = start.addingTimeInterval(Self.checkInterval)
    checking = true
    let needed = await needsInstall()
    checking = false
    guard needed else {
      replacementNeeded = false
      if case .failed = state { state = .idle }
      return
    }
    replacementNeeded = true
    state = .installing
    let result = await install()
    CMLogger.log("[auto] rclone install: \(result.succeeded ? "ok" : "failed") - \(result.message)")
    if result.succeeded {
      replacementNeeded = false
      state = .installed
    } else {
      // The wait counts from the end of the attempt, not its start.
      let end = now()
      nextCheck = end.addingTimeInterval(Self.checkInterval)
      state = .failed(result.message, retryAt: end.addingTimeInterval(Self.checkInterval))
    }
  }
}
