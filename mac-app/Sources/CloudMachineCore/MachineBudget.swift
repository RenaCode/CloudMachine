import Foundation

/// How much of the Google Drive account this Mac may use.
///
/// The limit is stored per Mac in `machines.json` (`limit_gb`, keyed by this
/// Mac's Drive folder) and acts in two ways:
///
/// - **Time Machine quota.** Time Machine keeps a destination under its quota
///   by deleting the oldest backups. The quota is set below the limit, because
///   the image on Drive is larger than the backup inside it: freed blocks are
///   never returned to the band files (29 Sep 2026: 417 GiB of data in 589 GiB
///   of bands, 71%). Setting it needs root, so the app offers the command.
/// - **An alarm on the real usage**: the size of this Mac's folder on Drive,
///   measured with `rclone size`, compared with the limit. The watchdog warns
///   from 90% and reports a failure above 100%. Nothing is deleted by it.
///
/// Until 6 Oct 2026 `limit_gb` was read and never used, while the README
/// described per-machine budgets; several Macs on one account simply shared
/// whatever space was left.
public enum MachineBudget {
  /// Share of the limit given to Time Machine as its quota - see above.
  public static let timeMachineQuotaShare = 0.7
  public static let warnPercent = 90
  /// Measuring lists every band through the Drive API (~20 requests for
  /// 19,000 files), so a measurement is reused for this long.
  public static let measurementMaxAge: TimeInterval = 6 * 3600

  // MARK: - The limit

  /// The limit of the Mac whose folder is `folder`, if one is set.
  public static func limitGB(in config: MachinesConfig, folder: String = DriveFolder.name) -> Int? {
    guard let limit = config.limitGB(forMachineKey: folder), limit > 0 else { return nil }
    return limit
  }

  public static func limitGB() -> Int? { limitGB(in: ConfigStore.load()) }

  /// Stores the limit for this Mac. Refuses to touch a `machines.json` that
  /// cannot be read: rewriting it would throw away the other entries.
  public static func setLimitGB(_ gb: Int, folder: String = DriveFolder.name) throws {
    guard gb > 0 else { throw BudgetError.invalidLimit }
    var config: MachinesConfig
    switch ConfigStore.loadResult() {
    case .loaded(let loaded): config = loaded
    case .missing: config = .empty
    case .corrupt: throw BudgetError.configUnreadable
    }
    config = withLimit(gb, folder: folder, in: config)
    try ConfigStore.save(config)
    CMLogger.log("Space limit for Drive folder '\(folder)' set to \(gb) GB")
  }

  static func withLimit(_ gb: Int, folder: String, in config: MachinesConfig) -> MachinesConfig {
    var config = config
    if let index = config.machines.firstIndex(where: { $0.key == folder }) {
      config.machines[index].limitGB = gb
    } else {
      config.machines.append(MachineEntry(key: folder, displayName: folder, limitGB: gb))
    }
    return config
  }

  public enum BudgetError: Error, Equatable {
    case invalidLimit
    case configUnreadable

    public var message: String {
      switch self {
      case .invalidLimit: return L10n.tr("The limit must be a whole number of GB above zero.")
      case .configUnreadable:
        return L10n.tr(
          "machines.json cannot be read, so it was not overwritten. Fix or remove it first.")
      }
    }
  }

  /// The Time Machine quota that goes with a limit.
  public static func timeMachineQuotaGB(forLimitGB limit: Int) -> Int {
    max(1, Int((Double(limit) * timeMachineQuotaShare).rounded(.down)))
  }

  /// `sudo tmutil setquota <destination> <GB>`.
  public static func setQuotaCommand(destinationID: String, limitGB: Int) -> String {
    "sudo tmutil setquota \(destinationID) \(timeMachineQuotaGB(forLimitGB: limitGB))"
  }

  // MARK: - Usage on Drive

  public struct Usage: Codable, Equatable {
    public var bytes: UInt64
    public var measuredAt: Date

    public var gb: Double { Double(bytes) / 1_073_741_824 }
  }

  static var usageFile: URL { CMPaths.appSupportDir.appendingPathComponent("drive-usage.json") }

