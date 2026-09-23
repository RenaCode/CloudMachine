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

  /// `true`, jesli operacja w ogole sie NIE ZACZELA - nie dlatego, ze cos
  /// poszlo zle, tylko dlatego, ze zasob byl zajety przez inna operacje
  /// (patrz `BackupImageService.busyResult`).
  ///
  /// Osobne pole, a nie rozpoznawanie po tresci `message`: dopasowanie do
  /// tekstu psuje sie przy kazdej zmianie komunikatu, a cicho - to znaczy
  /// tak, ze nikt tego nie zauwaza az do awarii.
  public var didNotRun: Bool

  public init(
    succeeded: Bool, message: String, isSudoAuthFailure: Bool = false, didNotRun: Bool = false
  ) {
    self.succeeded = succeeded
    self.message = message
    self.isSudoAuthFailure = isSudoAuthFailure
    self.didNotRun = didNotRun
  }

  /// Co wolajacy ma z tym wynikiem zrobic - w szczegolnosci z jakim kodem
  /// wyjscia ma sie skonczyc polecenie CLI chodzace pod launchd.
  ///
  /// Istnieje, bo "zajete przez inna operacje" NIE JEST awaria, a przez kod
  /// wyjscia 1 ladowalo w `launchd-gdrive-attach.err.log` - czyli dokladnie
  /// tam, gdzie czlowiek patrzy, pytajac "czy backup dziala". To ten sam blad,
  /// ktory ten kod tepi w druga strone ("brak odpowiedzi czytany jako
  /// odpowiedz"), tylko odwrocony: stan normalny czytany jako awaria.
  public enum Disposition: Equatable {
    /// Udalo sie.
    case ok
    /// Nic sie nie wydarzylo i nic sie nie zepsulo. Cykliczny tik ma po
    /// prostu sprobowac przy nastepnym przebiegu.
    case skipped
    /// Prawdziwa porazka - ta ma byc widoczna.
    case failed
  }

  public var disposition: Disposition {
    if succeeded { return .ok }
    return didNotRun ? .skipped : .failed
  }
}
