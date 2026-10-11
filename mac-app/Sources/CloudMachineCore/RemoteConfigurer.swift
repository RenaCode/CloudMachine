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
  ///
  /// `nil` = rclone DID NOT ANSWER (time limit, a failed start, an unreadable
  /// or broken `rclone.conf` - which rclone reports with exit code 1). Until
  /// 09.10.2026 all of that came out as `false`, i.e. "there is no remote",
  /// and the two guards built on this answer opened on it: `connect` went on
  /// to overwrite the working token, and `DriveFolder` took an installation
  /// whose backup lives in `mac-studio` for a new Mac and gave it a new, empty
  /// folder.
  ///
  /// "Not listed" is an answer only when rclone READ a configuration. Without
  /// `rclone.conf` it lists nothing and exits 0 - and on a Mac whose mount has
  /// already run (`InstallationTraces`), a lost file is far likelier than a
  /// remote that never was. That case is `nil` too: answered "no remote", it
  /// gave such a Mac a new, empty Drive folder for good (second audit, S4).
  public static func isConfigured(remoteName: String) async -> Bool? {
    let listed = remoteListed(
      remoteName, in: try? await CMTooling.runRclone(["listremotes"], timeout: 30))
    guard listed == false else { return listed }
    let configFile = configFileExists(
      in: try? await CMTooling.runRclone(["config", "file"], timeout: 30))
    let folders = InstallationTraces.cachedFolders()
    let answer = absentAnswer(configFileExists: configFile, cachedFolders: folders)
    if answer == nil {
      CMLogger.log(
        "rclone lists no '\(remoteName)' remote, but its configuration file "
          + (configFile == false ? "does not exist" : "could not be checked")
          + " while this Mac has cached Drive folders (\(folders.joined(separator: ", "))) -"
          + " treating it as UNKNOWN, not as 'no remote'")
    }
    return answer
  }

  /// Pure: what "the remote is not listed" means, given whether rclone's
  /// configuration file exists (`nil` = could not tell) and which Drive
  /// folders a mount has already cached here.
  static func absentAnswer(configFileExists: Bool?, cachedFolders: [String]) -> Bool? {
    if configFileExists == true { return false }
    return cachedFolders.isEmpty ? false : nil
  }

  /// Reads `rclone config file`. rclone says outright when the file is
  /// missing ("Configuration file doesn't exist, but rclone will use this
  /// path:"); otherwise the last line is the path, checked on disk. `nil` =
  /// no usable answer.
  static func configFileExists(in result: ProcessResult?) -> Bool? {
    guard let result, result.succeeded else { return nil }
    if result.stdout.lowercased().contains("doesn't exist") { return false }
    guard
      let path = result.stdout.split(whereSeparator: \.isNewline).last
        .map({ $0.trimmingCharacters(in: .whitespaces) }), path.hasPrefix("/")
    else { return nil }
    return FileManager.default.fileExists(atPath: path)
  }

  /// Pure reading of `rclone listremotes`, so the "no answer" cases can be
  /// tested. One remote per line, as `name:`; a whole line must match, so that
  /// `mygdrive:` is not taken for `gdrive:`.
  static func remoteListed(_ remoteName: String, in result: ProcessResult?) -> Bool? {
    guard let result, result.succeeded else { return nil }
    return result.stdout.split(whereSeparator: \.isNewline).contains {
      $0.trimmingCharacters(in: .whitespaces) == "\(remoteName):"
    }
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
  ///
  /// `acceptScopeChange` is the second, explicit "yes" that replacing an
  /// existing remote needs - see `replacementGate`. Even with it, the new
  /// token is checked against the existing image before anything is written
  /// (`replacementVerdict`).
  @discardableResult
  public static func connect(
    config: MachinesConfig, machineKey: String, replaceExisting: Bool = false,
    acceptScopeChange: Bool = false, folder: String? = nil
  ) async -> CMActionResult {
    let remoteName = DriveBufferService.remoteName

    // We ABORT rather than warn. `rclone config create` overwrites an entry
    // with the same name without asking, and with it the token, `client_id`
    // and `scope` of the working installation. A new credential with the
    // `drive.file` scope sees only files created by ITSELF - the existing
    // backup image, created by the previous credential, then becomes
    // invisible and the mount stops finding it. The backup is intact, but
    // inaccessible, which in practice means the same thing.
    let configured = await isConfigured(remoteName: remoteName)
    // "Could not check" stops here as firmly as "it exists": both mean we do
    // not know that there is nothing to overwrite. Even with
    // `--replace-existing` - the folder decision below needs this answer too.
    guard let configured else {
      var message = L10n.tr(
        "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.",
        remoteName, CMTooling.managedRclonePath.path)
      let folders = InstallationTraces.cachedFolders()
      if !folders.isEmpty {
        message +=
          "\n"
          + L10n.tr(
            "Or rclone.conf is missing: this Mac has already backed up to Google Drive (folders %@), so it is not connected anew blindly. Restore the file from a backup. To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.",
            folders.joined(separator: ", "), CMTooling.managedRclonePath.path)
      }
      return CMActionResult(succeeded: false, message: message)
    }
    if let refusal = replacementGate(
      configured: configured, replaceExisting: replaceExisting,
      acceptScopeChange: acceptScopeChange, remoteName: remoteName)
    {
      return refusal
    }

    // The folder is decided BEFORE the remote is created: an existing remote
    // is how `DriveFolder` recognises an installation whose backup already
    // lives under the legacy name. Asked after `config create`, every new Mac
    // would look like an old one and land in `mac-studio`.
    switch await DriveFolder.resolve(requested: folder) {
    case .failure(let refused):
      return CMActionResult(succeeded: false, message: refused.message)
    case .success:
      break
    }
    let remotePath = "\(remoteName):\(DriveBufferService.remotePath)"

    // What the CURRENT connection sees, asked before it is replaced: the new
    // token will be held against it. No answer stops here - the check below
    // would have nothing to compare with.
    var imageBefore: BackupImageService.RemotePresence?
    if configured {
      let presence = await BackupImageService.remoteImagePresence()
      if case .unknown(let why) = presence {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "Could not check with the current connection whether the backup image is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.",
            why, remoteName))
      }
      imageBefore = presence
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
    if let imageBefore {
      let imageAfter = await imagePresence(
        token: token, clientID: clientID, clientSecret: clientSecret)
      if let refusal = replacementVerdict(
        before: imageBefore, after: imageAfter, remoteName: remoteName)
      {
        return refusal
      }
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

  // MARK: - Replacing an existing remote

  /// Whether `connect` may go on, given what the user asked for. `nil` = go
  /// on; otherwise the refusal.
  ///
  /// Replacing a working remote takes TWO flags. The first,
  /// `--replace-existing`, is easy to reach for - until 11.10.2026 the panel
  /// itself suggested it after every change of the Google credentials. On a
  /// Mac like this project's own (`scope = drive`, its own `client_id`), the
  /// new sign-in gets `drive.file` and does not see the existing image: the
  /// mount shows an empty folder and `create-image` sees nothing to protect.
  /// The second flag is there so that the user has read that sentence.
  static func replacementGate(
    configured: Bool, replaceExisting: Bool, acceptScopeChange: Bool, remoteName: String
  ) -> CMActionResult? {
    guard configured else { return nil }
    guard replaceExisting else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.",
          remoteName))
    }
    guard acceptScopeChange else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible: the mount would show an empty folder, and create-image could start a second, empty backup next to it. Before anything is written, the new token is checked against the existing image, and the replacement is abandoned if it cannot see it. To go ahead, run again with --replace-existing --accept-scope-change.",
          remoteName))
    }
    return nil
  }

  /// Whether the new token may replace the remote, given what the old one and
  /// the new one see. `nil` = it may.
  ///
  /// Only an image that WAS visible can be lost: with none before, there is
  /// nothing for the new token to miss. When there was one, the new token
  /// has to see it too - "absent" and "no answer" both stop the replacement,
  /// because writing the token is the step that cannot be taken back (the
  /// old token is gone from `rclone.conf` with it).
  static func replacementVerdict(
    before: BackupImageService.RemotePresence, after: BackupImageService.RemotePresence,
    remoteName: String
  ) -> CMActionResult? {
    guard before == .present else { return nil }
    let why: String
    switch after {
    case .present: return nil
    case .absent: why = L10n.tr("it is not there for the new token")
    case .unknown(let reason): why = reason
    }
    return CMActionResult(
      succeeded: false,
      message: L10n.tr(
        "The new sign-in does NOT see the existing backup image (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. With this token the mount would show an empty folder. Keep the current connection, or sign in with the credential (client_id) that created the image.",
        why, remoteName))
  }

  /// Whether `token` sees this Mac's image - the same `lsf` as
  /// `BackupImageService.remoteImagePresence`, on a remote defined only for
  /// this call (`:drive:`), so nothing is written to `rclone.conf`. The token
  /// and the keys go through the environment, not the command line, for the
  /// reason given at `authorize`.
  static func imagePresence(token: String, clientID: String?, clientSecret: String?) async
    -> BackupImageService.RemotePresence
  {
    var env = ["RCLONE_DRIVE_TOKEN": token, "RCLONE_DRIVE_SCOPE": "drive.file"]
    if let clientID, let clientSecret {
      env["RCLONE_DRIVE_CLIENT_ID"] = clientID
      env["RCLONE_DRIVE_CLIENT_SECRET"] = clientSecret
    }
    guard
      let result = try? await ProcessRunner.run(
        CMTooling.managedRclonePath.path,
        ["lsf", "--dirs-only", ":drive:\(DriveBufferService.remotePath)"], env: env, timeout: 120)
    else {
      return .unknown(L10n.tr("rclone did not answer"))
    }
    return BackupImageService.classifyRemoteListing(
      succeeded: result.succeeded, stdout: result.stdout, stderr: result.stderr)
  }

  // MARK: - Saving credentials

  /// What the panel says after the Google credentials are saved.
  ///
  /// Until 11.10.2026 it always ended with "to use the new one, run
  /// configure-remote --replace-existing" - on a working installation, the
  /// one command that can make its backup invisible (see `replacementGate`).
  /// `nil` (not known yet) is answered as "connected": advice that is
  /// harmless on a new Mac, instead of advice that is dangerous on an old one.
  public static func credentialsSavedMessage(remoteConfigured: Bool?) -> String {
    if remoteConfigured == false {
      return L10n.tr(
        "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.")
    }
    return L10n.tr(
      "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet."
    )
  }
}
