import Foundation
import Security

/// Client-side encryption of the bands on Google Drive with rclone `crypt`.
///
/// Why rclone and not Time Machine's own "Encrypt backups": Time Machine
/// encrypts the disk image itself, and `vm-prepare-bundle` would then have to
/// re-band an encrypted image (`hdiutil convert` of an encrypted sparse
/// bundle answered "Permission denied" on macOS 27, 03.11.2026), and whether
/// Time Machine still finds the password for a converted image cannot be
/// tried without the live destination. `crypt` sits below everything Time
/// Machine sees: the image, Samba and punchfs are unchanged, and an existing
/// backup can be moved under encryption without a new full backup - the bands
/// are copied once, encrypted, next to the plain ones.
///
/// The move, in order, each step refusing rather than warning:
/// 1. `setup` - the `crypt` remote (`gdrive-crypt`, over
///    `gdrive:CloudMachine/<folder>-crypt`), on the Mac and in the machine.
/// 2. `copy` - plain bands and metadata to the encrypted folder, in the
///    background in the machine, while backups go on.
/// 3. `switch` - with Time Machine stopped and nothing left to upload: a last
///    sync, `rclone cryptcheck` of every file, then the machine mounts the
///    encrypted folder. The plain folder stays.
/// 4. `delete-plain` - only after a backup has finished into the encrypted
///    folder and its metadata was copied there; moved to Drive's bin.
/// `rollback` is `switch` the other way (decrypting back) until step 4.
public enum DriveEncryption {
  /// The rclone remote of type `crypt`.
  public static let cryptRemoteName = "gdrive-crypt"
  /// The bands inside it; the metadata copy is `tm-meta` (`VMLayout.metaRemote`).
  public static let encryptedRemote = "\(cryptRemoteName):tm"
  /// What the marker file holds once the machine mounts the encrypted folder.
  static let markerTag = "rclone-crypt"
  /// The Keychain service of the encryption password and salt.
  public static let keychainService = "cloudmachine-drive-crypt"
  public static let passwordAccount = "password"
  public static let saltAccount = "salt"
  /// The background copy in the machine (`systemd-run`).
  static let copyUnit = "cm-encrypt-copy"
  static let copyLog = "/var/log/cm-encrypt-copy.log"

  /// `~/Library/Application Support/CloudMachine/drive-encryption`: written by
  /// `switch` LAST, after the machine has moved; `VMLayout.remote` follows it.
  /// A throwaway machine has its own, so trying `switch` on `cmtest` cannot
  /// move what `cmsmb`'s agents use.
  static var markerFile: URL {
    CMPaths.appSupportDir.appendingPathComponent(markerName(instance: VMLayout.instanceName))
  }

  static func markerName(instance: String) -> String {
    instance == "cmsmb" ? "drive-encryption" : "drive-encryption-\(instance)"
  }

  /// A throwaway machine must name its own Drive folder: everything here
  /// derives from `VMLayout.plainRemote`, and `delete-plain` on `cmtest`
  /// with the default folder would delete the live backup.
  static func throwawayRefusal(instance: String, remoteOverride: String?) -> String? {
    guard instance != "cmsmb", remoteOverride == nil else { return nil }
    return L10n.tr(
      "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.",
      instance)
  }

  static var currentThrowawayRefusal: String? {
    throwawayRefusal(
      instance: VMLayout.instanceName, remoteOverride: VMLayout.override("CLOUDMACHINE_VM_REMOTE"))
  }

  public static var isEnabled: Bool { marker(in: markerFile) != nil }
  /// When the machine moved to the encrypted folder; `nil` = it has not.
  public static var switchedAt: Date? { marker(in: markerFile) }

