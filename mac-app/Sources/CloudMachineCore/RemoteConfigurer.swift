import Foundation

/// Port of `configure-remote.sh` (+ merged with the old `CloudMachineController.
/// connectGoogleDrive()` in the GUI) - connects to Google Drive via `rclone
/// authorize` (non-interactive OAuth in the browser), instead of the older,
/// interactive `rclone config` wizard. The CLI and the GUI now use EXACTLY the
/// same sign-in path.
public enum RemoteConfigurer {
  /// Whether the remote exists in the rclone configuration.
  ///
  /// Asks the binary managed by CloudMachine, not the one from Homebrew. Both
  /// read the same configuration file, but the rest of the system runs on ours
  /// - and the state shown to the user must describe what we really use, not
  /// an incidental second installation that may one day not be there.
  public static func isConfigured(remoteName: String) async -> Bool {
    guard let result = try? await CMTooling.runRclone(["listremotes"], timeout: 30) else {
      return false
    }
    return result.stdout.contains("\(remoteName):")
  }

  /// Keychain service under which the own OAuth credentials are stored.
  public static let keychainService = "cloudmachine-gdrive"

  /// Reads `client_id` / `client_secret` from the Keychain.
  ///
  /// The README had long described this as a working part of
  /// `configure-remote`, yet NOT A SINGLE line of code did it - `rclone
  /// authorize drive` ran on rclone's shared `client_id`, the very one the
  /// README says is being retired and is rate-limited jointly with all rclone
  /// users. The documentation described a safeguard that did not exist.
  static func keychainSecret(account: String) async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/security",
        ["find-generic-password", "-a", account, "-s", keychainService, "-w"],
        timeout: 30),
      result.succeeded
    else { return nil }
    let value = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return value.isEmpty ? nil : value
  }

  public static func extractToken(from output: String) -> String? {
    guard let startRange = output.range(of: "--->"),
      let endRange = output.range(of: "<---")
    else { return nil }
    let token = output[startRange.upperBound..<endRange.lowerBound]
    return token.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Connects to Google Drive and prepares EXACTLY the remote and folder that
  /// the mount uses.
  ///
  /// Previously the names were taken from `machines.json` (`remote_name`,
  /// `gdrive-cloudmachine` by default, plus a folder with the machine key),
  /// while the mount runs on the constants `DriveBufferService.remoteName` /
  /// `.remotePath` (`gdrive:CloudMachine/mac-studio`). The documented
  /// installation path - `configure-remote`, then `create-image` - therefore
  /// ended with a remote nobody ever uses, and a "Drive is not mounted" error
  /// at the next step. The working installation on this machine has a
  /// `[gdrive]` put together by hand; it could not be reproduced from the repo
  /// alone.
  ///
  /// `config` and `machineKey` stay in the signature because the GUI and the
  /// CLI have them, but from now on the remote's name is decided by the same
  /// constant that builds the mount command. One source of truth or none.
  @discardableResult
  public static func connect(
    config: MachinesConfig, machineKey: String, replaceExisting: Bool = false
  ) async -> CMActionResult {
    let remoteName = DriveBufferService.remoteName
    let remotePath = "\(remoteName):\(DriveBufferService.remotePath)"

    // We ABORT rather than warn. `rclone config create` overwrites an entry
    // with the same name without asking, and with it the token, `client_id`
    // and `scope` of the working installation. A new credential with the
    // `drive.file` scope sees only files created by ITSELF - the existing
    // backup image, created by the previous credential, then becomes
    // invisible and the mount stops finding it. The backup is intact, but
    // inaccessible, which in practice means the same thing.
    if !replaceExisting, await isConfigured(remoteName: remoteName) {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.",
          remoteName))
    }

    // Own OAuth credentials from the Keychain. On rclone's shared `client_id`
    // we compete for the rate limit with all rclone users, and that
    // `client_id` itself is being retired in 2026.
    let clientID = await keychainSecret(account: "client_id")
    let clientSecret = await keychainSecret(account: "client_secret")
    // We pass them to `authorize` through the ENVIRONMENT, not as arguments:
    // on macOS every user can see every process's command line via `ps`,
    // while the environment is visible only to the process owner and root.
    // `rclone authorize` waits for approval in the browser, so this process
    // lives for minutes, not for a fraction of a second.
    var authEnv: [String: String] = [:]
    if let clientID, let clientSecret {
      authEnv["RCLONE_DRIVE_CLIENT_ID"] = clientID
      authEnv["RCLONE_DRIVE_CLIENT_SECRET"] = clientSecret
    } else {
      // We do NOT abort - without our own keys the connection still works,
      // just worse. But we say so plainly instead of staying silent: this was
      // exactly the difference the README described as handled, and which
      // was not.
      CMLogger.log(
        "WARNING: no client_id/client_secret in the Keychain (service '\(keychainService)') - connecting with rclone's shared client_id, which is rate-limited jointly and being retired in 2026. See the README."
      )
    }

    // `drive.file` restricts access to files this application created
    // itself. Full `drive` - the default for `rclone authorize drive`, and
    // what the working installation has - grants reading, changing and
    // DELETING the entire contents of the Google account. That is an
    // incomparably broader permission than a directory with the bands of one
    // image needs, all the more so because the mount runs with
    // `--drive-use-trash=false`, so deletion has no trash from which anything
    // could be undone.
    //
    // Binary: THE SAME one the rest of the system uses
    // (`~/.cloudmachine/bin/rclone`), not `/usr/bin/env rclone`. Until
    // 23.09.2026 `connect` went through `env`, i.e. to rclone from Homebrew -
    // while `isConfigured` in this same file and the whole mount go through
    // `CMTooling.runRclone`. There were two consequences, both silent: without
    // Homebrew the documented installation path (`install-rclone`, then
    // `configure-remote`) ended with exit code 127 and a message without a
    // cause, and WITH Homebrew the configuration was written by a DIFFERENT
    // binary than the one the system then uses.
    //
    // `authorize` is called via `ProcessRunner.run` directly on the managed
    // binary's path, because `CMTooling.runRclone` does not accept `env`,
    // and the OAuth keys MUST go through the environment (see the comment
    // above) and `CMTooling.swift` was outside the scope of this fix.
    guard
      let authResult = try? await ProcessRunner.run(
        CMTooling.managedRclonePath.path,
        ["authorize", "drive", "--drive-scope", "drive.file"],
        env: authEnv, timeout: 300),
      authResult.succeeded
    else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.",
          CMTooling.managedRclonePath.path))
    }
    guard let token = extractToken(from: authResult.stdout) else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("Could not read the token from the output of rclone authorize."))
    }
    // Here the keys MUST go as arguments - `config create` is supposed to
    // write them to `rclone.conf`, so the environment would not help. The
    // process takes a fraction of a second and runs once, unlike `authorize`
    // above.
    var createArgs = ["config", "create", remoteName, "drive", "scope=drive.file"]
    if let clientID, let clientSecret {
      createArgs += ["client_id=\(clientID)", "client_secret=\(clientSecret)"]
    }
    createArgs.append("token=\(token)")
    // Again the same binary as the mount: if `config create` went through
    // Homebrew, it would write the entry into a configuration that the binary
    // used by the system may not read - and then `isConfigured` says "there is
    // no remote" right after a successful "connected".
    let createResult = try? await CMTooling.runRclone(createArgs, timeout: 60)
    guard createResult?.succeeded == true else {
      return CMActionResult(succeeded: false, message: L10n.tr("rclone config create failed."))
    }
    let mkdirResult = try? await CMTooling.runRclone(["mkdir", remotePath], timeout: 120)
    guard mkdirResult?.succeeded == true else {
      // We RETURN AN ERROR, not "success": the remote exists, but without
      // this folder we have no confirmation that writing to this account
      // actually works - and the next installation step (`create-image`)
      // assumes it does.
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Connected to Google Drive, but could not create the folder '%@' - without it the mount will not start. Check the account permissions and try again.",
          remotePath))
    }
    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "Connected to Google Drive as remote '%@', folder %@.", remoteName, remotePath))
  }
}
