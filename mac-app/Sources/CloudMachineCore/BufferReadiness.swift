import Foundation

/// Kiedy bufor jest na tyle gotowy, zeby podpiac na nim obraz.
///
/// Wydzielone z `attach-image`, zeby dalo sie sprawdzic testem bez montowania
/// czegokolwiek - tak samo jak `CooldownGate` i `TimeMachineStatus`.
public enum BufferReadiness {
  /// Ile czekac na gotowy bufor, zanim uznamy to za awarie.
  ///
  /// Dwie minuty wystarczaly, dopoki bufor startowal pusty. Po nieczystym
  /// zamknieciu jest inaczej: 13 wrz 2026 rclone wczytywal po starcie 225
  /// brudnych pozycji (9,4 GB), montowanie stanelo o 07:56:30, a czekanie
  /// poddalo sie o 07:56:20 - dziesiec sekund za wczesnie. Time Machine
  /// zostal bez celu az do nastepnego tykniecia launchd, czyli na 15 minut,
  /// i nikt sie o tym nie dowiedzial poza kodem wyjscia, ktorego nikt nie czyta.
  ///
  /// Czekanie jest darmowe - `attach` na juz podpietym obrazie tylko mowi
  /// "Juz podpiete" - a przegapione okno kosztuje kwadrans bez backupu.
  public static let defaultTimeout: TimeInterval = 900

  /// Co ile odpytywac.
  public static let defaultPoll: TimeInterval = 2

  /// Samo montowanie nie wystarczy.
  ///
  /// rclone wystawia montowanie, ZANIM wczyta brudny cache, wiec przez chwile
  /// katalog jest pusty. Podpiecie odpadloby wtedy na "Brak obrazu" - czyli na
  /// tym samym wyscigu, tyle ze o krok pozniej.
  public static func isReady(mounted: Bool, imageVisible: Bool) -> Bool {
    mounted && imageVisible
  }

  /// Czeka na gotowosc bufora. Zwraca `true`, jesli sie doczekal.
  ///
  /// Zegar i uspienie sa wstrzykiwane, zeby test nie musial czekac naprawde.
  public static func wait(
    timeout: TimeInterval = defaultTimeout,
    poll: TimeInterval = defaultPoll,
    now: () -> Date = Date.init,
    sleep: (TimeInterval) async -> Void,
    probe: () -> Bool
  ) async -> Bool {
    let deadline = now().addingTimeInterval(timeout)
    while true {
      if probe() { return true }
      if now() >= deadline { return false }
      await sleep(poll)
    }
  }
}
