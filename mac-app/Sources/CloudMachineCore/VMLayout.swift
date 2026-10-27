import Foundation

/// The CloudMachine machine: a Lima VM that serves Time Machine over SMB and
/// keeps the bands on Google Drive (see `vm/README.md`).
///
/// Why a machine at all: macOS 27 refuses a disk image as a NEW Time Machine
/// destination (`tmutil setdestination` -> error 45, even for a local
/// sparsebundle), and NetFS refuses SMB to the Mac's own address. A share
/// served from a VM on the Mac is what Time Machine still accepts.
public enum VMLayout {
  /// Lima instance name: `cmsmb`, which the launchd agents look up.
  /// `CLOUDMACHINE_VM_INSTANCE` points the commands at another machine -
  /// that is how a change is tried on a throwaway VM while `cmsmb` keeps
  /// backing up.
  public static var instanceName: String {
    override("CLOUDMACHINE_VM_INSTANCE") ?? "cmsmb"
  }

  static func override(_ name: String) -> String? {
    guard let value = ProcessInfo.processInfo.environment[name], !value.isEmpty else { return nil }
    return value
  }
  /// SMB share name, as in `vm/samba/smb.conf`.
  public static let shareName = "CloudMachine"
  /// SMB user created by the provisioning script.
  public static let smbUser = "tm"

  /// Guest paths (`vm/cmsmb.yaml`, `vm/systemd/*`).
  public enum Guest {
    public static let localRoot = "/srv/tm-local"
    public static let driveRoot = "/srv/tm"
    public static let punchRoot = "/srv/tm-punch"
    public static let rcloneConfig = "/etc/rclone/rclone.conf"
    public static let vmEnv = "/etc/cloudmachine/vm.env"
    public static let bundleEnv = "/etc/cloudmachine/bundle.env"
    public static let cacheDir = "/var/cache/rclone"
    public static let backupDir = "/var/lib/cloudmachine/prepare-backup"
    public static let rcAddress = "127.0.0.1:5572"
  }

  /// The systemd units the share depends on, in start order.
  public static let services = ["smb-throttle", "rclone-tm", "punchfs", "tm-bands-bind", "smbd"]

  /// Host-side state: `~/.cloudmachine/vm`.
  public static var hostDir: URL {
    CMPaths.stateDir.appendingPathComponent("vm")
  }
  /// The SMB password of `tm`, mode 600. Never logged.
  public static var passwordFile: URL { hostDir.appendingPathComponent("tm-smb.pass") }
  /// Present while the guard holds Time Machine paused; it resumes only then.
  public static var guardMarker: URL { hostDir.appendingPathComponent("guard-paused") }

  /// `gdrive:CloudMachine/<folder>-tm`. The `-tm` suffix keeps it apart from
  /// `CloudMachine/<folder>`, where the retired disk-image layout kept its
  /// image - the two never share bands.
  /// `CLOUDMACHINE_VM_REMOTE` replaces it whole (see `instanceName`).
  public static var remote: String {
    override("CLOUDMACHINE_VM_REMOTE")
      ?? "\(DriveFolder.remoteName):\(DriveFolder.remoteRoot)/\(DriveFolder.name)-tm"
  }

