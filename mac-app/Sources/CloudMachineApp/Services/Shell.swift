import Foundation
import AppKit
import CloudMachineCore

enum ShellError: LocalizedError {
    case privilegedFailed(String)

    var errorDescription: String? {
        switch self {
        case .privilegedFailed(let msg): return msg
        }
    }
}

/// Cienka warstwa nad NSAppleScript do uruchamiania polecen z podniesionymi
/// uprawnieniami. Uruchamianie zwyklych (nieuprzywilejowanych) polecen -
/// patrz `ProcessRunner` w CloudMachineCore, dzielone z CLI.
enum Shell {
    /// Uruchamia polecenie z podniesionymi uprawnieniami przez natywny dialog
    /// autoryzacji macOS (Touch ID / haslo administratora) - bez potrzeby
    /// wczesniejszej konfiguracji sudoers. Uzywane do jednorazowych akcji
    /// wykonywanych z poziomu GUI, gdy uzytkownik jest przy komputerze.
    static func runPrivileged(_ shellCommand: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let escaped = shellCommand
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                let source = "do shell script \"\(escaped)\" with administrator privileges"
                guard let script = NSAppleScript(source: source) else {
                    continuation.resume(throwing: ShellError.privilegedFailed("Nie udalo sie przygotowac AppleScript."))
                    return
                }
                var errorDict: NSDictionary?
                let output = script.executeAndReturnError(&errorDict)
                if let errorDict {
                    let message = errorDict[NSAppleScript.errorMessage] as? String ?? "Nieznany blad autoryzacji."
                    continuation.resume(throwing: ShellError.privilegedFailed(message))
                    return
                }
                continuation.resume(returning: output.stringValue ?? "")
            }
        }
    }
}
