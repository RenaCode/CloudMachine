import Foundation
import Security

/// `vm-setup`: creates or starts the machine from `vm/cmsmb.yaml`, gives it
/// rclone's configuration and the Drive folder, sets the SMB password, and
/// prints the one `tmutil` command only an administrator can run.
///
/// Every step checks first, so running it again is safe: an existing machine
/// is started, not recreated; an existing password is kept; an existing
/// rclone configuration in the machine is kept unless asked otherwise (rclone
/// in the machine refreshes its own token and writes it back there).
public enum VMSetup {
  public struct Result: Sendable {
    public var succeeded: Bool
    public var messages: [String]
    /// The `tmutil setdestination` command - holds the password, so it is
    /// printed for the person and never logged.
    public var destinationCommand: String?
  }

  public static func run(replaceRcloneConfig: Bool) async -> Result {
    var messages: [String] = []
    func fail(_ message: String) -> Result {
      CMLogger.log("vm-setup: \(message)")
      return Result(succeeded: false, messages: messages + [message], destinationCommand: nil)
    }

    guard VMLayout.limactlPath != nil else {
      return fail(L10n.tr("limactl not found - install Lima: brew install lima"))
    }
    guard let templates = VMLayout.templateDir else {
      return fail(L10n.tr("Could not find the vm/ directory with the machine template."))
    }
    guard FileManager.default.fileExists(atPath: VMLayout.hostRcloneConfig.path) else {
      return fail(
        L10n.tr(
          "No rclone configuration at %@ - connect Google Drive first (configure-remote).",
          VMLayout.hostRcloneConfig.path))
    }

    // 1. The machine.
    let status: String?
    do {
      status = try await VMLayout.instanceStatus()
    } catch {
      return fail(L10n.tr("Could not ask Lima about the machine: %@", error.localizedDescription))
    }
    if status == nil {
      messages.append(
        L10n.tr(
          "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...",
          VMLayout.instanceName))
      CMLogger.log("vm-setup: creating \(VMLayout.instanceName)")
      let template = templates.appendingPathComponent("cmsmb.yaml").path
      let created = try? await VMLayout.limactl(
        ["create", "--tty=false", "--name", VMLayout.instanceName, template], timeout: 1800)
      guard created?.succeeded == true else {
        return fail(L10n.tr("limactl create failed: %@", VMLayout.errorTail(created)))
      }
    }
    // The first boot of a new machine can take ~30 min on Ubuntu 24.04 (27.10.2026; 1 min on 28.10):
    // Lima copies every `mode: data` file with `sudo -iu root`, and while
    // cloud-final runs logind cannot open the session - pam_systemd waits 2 min
    // per file. Lima gives up after 10 min by default; later boots take seconds.
    if status != "Running" {
      CMLogger.log("vm-setup: starting \(VMLayout.instanceName)")
      let started = try? await VMLayout.limactl(
        ["start", "--tty=false", "--timeout", "50m", VMLayout.instanceName], timeout: 3600)
      guard started?.succeeded == true else {
        return fail(
          L10n.tr(
            "limactl start failed: %@\nThe machine's own log: %@", VMLayout.errorTail(started),
            "~/.lima/\(VMLayout.instanceName)/ha.stderr.log"))
      }
      messages.append(L10n.tr("Machine %@ is running.", VMLayout.instanceName))
    } else {
      messages.append(L10n.tr("Machine %@ was already running.", VMLayout.instanceName))
    }

    if await VMLayout.excludeMachineFromTimeMachine() {
      messages.append(
        L10n.tr(
          "Excluded %@ (the machine and its upload buffer) from Time Machine.",
          VMLayout.limaHome.path))
    } else {
      messages.append(
        L10n.tr(
          "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@",
          VMLayout.limaHome.path, VMLayout.limaHome.path))
    }

    // 2. The Drive folder.
    let env = VMLayout.envLine("CM_REMOTE", VMLayout.remote)
    guard
      let wroteEnv = try? await VMLayout.rootShell(
        "mkdir -p /etc/cloudmachine && printf '%s\\n' \(VMLayout.shellQuoted(env)) > \(VMLayout.Guest.vmEnv)",
        timeout: 60), wroteEnv.succeeded
    else { return fail(L10n.tr("Could not write %@ in the machine.", VMLayout.Guest.vmEnv)) }
    messages.append(L10n.tr("Google Drive folder: %@", VMLayout.remote))

    // 3. rclone's configuration.
    let hasConfig =
      (try? await VMLayout.rootShell("test -s \(VMLayout.Guest.rcloneConfig)", timeout: 60))?
      .succeeded == true
    if !hasConfig || replaceRcloneConfig {
      guard await copyIn(VMLayout.hostRcloneConfig, to: VMLayout.Guest.rcloneConfig, mode: "600")
      else { return fail(L10n.tr("Could not copy the rclone configuration into the machine.")) }
      messages.append(L10n.tr("rclone configuration copied into the machine."))
    } else {
      messages.append(
        L10n.tr(
          "rclone configuration already in the machine - kept (--replace-rclone-config replaces it)."
        ))
    }
    let made = try? await VMLayout.rootShell(
      "/usr/local/bin/rclone --config \(VMLayout.Guest.rcloneConfig) mkdir \(VMLayout.shellQuoted(VMLayout.remote))",
      timeout: 300)
    guard made?.succeeded == true else {
      return fail(
        L10n.tr(
          "Could not create %@ on Google Drive: %@", VMLayout.remote, VMLayout.errorTail(made)))
    }

    // 4. The SMB password.
    let password: String
    switch loadOrCreatePassword() {
    case .some(let value): password = value
    case .none:
      return fail(L10n.tr("Could not write the password file %@.", VMLayout.passwordFile.path))
    }
    guard await setSmbPassword() else {
      return fail(
        L10n.tr("Could not set the SMB password of user %@ in the machine.", VMLayout.smbUser))
    }
    messages.append(L10n.tr("SMB password stored in %@ (mode 600).", VMLayout.passwordFile.path))

    // 5. Services.
    let units = VMLayout.services.map(VMLayout.unitName).joined(separator: " ")
    guard
      let started = try? await VMLayout.rootShell(
        "systemctl daemon-reload && systemctl start \(units)", timeout: 300),
      started.succeeded
    else {
      return fail(
        L10n.tr("The services in the machine did not start - check: cloudmachine-agent vm-status"))
    }

    // 6. The address and the command.
    guard let address = await VMLayout.currentAddress() else {
      return fail(L10n.tr("The machine has no address on the vzNAT network."))
    }
    let command = destinationCommand(password: password, address: address)
    CMLogger.log("vm-setup: done, machine at \(address)")
    return Result(succeeded: true, messages: messages, destinationCommand: command)
  }

