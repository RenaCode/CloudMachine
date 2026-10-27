import ArgumentParser
import CloudMachineCore
import Foundation

// The machine (Time Machine over SMB to a Lima VM) - see vm/README.md.

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
    help: ArgumentHelp(L10n.tr("Also install the launchd agents (same as install-launchd).")))
  var installAgents = false

  func run() async throws {
    let result = await VMSetup.run(replaceRcloneConfig: replaceRcloneConfig)
    for line in result.messages { print(line) }
    guard result.succeeded else { throw ExitCode.failure }
    if installAgents {
      let agents = await LaunchdInstaller.install()
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

  @Flag(
    name: .long,
    help: ArgumentHelp(
      L10n.tr(
        "Only print what the guard would decide - for trying thresholds on a throwaway machine.")))
  var dryRun = false

  func run() async throws {
    let thresholds = VMGuard.Thresholds(highGiB: highGiB, lowGiB: lowGiB, minFreeGiB: minFreeGiB)
    guard dryRun else {
      await VMGuard(thresholds: thresholds).step()
      return
    }
    // Time Machine is global: a guard tried on `cmtest` would pause the live
    // machine's backup. Print the decision for every state it depends on.
    guard let reading = await VMLayout.currentReading() else {
      print(L10n.tr("No answer from the machine (rclone rc) - the guard would do nothing."))
      throw ExitCode.failure
    }
    let unsent = reading.buffer.unsentBytes.map { "\($0 / VMGuard.gib)" } ?? "?"
    print(
      L10n.tr(
        "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).",
        unsent, "\(reading.freeBytes / VMGuard.gib)", "\(highGiB)", "\(minFreeGiB)",
        "\(lowGiB)"))
    for (running, paused) in [(true, false), (true, true), (false, true)] {
      let action = VMGuard.decide(
        reading: reading, backupRunning: running, pausedByGuard: paused, thresholds: thresholds)
      print(
        L10n.tr(
          "Backup %@, paused by the guard %@: %@",
          running ? L10n.tr("running") : L10n.tr("stopped"),
          paused ? L10n.tr("yes") : L10n.tr("no"), "\(action)"))
    }
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
    print(L10n.tr("Drive folder:     %@", VMLayout.remote))

    let limit = MachineBudget.limitGB()
    print(
      L10n.tr(
        "Space limit:      %@",
        MachineBudget.summary(limitGB: limit, usage: MachineBudget.storedUsage())))
    if let limit, let destinations = await TimeMachineStatus.destinationsReading(),
      let ours = VMStatus.machineDestination(in: destinations, address: nil), let id = ours.id,
      !MachineBudget.quotaMatches(currentQuotaGB: ours.quotaGB, limitGB: limit)
    {
      print(
        L10n.tr(
          "                  Time Machine quota not set to match - run: %@",
          MachineBudget.setQuotaCommand(destinationID: id, limitGB: limit)))
    }

    // Who watches the watchdog: without this line "no alarm" meant both "the
    // backup works" and "nobody checked" - see `WatchdogHeartbeat`.
    print(L10n.tr("Backup watchdog:  %@", StatusLines.watchdogRun(WatchdogHeartbeat.current())))
    let broken = await AgentRepair.brokenAgents()
    print(
      L10n.tr(
        "Agents:           %@",
        broken.isEmpty
          ? "OK"
          : L10n.tr(
            "CANNOT START: %@ - open CloudMachine or run backup-health to reload them",
            broken.joined(separator: ", "))))
    // At the very end: an alarm whose notification failed is seen ONLY here.
    for line in StatusLines.undeliveredAlert(HealthAlert.lastDeliveryFailure()) {
      print(line)
    }
    if !healthy { throw ExitCode.failure }
  }
}
