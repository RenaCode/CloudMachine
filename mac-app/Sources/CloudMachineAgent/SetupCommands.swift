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

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr(
        "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later."
      )))
  var folder: String?

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let result = await RemoteConfigurer.connect(
      config: config, machineKey: key, replaceExisting: replaceExisting, folder: folder)
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

struct SetLimit: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "set-limit",
    abstract: L10n.tr(
      "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command."))

  @Option(name: .long, help: ArgumentHelp(L10n.tr("Limit in GB.")))
  var gb: Int

  func run() async throws {
    do {
      try MachineBudget.setLimitGB(gb)
    } catch let error as MachineBudget.BudgetError {
      print(error.message)
      throw ExitCode.failure
    }
    print(L10n.tr("Limit for this Mac: %@ GB.", "\(gb)"))
    if let id = await TimeMachineStatus.destinationID(
      forMountPointContaining: BackupImageService.targetPath.path)
    {
      print(L10n.tr("Now set the Time Machine quota (needs an administrator password):"))
      print("  " + MachineBudget.setQuotaCommand(destinationID: id, limitGB: gb))
    }
    await MachineBudget.measureUsage()
  }
}
