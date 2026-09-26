import Foundation

/// Czy podpiety obraz NAPRAWDE oddaje dane - a nie tylko figuruje w tablicy
/// montowan.
///
/// DLACZEGO TO ISTNIEJE
///
/// 22 wrz 2026 o 00:17 rclone dostal od Google HTTP 401 na listowaniu pasm,
/// oddal blad we/wy do FUSE-T, a sterownik obrazu uznal urzadzenie za
/// odlaczone. Od tej chwili kazdy odczyt pliku spod `/Volumes/CloudMachine`
/// konczyl sie `errno 6 ENXIO` ("Device not configured") i Time Machine
/// padal co przebieg z `BACKUP_FAILED_DISCONNECTED_DESTINATION`.
///
/// Tymczasem `mount` nadal pokazywal wolumen, `hdiutil info` nadal pokazywal
/// obraz, `ls` katalogu dzialal (z cache jadra), a `statfs` oddawal wolne
/// miejsce. Wszystko, na czym stal `isAttached`, mowilo "OK". Skutek:
/// `drive-status` "Obraz podpiety: OK", GUI "Wszystko wyslane", a agent
/// `gdrive-attach` co 15 minut meldowal "Juz podpiete" i NIE podpinal na nowo.
/// Przez 15 godzin jedynym, co krzyczalo, byl `backup-health` - po fakcie,
/// z wieku ostatniej kopii.
///
/// Zmierzone na martwym urzadzeniu: `open()` katalogu - OK, `listdir` - OK,
/// `statvfs` - OK, `fsync` - OK, **`open`+`read` 1 bajtu zwyklego pliku - ENXIO**.
/// Dlatego sonda czyta bajt. Nic slabszego nie odroznia zywego od martwego.
public enum ImageProbe {

  public enum Verdict: Equatable, Sendable {
    /// Odczyt sie udal.
    case readable
    /// Urzadzenie nie oddaje danych. `errno` z nieudanego odczytu.
    case dead(errno: Int32)
    /// W katalogu glownym nie ma zwyklego pliku, ktory daloby sie przeczytac -
    /// tak wyglada swiezy wolumen przed pierwsza kopia. Nie da sie stwierdzic
    /// awarii, wiec NIE zglaszamy jej.
    case nothingToProbe
    /// Sonda NIE ODPOWIEDZIALA w wyznaczonym czasie.
    ///
    /// To NIE jest `.dead` i zlanie tych dwoch przypadkow byloby grozne:
    /// `.dead` wyzwala w `attach-image` odpiecie NA SILE obrazu, na ktorym
    /// czekaja jeszcze niewyslane dane, a tutaj nie wiemy nawet tego, czy
    /// urzadzenie jest martwe. Brak wiedzy ma WSTRZYMYWAC operacje
    /// nieodwracalna, nie ja wyzwalac - dlatego ten werdykt mapuje sie na
    /// `BackupImageService.Attachment.unknown`, ktore juz blokuje `attach`
    /// i `create`.
    case timedOut
  }

  /// Bledy, ktore znacza "urzadzenie zniklo", a nie "plik jest dziwny".
  ///
  /// EACCES czy EISDIR to wlasciwosc pliku, nie wolumenu - taki plik pomijamy
  /// i probujemy nastepnego. ENXIO/EIO/ENODEV/ENOTCONN to wolumen.
  static let deviceErrors: Set<Int32> = [ENXIO, EIO, ENODEV, ENOTCONN]

