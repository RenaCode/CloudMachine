import ArgumentParser
import CloudMachineCore
import Foundation

/// The commands around the machine that are not `vm-*`: the watchdog, the
/// clean shutdown, the Mac's rclone and the version.

// MARK: - Backup cycle watchdog

struct BackupHealthCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "backup-health",
    abstract:
      L10n.tr(
        "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures."
      ))

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("After this many hours without a successful backup we consider the cycle broken.")))
  var maxAgeHours: Double = BackupHealth.maxAgeHours

  @Flag(
    name: .long, help: ArgumentHelp(L10n.tr("Only print the state, without a system notification."))
  )
  var quiet = false

  @Option(
    name: .long,
    help: ArgumentHelp(
      L10n.tr(
        "A different Time Machine preferences file - to test the watchdog on a known sample.")))
  var preferences: String = BackupHealth.preferencesPath

  func run() async throws {
    let report = await BackupHealth.currentReport(
      maxAgeHours: maxAgeHours, preferencesFile: preferences)

    // The "watchdog ran" marker - BEFORE printing anything and before deciding
    // the exit code, because a run that found a failure is just as much a run
    // as one that found nothing. Without it, the only symptom of a dead or hung
    // watchdog would be silence - and silence is the normal state here (see
    // `WatchdogHeartbeat`).
    WatchdogHeartbeat.record()

    // The watchdog runs every 30 minutes whether or not anyone opened the app,
    // so it is also what brings back an agent launchd stopped being able to
    // start (see `AgentRepair`), and what clears the retired layout's agents.
    await AgentRepair.removeRetiredAgents()
    let repaired = await AgentRepair.repairBroken()
    if !repaired.isEmpty {
      print(
        L10n.tr("Reloaded agents that could not start: %@", repaired.joined(separator: ", ")))
    }

    if let lastSuccess = report.lastSuccess {
      print(L10n.tr("Last successful backup: %@", BackupHealth.stamp(lastSuccess)))
    } else {
      print(L10n.tr("Last successful backup: NONE"))
    }
    if let lastAttempt = report.lastAttempt {
      print(L10n.tr("Last attempt:           %@", BackupHealth.stamp(lastAttempt)))
    }

    // Deferred for the startup period - not a failure, but we do not hide them.
    for problem in report.deferred {
      print(L10n.tr("WAITING (system startup): %@", problem.summary))
    }

    guard !report.healthy else {
      print(L10n.tr("Backup cycle: OK"))
      if !quiet { await HealthAlert.report(report) }
      return
    }

    for problem in report.problems {
      print(L10n.tr("FAILURE: %@", problem.summary))
      print(L10n.tr("         %@", problem.detail))
    }
    if !quiet { await HealthAlert.report(report) }

    // A non-zero exit code, so that launchd, `&&` in a script and a person
    // looking at `echo $?` get the same signal as the text above.
    throw ExitCode(1)
  }
}

// MARK: - Safe shutdown

struct PrepareShutdown: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "prepare-shutdown",
    abstract: L10n.tr(
      "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly."
    ))

  @Option(
    name: .long,
    help: ArgumentHelp(L10n.tr("At most this many minutes of waiting for the upload.")))
  var waitMinutes: Int = Int(VMShutdown.drainTimeout / 60)

  func run() async throws {
    let result = await VMShutdown.perform(
      drainTimeout: TimeInterval(max(0, waitMinutes) * 60), progress: { print($0) })
    print(result.message)
    guard result.succeeded else {
      print(L10n.tr("Check the state:  %@", "cloudmachine-agent vm-status"))
      throw ExitCode(1)
    }
  }
}

// MARK: - rclone installation

struct InstallRclone: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-rclone",
    abstract: L10n.tr(
      "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf)."
    ))

  func run() async throws {
    let result = await RcloneInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Version

/// Answers the question "is what runs the same as what is in the repository".
///
/// `1.1.0` alone does not answer it - so we print the commit and the state of
/// the tree at build time, and with no bundle we say outright that it is a
/// build from the working tree, instead of making up a number.
struct Version: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "version",
    abstract: L10n.tr(
      "Prints the version, the build number and the commit this binary was built from."))

  @Flag(name: .long, help: ArgumentHelp(L10n.tr("Only one line, without a description.")))
  var short = false

  func run() async throws {
    guard let version = AppVersionReader.current() else {
      print(L10n.tr("Build from the working tree (outside a bundle) - no version data."))
      return
    }
    guard !short else {
      print(version.summary)
      return
    }
    print(L10n.tr("Version: %@", version.shortVersion))
    print(L10n.tr("Build:   %@", version.build))
    print(L10n.tr("Commit:  %@", version.commit))
    if version.dirty {
      print("")
      print(
        L10n.tr(
          "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs."
        ))
    }
  }
}