  public static func storedUsage() -> Usage? {
    guard let data = try? Data(contentsOf: usageFile) else { return nil }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode(Usage.self, from: data)
  }

  /// `rclone size --json` output -> bytes.
  static func bytes(fromSizeJSON text: String) -> UInt64? {
    guard let data = text.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let bytes = object["bytes"] as? NSNumber
    else { return nil }
    return bytes.uint64Value
  }

  /// Measures this Mac's folder on Drive and stores the result. `nil` when
  /// rclone did not answer - never zero, which would read as "empty".
  @discardableResult
  public static func measureUsage(now: Date = Date()) async -> Usage? {
    let path = "\(DriveBufferService.remoteName):\(DriveBufferService.remotePath)"
    guard let result = try? await CMTooling.runRclone(["size", "--json", path], timeout: 300),
      result.succeeded, let bytes = bytes(fromSizeJSON: result.stdout)
    else {
      CMLogger.log("Could not measure the size of \(path) on Google Drive")
      return nil
    }
    let usage = Usage(bytes: bytes, measuredAt: now)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    if let data = try? encoder.encode(usage) {
      try? data.write(to: usageFile, options: .atomic)
    }
    return usage
  }

  /// The stored measurement, refreshed first when it is older than
  /// `measurementMaxAge`. Only measures when a limit is set: without one
  /// there is nothing to compare with.
  public static func currentUsage(now: Date = Date()) async -> Usage? {
    let stored = storedUsage()
    if let stored, now.timeIntervalSince(stored.measuredAt) < measurementMaxAge { return stored }
    return await measureUsage(now: now) ?? stored
  }

  // MARK: - Evaluation

  public enum Level: Equatable {
    case ok
    case near
    case over
  }

  public static func level(usageBytes: UInt64, limitGB: Int) -> Level {
    let percent = Double(usageBytes) / 1_073_741_824 / Double(limitGB) * 100
    if percent > 100 { return .over }
    if percent >= Double(warnPercent) { return .near }
    return .ok
  }

  static func problems(usage: Usage?, limitGB: Int?) -> [BackupHealth.Problem] {
    guard let limitGB, let usage else { return [] }
    let used = String(format: "%.0f", usage.gb)
    switch level(usageBytes: usage.bytes, limitGB: limitGB) {
    case .ok:
      return []
    case .near:
      return [
        BackupHealth.Problem(
          summary: L10n.tr("This Mac is close to its space limit on Google Drive"),
          detail: L10n.tr(
            "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (drive-status).",
            used, "\(limitGB)"),
          code: "drive-budget-near")
      ]
    case .over:
      return [
        BackupHealth.Problem(
          summary: L10n.tr("This Mac is over its space limit on Google Drive"),
          detail: L10n.tr(
            "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or drive-status), or raise the limit.",
            used, "\(limitGB)"),
          code: "drive-budget-exceeded")
      ]
    }
  }

  /// Whether the Time Machine quota matches the limit. `nil` quota = none set.
  public static func quotaMatches(currentQuotaGB: Double?, limitGB: Int) -> Bool {
    guard let currentQuotaGB else { return false }
    return Int(currentQuotaGB.rounded()) == timeMachineQuotaGB(forLimitGB: limitGB)
  }

  /// One status line: usage against the limit, or why there is none.
  public static func summary(limitGB: Int?, usage: Usage?) -> String {
    guard let limitGB else { return L10n.tr("not set") }
    guard let usage else {
      return L10n.tr("%@ GB - usage not measured yet", "\(limitGB)")
    }
    let percent = Int((usage.gb / Double(limitGB) * 100).rounded())
    return L10n.tr(
      "%@ of %@ GB used (%@%%)", String(format: "%.0f", usage.gb), "\(limitGB)", "\(percent)")
  }

  /// For the watchdog: measures if needed and compares with the limit.
  public static func currentProblems() async -> [BackupHealth.Problem] {
    guard let limit = limitGB() else { return [] }
    return problems(usage: await currentUsage(), limitGB: limit)
  }
}