  static func marker(in file: URL) -> Date? {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return nil }
    return marker(text: text)
  }

  /// `rclone-crypt <unix seconds>`. Anything else is no marker: a half
  /// written file must not move the machine to a folder it never copied to.
  static func marker(text: String) -> Date? {
    let fields = text.split(whereSeparator: \.isWhitespace)
    guard fields.count == 2, fields[0] == markerTag, let seconds = TimeInterval(fields[1]) else {
      return nil
    }
    return Date(timeIntervalSince1970: seconds)
  }

  static func markerText(switchedAt: Date) -> String {
    "\(markerTag) \(Int(switchedAt.timeIntervalSince1970))\n"
  }

  /// `gdrive:CloudMachine/<folder>-crypt`, what the `crypt` remote wraps (the
  /// plain folder with `-crypt` instead of `-tm`). Its own folder: `crypt`
  /// cannot list a folder that also holds plain names.
  public static var cryptRoot: String { cryptRoot(plain: VMLayout.plainRemote) }

  static func cryptRoot(plain: String) -> String {
    (plain.hasSuffix("-tm") ? String(plain.dropLast(3)) : plain) + "-crypt"
  }

  /// The section added to `rclone.conf`. Names are encrypted too: band
  /// names say little, but folder names would say which Mac this is.
  static func configSection(cryptRoot: String, obscuredPassword: String, obscuredSalt: String)
    -> String
  {
    """

    [\(cryptRemoteName)]
    type = crypt
    remote = \(cryptRoot)
    password = \(obscuredPassword)
    password2 = \(obscuredSalt)
    filename_encryption = standard
    directory_name_encryption = true

    """
  }

  /// Whether `rclone.conf` text already defines the `crypt` remote.
  static func hasSection(_ config: String) -> Bool {
    config.split(whereSeparator: \.isNewline).contains {
      $0.trimmingCharacters(in: .whitespaces) == "[\(cryptRemoteName)]"
    }
  }

  // MARK: - Moving between the folders (pure, tested)

  /// Which way `switch` moves the bands: `encrypt` (plain -> encrypted) or,
  /// for `rollback`, `decrypt`.
  public enum Direction: Sendable {
    case encrypt, decrypt
  }

  public struct Remotes: Equatable, Sendable {
    public var plain: String
    public var encrypted: String

    public init(plain: String, encrypted: String = DriveEncryption.encryptedRemote) {
      self.plain = plain
      self.encrypted = encrypted
    }

    func source(_ direction: Direction) -> String {
      direction == .encrypt ? plain : encrypted
    }
    func target(_ direction: Direction) -> String {
      direction == .encrypt ? encrypted : plain
    }
  }

  static func rclone(_ args: String) -> String {
    "/usr/local/bin/rclone --config \(VMLayout.Guest.rcloneConfig) \(args)"
  }

  /// The background copy: bands, then metadata. `copy`, not `sync` - it
  /// runs while backups go on, and `switch` does the exact last pass.
  /// `--drive-stop-on-upload-limit` ends it at Google's daily limit instead of
  /// retrying all night; running `copy` again picks up where it stopped.
  static func copyScript(_ remotes: Remotes) -> String {
    let flags = "--transfers 4 --drive-chunk-size 32M --drive-stop-on-upload-limit"
    let p = VMLayout.shellQuoted
    return [
      // RemainAfterExit keeps a finished copy visible as `exited`/`success`;
      // without it the unit is unloaded and reads like one that never ran.
      "systemctl stop \(copyUnit) 2>/dev/null || true",
      "systemctl reset-failed \(copyUnit) 2>/dev/null || true",
      "systemd-run --unit \(copyUnit) -p RemainAfterExit=yes -p Nice=10 /bin/bash -c "
        + p(
          "set -euo pipefail; exec >>\(copyLog) 2>&1; date; "
            + rclone("copy \(p(remotes.plain)) \(p(remotes.encrypted)) \(flags)") + "; "
            + rclone(
              "copy \(p(remotes.plain + "-meta")) \(p(remotes.encrypted + "-meta")) \(flags)")
            + "; date; echo CM-COPY-DONE"),
    ].joined(separator: "\n")
  }

  static let copyStateScript =
    "systemctl show -p LoadState -p ActiveState -p SubState -p Result \(copyUnit)"

  /// The background copy, from `copyStateScript`.
  public enum CopyState: Equatable, Sendable {
    /// No such unit: never started, or the machine restarted since.
    case notRun
    case running
    case done
    /// Ended badly; the unit's `Result` (`exit-code`, ...).
    case failed(String)
    /// Not that output.
    case unknown
  }

  static func copyState(showOutput: String) -> CopyState {
    var fields: [String: String] = [:]
    for line in showOutput.split(whereSeparator: \.isNewline) {
      let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
      if parts.count == 2 { fields[parts[0]] = parts[1] }
    }
    guard let load = fields["LoadState"], let active = fields["ActiveState"] else {
      return .unknown
    }
    if load == "not-found" { return .notRun }
    let result = fields["Result"] ?? ""
    if result != "success" { return .failed(result) }
    if active == "active", fields["SubState"] == "exited" { return .done }
    if active == "active" || active == "activating" { return .running }
    return .failed(active)
  }

  /// The last pass before the machine moves, with Time Machine stopped: sync
  /// bands and metadata from `direction`'s source to its target, then
  /// `cryptcheck` every file (contents, not just sizes). `set -e`: any
  /// difference fails the script, and nothing is moved.
  static func finalSyncScript(_ remotes: Remotes, direction: Direction) -> String {
    let p = VMLayout.shellQuoted
    let flags = "--transfers 8 --drive-chunk-size 32M"
    return [
      "set -euo pipefail",
      rclone("sync \(p(remotes.source(direction))) \(p(remotes.target(direction))) \(flags)"),
      rclone(
        "sync \(p(remotes.source(direction) + "-meta")) \(p(remotes.target(direction) + "-meta")) \(flags)"
      ),
      // cryptcheck takes the plain side first, whichever way the copy went.
      rclone("cryptcheck \(p(remotes.plain)) \(p(remotes.encrypted))"),
      rclone("cryptcheck \(p(remotes.plain + "-meta")) \(p(remotes.encrypted + "-meta"))"),
      "echo CM-CHECKED",
    ].joined(separator: "\n")
  }

  /// Before anything stops: the machine runs this app's template (the unit
  /// names the move restarts) and mounts `oldRemote`, the folder the move
  /// starts from. A machine set up by hand, or already moved, is refused.
  static func preflightScript(oldRemote: String) -> String {
    [
      "set -euo pipefail",
      "systemctl cat rclone-tm punchfs tm-bands-bind smbd >/dev/null",
      "test -s /etc/cloudmachine/bundle.env",
      "grep -qx \(VMLayout.shellQuoted(VMLayout.envLine("CM_REMOTE", oldRemote))) \(VMLayout.Guest.vmEnv)",
      "echo CM-PREFLIGHT",
    ].joined(separator: "\n")
  }

  /// rclone's buffer for a remote: `vfs/<name>/<path>` and `vfsMeta/...`.
  static func cachePaths(remote: String) -> [String] {
    let parts = remote.split(separator: ":", maxSplits: 1).map(String.init)
    let name = parts[0]
    let path = parts.count > 1 ? parts[1] : ""
    return ["vfs", "vfsMeta"].map {
      "\(VMLayout.Guest.cacheDir)/\($0)/\(name)" + (path.isEmpty ? "" : "/\(path)")
    }
  }

  /// Points the machine at `newRemote`. Runs after `finalSyncScript`; Samba
  /// was stopped before that sync (`move`), so nothing has written since.
  ///
  /// The old remote's buffer is deleted: everything in it is on Drive (the
  /// queue is checked empty again here, after Samba stopped), and a second
  /// 120 GB buffer would not fit the machine's disk. Any failure puts
  /// `vm.env` back and starts the old layout again (`trap`).
  static func repointScript(oldRemote: String, newRemote: String, stamp: String) -> String {
    let env = VMLayout.Guest.vmEnv
    let saved = "\(env).before-\(stamp)"
    let units = "rclone-tm punchfs tm-bands-bind"
    let queue =
      "curl -s -m 20 -X POST http://\(VMLayout.Guest.rcAddress)/vfs/queue"
      + " | python3 -c 'import json,sys; print(sum(i.get(\"size\",0) for i in json.load(sys.stdin)[\"queue\"]))'"
    return [
      preflightScript(oldRemote: oldRemote),
      "B=$(. /etc/cloudmachine/bundle.env && echo \"/srv/tm-local/$CM_BUNDLE/bands\")",
      "before=$(find \"$B/\" -type f | wc -l)",
      "test \"$before\" -gt 0",
      "systemctl stop smbd",
      "unsent=$(\(queue))",
      "if [ \"$unsent\" != 0 ]; then systemctl start smbd; echo \"unsent $unsent bytes\" >&2; exit 3; fi",
      "cp -p \(env) \(VMLayout.shellQuoted(saved))",
      "restore() { cp -p \(VMLayout.shellQuoted(saved)) \(env); systemctl restart \(units); systemctl start smbd; }",
      "trap 'echo \"FAILED - the previous folder is back\" >&2; restore' ERR",
      "systemctl stop tm-bands-bind punchfs rclone-tm",
      "printf '%s\\n' \(VMLayout.shellQuoted(VMLayout.envLine("CM_REMOTE", newRemote))) > \(env)",
      "rm -rf " + cachePaths(remote: oldRemote).map(VMLayout.shellQuoted).joined(separator: " "),
      "systemctl start rclone-tm punchfs tm-bands-bind",
      "mountpoint -q \"$B\"",
      "after=$(find \"$B/\" -type f | wc -l)",
      "test \"$after\" -eq \"$before\"",
      "systemctl start smbd",
      "trap - ERR",
      "echo CM-REPOINTED $before",
    ].joined(separator: "\n")
  }

  /// Moves the plain folders to Drive's bin (30 days to change one's mind),
  /// not `--drive-use-trash=false` like the machine's own deletes.
  static func deletePlainScript(plain: String) -> String {
    let p = VMLayout.shellQuoted
    return [
      "set -euo pipefail",
      rclone("purge --drive-use-trash=true \(p(plain))"),
      rclone("purge --drive-use-trash=true \(p(plain + "-meta"))"),
      "echo CM-DELETED",
    ].joined(separator: "\n")
  }

  // MARK: - Gates (pure, tested)

  /// What `switch` and `rollback` check before touching anything. `nil` in a
  /// field = not read, which refuses like a bad answer.
  public struct SwitchFacts: Sendable {
    public var direction: Direction
    public var enabled: Bool
    public var cryptRemoteInMachine: Bool?
    public var timeMachineRunning: Bool?
    public var reading: VMLayout.Reading?
    public var copyState: CopyState
    /// `VMLayout.guardMarker` exists: the guard paused Time Machine and
    /// resumes it by itself (`tmutil startbackup`), automatic backups or not.
    public var guardHoldsPause: Bool
  }

  static func switchRefusal(_ facts: SwitchFacts) -> String? {
    switch (facts.direction, facts.enabled) {
    case (.encrypt, true):
      return L10n.tr("The machine already uses the encrypted folder - nothing to switch.")
    case (.decrypt, false):
      return L10n.tr("The machine does not use the encrypted folder - nothing to roll back.")
    default: break
    }
    guard facts.cryptRemoteInMachine == true else {
      return L10n.tr(
        "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup",
        cryptRemoteName)
    }
    guard let running = facts.timeMachineRunning else {
      return L10n.tr("tmutil did not answer - not switching while Time Machine's state is unknown.")
    }
    if running {
      return L10n.tr(
        "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again."
      )
    }
    guard let buffer = facts.reading?.buffer, let unsent = buffer.unsentBytes else {
      return L10n.tr("No answer from rclone in the machine - the upload queue is unknown.")
    }
    if unsent > 0 || buffer.uploadsInProgress > 0 || buffer.erroredFiles > 0 {
      return L10n.tr(
        "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status",
        "\(unsent >> 20)", "\(buffer.uploadsInProgress)", "\(buffer.erroredFiles)")
    }
    if facts.guardHoldsPause {
      return L10n.tr(
        "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done."
      )
    }
    // The copy must have run and ended well; the last sync then moves only
    // what changed since. Without it that sync is the whole backup, run with
    // Time Machine off for hours.
    if facts.direction == .encrypt, facts.copyState != .done {
      return L10n.tr(
        "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.",
        "\(facts.copyState)")
    }
    return nil
  }

  /// What `delete-plain` checks. The plain folder is the one backup known
  /// to be good until the encrypted one has proved itself.
  public struct DeleteFacts: Sendable {
    public var switchedAt: Date?
    public var lastBackup: Date?
    public var lastMetaSync: Date?
    public var reading: VMLayout.Reading?
    public var secretsSavedElsewhere: Bool
    public var restoreChecked: Bool
  }

  static func deleteRefusal(_ facts: DeleteFacts) -> String? {
    guard let switchedAt = facts.switchedAt else {
      return L10n.tr(
        "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it."
      )
    }
    guard facts.secretsSavedElsewhere else {
      return L10n.tr(
        "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere."
      )
    }
    guard facts.restoreChecked else {
      return L10n.tr(
        "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked."
      )
    }
    guard let lastBackup = facts.lastBackup else {
      return L10n.tr(
        "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting."
      )
    }
    if lastBackup <= switchedAt {
      return L10n.tr(
        "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.",
        BackupHealth.stamp(lastBackup), BackupHealth.stamp(switchedAt))
    }
    guard let meta = facts.lastMetaSync, meta > lastBackup else {
      return L10n.tr(
        "The image metadata has not been copied to the encrypted folder since the last backup - not deleting."
      )
    }
    guard let buffer = facts.reading?.buffer, buffer.unsentBytes == 0,
      buffer.uploadsInProgress == 0, buffer.erroredFiles == 0
    else {
      return L10n.tr(
        "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting."
      )
    }
    return nil
  }

  // MARK: - Steps

  public struct Outcome: Sendable {
    public var succeeded: Bool
    public var message: String
  }

  static func fail(_ message: String) -> Outcome {
    CMLogger.log("vm-encrypt: \(message.replacingOccurrences(of: "\n", with: " "))")
    return Outcome(succeeded: false, message: message)
  }

  /// A random salt: 32 bytes, base64.
  static func randomSalt() -> String? {
    var bytes = [UInt8](repeating: 0, count: 32)
    guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
      return nil
    }
    return Data(bytes).base64EncodedString()
  }

  /// `rclone obscure`, the secret through the environment (not `ps`).
  static func obscure(_ secret: String) async -> String? {
    let result = try? await ProcessRunner.run(
      "/bin/sh", ["-c", "printf '%s' \"$CM_SECRET\" | \"$CM_RCLONE\" obscure -"],
      env: ["CM_SECRET": secret, "CM_RCLONE": CMTooling.managedRclonePath.path], timeout: 30)
    guard let result, result.succeeded else { return nil }
    let value = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return value.isEmpty ? nil : value
  }

  /// Step 1. Adds the `crypt` remote to rclone.conf on the Mac and in the
  /// machine, and keeps the password and salt in the Keychain. Moves no data.
  /// Refuses if the remote exists anywhere: a second password would make the
  /// first copy unreadable.
  public static func setup(password: String) async -> Outcome {
    if let refusal = currentThrowawayRefusal { return fail(refusal) }
    guard password.count >= 12 else {
      return fail(L10n.tr("The password must have at least 12 characters."))
    }
    let hostConfig = VMLayout.hostRcloneConfig
    guard let existing = try? String(contentsOf: hostConfig, encoding: .utf8) else {
      return fail(L10n.tr("Could not read %@.", hostConfig.path))
    }
    if hasSection(existing) {
      return fail(
        L10n.tr(
          "'%@' is already in %@ - not replacing its password.", cryptRemoteName, hostConfig.path))
    }
    guard
      let inMachine = try? await VMLayout.rootShell(
        "grep -qx '\\[\(cryptRemoteName)\\]' \(VMLayout.Guest.rcloneConfig) && echo YES || echo NO",
        timeout: 60), inMachine.succeeded
    else {
      return fail(
        L10n.tr("The machine does not answer - is it running? cloudmachine-agent vm-status"))
    }
    if inMachine.stdout.contains("YES") {
      return fail(
        L10n.tr(
          "'%@' is already in the machine's rclone.conf - not replacing its password.",
          cryptRemoteName))
    }
    guard let salt = randomSalt(), let obscuredPassword = await obscure(password),
      let obscuredSalt = await obscure(salt)
    else { return fail(L10n.tr("rclone obscure failed.")) }
    let section = configSection(
      cryptRoot: cryptRoot, obscuredPassword: obscuredPassword,
      obscuredSalt: obscuredSalt)

    // The Keychain first: a remote whose password exists nowhere else is
    // the one mistake here that cannot be undone.
    do {
      try await KeychainStore.save(password, account: passwordAccount, service: keychainService)
      try await KeychainStore.save(salt, account: saltAccount, service: keychainService)
    } catch {
      return fail(error.localizedDescription)
    }
    let staging = VMLayout.hostDir.appendingPathComponent("crypt-section-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: staging) }
    guard
      FileManager.default.createFile(
        atPath: staging.path, contents: Data(section.utf8), attributes: [.posixPermissions: 0o600])
    else { return fail(L10n.tr("Could not write %@.", staging.path)) }
    let remoteStaging = "/tmp/cm-crypt-\(UUID().uuidString)"
    guard
      let copied = try? await VMLayout.limactl(
        ["copy", staging.path, "\(VMLayout.instanceName):\(remoteStaging)"], timeout: 120),
      copied.succeeded,
      let appended = try? await VMLayout.rootShell(
        "set -e; cat \(remoteStaging) >> \(VMLayout.Guest.rcloneConfig); rm -f \(remoteStaging)",
        timeout: 60), appended.succeeded
    else { return fail(L10n.tr("Could not add the remote to the machine's rclone.conf.")) }
    do {
      let handle = try FileHandle(forWritingTo: hostConfig)
      try handle.seekToEnd()
      try handle.write(contentsOf: Data(section.utf8))
      try handle.close()
    } catch {
      return fail(
        L10n.tr("Could not add the remote to %@: %@", hostConfig.path, error.localizedDescription))
    }
    CMLogger.log(
      "vm-encrypt: setup - \(cryptRemoteName) over \(cryptRoot)")
    return Outcome(
      succeeded: true,
      message: L10n.tr(
        "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy",
        cryptRemoteName, cryptRoot, keychainService, salt))
  }

  static var remotes: Remotes { Remotes(plain: VMLayout.plainRemote) }

  /// Step 2. Starts the background copy in the machine and returns.
  public static func copy() async -> Outcome {
    if let refusal = currentThrowawayRefusal { return fail(refusal) }
    if isEnabled { return fail(L10n.tr("The machine already uses the encrypted folder.")) }
    let shown = try? await VMLayout.rootShell(copyStateScript, timeout: 60)
    if shown.map({ copyState(showOutput: $0.stdout) }) == .running {
      return fail(
        L10n.tr("The copy is already running - see: cloudmachine-agent vm-encrypt status"))
    }
    let started = try? await VMLayout.rootShell(copyScript(remotes), timeout: 120)
    guard started?.succeeded == true else {
      return fail(L10n.tr("Could not start the copy: %@", VMLayout.errorTail(started)))
    }
    return Outcome(
      succeeded: true,
      message: L10n.tr(
        "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status",
        copyUnit, copyLog))
  }

  /// Steps 3 and `rollback`.
  public static func move(_ direction: Direction) async -> Outcome {
    if let refusal = currentThrowawayRefusal { return fail(refusal) }
    let inMachine = try? await VMLayout.rootShell(
      "grep -qx '\\[\(cryptRemoteName)\\]' \(VMLayout.Guest.rcloneConfig) && echo YES || echo NO",
      timeout: 60)
    let shown = try? await VMLayout.rootShell(copyStateScript, timeout: 60)
    let facts = SwitchFacts(
      direction: direction, enabled: isEnabled,
      cryptRemoteInMachine: inMachine?.succeeded == true
        ? inMachine?.stdout.contains("YES") : nil,
      timeMachineRunning: await TimeMachineStatus.runningState(),
      reading: await VMLayout.currentReading(),
      copyState: shown?.succeeded == true ? copyState(showOutput: shown!.stdout) : .unknown,
      guardHoldsPause: FileManager.default.fileExists(atPath: VMLayout.guardMarker.path))
    if let refusal = switchRefusal(facts) { return fail(refusal) }
    let old = direction == .encrypt ? remotes.plain : remotes.encrypted
    let new = direction == .encrypt ? remotes.encrypted : remotes.plain
    let preflight = try? await VMLayout.rootShell(preflightScript(oldRemote: old), timeout: 60)
    guard preflight?.stdout.contains("CM-PREFLIGHT") == true else {
      return fail(
        L10n.tr(
          "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@",
          old, VMLayout.errorTail(preflight)))
    }

    // Samba off BEFORE the last sync: a backup started now (by hand, by the
    // guard) cannot write a band that the sync has already passed.
    guard (try? await VMLayout.rootShell("systemctl stop smbd", timeout: 120))?.succeeded == true
    else { return fail(L10n.tr("Could not stop smbd in the machine.")) }
    CMLogger.log("vm-encrypt: \(direction) - last sync and cryptcheck")
    let synced = try? await VMLayout.rootShell(
      finalSyncScript(remotes, direction: direction), timeout: 6 * 3600)
    guard synced?.succeeded == true, synced?.stdout.contains("CM-CHECKED") == true else {
      _ = try? await VMLayout.rootShell("systemctl start smbd", timeout: 120)
      return fail(
        L10n.tr(
          "The last sync or cryptcheck failed - the machine was NOT moved: %@",
          VMLayout.errorTail(synced)))
    }
    let moved = try? await VMLayout.rootShell(
      repointScript(oldRemote: old, newRemote: new, stamp: VMBundlePrep.stamp()), timeout: 1800)
    guard moved?.succeeded == true, moved?.stdout.contains("CM-REPOINTED") == true else {
      return fail(
        L10n.tr(
          "Moving the machine failed; it went back to %@: %@", old, VMLayout.errorTail(moved)))
    }
    do {
      if direction == .encrypt {
        try FileManager.default.createDirectory(
          at: markerFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try markerText(switchedAt: Date()).write(to: markerFile, atomically: true, encoding: .utf8)
      } else {
        try FileManager.default.removeItem(at: markerFile)
      }
    } catch {
      return fail(
        L10n.tr(
          "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.",
          new, markerFile.path, error.localizedDescription))
    }
    CMLogger.log("vm-encrypt: \(direction) done - machine on \(new)")
    return Outcome(
      succeeded: true,
      message: L10n.tr(
        "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable",
        new, old))
  }

  /// Step 4.
  public static func deletePlain(secretsSavedElsewhere: Bool, restoreChecked: Bool) async
    -> Outcome
  {
    if let refusal = currentThrowawayRefusal { return fail(refusal) }
    let plist = BackupHealth.loadPreferences(BackupHealth.preferencesPath)
    let meta = try? await VMLayout.rootShell(
      "stat -c %Y \(VMLayout.Guest.metaSyncStamp)", timeout: 60)
    let facts = DeleteFacts(
      switchedAt: switchedAt,
      lastBackup: plist.flatMap { BackupHealth.dates(inPreferences: $0).lastSuccess },
      lastMetaSync: meta.flatMap { $0.succeeded ? metaSyncDate($0.stdout) : nil },
      reading: await VMLayout.currentReading(),
      secretsSavedElsewhere: secretsSavedElsewhere, restoreChecked: restoreChecked)
    if let refusal = deleteRefusal(facts) { return fail(refusal) }
    let deleted = try? await VMLayout.rootShell(
      deletePlainScript(plain: VMLayout.plainRemote), timeout: 3600)
    guard deleted?.succeeded == true, deleted?.stdout.contains("CM-DELETED") == true else {
      return fail(L10n.tr("Deleting the plain folder failed: %@", VMLayout.errorTail(deleted)))
    }
    return Outcome(
      succeeded: true,
      message: L10n.tr(
        "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).",
        VMLayout.plainRemote))
  }

  /// `stat -c %Y` of the metadata stamp.
  static func metaSyncDate(_ statOutput: String) -> Date? {
    TimeInterval(statOutput.trimmingCharacters(in: .whitespacesAndNewlines))
      .map(Date.init(timeIntervalSince1970:))
  }

  /// Read-only: where things stand.
  public static func status() async -> [String] {
    var out = [
      L10n.tr("Machine uses:     %@", isEnabled ? encryptedRemote : VMLayout.plainRemote),
      L10n.tr("Encrypted folder: %@", cryptRoot),
    ]
    if let switchedAt {
      out.append(L10n.tr("Switched:         %@", BackupHealth.stamp(switchedAt)))
    }
    let shown = try? await VMLayout.rootShell(copyStateScript, timeout: 60)
    let state = shown?.succeeded == true ? copyState(showOutput: shown!.stdout) : .unknown
    out.append(L10n.tr("Copy:             %@", "\(state)"))
    let tail = try? await VMLayout.rootShell("tail -n 3 \(copyLog) 2>/dev/null", timeout: 60)
    if let text = tail?.stdout, !text.isEmpty { out.append(text.trimmingCharacters(in: .newlines)) }
    return out
  }
}
