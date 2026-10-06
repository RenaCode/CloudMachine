import Foundation

/// Launches a process that inherits the current terminal's stdout/stderr
/// instead of buffering them in memory (like `ProcessRunner`) - for
/// long-running, "chatty" build tools (`swift build`, `codesign`), where the
/// user should see progress live, just as with the original bash scripts.
enum InteractiveProcess {
  @discardableResult
  static func run(_ executable: String, _ args: [String], currentDirectory: URL? = nil) async throws
    -> Int32
  {
    try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      process.executableURL = URL(fileURLWithPath: executable)
      process.arguments = args
      if let currentDirectory {
        process.currentDirectoryURL = currentDirectory
      }
      process.standardOutput = FileHandle.standardOutput
      process.standardError = FileHandle.standardError
      process.terminationHandler = { proc in
        continuation.resume(returning: proc.terminationStatus)
      }
      do {
        try process.run()
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
