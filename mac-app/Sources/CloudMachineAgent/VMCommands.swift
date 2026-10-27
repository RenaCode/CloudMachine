import ArgumentParser
import CloudMachineCore
import Foundation

// The machine layout (Time Machine over SMB to a Lima VM) - see vm/README.md.
// It runs beside the attached-image commands; none of these touch the image.

struct VMSetupCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-setup",
    abstract: L10n.tr(
      "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command."
    ))

  @Flag(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("Copy rclone.conf into the machine even if it already has one.")))
  var replaceRcloneConfig = false

  @Flag(
    name: .long,
    help: ArgumentHelp(L10n.tr("Also install the vm-start and vm-guard launchd agents.")))
  var installAgents = false

  func run() async throws {
    let result = await VMSetup.run(replaceRcloneConfig: replaceRcloneConfig)
    for line in result.messages { print(line) }
    guard result.succeeded else { throw ExitCode.failure }
    if installAgents {
      let agents = await LaunchdInstaller.installVMAgents()
      print(agents.message)
      if !agents.succeeded { throw ExitCode.failure }
    }
    if let command = result.destinationCommand {
      // Printed, never logged: it holds the password.
      print("")
      print(
        L10n.tr("Point Time Machine at the machine (once, needs an administrator password):"))
      print("  \(command)")
      print(
        L10n.tr(
          "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle"
        ))
    }
  }
}

struct VMPrepareBundle: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-prepare-bundle",
    abstract: L10n.tr(
      "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive."
    ))

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("Image name in the machine (default: from the computer name).")))
  var bundle: String?

  func run() async throws {
    let outcome = await VMBundlePrep.run(bundleOverride: bundle)
    print(outcome.message)
    if !outcome.succeeded { throw ExitCode.failure }
  }
}

struct VMGuardCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-guard",
    abstract: L10n.tr(
      "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused."
    ))

  @Option(name: .long, help: ArgumentHelp(L10n.tr("Pause above this many GiB in the buffer.")))
  var highGiB: Int = VMGuard.Thresholds().highGiB

  @Option(
    name: .long,
    help: ArgumentHelp(L10n.tr("Resume below this many GiB (only a backup the guard paused).")))
  var lowGiB: Int = VMGuard.Thresholds().lowGiB

  @Option(
    name: .long,
    help: ArgumentHelp(L10n.tr("Pause when the machine has less free than this, in GiB."))
  )
  var minFreeGiB: Int = VMGuard.Thresholds().minFreeGiB

  func run() async throws {
    let guardian = VMGuard(
      thresholds: .init(highGiB: highGiB, lowGiB: lowGiB, minFreeGiB: minFreeGiB))
    await guardian.step()
  }
}

struct VMStatusCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-status",
    abstract: L10n.tr(
      "Shows the machine: address, services, upload buffer, free space and the Time Machine destination."
    ))

  func run() async throws {
    let (lines, healthy) = await VMStatus.lines()
    for line in lines { print(line) }
    if !healthy { throw ExitCode.failure }
  }
}