  /// The SMB password `vm-setup` stored, if it did. Never creates one.
  public static func storedPassword(file: URL = VMLayout.passwordFile) -> String? {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return nil }
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  /// The same command with the password masked - for showing on screen; the
  /// real one goes only to the clipboard.
  public static func maskedDestinationCommand(address: String) -> String {
    "sudo tmutil setdestination 'smb://\(VMLayout.smbUser):••••••@\(address)/\(VMLayout.shareName)'"
  }

  /// `sudo tmutil setdestination smb://tm:<password>@<address>/CloudMachine`.
  public static func destinationCommand(password: String, address: String) -> String {
    let allowed = CharacterSet.alphanumerics
    let user = VMLayout.smbUser
    let encoded = password.addingPercentEncoding(withAllowedCharacters: allowed) ?? password
    return "sudo tmutil setdestination 'smb://\(user):\(encoded)@\(address)/\(VMLayout.shareName)'"
  }

  /// Copies a Mac file into the machine as root with the given mode.
  /// `limactl copy` writes as the Lima user, so the file goes to a private
  /// temporary directory first and is moved with `install`.
  static func copyIn(_ source: URL, to destination: String, mode: String) async -> Bool {
    let staging = "/tmp/cm-copy-\(UUID().uuidString)"
    guard
      let made = try? await VMLayout.limactl(
        ["shell", "--workdir", "/", VMLayout.instanceName, "install", "-d", "-m", "700", staging],
        timeout: 60), made.succeeded,
      let copied = try? await VMLayout.limactl(
        ["copy", source.path, "\(VMLayout.instanceName):\(staging)/file"], timeout: 300),
      copied.succeeded
    else { return false }
    let moved = try? await VMLayout.rootShell(
      "install -D -m \(mode) -o root -g root \(staging)/file \(VMLayout.shellQuoted(destination)); "
        + "rc=$?; rm -rf \(staging); exit $rc", timeout: 60)
    return moved?.succeeded == true
  }

  /// The password from the file, or a new one written with mode 600 from the
  /// start (never readable by others, not even for a moment).
  static func loadOrCreatePassword(file: URL = VMLayout.passwordFile) -> String? {
    if let existing = try? String(contentsOf: file, encoding: .utf8) {
      let trimmed = existing.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty { return trimmed }
    }
    try? FileManager.default.createDirectory(
      at: file.deletingLastPathComponent(), withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    guard let password = randomPassword() else { return nil }
    try? FileManager.default.removeItem(at: file)
    guard
      FileManager.default.createFile(
        atPath: file.path, contents: Data((password + "\n").utf8),
        attributes: [.posixPermissions: 0o600])
    else { return nil }
    return password
  }

  /// 24 characters from [A-Za-z0-9] - safe in a URL, a shell and smbpasswd.
  static func randomPassword(length: Int = 24) -> String? {
    let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
    var result = ""
    while result.count < length {
      var byte: UInt8 = 0
      guard SecRandomCopyBytes(kSecRandomDefault, 1, &byte) == errSecSuccess else { return nil }
      // Rejection sampling: 248 = 4 * 62, so every character is equally likely.
      if byte < 248 { result.append(alphabet[Int(byte) % alphabet.count]) }
    }
    return result
  }

  /// `smbpasswd` reads the password from the copied file, never from the
  /// command line (`ps` shows that) and never through the log.
  static func setSmbPassword() async -> Bool {
    let staging = "/tmp/cm-copy-\(UUID().uuidString)"
    guard
      let made = try? await VMLayout.limactl(
        ["shell", "--workdir", "/", VMLayout.instanceName, "install", "-d", "-m", "700", staging],
        timeout: 60), made.succeeded,
      let copied = try? await VMLayout.limactl(
        ["copy", VMLayout.passwordFile.path, "\(VMLayout.instanceName):\(staging)/p"], timeout: 60),
      copied.succeeded
    else { return false }
    let script =
      "p=$(head -1 \(staging)/p); rm -rf \(staging); "
      + "printf '%s\\n%s\\n' \"$p\" \"$p\" | smbpasswd -s -a \(VMLayout.smbUser) >/dev/null"
    return (try? await VMLayout.rootShell(script, timeout: 60))?.succeeded == true
  }
}
