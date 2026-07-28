import ArgumentParser
import CloudMachineCore
import Foundation

struct VerifyBackup: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "verify-backup",
    abstract:
      "Pelna weryfikacja spojnosci najnowszego backupu (destinationinfo, listbackups, verifychecksums)."
  )

  func run() async throws {
    let result = await BackupVerifier.runFullCheck()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct ArchiveNow: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "archive-now",
    abstract: "Recznie kopiuje wszystkie jeszcze nie zarchiwizowane lokalne backupy na Google Drive."
  )

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let result = await CloudArchiveService.archivePending(config: config, machineKey: key)
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct InstallLaunchd: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-launchd",
    abstract: "Generuje i instaluje agentow launchd (verify-watchdog, archive-watchdog)."
  )

  func run() async throws {
    let result = await LaunchdInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct ConfigureRemote: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "configure-remote",
    abstract:
      "Laczy z Google Drive przez rclone (OAuth w przegladarce) i tworzy folder tej maszyny.")

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let result = await RemoteConfigurer.connect(config: config, machineKey: key)
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct InstallDependencies: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-dependencies",
    abstract: "Instaluje rclone przez Homebrew (zaklada, ze Homebrew jest juz obecny).")

  func run() async throws {
    let result = await DependencyInstaller.installRclone()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}
