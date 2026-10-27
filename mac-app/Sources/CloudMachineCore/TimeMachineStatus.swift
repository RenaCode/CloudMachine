import Foundation

/// Parsing the text output of `tmutil status`/`tmutil destinationinfo` - both
/// are really "plist-like" text, not real JSON/plist, so it is simplest and
/// safest to parse line by line, the way the original `awk` in bash did.
/// Progress of an active backup, extracted from the `Progress = { ... }` block
/// in `tmutil status`. All fields optional - macOS does not always fill the
/// whole block (e.g. in phases other than "Copying" some fields may be
/// missing).
public struct TimeMachineProgress: Equatable {
  public var phase: String?
  public var percent: Double?
  public var bytes: Double?
  public var totalBytes: Double?
  public var files: Int?
  public var totalFiles: Int?
  public var timeRemainingSeconds: Double?
}

public enum TimeMachineStatus {

  /// Time limit for EVERY `tmutil` call in this file.
  ///
  /// Until 23.09.2026 there was no limit here at all, and that was a failure
  /// waiting for its day. `tmutil destinationinfo` reaches the backup
  /// destination - then a FUSE-T mount on Google Drive, now an SMB share in
  /// the machine. With a dead destination (the ENXIO incident of 22.09) the
  /// read enters uninterruptible I/O and NEVER returns. The `backup-health` watchdog then hangs on
  /// `currentReport()`, and launchd with `StartInterval` does not start a
  /// second instance while the first one is alive - i.e. the watchdog goes
  /// silent PERMANENTLY, exactly at the moment it is supposed to speak.
  ///
  /// How the number was chosen, rather than "some limit off the top of the
  /// head":
  ///   - on a healthy system `tmutil status` and `destinationinfo` answer well
  ///     below a second (measured by hand on this machine),
  ///   - on a mount that is still alive but answers slowly, the same read can
  ///     take tens of seconds, because it goes over the network,
  ///   - the project already has one slip with a limit chosen for a CLEAN
  ///     start: 120 s was enough after a restart, and after a failure it was
  ///     10 s short. That is why 90 s is not "as long as it usually takes" but
  ///     two orders of magnitude of headroom over the healthy case and a
  ///     generous margin over the slow one.
  ///
  /// The upper bound on WAITING is higher than this number: on `timeout`
  /// `ProcessRunner` sends SIGTERM, after +5 s SIGKILL, and after +10 s it
  /// gives up and returns an error (SIGKILL does not work on a process in
  /// state "U"). The real maximum is therefore 100 s per call.
  /// `backup-health` makes one of them per run, with a `StartInterval` of
  /// 1800 s - an 18-fold margin, so the limit cannot eat up the run window.
  public static let commandTimeout: TimeInterval = 90

  /// Raw `tmutil` output. `nil` means EXACTLY one thing: tmutil DID NOT
  /// ANSWER (time limit, or it could not be started) - not "it answered no".
  /// Every caller has to tell these two apart itself, because merging them
  /// into `false`/`nil` is exactly the kind of silent failure the
  /// `BackupHealth` header warns against.
  private static func output(_ arguments: [String]) async -> String? {
    do {
      let result = try await ProcessRunner.run(
        "/usr/bin/tmutil", arguments, timeout: commandTimeout)
      guard let answer = answer(from: result) else {
        CMLogger.log(
          "tmutil \(arguments.joined(separator: " ")): NO ANSWER - exit code \(result.exitCode), \(result.stdout.isEmpty ? "empty output" : "\(result.stdout.utf8.count) B of output")"
        )
        return nil
      }
      return answer
    } catch {
      CMLogger.log(
        "tmutil \(arguments.joined(separator: " ")): NO ANSWER - \(error.localizedDescription)"
      )
      return nil
    }
  }