  /// Lima's directory with the machine's disk (`LIMA_HOME`, else `~/.lima`).
  /// The disk holds rclone's buffer: left in the backup, Time Machine copies
  /// its own backlog through the machine - on 27.10.2026 that kept the first
  /// backup on one ever-changing 17 GB file for half an hour.
  public static var limaHome: URL {
    if let custom = override("LIMA_HOME") { return URL(fileURLWithPath: custom) }
    return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".lima")
  }

  /// Keeps `limaHome` out of Time Machine. The exclusion is an xattr on the
  /// directory, so it is renewed rather than set once.
  @discardableResult
  public static func excludeMachineFromTimeMachine() async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/tmutil", ["addexclusion", limaHome.path], timeout: 30)
    return result?.succeeded == true
  }

  /// `vm/` among the resources (the repo root in a checkout, Resources in the app).
  public static var templateDir: URL? {
    guard let root = CMPaths.resourcesRoot else { return nil }
    let dir = root.appendingPathComponent("vm")
    return FileManager.default.fileExists(atPath: dir.appendingPathComponent("cmsmb.yaml").path)
      ? dir : nil
  }

  /// Lima from Homebrew. `nil` = not installed.
  public static var limactlPath: String? {
    ["/opt/homebrew/bin/limactl", "/usr/local/bin/limactl"].first {
      FileManager.default.isExecutableFile(atPath: $0)
    }
  }

  /// rclone's configuration on the Mac - the machine gets a copy of it.
  public static var hostRcloneConfig: URL {
    if let custom = ProcessInfo.processInfo.environment["RCLONE_CONFIG"], !custom.isEmpty {
      return URL(fileURLWithPath: custom)
    }
    return FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".config/rclone/rclone.conf")
  }

  // MARK: - Running things in the machine

  /// `limactl` with the given arguments. Throws only when it cannot start;
  /// a non-zero exit is in the result.
  public static func limactl(_ args: [String], timeout: TimeInterval) async throws
    -> ProcessResult
  {
    guard let lima = limactlPath else {
      throw ProcessRunnerError.launchFailed(
        L10n.tr("limactl not found - install Lima: brew install lima"))
    }
    return try await ProcessRunner.run(lima, args, timeout: timeout)
  }

  /// A root shell script in the machine. `--workdir /`, because Lima
  /// otherwise tries to enter the Mac's current directory in the guest.
  public static func rootShell(_ script: String, timeout: TimeInterval) async throws
    -> ProcessResult
  {
    try await limactl(
      ["shell", "--workdir", "/", instanceName, "sudo", "bash", "-c", script], timeout: timeout)
  }

  /// The last lines of what a failed command said, for an error message.
  public static func errorTail(_ result: ProcessResult?, lines: Int = 5) -> String {
    guard let result else { return L10n.tr("no answer within the time limit") }
    let text = (result.stderr + "\n" + result.stdout)
      .split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
    return text.isEmpty
      ? L10n.tr("exit code %@, no message", "\(result.exitCode)")
      : text.suffix(lines).joined(separator: "\n")
  }

  /// Quotes a value for a bash script (single quotes).
  static func shellQuoted(_ value: String) -> String {
    "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
  }

  /// A line of a systemd `EnvironmentFile`: double quotes, with `\` and `"`
  /// escaped (systemd unquotes them).
  static func envLine(_ key: String, _ value: String) -> String {
    let escaped = value.replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
    return "\(key)=\"\(escaped)\""
  }

  // MARK: - Parsing (pure, tested)

  /// The instance's status from `limactl list --json` (one JSON object per
  /// line). `nil` = no such instance.
  static func instanceStatus(listJSON: String, name: String = instanceName) -> String? {
    for line in listJSON.split(separator: "\n") {
      guard let data = line.data(using: .utf8),
        let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        object["name"] as? String == name
      else { continue }
      return object["status"] as? String ?? "Unknown"
    }
    return nil
  }

  /// The address the Mac reaches the machine at, from
  /// `ip -4 -o addr show scope global`.
  ///
  /// Lima's own user-mode network (192.168.5.0/24) is reachable only through
  /// Lima's port forwarding, not by Time Machine; the vzNAT address is the
  /// other one (192.168.64.x on this Mac's measurements, but taken from the
  /// machine rather than assumed).
  static func vmAddress(ipAddrOutput: String) -> String? {
    for line in ipAddrOutput.split(separator: "\n") {
      let fields = line.split(separator: " ", omittingEmptySubsequences: true)
      guard let index = fields.firstIndex(of: "inet"), index + 1 < fields.count else { continue }
      let address = String(fields[index + 1].split(separator: "/")[0])
      if address.hasPrefix("192.168.5.") || address.hasPrefix("127.") { continue }
      return address
    }
    return nil
  }

  /// What rclone says about the upload buffer.
  ///
  /// `bytesUsed` is the whole cache on disk, uploaded bands included: rclone
  /// keeps them for reading until the cache reaches `--vfs-cache-max-size`.
  /// It does NOT fall when the upload catches up - on 27.10.2026 it stayed at
  /// 116 GiB for 13 minutes while the real backlog was 30 GiB, and a guard
  /// deciding on it never resumed the backup. Decisions use `unsentBytes`,
  /// the sum of `vfs/queue`.
  public struct BufferStats: Equatable, Sendable {
    public var bytesUsed: Int64
    public var uploadsQueued: Int
    public var uploadsInProgress: Int
    /// Bytes still to upload; `nil` = `vfs/queue` did not answer.
    public var unsentBytes: Int64?
    /// Bands rclone gave up on: they exist only in the machine's buffer, so
    /// the backup on Drive is incomplete until they are uploaded.
    public var erroredFiles: Int
    /// rclone has nothing left to evict - the buffer holds only unsent data.
    public var outOfSpace: Bool

    public init(
      bytesUsed: Int64, uploadsQueued: Int, uploadsInProgress: Int, unsentBytes: Int64? = nil,
      erroredFiles: Int = 0, outOfSpace: Bool = false
    ) {
      self.bytesUsed = bytesUsed
      self.uploadsQueued = uploadsQueued
      self.uploadsInProgress = uploadsInProgress
      self.unsentBytes = unsentBytes
      self.erroredFiles = erroredFiles
      self.outOfSpace = outOfSpace
    }
  }

  /// Sum of the item sizes in `vfs/queue`; `nil` when it is not that JSON.
  static func unsentBytes(vfsQueueJSON: String) -> Int64? {
    guard let data = vfsQueueJSON.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let queue = object["queue"] as? [[String: Any]]
    else { return nil }
    return queue.reduce(Int64(0)) { $0 + ((($1["size"] as? NSNumber)?.int64Value) ?? 0) }
  }

  static func bufferStats(vfsStatsJSON: String) -> BufferStats? {
    guard let data = vfsStatsJSON.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let cache = object["diskCache"] as? [String: Any],
      let used = (cache["bytesUsed"] as? NSNumber)?.int64Value
    else { return nil }
    return BufferStats(
      bytesUsed: used,
      uploadsQueued: (cache["uploadsQueued"] as? NSNumber)?.intValue ?? 0,
      uploadsInProgress: (cache["uploadsInProgress"] as? NSNumber)?.intValue ?? 0,
      erroredFiles: (cache["erroredFiles"] as? NSNumber)?.intValue ?? 0,
      // A flag, not a counter: older rclone does not report it, and its
      // absence cannot be mistaken for "buffer full".
      outOfSpace: (cache["outOfSpace"] as? Bool) ?? false)
  }

  /// One reading of the machine for the guard and the status: the rclone
  /// buffer and the free space on the buffer's disk.
  public struct Reading: Equatable, Sendable {
    public var buffer: BufferStats
    public var freeBytes: Int64

    public init(buffer: BufferStats, freeBytes: Int64) {
      self.buffer = buffer
      self.freeBytes = freeBytes
    }
  }

  /// The script prints `vfs/stats` JSON on one line, `CMQUEUE <vfs/queue JSON>`
  /// on the next, then `CMFREE <bytes>`.
  static let readingScript =
    "curl -s -m 20 -X POST http://\(Guest.rcAddress)/vfs/stats | tr -d '\\n'; echo; "
    + "printf 'CMQUEUE '; curl -s -m 20 -X POST http://\(Guest.rcAddress)/vfs/queue | tr -d '\\n'; echo; "
    + "echo CMFREE $(df -B1 --output=avail \(Guest.cacheDir) | tail -1 | tr -dc 0-9)"

  /// `nil` unless BOTH parts are there: half an answer is no answer.
  static func reading(scriptOutput: String) -> Reading? {
    var stats: BufferStats?
    var free: Int64?
    var unsent: Int64?
    for line in scriptOutput.split(separator: "\n") {
      if line.hasPrefix("CMQUEUE ") {
        unsent = unsentBytes(vfsQueueJSON: String(line.dropFirst("CMQUEUE ".count)))
      } else if line.hasPrefix("CMFREE ") {
        free = Int64(line.dropFirst("CMFREE ".count).trimmingCharacters(in: .whitespaces))
      } else if line.hasPrefix("{") {
        stats = bufferStats(vfsStatsJSON: String(line))
      }
    }
    guard var stats, let free else { return nil }
    stats.unsentBytes = unsent
    return Reading(buffer: stats, freeBytes: free)
  }

  /// Reads the machine. `nil` = no answer (machine down, rclone not up, time
  /// limit) - which callers must treat as "unknown", never as zero.
  public static func currentReading() async -> Reading? {
    guard let result = try? await rootShell(readingScript, timeout: 40), result.succeeded
    else { return nil }
    return reading(scriptOutput: result.stdout)
  }

  /// The machine's SMB address, or `nil` when it does not answer.
  public static func currentAddress() async -> String? {
    guard
      let result = try? await limactl(
        [
          "shell", "--workdir", "/", instanceName, "ip", "-4", "-o", "addr", "show", "scope",
          "global",
        ], timeout: 30),
      result.succeeded
    else { return nil }
    return vmAddress(ipAddrOutput: result.stdout)
  }

  /// Starts a stopped machine (`limactl start`); on a running one Lima only
  /// says so. The first start after a Mac restart can take minutes: rclone
  /// re-reads its buffer before it serves anything.
  public static func start() async -> CMActionResult {
    let started = try? await limactl(["start", "--tty=false", instanceName], timeout: 1800)
    guard started?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("limactl start failed: %@", errorTail(started)))
    }
    return CMActionResult(
      succeeded: true, message: L10n.tr("Machine %@ is running.", instanceName))
  }

  /// `Running`, `Stopped`, ... or `nil` when there is no instance. Throws
  /// when `limactl` itself does not answer.
  public static func instanceStatus() async throws -> String? {
    let result = try await limactl(["list", "--json"], timeout: 60)
    guard result.succeeded else {
      throw ProcessRunnerError.launchFailed(
        L10n.tr(
          "limactl list failed: %@", result.stderr.trimmingCharacters(in: .whitespacesAndNewlines)))
    }
    return instanceStatus(listJSON: result.stdout)
  }
}
