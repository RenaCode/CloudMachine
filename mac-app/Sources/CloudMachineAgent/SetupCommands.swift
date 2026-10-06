import ArgumentParser
import CloudMachineCore
import Foundation

struct InstallLaunchd: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-launchd",
    abstract:
      L10n.tr(
        "Generates and installs the launchd agents (Drive buffer, image attach, buffer guard).")
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
      L10n.tr(
        "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder."
      ))

  @Flag(
    name: .long,
    help:
      ArgumentHelp(
        L10n.tr("Overwrite the existing remote. RISKY: replaces the token and permissions."))
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
    abstract:
      L10n.tr(
        "Installs rclone through Homebrew - WARNING: this build CANNOT mount, see install-rclone."
      ))

  func run() async throws {
    let result = await DependencyInstaller.installRclone()
    print(result.message)
    if !result.succeeded { throw ExitCode.failure }
  }
}