  /// Which `tmutil` results count as an answer. Pure, so it can be tested.
  ///
  /// Until 09.10.2026 the exit code was not looked at at all, and an EMPTY
  /// stdout was parsed like any other: `destinationinfo` -> `.none`, i.e. the
  /// "destination not registered" alarm; `status` -> "no backup in progress".
  /// Both are answers about Time Machine that tmutil never gave. Every
  /// subcommand used here prints something when it works - even with no
  /// destination there is the sentence below - so "nothing" is not an answer.
  ///
  /// The one failure that IS an answer: with no destination registered,
  /// `destinationinfo` says so in words, and we do not rely on which exit
  /// code it pairs that with across macOS versions.
  static func answer(from result: ProcessResult) -> String? {
    if (result.stdout + result.stderr).contains("No destinations configured") {
      return result.stdout + result.stderr
    }
    guard result.succeeded,
      !result.stdout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else { return nil }
    return result.stdout
  }

  /// `sudo -n tmutil <command>` (the NOPASSWD rule, for agents without a GUI
  /// session), then plain `tmutil` when there is no such rule. `startbackup`
  /// and `stopbackup` need no root, so the second attempt usually works.
  /// `true` only when one of them succeeded; failures are logged.
  public static func control(_ command: String) async -> Bool {
    if let viaSudo = try? await ProcessRunner.runTmutilUnattended([command], timeout: 120) {
      if viaSudo.succeeded { return true }
      if !viaSudo.isSudoAuthFailure {
        CMLogger.log(
          "sudo tmutil \(command): exit code \(viaSudo.exitCode) \(shortError(viaSudo))")
        return false
      }
    }
    guard let direct = try? await ProcessRunner.run("/usr/bin/tmutil", [command], timeout: 120)
    else {
      CMLogger.log("tmutil \(command): NO ANSWER within the time limit.")
      return false
    }
    if !direct.succeeded {
      CMLogger.log("tmutil \(command): exit code \(direct.exitCode) \(shortError(direct))")
    }
    return direct.succeeded
  }

  private static func shortError(_ result: ProcessResult) -> String {
    let text = (result.stderr + " " + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "(no message)" : text.replacingOccurrences(of: "\n", with: " ")
  }

  /// Whether a backup is in progress. `nil` = tmutil did not answer, i.e.
  /// UNKNOWN.
  ///
  /// The distinction matters for the machine's guard: it pauses only a backup
  /// that is RUNNING, and "unknown" is not that.
  public static func runningState() async -> Bool? {
    guard let out = await output(["status"]) else { return nil }
    return isRunning(statusOutput: out)
  }

  /// Shortcut for PURELY INFORMATIONAL places (a status printout, a preview in
  /// the GUI), where no answer and "not in progress" look the same and nothing
  /// follows from it. Wherever a DECISION follows from the answer, use
  /// `runningState()` and handle `nil` separately.
  public static func isRunning() async -> Bool {
    await runningState() ?? false
  }

  /// Pure parsing function - split out of `isRunning()` so it can be tested
  /// without `tmutil` on a real Mac (see `CooldownGate` for the same pattern
  /// in this project). All the parsing logic in this file previously had not a
  /// single test, even though this is exactly where real bugs were (a wrongly
  /// guessed volume name, mount collisions).
  static func isRunning(statusOutput: String) -> Bool {
    for line in statusOutput.split(separator: "\n") {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      if trimmed.hasPrefix("Running") {
        return trimmed.contains("= 1")
      }
    }
    return false
  }

  /// Parses `tmutil status` line by line (the same style as the rest of the
  /// file) - the keys inside the `Progress` block (`bytes`, `files`,
  /// `TimeRemaining`...) are unique in the whole output, so there is no need to
  /// track the nesting of braces separately. Returns `nil` if nothing is being
  /// copied at the moment.
  ///
  /// Here `nil` also means "tmutil did not answer", and this is the only place
  /// in this file where merging the two cases is fine: progress serves ONLY to
  /// show a bar in the interface and no decision follows from it. Whoever asks
  /// about progress asks `runningState()` beforehand anyway.
  public static func currentProgress() async -> TimeMachineProgress? {
    guard let out = await output(["status"]) else { return nil }
    return currentProgress(statusOutput: out)
  }

  static func currentProgress(statusOutput: String) -> TimeMachineProgress? {
    var running = false
    var progress = TimeMachineProgress()

    for rawLine in statusOutput.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      guard let eqIndex = line.firstIndex(of: "=") else { continue }
      let key = line[line.startIndex..<eqIndex].trimmingCharacters(in: .whitespaces)
      var value = String(line[line.index(after: eqIndex)...]).trimmingCharacters(in: .whitespaces)
      if value.hasSuffix(";") { value.removeLast() }
      value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))

