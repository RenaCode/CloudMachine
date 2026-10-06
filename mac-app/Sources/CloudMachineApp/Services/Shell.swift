import AppKit
import CloudMachineCore
import Foundation

enum ShellError: LocalizedError {
  case privilegedFailed(String)

  var errorDescription: String? {
    switch self {
    case .privilegedFailed(let msg): return msg
    }
  }
}

/// A thin layer over NSAppleScript for running commands with elevated
/// privileges. For running ordinary (unprivileged) commands -
/// see `ProcessRunner` in CloudMachineCore, shared with the CLI.
enum Shell {
  /// Runs a command with elevated privileges through the native macOS
  /// authorization dialog (Touch ID / administrator password) - without any need
  /// to configure sudoers beforehand. Used for one-off actions
  /// performed from the GUI, while the user is at the computer.
  static func runPrivileged(_ shellCommand: String) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        let escaped =
          shellCommand
          .replacingOccurrences(of: "\\", with: "\\\\")
          .replacingOccurrences(of: "\"", with: "\\\"")
        let source = "do shell script \"\(escaped)\" with administrator privileges"
        guard let script = NSAppleScript(source: source) else {
          continuation.resume(
            throwing: ShellError.privilegedFailed(L10n.tr("Could not prepare the AppleScript.")))
          return
        }
        var errorDict: NSDictionary?
        let output = script.executeAndReturnError(&errorDict)
        if let errorDict {
          let message =
            errorDict[NSAppleScript.errorMessage] as? String
            ?? L10n.tr("Unknown authorization error.")
          continuation.resume(throwing: ShellError.privilegedFailed(message))
          return
        }
        continuation.resume(returning: output.stringValue ?? "")
      }
    }
  }
}
