import Foundation

/// Odpala proces, ktory dziedziczy stdout/stderr biezacego terminala zamiast
/// buforowac je w pamieci (jak `ProcessRunner`) - dla dlugotrwalych,
/// "gadatliwych" narzedzi budowania (`swift build`, `codesign`), gdzie
/// uzytkownik powinien widziec postep na zywo, tak jak przy oryginalnych
/// skryptach bash.
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