      switch key {
      case "Running": running = (value == "1")
      case "BackupPhase": progress.phase = value
      case "Percent": progress.percent = Double(value)
      case "bytes": progress.bytes = Double(value)
      case "totalBytes": progress.totalBytes = Double(value)
      case "files": progress.files = Int(value)
      case "totalFiles": progress.totalFiles = Int(value)
      case "TimeRemaining": progress.timeRemainingSeconds = Double(value)
      default: break
      }
    }
    return running ? progress : nil
  }

  /// One block of `tmutil destinationinfo`. Fields macOS left out are `nil`:
  /// a network destination has a `Mount Point` only while it is mounted.
  public struct Destination: Equatable, Sendable {
    public var name: String?
    public var kind: String?
    public var url: String?
    public var mountPoint: String?
    public var id: String?
    /// `Quota : 300 GB` -> 300; `nil` = no quota set.
    public var quotaGB: Double?

    public init(
      name: String? = nil, kind: String? = nil, url: String? = nil, mountPoint: String? = nil,
      id: String? = nil, quotaGB: Double? = nil
    ) {
      self.name = name
      self.kind = kind
      self.url = url
      self.mountPoint = mountPoint
      self.id = id
      self.quotaGB = quotaGB
    }
  }

  /// The destinations, in order. Blocks are separated by `====` lines; a
  /// `Name` line also starts a new block, so output without separators parses
  /// the same way. Pure, so it is tested on recorded output.
  static func destinations(destinationInfoOutput: String) -> [Destination] {
    var result: [Destination] = []
    var current: Destination?
    func flush() {
      if let current, current != Destination() { result.append(current) }
      current = nil
    }
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      if line.hasPrefix("====") {
        flush()
        continue
      }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      let key = parts[0].trimmingCharacters(in: .whitespaces)
      let value = parts[1].trimmingCharacters(in: .whitespaces)
      if key == "Name", current?.name != nil { flush() }
      var block = current ?? Destination()
      switch key {
      case "Name": block.name = value
      case "Kind": block.kind = value
      case "URL": block.url = value
      case "Mount Point": block.mountPoint = value
      case "ID": block.id = value
      case "Quota": block.quotaGB = quotaGB(value)
      default: break
      }
      current = block
    }
    flush()
    return result
  }

  /// `Quota` as tmutil prints it, in GB. tmutil formats it for the user's
  /// region whatever `LC_ALL` says: 2450 GB came out as `2,45 TB` on
  /// 27.10.2026, and reading only "<number> GB" took that for no quota.
  /// Decimal units, as macOS shows sizes. `nil` = not a size.
  static func quotaGB(_ value: String) -> Double? {
    let parts = value.split(separator: " ")
    guard let first = parts.first,
      let number = Double(first.replacingOccurrences(of: ",", with: "."))
    else { return nil }
    switch parts.count > 1 ? parts[1].uppercased() : "GB" {
    case "TB": return number * 1000
    case "GB": return number
    case "MB": return number / 1000
    default: return nil
    }
  }

  /// The registered destinations; `nil` = tmutil DID NOT ANSWER, `[]` = it
  /// answered that there are none.
  public static func destinationsReading() async -> [Destination]? {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return destinations(destinationInfoOutput: out)
  }
}
