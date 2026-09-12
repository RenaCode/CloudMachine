import ArgumentParser
import CloudMachineCore
import Foundation

struct InstallLaunchd: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-launchd",
    abstract: "Generuje i instaluje agentow launchd (bufor Drive, podpiecie obrazu, dozorca bufora)."
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

  @Flag(
    name: .long,
    help:
      "Nadpisz istniejacy remote. RYZYKOWNE: podmienia token i uprawnienia."
  )
  var replaceExisting = false

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let result = await RemoteConfigurer.connect(
      config: config, machineKey: key, replaceExisting: replaceExisting)
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}

struct InstallDependencies: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-dependencies",
    abstract: "Instaluje rclone przez Homebrew - UWAGA: ta wersja NIE umie montowac, patrz install-rclone.")

  func run() async throws {
    let result = await DependencyInstaller.installRclone()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}