  /// Czysta wersja: listowanie i odczyt sa wstrzykiwane, zeby test mogl
  /// podstawic ENXIO bez psucia prawdziwego urzadzenia.
  ///
  /// - `regularFiles`: zwykle pliki w katalogu glownym wolumenu.
  /// - `readFirstByte`: rzuca `POSIXError`-podobny blad z `errno`, gdy odczyt pada.
  public static func probe(
    regularFiles: () throws -> [URL],
    readFirstByte: (URL) -> Int32?
  ) -> Verdict {
    let files: [URL]
    do {
      files = try regularFiles()
    } catch {
      // Listowanie tez potrafi pasc na martwym urzadzeniu - i to jest ten
      // przypadek, ktory `try?` polykal. `--dir-cache-time` wynosi 5 minut:
      // dopoki cache jest swiezy, `contentsOfDirectory` chodzi z pamieci jadra
      // i dziala nawet po ENXIO (stad zdanie wyzej, ze listowanie "to nie jest
      // test"). Po wygasnieciu cache to samo listowanie idzie po dane do
      // rclone i pada tym samym ENXIO, co odczyt. Do 23 wrzesnia 2026 sonda
      // mowila wtedy `.nothingToProbe`, `BackupImageService.attachment`
      // mapowalo to na `.attached`, a agent `gdrive-attach` co 15 minut
      // meldowal "Juz podpiete" - czyli dokladnie ta awaria, dla ktorej ta
      // sonda powstala, wracala tylnymi drzwiami po piatej minucie.
      if let code = deviceErrno(of: error), deviceErrors.contains(code) {
        return .dead(errno: code)
      }
      // Blad bez rozpoznanego errno urzadzenia nie dowodzi niczego o wolumenie.
      return .nothingToProbe
    }
    guard !files.isEmpty else { return .nothingToProbe }
    for file in files {
      guard let errno = readFirstByte(file) else { return .readable }
      if deviceErrors.contains(errno) { return .dead(errno: errno) }
      // Blad wlasciwy dla pliku - sprobuj innego.
    }
    return .nothingToProbe
  }

  /// Wyciaga surowe `errno` z bledu rzuconego przez listowanie katalogu.
  ///
  /// Foundation nie oddaje go wprost: `contentsOfDirectory` opakowuje blad
  /// POSIX-a w `NSCocoaErrorDomain` (np. 256 `NSFileReadUnknownError`),
  /// a oryginalne `errno` chowa pod `NSUnderlyingErrorKey` jako
  /// `NSPOSIXErrorDomain`. Sprawdzamy trzy postacie, bo kazda z nich wychodzi
  /// z innej warstwy: `POSIXError` z kodu wolajacego libc wprost,
  /// `NSPOSIXErrorDomain` z cienkiego opakowania, i dopiero potem zagniezdzenie.
  static func deviceErrno(of error: Error) -> Int32? {
    if let posix = error as? POSIXError { return posix.code.rawValue }
    let ns = error as NSError
    if ns.domain == NSPOSIXErrorDomain { return Int32(ns.code) }
    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError,
      underlying.domain == NSPOSIXErrorDomain
    {
      return Int32(underlying.code)
    }
    return nil
  }

  // MARK: - Limit czasu
  //
  // DLACZEGO WATEK ODDZIELONY DEADLINEM, A NIE `ProcessRunner.run(timeout:)`
  //
  // Sonda to `readdir` plus `open`/`read` na wolumenie stojacym na FUSE-T.
  // Kiedy rclone przestaje odpowiadac, te wywolania wchodza w NIEPRZERYWALNE
  // oczekiwanie w jadrze (stan "U" w `ps`). Takiego watku nie da sie ani
  // anulowac, ani ubic: `Task.cancel()` jest kooperacyjne i `read()` w jadrze
  // z nim nie wspolpracuje, a SIGKILL tez nie dziala - to samo ograniczenie
  // opisuje juz `ProcessRunner` przy swojej "ostatecznej granicy". Skoro sondy
  // nie da sie PRZERWAC, jedyne, co da sie zagwarantowac, to ze jej
  // zawieszenie nie zawiesza WOLAJACEGO. Sonda dostaje wiec wlasny watek,
  // a wolajacy deadline i werdykt `.timedOut`.
  //
  // Dlatego tez nie ma tu (i nie moze byc) synchronicznego `probe(volume:)` -
  // byl do 26.09.2026 i wlasnie on zamrazal panel na `@MainActor` oraz
  // uciszal czujke `backup-health` na stale. Jedyne wejscie na zywy wolumen
  // jest `async`, zeby wolajacy czekal bez blokowania watku.
  //
  // Rozwazone i ODRZUCONE:
  //
  // - Sonda w PODPROCESIE przez `ProcessRunner.run(..., timeout:)` - wzorzec,
  //   ktory w tym repo ratuje `tmutil`. Kupuje tu dokladnie tyle samo, co
  //   watek (zawieszenie nie zatrzymuje wolajacego), a placi znacznie wiecej:
  //   nowa podkomenda agenta, odnajdywanie binarki w trzech ukladach (bundel
  //   GUI, `.build/` przy pracy z terminala, `/Applications` pod launchd),
  //   `fork`+`exec` co 10 s w petli odswiezania panelu i - tak samo jak tu -
  //   osierocony proces zawieszony w jadrze, ktorego nikt nie ubije. Trzy nowe
  //   miejsca, w ktorych sonda moze przestac dzialac po cichu, za zysk
  //   ograniczony do tego, ze zaklinowany watek nalezy do obcego procesu.
  //
  // - `open(..., O_NONBLOCK)`. Na PLIKU ZWYKLYM O_NONBLOCK nie czyni `read()`
  //   nieblokujacym - dotyczy FIFO, gniazd i urzadzen znakowych, a nie
  //   oczekiwania na I/O pliku; `readdir` nie ma nawet takiego wariantu.
  //   Sonda stracilaby wiec czytelnosc kodu, nie zyskujac gwarancji, a przy
  //   okazji przestalaby mierzyc to, po co istnieje: ODDANIE bajtu przez
  //   urzadzenie.
  //
  // - Wyscig dwoch `Task` z `Task.sleep` i `cancel()` na przegranym - patrz
  //   wyzej, anulowanie nie ma jak dosiegnac `read()` w jadrze. Watek z puli
  //   `DispatchQueue.global()` odpada z tego samego powodu, tylko gorzej:
  //   zaklinowany watek zostaje zajety na zawsze, a pula ma ~64 miejsca
  //   i jest wspoldzielona z cala reszta procesu.

