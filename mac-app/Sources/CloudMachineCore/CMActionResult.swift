import Foundation

/// Wynik jednorazowej akcji (setup, instalacja, weryfikacja...) - wspolny
/// ksztalt uzywany przez wiele serwisow w CloudMachineCore, zeby CLI i GUI
/// mialy jeden, spojny sposob raportowania sukcesu/porazki.
public struct CMActionResult {
  public var succeeded: Bool
  public var message: String
  /// `true`, jesli `succeeded == false` konkretnie dlatego, ze brakowalo
  /// reguly sudoers NOPASSWD (patrz `ProcessResult.isSudoAuthFailure`) - a
  /// NIE dlatego, ze samo polecenie zawiodlo. Pozwala wywolujacemu (GUI)
  /// odroznic "trzeba najpierw ustawic sudoers i sprobowac ponownie" od
  /// prawdziwego bledu, zamiast zwracac uzytkownikowi martwy koniec.
  public var isSudoAuthFailure: Bool

  public init(succeeded: Bool, message: String, isSudoAuthFailure: Bool = false) {
    self.succeeded = succeeded
    self.message = message
    self.isSudoAuthFailure = isSudoAuthFailure
  }
}
