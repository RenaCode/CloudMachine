import CloudMachineCore
import Foundation

/// What still has to be done before this Mac backs up, in the order it has to
/// be done.
///
/// Installed from Homebrew, the app is the first thing a person opens, so the
/// setup lives here: each step either has a button that does it, or - for the
/// ones that cannot run from the app - a command to copy. Google sign-in needs
/// a browser round trip that `configure-remote` waits on in a terminal,
/// installing Lima is Homebrew's job, and pointing Time Machine at the machine
/// needs `sudo`.
///
/// A pure function of what the controller measured, so the order and the
/// conditions are tested without a GUI. `nil` inputs mean "not measured
/// yet" and never produce a step: telling someone to set up a machine that
/// already exists is worse than showing the step a few seconds late.
struct SetupStep: Equatable {
  enum Action: Equatable {
    case installRclone
    case setUpMachine
    case startMachine
    case grantFullDiskAccess
    case installAgents
    case prepareBundle
  }

  let title: String
  /// Shown with a Copy button; for steps the app cannot do itself.
  let command: String?
  let action: Action?
  /// The step where this Mac's Drive folder is chosen: the card shows a name
  /// field and puts `--folder NAME` into the command.
  var choosesFolder = false
  /// What the card shows instead of `command`, when `command` holds a secret
  /// (the SMB password): the Copy button still copies `command`.
  var displayedCommand: String?
}

enum SetupPlan {
  struct Inputs: Equatable {
    var hasRclone: Bool
    var remoteConfigured: Bool
    var hasLima: Bool
    /// `nil` = Lima did not answer.
    var machineExists: Bool?
    var machineRunning: Bool
    var hasFullDiskAccess: Bool
    var agentsInstalled: Bool?
    var timeMachineNotPointingHere: Bool
    var bundleNeedsPreparing: Bool
    var connectCommand: String
    /// `nil` while the machine has no address or no stored password.
    var setDestinationCommand: String?
    var maskedSetDestinationCommand: String?
  }

  /// `configure-remote`, with `--folder` only for a valid name - an invalid
  /// one is left out rather than passed on to be refused.
  static func connectCommand(agent: String, folder: String?) -> String {
    let base = "\(agent) configure-remote"
    guard let folder, DriveFolder.isValid(folder) else { return base }
    return "\(base) --folder \(folder)"
  }

  static let installLimaCommand = "brew install lima"

  static func steps(_ input: Inputs) -> [SetupStep] {
    var steps: [SetupStep] = []
    if !input.hasRclone {
      steps.append(
        SetupStep(
          title: L10n.tr("Install rclone (signs in to Google Drive for the machine)"),
          command: nil, action: .installRclone))
    }
    // The Drive folder of this Mac is chosen here, before the machine is
    // created: the machine takes its folder from it.
    if !input.remoteConfigured {
      steps.append(
        SetupStep(
          title: L10n.tr("Connect Google Drive: run this in Terminal and approve in the browser"),
          command: input.connectCommand, action: nil, choosesFolder: true))
      return steps
    }
    if !input.hasLima {
      steps.append(
        SetupStep(
          title: L10n.tr("Install Lima, which runs the CloudMachine machine: run this in Terminal"),
          command: installLimaCommand, action: nil))
      return steps
    }
    if input.machineExists == false {
      steps.append(
        SetupStep(
          title: L10n.tr(
            "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)"
          ),
          command: nil, action: .setUpMachine))
      return steps
    }
    if input.machineExists == true, !input.machineRunning {
      steps.append(
        SetupStep(
          title: L10n.tr("Start the CloudMachine machine"), command: nil, action: .startMachine))
      return steps
    }
    if !input.hasFullDiskAccess {
      steps.append(
        SetupStep(
          title: L10n.tr(
            "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete"),
          command: nil, action: .grantFullDiskAccess))
    }
    if input.agentsInstalled == false {
      steps.append(
        SetupStep(
          title: L10n.tr(
            "Install the background agents (machine start, buffer guard, backup watchdog)"),
          command: nil, action: .installAgents))
      return steps
    }
    guard input.machineRunning else { return steps }
    if input.timeMachineNotPointingHere {
      if let command = input.setDestinationCommand {
        steps.append(
          SetupStep(
            title: L10n.tr(
              "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)"
            ),
            command: command, action: nil,
            displayedCommand: input.maskedSetDestinationCommand))
      } else {
        // No password file or no address: `vm-setup` writes the first and
        // reads the second, and prints the command itself.
        steps.append(
          SetupStep(
            title: L10n.tr(
              "Set up the CloudMachine machine again, so it prints the Time Machine command"),
            command: nil, action: .setUpMachine))
      }
      return steps
    }
    if input.bundleNeedsPreparing {
      steps.append(
        SetupStep(
          title: L10n.tr(
            "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands"
          ),
          command: nil, action: .prepareBundle))
    }
    return steps
  }
}
