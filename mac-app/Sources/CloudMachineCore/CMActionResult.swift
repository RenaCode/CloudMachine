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

  /// `true` if the operation did NOT START at all - not because something went
  /// wrong, but because the resource was held by another operation (see
  /// `BackupImageService.busyResult`).
  ///
  /// A separate field rather than recognizing it by the content of `message`:
  /// matching on text breaks with every change of the message, and does so
  /// silently - meaning nobody notices until something fails.
  public var didNotRun: Bool

  public init(
    succeeded: Bool, message: String, isSudoAuthFailure: Bool = false, didNotRun: Bool = false
  ) {
    self.succeeded = succeeded
    self.message = message
    self.isSudoAuthFailure = isSudoAuthFailure
    self.didNotRun = didNotRun
  }

  /// What the caller should do with this result - in particular, which exit
  /// code a CLI command running under launchd should end with.
  ///
  /// It exists because "busy with another operation" is NOT a failure, yet
  /// with exit code 1 it ended up in `launchd-gdrive-attach.err.log` - exactly
  /// where a person looks when asking "is the backup working". It is the same
  /// bug this code fights in the other direction ("no answer read as an
  /// answer"), only reversed: a normal state read as a failure.
  public enum Disposition: Equatable {
    /// It worked.
    case ok
    /// Nothing happened and nothing broke. A periodic tick should simply try
    /// again on the next run.
    case skipped
    /// A real failure - this one must be visible.
    case failed
  }

  public var disposition: Disposition {
    if succeeded { return .ok }
    return didNotRun ? .skipped : .failed
  }
}
