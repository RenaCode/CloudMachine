import ArgumentParser
import CloudMachineCore
import Foundation

@main
struct CloudMachineAgent: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "cloudmachine-agent",
    abstract:
      L10n.tr(
        "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal."
      ),
    subcommands: [
      InstallLaunchd.self,
      ConfigureRemote.self,
      InstallDependencies.self,
      BuildApp.self,
      MakeDmg.self,
      SetupSigningCert.self,
      // The Google Drive layer - replaced the scripts in gdrive/.
      InstallRclone.self,
      InstallFuse.self,
      MountDrive.self,
      CreateImage.self,
      AttachImage.self,
      Version.self,
      DetachImage.self,
      VerifyImage.self,
      BufferGuard.self,
      BackupHealthCommand.self,
      PrepareShutdown.self,
      DriveStatus.self,
    ]
  )
}

/// Shared context (config + this machine's key) loaded by every subcommand
/// that needs it - one place to handle "config corrupted" instead of
/// repeating it in every file.
enum CLIContext {
  static func load() async -> (config: MachinesConfig, machineKey: String) {
    let outcome = ConfigStore.loadOrInitialize()
    // We ABORT, we do not warn. Previously the same message - "original kept
    // on disk with a backup copy next to it" - was also printed when
    // `backupCorruptFile()` returned `nil`, i.e. when there was no copy at all.
    // Working on an empty configuration ends with the only copy being
    // overwritten on the first save, and that can no longer be undone.
    guard let config = outcome.config else {
      CMLogger.log(
        """
        ABORTED: the configuration file \(CMPaths.configPath.path) is corrupted \
        (\(outcome.corruption?.localizedDescription ?? "unknown error")) and a copy of it \
        COULD NOT be set aside. With an empty configuration in memory the first save \
        would overwrite the only copy. Copy this file somewhere else, fix it or delete it - \
        and run the command again.
        """)
      exit(1)
    }
    if case .corruptButBackedUp(_, let backup, let error) = outcome {
      CMLogger.log(
        "ERROR: the configuration file is corrupted (\(error.localizedDescription)) - using an empty configuration in memory, original copied to \(backup.path)."
      )
    }
    let key = await MachineIdentity.currentKey()
    return (config, key)
  }
}
