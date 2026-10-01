import Foundation

/// Czekanie, az rclone wysle zaleglosc, ZANIM ruszy `hdiutil attach`.
///
/// Do 01.10.2026 `attach()` czekal na pusta kolejke sztywne 120 s. To starcza
/// przy zwyklym podpieciu, ale nie po restarcie Maca bez `prepare-shutdown`:
/// przy `--vfs-write-back 600s` w buforze zostaje wtedy ~10 min zapisow
/// (01.10 - ~19 GB, ~600 pasm). Zmierzone tego dnia: rclone wczytywal brudny
/// cache 15:32-15:36, wysylal 15:37-15:42 (~120 pasm/min), a 120 s minelo
/// w polowie. Pierwsze `hdiutil attach` ruszylo o 15:39 w pelnej wysylce,
/// otworzylo plik blokady i WISIALO 5 min, po czym padlo z "image not
/// recognized"; druga proba padla po 90 s, trzecia - juz w ciszy - przeszla
/// w 15 s. Time Machine stal bez celu 17 min, a czujka krzyczala AWARIA.
///
/// Sztywny dluzszy limit nie jest odpowiedzia: przy wyczerpanym dobowym
/// limicie Google kolejka nie zejdzie wcale i kazde podpiecie placilo by go
/// w calosci. Czekamy wiec tak dlugo, jak wysylka ROBI POSTEP, a poddajemy
/// sie, gdy przez `stallTimeout` liczba niewyslanych pozycji nie spadla
/// ponizej dotychczasowego minimum. `maxTotal` to twardy sufit - launchd
/// czeka na ten proces, a obraz bez podpiecia to Time Machine bez celu.
public enum UploadDrain {

  public static let defaultStallTimeout: TimeInterval = 120
  /// 20 min: zaleglosc z 01.10 (~19 GB) zeszla w ~6 min, wiec to trzy razy
  /// tyle. Wiecej i tak nie ma sensu - kolejka, ktora rosnie szybciej, niz
  /// schodzi, to juz nie rozruch, tylko zator, i zglosi go dozorca.
  public static let defaultMaxTotal: TimeInterval = 1200
  public static let defaultPoll: TimeInterval = 5
  /// Co ile ponawiamy przesuniecie terminow wysylki. Po starcie rclone
  /// wczytuje brudny cache pasmo po pasmie (01.10: cztery minuty) i kazde
  /// dostaje termin `writeBackSeconds` w przod - jedno przesuniecie na
  /// poczatku nie obejmie tych wczytanych pozniej.
  public static let defaultExpiryInterval: TimeInterval = 60

  public enum Outcome: Equatable {
    /// Kolejka pusta - mozna montowac.
    case idle
    /// Przez `stallTimeout` brak postepu.
    case stalled(unsent: Int)
    /// Postep byl, ale nie zdazyl przed `maxTotal`.
    case timedOut(unsent: Int)
    /// rclone nie odpowiadal przez caly `stallTimeout`.
    case noAnswer
  }

  /// `unsent` zwraca liczbe niewyslanych pozycji albo `nil`, gdy rclone nie
  /// odpowiedzial. Brak odpowiedzi nie jest postepem: liczy sie do
  /// `stallTimeout` tak samo jak stojaca kolejka.
  public static func wait(
    stallTimeout: TimeInterval = defaultStallTimeout,
    maxTotal: TimeInterval = defaultMaxTotal,
    poll: TimeInterval = defaultPoll,
    expiryInterval: TimeInterval = defaultExpiryInterval,
    now: () -> Date = Date.init,
    sleep: (TimeInterval) async -> Void,
    expire: () async -> Void,
    unsent: () async -> Int?
  ) async -> Outcome {
    let start = now()
    var lastProgress = start
    var lastExpiry: Date?
    var best: Int?
    var last: Int?

    while true {
      if lastExpiry.map({ now().timeIntervalSince($0) >= expiryInterval }) ?? true {
        await expire()
        lastExpiry = now()
      }
      let reading = await unsent()
      if let reading {
        if reading == 0 { return .idle }
        last = reading
        if best.map({ reading < $0 }) ?? true {
          best = reading
          lastProgress = now()
        }
      }
      let t = now()
      if t.timeIntervalSince(lastProgress) >= stallTimeout {
        return last.map { .stalled(unsent: $0) } ?? .noAnswer
      }
      if t.timeIntervalSince(start) >= maxTotal {
        return last.map { .timedOut(unsent: $0) } ?? .noAnswer
      }
      await sleep(poll)
    }
  }
}
