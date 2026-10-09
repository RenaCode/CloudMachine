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
  /// destination, i.e. the FUSE-T mount living on Google Drive. With a dead
  /// mount (the ENXIO incident of 22.09) the read enters uninterruptible I/O
  /// and NEVER returns. The `backup-health` watchdog then hangs on
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

  /// Whether a backup is in progress. `nil` = tmutil did not answer, i.e.
  /// UNKNOWN.
  ///
  /// The distinction matters here for the buffer guard: "not in progress"
  /// tells it to go into standby and forget it was supervising a backup, while
  /// "unknown" must leave the state unchanged.
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

  /// Counterpart of `tmutil destinationinfo | awk ... -v mp="$SP_MOUNT"` -
  /// looks for the block whose "Mount Point" contains `mountPoint`, and returns
  /// its ID.
  public static func destinationID(forMountPointContaining mountPoint: String) async -> String? {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return destinationID(forMountPointContaining: mountPoint, destinationInfoOutput: out)
  }

  static func destinationID(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  )
    -> String?
  {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("ID") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        return parts[1].trimmingCharacters(in: .whitespaces)
      }
    }
    return nil
  }

  /// Quota (GB) configured for the TM destination at the given mount point -
  /// parses the "Quota" line (e.g. "300 GB") from the block found the same way
  /// as in `destinationID`. `nil` if TM reports no quota for this destination.
  public static func destinationQuotaGB(forMountPointContaining mountPoint: String) async
    -> Double?
  {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return destinationQuotaGB(forMountPointContaining: mountPoint, destinationInfoOutput: out)
  }

  static func destinationQuotaGB(
    forMountPointContaining mountPoint: String, destinationInfoOutput: String
  ) -> Double? {
    var found = false
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      if line.hasPrefix("Mount Point") {
        found = line.contains(mountPoint)
        continue
      }
      if found, line.hasPrefix("Quota") {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        let valueText = parts[1].trimmingCharacters(in: .whitespaces)
        let numberText = valueText.split(separator: " ").first.map(String.init) ?? valueText
        return Double(numberText)
      }
    }
    return nil
  }

  /// Mount point of the CURRENTLY registered Time Machine destination (the
  /// architecture guarantees exactly one active local destination - see
  /// LocalBackupService). Returns the real, registered path instead of
  /// guessing it from the default volume name - the user may name the local
  /// volume anything (e.g. a manually created "TimeMachine" partition instead
  /// of the default "CloudMachine-Local"), and guessing by name was a real
  /// bug: after a manual volume rename the whole GUI/watchdog status showed
  /// "no local volume" / "TimeMachine not registered", despite a correctly
  /// working, registered destination.
  ///
  /// Returns `nil` both when there is no destination and when tmutil did not
  /// answer - whoever has to tell these two apart (the `backup-health`
  /// watchdog: one means "someone changed the destination", the other "we know
  /// nothing") asks `destinationReading()`.
  public static func currentDestinationMountPoint() async -> String? {
    if case .mountPoint(let path) = await destinationReading() { return path }
    return nil
  }

  /// The answer of `tmutil destinationinfo` with an explicit third state: NO
  /// ANSWER.
  ///
  /// The third state has to exist separately for the same reason as
  /// `queueUnknown` in `UploadState`: without it a hung tmutil looked exactly
  /// like an unregistered destination and the watchdog would report "Time
  /// Machine does not point to CloudMachine" - a true-sounding and false
  /// sentence that sends the person the wrong way.
  public enum DestinationReading: Equatable, Sendable {
    case mountPoint(String)
    /// tmutil answered, but there is no destination.
    case none
    /// tmutil did not answer within the time limit.
    case noAnswer
  }

  public static func destinationReading() async -> DestinationReading {
    guard let out = await output(["destinationinfo"]) else { return .noAnswer }
    guard let path = currentDestinationMountPoint(destinationInfoOutput: out) else { return .none }
    return .mountPoint(path)
  }

  static func currentDestinationMountPoint(destinationInfoOutput: String) -> String? {
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("Mount Point") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      return parts[1].trimmingCharacters(in: .whitespaces)
    }
    return nil
  }

  /// All registered Time Machine destination IDs - used by
  /// `LocalBackupService.setAsDestination` to remove previous destinations
  /// before registering a new one (this architecture keeps exactly one active
  /// local destination, unlike the legacy approach).
  ///
  /// An empty list on no answer is SAFE here, and that is the only reason it
  /// stays: the only caller deletes the returned destinations one by one
  /// before registering a new one, so "I do not know" ends with something not
  /// being removed, not with the wrong thing being removed.
  public static func allDestinationIDs() async -> [String] {
    guard let out = await output(["destinationinfo"]) else { return [] }
    return allDestinationIDs(destinationInfoOutput: out)
  }

  static func allDestinationIDs(destinationInfoOutput: String) -> [String] {
    var ids: [String] = []
    for rawLine in destinationInfoOutput.split(separator: "\n") {
      let line = String(rawLine)
      guard line.hasPrefix("ID") else { continue }
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      ids.append(parts[1].trimmingCharacters(in: .whitespaces))
    }
    return ids
  }

  /// `nil` = tmutil did not answer. Deliberately NOT `false`: "the
  /// configuration does not contain this text" and "could not ask" are two
  /// different answers.
  public static func destinationInfoContains(_ needle: String) async -> Bool? {
    guard let out = await output(["destinationinfo"]) else { return nil }
    return out.contains(needle)
  }
}
