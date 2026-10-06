import CloudMachineCore
import Foundation

/// What still has to be done before this Mac backs up, in the order it has to
/// be done.
///
/// Installed from Homebrew, the app is the first thing a person opens, so the
/// setup lives here: each step either has a button that does it, or - for the
/// two that cannot run from the app - a command to copy. Google sign-in needs a
/// browser round trip that `configure-remote` waits on in a terminal, and
/// pointing Time Machine at a disk needs `sudo`.
///
/// A pure function of what the controller measured, so the order and the
/// conditions are tested without a GUI. `nil` inputs mean "not measured
/// yet" and never produce a step: telling someone to create an image that
/// already exists is worse than showing the step a few seconds late.
struct SetupStep: Equatable {
  enum Action: Equatable {
    case installRclone
    case installFuse
    case grantFullDiskAccess
    case installAgents
    case createImage
    case attachImage
  }

  let title: String
  /// Shown with a Copy button; for steps the app cannot do itself.
  let command: String?
  let action: Action?
}

enum SetupPlan {
  struct Inputs: Equatable {
    var hasRclone: Bool
    var hasFuse: Bool
    var remoteConfigured: Bool
    var hasFullDiskAccess: Bool
    var agentsInstalled: Bool?
    var mounted: Bool
    var imageExists: Bool?
    var imageAttached: Bool
    var timeMachineNotPointingHere: Bool
    var connectCommand: String
    var setDestinationCommand: String
  }

  static func steps(_ input: Inputs) -> [SetupStep] {
    var steps: [SetupStep] = []
    if !input.hasRclone {
      steps.append(
        SetupStep(
          title: L10n.tr("Install rclone (the official build, which can mount)"), command: nil,
          action: .installRclone))
    }
    if !input.hasFuse {
      steps.append(
        SetupStep(title: L10n.tr("Install FUSE-T"), command: nil, action: .installFuse))
    }
    // Before anything that mounts: the Drive folder of this Mac is chosen
    // here, and a mount started earlier would use the legacy name.
    if !input.remoteConfigured {
      steps.append(
        SetupStep(
          title: L10n.tr("Connect Google Drive: run this in Terminal and approve in the browser"),
          command: input.connectCommand, action: nil))
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
          title: L10n.tr("Install the background agents (mount, image attach, watchdogs)"),
          command: nil, action: .installAgents))
      return steps
    }
    guard input.mounted else { return steps }
    if input.imageExists == false {
      steps.append(
        SetupStep(
          title: L10n.tr("Create the backup image on Google Drive"), command: nil,
          action: .createImage))
      return steps
    }
    if input.imageExists == true, !input.imageAttached {
      steps.append(
        SetupStep(title: L10n.tr("Attach the backup image"), command: nil, action: .attachImage))
      return steps
    }
    if input.imageAttached, input.timeMachineNotPointingHere {
      steps.append(
        SetupStep(
          title: L10n.tr("Point Time Machine at CloudMachine: run this in Terminal (needs sudo)"),
          command: input.setDestinationCommand, action: nil))
    }
    return steps
  }
}
