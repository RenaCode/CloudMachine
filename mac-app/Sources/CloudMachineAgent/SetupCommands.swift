import ArgumentParser
import CloudMachineCore
import Foundation

struct VerifyBackup: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "verify-backup",
    abstract:
      "Pelna weryfikacja spojnosci najnowszego backupu (destinationinfo, listbackups, verifychecksums, rclone check)."
  )

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let result = await BackupVerifier.runFullCheck(config: config, machineKey: key)
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct InstallLaunchd: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-launchd",
    abstract:
      "Generuje i instaluje agentow launchd (mount-watchdog, backup-watchdog, quota-watchdog, verify-watchdog)."
  )

  func run() async throws {
    let result = await LaunchdInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct SetupTimeMachine: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "setup-timemachine",
    abstract: "Rejestruje zamontowany sparsebundle jako cel Time Machine.")

  func run() async throws {
    let (_, key) = await CLIContext.load()
    let result = await TimeMachineSetup.registerUnattended(machineKey: key)
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
