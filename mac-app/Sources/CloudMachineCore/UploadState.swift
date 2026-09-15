import Foundation

/// Odpowiedz na jedyne pytanie, ktore uzytkownik naprawde zadaje: czy kopia
/// dolatuje na Google Drive, a jesli nie - dlaczego i czy trzeba cos zrobic.
///
/// Powod istnienia: dotychczas interfejs pokazywal liczniki (kolejka, bledy,
/// rozmiar bufora) i surowy dziennik. Z jednego i drugiego da sie wyczytac
/// odpowiedz, ale trzeba wiedziec, czego szukac - a przy zatorze 12 wrzesnia
/// 2026 nie wyczytal jej nikt. Liczby opisuja stan, nie tlumacza go.
///
/// Rozroznienie, ktore najbardziej tu wazy: **limit dobowy mija sam, brak
/// miejsca nie**. Jedno znaczy "poczekaj", drugie "zrob cos". Wygladaja
/// podobnie w kazdym liczniku i roznia sie wszystkim, co z nich wynika.
public enum UploadState: Equatable, Sendable {

  /// Nie ma polaczenia z Dyskiem - kopie zapisuja sie tylko lokalnie.
  case mountDown
  /// Dysk pelny. NIE minie samo.
  case driveFull
  /// rclone odpuscil te pliki. Istnieja wylacznie na tym Macu.
  case failedFiles(Int)
  /// Bufor zapchany samymi niewyslanymi danymi.
  case bufferFull
  /// Dobowy limit zapisu Google wyczerpany. Mija SAM.
  case dailyQuotaExhausted
  /// Wysylka idzie.
  case flowing(queued: Int)
  /// Nic nie czeka - wszystko jest na Dysku.
  case upToDate

  /// Czy stan wymaga reakcji czlowieka. `false` znaczy "samo sie ulozy",
  /// a nie "wszystko dobrze" - patrz `dailyQuotaExhausted`.
  public var needsAttention: Bool {
    switch self {
    case .mountDown, .driveFull, .failedFiles, .bufferFull: return true
    case .dailyQuotaExhausted, .flowing, .upToDate: return false
    }
  }

  /// Czy stan jest NOMINALNY.
  ///
  /// Rozne od `needsAttention` i celowo: przy wyczerpanym limicie dobowym nikt
  /// nie musi nic robic, ale pasma leza wtedy wylacznie na tym Macu - a pasek
  /// menu nie ma prawa swiecic wtedy na zielono. Audyt wrzesniowy zaczal sie
  /// dokladnie od tego, ze "Gotowe" wyswietlalo sie przy pasmach, ktore nigdy
  /// nie dolecialy na Dysk.
  public var isNominal: Bool {
    switch self {
    case .flowing, .upToDate: return true
    case .mountDown, .driveFull, .failedFiles, .bufferFull, .dailyQuotaExhausted: return false
    }
  }

  /// Czy kopia faktycznie dolatuje na Dysk w tej chwili.
  public var isMovingData: Bool {
    if case .flowing = self { return true }
    return false
  }

  /// Jedno zdanie do paska i naglowka karty.
  public var headline: String {
    switch self {
    case .mountDown: return "Wysyłka nie działa"
    case .driveFull: return "Wysyłka stoi — brak miejsca na Google Drive"
    case .failedFiles(let count): return "Nie wysłano \(count) fragmentów kopii"
    case .bufferFull: return "Wysyłka nie nadąża za zapisem"
    case .dailyQuotaExhausted: return "Wysyłka wstrzymana — dobowy limit Google"
    case .flowing(let queued): return "Wysyłanie na Google Drive — \(queued) w kolejce"
    case .upToDate: return "Wszystko wysłane na Google Drive"
    }
  }

  /// Co to znaczy i co z tym zrobic. Pisane do czytania, nie do diagnozy -
  /// komu potrzebne liczby, ten ma `cloudmachine-agent drive-status`.
  public var explanation: String {
    switch self {
    case .mountDown:
      return """
        Nie ma połączenia z Google Drive, więc kopie powstają tylko na tym Macu. \
        Jeśli to nie minie samo w kilka minut, sprawdź sieć i połączenie z Dyskiem.
        """
    case .driveFull:
      return """
        Na Google Drive nie ma już miejsca. To NIE minie samo — trzeba zwolnić \
        miejsce na Dysku. Do tego czasu Time Machine jest wstrzymany, żeby nie \
        zapełnić dysku tego Maca.
        """
    case .failedFiles(let count):
      return """
        \(count) fragmentów kopii nie udało się wysłać i rclone przestał próbować. \
        Te fragmenty istnieją wyłącznie na tym Macu, więc kopia na Dysku jest \
        niekompletna. To wymaga sprawdzenia.
        """
    case .bufferFull:
      return """
        Time Machine pisze szybciej, niż idzie wysyłka, i bufor się zapełnił. \
        Backup zostanie wstrzymany, aż wysyłka nadgoni — to zabezpieczenie przed \
        zapełnieniem dysku, nie awaria.
        """
    case .dailyQuotaExhausted:
      return """
        Google przyjmuje 750 GB na dobę i ten limit został wyczerpany. \
        Nie trzeba nic robić: limit odnawia się sam, zwykle w kilka godzin. \
        Kopie Time Machine powstają przez ten czas normalnie i czekają w buforze — \
        wyślą się, gdy tylko Google znów zacznie przyjmować.
        """
    case .flowing(let queued):
      return "\(queued) fragmentów kopii czeka w kolejce i leci na Dysk."
    case .upToDate:
      return "Nic nie czeka w kolejce — kopia na Google Drive jest kompletna."
    }
  }

  /// Sklada stan z pojedynczych faktow.
  ///
  /// Kolejnosc NIE jest dowolna - od najtwardszego faktu do najmiekszego.
  /// `failedFiles` wyprzedza limit dobowy, bo "rclone odpuscil" znaczy, ze
  /// kopia jest niekompletna TERAZ, a limit znaczy tylko, ze poczeka.
  public static func from(
    mounted: Bool,
    queued: Int,
    inProgress: Int,
    failedFiles: Int,
    bufferOutOfSpace: Bool,
    driveFull: Bool,
    dailyQuotaExhausted: Bool
  ) -> UploadState {
    if !mounted { return .mountDown }
    if driveFull { return .driveFull }
    if failedFiles > 0 { return .failedFiles(failedFiles) }
    if bufferOutOfSpace { return .bufferFull }
    if dailyQuotaExhausted { return .dailyQuotaExhausted }
    if queued > 0 || inProgress > 0 { return .flowing(queued: queued + inProgress) }
    return .upToDate
  }
}