  /// Ile czekamy na werdykt, zanim oglosimy `.timedOut`.
  ///
  /// Na zywym wolumenie sonda trwa mikrosekundy - jeden `readdir` i odczyt
  /// jednego bajtu. Te 15 s to wiec nie budzet na prace, a granica
  /// cierpliwosci. Dolna granice wyznacza ZYWY, ale wolny FUSE-T (pasmo
  /// sciagane z Dysku w trakcie odczytu), ktorego nie wolno brac za
  /// niewiadoma; gorna - to, po co ten limit istnieje: 25.09.2026
  /// `drive-status` wisial ponad 25 s i trzeba go bylo zabic recznie, a czujka
  /// `backup-health` chodzi co 1800 s, wiec pelne 15 s i tak nie zblizy sie
  /// do jej okna.
  public static let probeTimeout: TimeInterval = 15

  /// Werdykt przekazywany z watku sondujacego do wolajacego.
  ///
  /// Obie strony musza przezyc brak drugiej: wolajacy moze sie poddac na
  /// deadline i nigdy nie odebrac werdyktu, a watek moze nigdy nie dojsc do
  /// `finish`, bo utknal w jadrze.
  private final class ProbeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var verdict: Verdict?
    private var handler: ((Verdict) -> Void)?

    func finish(_ value: Verdict) {
      lock.lock()
      guard verdict == nil else {
        lock.unlock()
        return
      }
      verdict = value
      let waiting = handler
      handler = nil
      lock.unlock()
      waiting?(value)
    }

