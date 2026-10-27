import Foundation

/// Result of a one-off action (setup, installation, verification...) - a
/// shared shape used by many services in CloudMachineCore, so that the CLI and
/// the GUI have one consistent way of reporting success/failure.
public struct CMActionResult {
  public var succeeded: Bool
  public var message: String
  /// `true` if `succeeded == false` specifically because the NOPASSWD sudoers
  /// rule was missing (see `ProcessResult.isSudoAuthFailure`) - and NOT
  /// because the command itself failed. Lets the caller (GUI) tell "sudoers
  /// has to be set up first, then retry" apart from a real error, instead of
  /// handing the user a dead end.
  public var isSudoAuthFailure: Bool

  public init(succeeded: Bool, message: String, isSudoAuthFailure: Bool = false) {
    self.succeeded = succeeded
    self.message = message
    self.isSudoAuthFailure = isSudoAuthFailure
  }
}
