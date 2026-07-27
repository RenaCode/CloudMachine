import Foundation

/// Wynik jednorazowej akcji (setup, instalacja, weryfikacja...) - wspolny
/// ksztalt uzywany przez wiele serwisow w CloudMachineCore, zeby CLI i GUI
/// mialy jeden, spojny sposob raportowania sukcesu/porazki.
public struct CMActionResult {
    public var succeeded: Bool
    public var message: String

    public init(succeeded: Bool, message: String) {
        self.succeeded = succeeded
        self.message = message
    }
}