    /// Wola `handler` z werdyktem - natychmiast, jesli sonda zdazyla
    /// odpowiedziec, zanim wolajacy zapisal sie na powiadomienie.
    func whenDone(_ handler: @escaping (Verdict) -> Void) {
      lock.lock()
      if let verdict {
        lock.unlock()
        handler(verdict)
        return
      }
      self.handler = handler
      lock.unlock()
    }
  }

  /// Ktore wolumeny maja wlasnie sonde w locie.
  private final class ProbeSlots: @unchecked Sendable {
    static let shared = ProbeSlots()
    private let lock = NSLock()
    private var busy: Set<String> = []

    /// `true` = slot byl wolny i od tej chwili nalezy do wolajacego.
    func claim(_ slot: String) -> Bool {
      lock.lock()
      defer { lock.unlock() }
      return busy.insert(slot).inserted
    }

    func release(_ slot: String) {
      lock.lock()
      busy.remove(slot)
      lock.unlock()
    }
  }

  /// Startuje sonde na WLASNYM watku. `nil` = sonda tego slotu wciaz trwa.
  ///
  /// Jedna sonda na slot to nie optymalizacja. Bez tego panel GUI, ktory
  /// odswieza sie co 10 s, zostawialby na trwale zaklinowanym wolumenie po
  /// jednym wiszacym watku na przebieg - kilkaset na godzine, kazdy z wlasnym
  /// stosem i zaden do odzyskania. Drugi watek i tak nie dowiedzialby sie
  /// niczego nowego: skoro pierwszy stoi w jadrze, odpowiedzi nie ma, wiec
  /// kolejny wolajacy dostaje `.timedOut` od razu.
  private static func startProbe(
    slot: String,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32?
  ) -> ProbeBox? {
    guard ProbeSlots.shared.claim(slot) else { return nil }
    let box = ProbeBox()
    let thread = Thread {
      let verdict = probe(regularFiles: regularFiles, readFirstByte: readFirstByte)
      // Zwolnienie slotu PRZED oddaniem werdyktu: inaczej wolajacy obudzony
      // przez `finish` widzialby slot jako wciaz zajety.
      ProbeSlots.shared.release(slot)
      box.finish(verdict)
    }
    thread.name = "com.renacode.cloudmachine.image-probe"
    thread.stackSize = 512 * 1024
    thread.start()
    return box
  }

  /// Sonda na zywym wolumenie. Po `timeout` oddaje `.timedOut`, a wolajacy
  /// idzie dalej - sam odczyt moze zostac w jadrze na zawsze i to jest
  /// przyjete, byle nie zabral ze soba czujki ani interfejsu.
  public static func probe(volume: URL, timeout: TimeInterval = probeTimeout) async -> Verdict {
    await probe(
      slot: volume.path, timeout: timeout,
      regularFiles: { try regularFiles(in: volume) },
      readFirstByte: { readFirstByteErrno(of: $0) })
  }

  /// Jak wyzej, ale z wstrzykiwanym listowaniem i odczytem - zeby test mogl
  /// podstawic sonde, ktora NIGDY NIE ODPOWIADA, bez martwego wolumenu pod
  /// reka. `slot` jest osobnym parametrem z tego samego powodu: dwa testy nie
  /// moga sobie wzajemnie zajmowac tego samego slotu.
  static func probe(
    slot: String,
    timeout: TimeInterval,
    regularFiles: @escaping @Sendable () throws -> [URL],
    readFirstByte: @escaping @Sendable (URL) -> Int32?
  ) async -> Verdict {
    guard
      let box = startProbe(slot: slot, regularFiles: regularFiles, readFirstByte: readFirstByte)
    else { return .timedOut }
    return await withCheckedContinuation { (continuation: CheckedContinuation<Verdict, Never>) in
      let once = ContinuationGuard()
      box.whenDone { verdict in
        if once.claim() { continuation.resume(returning: verdict) }
      }
      DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
        if once.claim() { continuation.resume(returning: .timedOut) }
      }
    }
  }

  /// Zwykle pliki w katalogu glownym. Dopoki cache katalogu jest swiezy
  /// (`--dir-cache-time 5m`), listowanie chodzi z pamieci i dziala takze na
  /// martwym urzadzeniu - dlatego samo powodzenie listowania NIE jest dowodem
  /// zycia, tylko lista kandydatow do testu. Po wygasnieciu cache to samo
  /// listowanie pada ENXIO i wtedy jest juz dowodem smierci - obsluguje to
  /// `probe`, nie ta funkcja.
  static func regularFiles(in volume: URL) throws -> [URL] {
    try FileManager.default.contentsOfDirectory(
      at: volume, includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsSubdirectoryDescendants]
    )
    .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
  }

  /// `nil` = odczyt sie udal (takze pusty plik), inaczej `errno`.
  ///
  /// Przez `open`/`read` z libc, nie przez `Data(contentsOf:)`: Foundation
  /// czyta caly plik, a nas interesuje jeden bajt i surowe errno.
  static func readFirstByteErrno(of file: URL) -> Int32? {
    let fd = open(file.path, O_RDONLY)
    guard fd >= 0 else { return errno }
    defer { close(fd) }
    var byte: UInt8 = 0
    let n = read(fd, &byte, 1)
    return n < 0 ? errno : nil
  }
}
