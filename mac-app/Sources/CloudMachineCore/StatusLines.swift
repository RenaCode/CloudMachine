import Foundation

/// Skladanie wierszy `drive-status`. Czyste funkcje, bo wiersz statusu jest
/// tym, co czlowiek CZYTA, pytajac "czy backup dziala" - a dotad nie dalo sie
/// go sprawdzic testem, bo powstawal w `print` wewnatrz polecenia CLI.
///
/// Te wiersze lamaly sie juz dwa razy w ten sam sposob: przez zamiane "nie
/// wiem" na jakas wartosc. Raz przez podstawienie zer za brak odpowiedzi
/// rclone (stad `UploadState.queueUnknown`), raz przez `Optional(427)` po tym,
/// jak `BufferGuardService.freeGB()` slusznie przestal udawac, ze brak pomiaru
/// to zero. Dlatego kazda z ponizszych funkcji ma jawna galaz dla braku danych.
public enum StatusLines {

  /// Wiersz "Montowanie Drive".
  ///
  /// Trzeci stan jest osobny z tego samego powodu, co przy kolejce: `BRAK`
  /// znaczy "sprawdzilem i nie ma", a to jest wniosek, ktorego przy nieudanym
  /// odczycie tablicy montowan nikt nie ma prawa wyciagnac.
  public static func mounted(_ state: Bool?) -> String {
    switch state {
    case .some(true): return "OK"
    case .some(false): return "BRAK"
    case .none: return "NIE WIADOMO - nie udalo sie odczytac tablicy montowan"
    }
  }

  /// Wiersz "Wolne na dysku".
  ///
  /// `nil` MUSI byc nazwany. Nie `Optional(427)` (bo to wyglada na usterke
  /// programu, a nie na informacje) i nie podstawione zero (bo zero jest
  /// KONKRETNA liczba, na ktorej dozorca bufora wstrzymuje Time Machine -
  /// dokladnie ten blad naprawial drugi agent, zmieniajac typ na `Int?`).
  /// Brak pomiaru znaczy, ze dozorca nie chroni juz dysku przed zapelnieniem,
  /// wiec wiersz ma to powiedziec wprost.
  public static func freeDisk(_ gb: Int?) -> String {
    guard let gb else {
      return "NIE ZMIERZONO - dozorca bufora nie wstrzyma Time Machine przed zapelnieniem dysku"
    }
    return "\(gb) GB"
  }

  /// Wiersze o powiadomieniu, ktorego NIE udalo sie doreczyc.
  ///
  /// `HealthAlert.notify` zwraca od niedawna `Bool`, a `HealthAlert.report`
  /// nie zamyka sprawy znacznikiem, dopoki powiadomienie nie doszlo - dzieki
  /// temu alarm nie ginie juz po cichu na 12 godzin. Ale samo to nie wystarczy:
  /// dopoki nikt tego nie WYPISUJE, czlowiek dowiaduje sie o niedoreczonym
  /// alarmie tylko wtedy, gdy sam zajrzy do pliku stanu. Odmowa uprawnien do
  /// powiadomien jest typowa dla procesu launchd, wiec to nie jest przypadek
  /// teoretyczny.
  ///
  /// Pusta tablica = nie ma czego zglaszac.
  public static func undeliveredAlert(_ failure: (at: Date, summary: String, reason: String)?)
    -> [String]
  {
    guard let failure else { return [] }
    return [
      "NIEDORECZONY ALARM: \(failure.summary)",
      "        z \(BackupHealth.stamp(failure.at)), powod: \(failure.reason)",
      "        Powiadomienie systemowe nie doszlo - ten alarm zobaczysz TYLKO tutaj.",
    ]
  }
}
