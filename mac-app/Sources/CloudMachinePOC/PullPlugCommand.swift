import ArgumentParser
import CloudMachineCore
import Foundation

/// Symuluje smierc warstwy chmurowej w trakcie zapisu.
///
/// Najgrozniejszy scenariusz tej architektury: Time Machine pisze do
/// podpietego obrazu, a pod spodem znika montowanie rclone - bo padl proces,
/// bo FUSE-T sie wysypal, bo system uspil dysk. Obraz traci swoje pasma w
/// srodku zapisu.
///
/// Test odpina zewnetrzny obraz (zastepnik montowania rclone) w trakcie zapisu
/// do wewnetrznego, potem podpina wszystko z powrotem i sprawdza `fsck_apfs`.
///
/// Interesuje nas nie to, czy zapis przezyje - nie przezyje - tylko czy obraz
/// da sie pozniej naprawic, czy jest do wyrzucenia. Roznica miedzy "backup
/// przerwany, wznowi sie" a "backup stracony, zaczynamy od zera".
struct PullPlugCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "pullplug",
    abstract: "Wyrywa warstwe chmurowa w trakcie zapisu i sprawdza, czy obraz przezyl.")

  @Option(name: .long, help: "Rozmiar pasma w MB.")
  var bandMB: Int = 64

  @Option(name: .long, help: "Ile razy powtorzyc wyrwanie podlogi.")
  var rounds: Int = 3

  @Option(name: .long, help: "Katalog roboczy.")
  var root: String = "/tmp/cm-plug"

  @Flag(name: .long, help: "Tylko posprzataj po poprzednim przebiegu i zakoncz.")
  var clean = false

  private static let fsck =
    "/System/Library/Filesystems/apfs.fs/Contents/Resources/fsck_apfs"

  private var runRoot: URL { URL(fileURLWithPath: root) }
  private var outerImage: URL { runRoot.appendingPathComponent("stand-in.sparseimage") }
  private var mountPoint: URL { runRoot.appendingPathComponent("drive") }
  private var image: URL { mountPoint.appendingPathComponent("plug.sparsebundle") }
  private var target: URL { URL(fileURLWithPath: "/Volumes/PlugPOC") }

  private func detachAll() async {
    await POC.detachQuietly(target.path, force: true)
    await POC.detachQuietly(mountPoint.path, force: true)
  }

  func run() async throws {
    guard !clean else {
      await detachAll()
      try? FileManager.default.removeItem(at: runRoot)
      print("Posprzatane.")
      return
    }

    do {
      try await exercise()
    } catch {
      await detachAll()
      throw error
    }
    await detachAll()
  }

  private func exercise() async throws {
    await detachAll()
    try POC.recreateDirectory(runRoot)
    try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)

    print("Przygotowanie")
    try await POC.createSparseImage(at: outerImage, sizeGB: 20, volumeName: "PlugStandIn")
    try await POC.attach(outerImage, mountpoint: mountPoint)
    try await POC.createSparsebundle(
      at: image, sizeGB: 10, volumeName: "PlugPOC", bandMB: bandMB)

    var failed = 0
    // Rundy, ktore NIC NIE ZMIERZYLY: zapis sie nie zaczal, skonczyl sie przed
    // wyrwaniem podlogi albo obrazu nie dalo sie sprawdzic. Bez tego licznika
    // przebieg bez ani jednego pomiaru konczyl sie zdaniem "Obraz przezyl
    // kazde wyrwanie podlogi".
    var unmeasured = 0
    var executed = 0
    for round in 1...rounds {
      executed += 1
      print("")
      print("--- runda \(round) ---")
      try await POC.attach(image, mountpoint: target)

      // Zapis w tle, zeby wyrwac podloge w jego trakcie. Ten zapis MA paść -
      // przerwanie w polowie jest cala trescia testu.
      let writer = Task.detached { [target] in
        writeUntilItBreaks(
          to: target.appendingPathComponent("obciazenie-\(round).bin"), megabytes: 1500)
      }
      try await Task.sleep(nanoseconds: 3_000_000_000)

      print("Wyrywam podloge (odpinam zastepnik montowania)")
      await POC.detachQuietly(mountPoint.path, force: true)
      // "Nie zaczalem pisac" NIE jest "zapis przerwany". Pierwsze znaczy, ze
      // runda nie miala czego przerywac, czyli nie zmierzyla niczego.
      switch await writer.value {
      case .neverStarted(let powod):
        print("  ZAPIS NIGDY NIE WYSTARTOWAL: \(powod)")
        print("  runda NIC NIE MIERZY - nie bylo czego przerywac")
        unmeasured += 1
      case .interrupted(let megabytes):
        print("  zapis przerwany po \(megabytes) MB, zgodnie z oczekiwaniem")
      case .completed(let megabytes):
        print("  UWAGA: zapis \(megabytes) MB skonczyl sie PRZED wyrwaniem podlogi")
        print("  runda NIC NIE MIERZY - podloga zniknela juz po zapisie")
        unmeasured += 1
      }
      await POC.detachQuietly(target.path, force: true)

      print("Przywracam warstwe i sprawdzam obraz")
      // Nie sprawdzamy obrazu w miejscu. Po wymuszonym odpieciu urzadzenie
      // potrafi zostac w systemie jako zombie; podpiecie zwraca wtedy martwy
      // uchwyt, a fsck_apfs melduje "failed to read container superblock" z
      // UUID z samych zer. Wyglada to jak nieodwracalne uszkodzenie, a jest
      // tylko nieczytelnym urzadzeniem - wczesniejsza wersja tego testu na tej
      // podstawie trzy razy z rzedu orzekla utrate backupu, ktory byl caly.
      //
      // Kopia pod swieza sciezka jest odporna na ten artefakt: nowy plik, nowe
      // urzadzenie, zaden stary uchwyt nie ma z nim zwiazku.
      await POC.detachQuietly(target.path, force: true)
      await POC.purgeStaleDevices(forImage: image)
      try await Task.sleep(nanoseconds: 2_000_000_000)
      try await POC.attach(outerImage, mountpoint: mountPoint)
      try await Task.sleep(nanoseconds: 1_000_000_000)

      let copy = runRoot.appendingPathComponent("kontrola-\(round).sparsebundle")
      try? FileManager.default.removeItem(at: copy)
      try FileManager.default.copyItem(at: image, to: copy)

      guard let device = try await attachWithoutMounting(copy) else {
        print("  WYNIK: obrazu nie da sie nawet podpiac - stracony")
        failed += 1
        break
      }

      let log = runRoot.appendingPathComponent("fsck-\(round).log")
      switch await checkImage(device: device, writingTo: log, repair: false) {
      case .consistent:
        print("  WYNIK: spojny")
      case .notChecked(let powod):
        // NIE "stracony": nie mamy ani jednego wyniku. Na podstawie tego zdania
        // odtwarza sie backup od zera, wiec nie ma prawa go mowic zgadywanie.
        print("  WYNIK: NIE UDALO SIE SPRAWDZIC (\(powod))")
        print("  spojnosc obrazu POZOSTAJE NIESPRAWDZONA - runda nic nie mierzy")
        unmeasured += 1
      case .inconsistent:
        print("  WYNIK: niespojny - probuje naprawic")
        switch await checkImage(device: device, writingTo: log, repair: true, append: true) {
        case .consistent:
          print("  naprawa udana - backup do uratowania")
        case .inconsistent:
          print("  naprawa nieudana - backup stracony (log: \(log.path))")
          failed += 1
        case .notChecked(let powod):
          print("  naprawy NIE UDALO SIE uruchomic (\(powod))")
          print("  nie wiadomo, czy backup da sie uratowac (log: \(log.path))")
          unmeasured += 1
        }
      }
      await POC.detachQuietly(device, force: true)
      try? FileManager.default.removeItem(at: copy)
    }

    print("")
    print("===================================")
    for line in Self.summary(
      requestedRounds: rounds, executedRounds: executed, lost: failed, unmeasured: unmeasured)
    {
      print(line)
    }
  }

  /// Podpina kopie bez montowania i zwraca urzadzenie z kontenerem APFS.
  /// `41504653` to typ partycji Apple_APFS w wydruku `hdiutil attach -nomount`.
  private func attachWithoutMounting(_ copy: URL) async throws -> String? {
    guard
      let result = try? await POC.run(
        "/usr/bin/hdiutil", ["attach", copy.path, "-nomount"], timeout: 300)
    else { return nil }
    for line in result.stdout.components(separatedBy: .newlines) where line.contains("41504653") {
      let device = line.prefix(while: { !$0.isWhitespace })
      if !device.isEmpty { return String(device) }
    }
    return nil
  }

  /// `fsck_apfs` na uszkodzonym obrazie potrafi chodzic godzinami - dlatego
  /// `timeout: nil`. Zabity fsck zglasza porazke, ktorej nie da sie odroznic
  /// od realnej niespojnosci, a to tutaj jest cala mierzona wielkosc.
  private func checkImage(
    device: String, writingTo log: URL, repair: Bool, append: Bool = false
  ) async -> ImageCheck {
    let result = try? await ProcessRunner.run(
      Self.fsck, [repair ? "-y" : "-n", device], timeout: nil)
    let text = (result?.stdout ?? "") + (result?.stderr ?? "")
    let previous = append ? ((try? String(contentsOf: log, encoding: .utf8)) ?? "") : ""
    try? (previous + text).write(to: log, atomically: true, encoding: .utf8)
    return Self.classify(fsck: result)
  }

  /// "Nie udalo sie sprawdzic" to NIE to samo co "niespojny".
  ///
  /// Ten sam wzorzec, co w `BackupImageService.verifyLocked()`: `fsck_apfs`
  /// nieuruchomiony (brak binarki, ubity proces, wyrwane urzadzenie) dawal
  /// `false` dokladnie tak samo jak `fsck_apfs`, ktory znalazl uszkodzenie -
  /// harness meldowal wtedy "backup stracony" i liczyl nieodwracalna strate,
  /// nie majac ani jednego wyniku. Falszywy alarm o utracie calej kopii jest
  /// tu grozniejszy niz brak odpowiedzi, bo na jego podstawie odtwarza sie
  /// backup od zera.
  static func classify(fsck result: ProcessResult?) -> ImageCheck {
    guard let result else {
      return .notChecked("fsck_apfs nie dal sie uruchomic albo nie zwrocil wyniku")
    }
    return result.succeeded ? .consistent : .inconsistent
  }

  /// Ostatnie zdanie przebiegu - jedyne, ktore ktokolwiek zapamieta.
  ///
  /// Czyste i wydzielone, bo to tutaj byla usterka: dopoki liczyly sie tylko
  /// straty, przebieg BEZ ANI JEDNEGO pomiaru konczyl sie zdaniem "Obraz
  /// przezyl kazde wyrwanie podlogi". Harness nie ma prawa orzekac, ze cos
  /// przezylo, jesli nie wie, czy to cos w ogole probowal zabic.
  static func summary(requestedRounds: Int, executedRounds: Int, lost: Int, unmeasured: Int)
    -> [String]
  {
    var lines = [
      "Rundy: \(requestedRounds) zamowione, \(executedRounds) wykonane   "
        + "nieodwracalnych strat: \(lost)   rund bez pomiaru: \(unmeasured)"
    ]
    if executedRounds == 0 {
      lines.append("PRZEBIEG NIC NIE ZMIERZYL: nie wykonano ani jednej rundy.")
      return lines
    }
    if lost > 0 {
      lines.append("UWAGA: architektura gubi backup przy utracie warstwy chmurowej.")
      return lines
    }
    if unmeasured > 0 {
      lines.append(
        "PRZEBIEG NIC NIE DOWODZI: \(unmeasured) z \(executedRounds) rund nie zmierzylo niczego")
      lines.append(
        "(zapis sie nie zaczal, skonczyl sie przed wyrwaniem podlogi albo obrazu nie "
          + "dalo sie sprawdzic).")
      return lines
    }
    lines.append("Obraz przezyl kazde wyrwanie podlogi.")
    return lines
  }
}

/// Wynik sprawdzenia obrazu `fsck_apfs`. Trzy stany, bo "nie udalo sie
/// sprawdzic" i "niespojny" to dwie rozne odpowiedzi - patrz `classify`.
enum ImageCheck: Equatable {
  case consistent
  case inconsistent
  case notChecked(String)
}

/// Co sie stalo z probnym zapisem.
///
/// Trzy stany, nie dwa. `writeUntilItBreaks` zwracalo `Bool`, a `false` znaczylo
/// jednoczesnie "zapis przerwano w polowie" (cala tresc testu) i "zapisu nie
/// dalo sie w ogole zaczac" - `createFile` albo `FileHandle` padly od razu, na
/// przyklad bo sciezki nie ma. Harness drukowal wtedy "zapis przerwany, zgodnie
/// z oczekiwaniem" i konczyl "Obraz przezyl kazde wyrwanie podlogi", nie
/// napisawszy ani jednego bajtu.
///
/// `completed` tez jest osobno i tez NIE jest sukcesem testu: zapis, ktory
/// skonczyl sie przed wyrwaniem podlogi, nie zmierzyl niczego (dokladnie ta
/// pulapka, przed ktora ostrzega komentarz o `arc4random_buf` przy funkcji).
enum WriteProbe: Equatable {
  /// Zapisu NIE ZACZELISMY - runda nic nie mierzy.
  case neverStarted(String)
  /// Zapis szedl i zostal przerwany - oczekiwany przypadek.
  case interrupted(megabytesWritten: Int)
  /// Zapis doszedl do konca, czyli podloga zniknela za pozno albo wcale.
  case completed(megabytesWritten: Int)
}

/// Leje losowe dane, dopoki podloga nie zniknie.
///
/// Wewnetrzna (nie `private`), zeby test mogl sprawdzic, ze "nie zaczalem
/// pisac" i "zapis przerwany" to dwie rozne odpowiedzi.
///
/// Pisze porcjami przez `FileHandle`, a nie jednym `Data.write`, zeby zapis
/// naprawde trwal i dalo sie go przerwac w polowie.
///
/// Zrodlem danych jest `/dev/urandom` - dokladnie jak `dd if=/dev/urandom` w
/// wersji powlokowej. To nie jest przesadna wiernosc, tylko warunek dzialania
/// testu: to urandom wyznacza tempo zapisu. Wersja losujaca przez
/// `arc4random_buf` przepychala 1500 MB w mniej niz trzy sekundy, wiec zapis
/// konczyl sie PRZED wyrwaniem podlogi - harness meldowal "obraz przezyl", nie
/// sprawdziwszy tego, po co istnieje. Zmierzone: z urandom zapis wciaz trwa,
/// gdy znika montowanie.
func writeUntilItBreaks(to url: URL, megabytes: Int) -> WriteProbe {
  guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
    return .neverStarted("nie udalo sie utworzyc \(url.path)")
  }
  guard let handle = FileHandle(forWritingAtPath: url.path) else {
    return .neverStarted("nie udalo sie otworzyc do zapisu \(url.path)")
  }
  guard let entropy = FileHandle(forReadingAtPath: "/dev/urandom") else {
    try? handle.close()
    return .neverStarted("nie udalo sie otworzyc /dev/urandom")
  }
  defer {
    try? handle.close()
    try? entropy.close()
  }
  var written = 0
  for _ in 0..<megabytes {
    do {
      guard let chunk = try entropy.read(upToCount: 1024 * 1024), !chunk.isEmpty else {
        // Zero bajtow z urandom przy PIERWSZEJ porcji znaczy, ze zapis nigdy
        // sie nie zaczal - a przy setnej, ze padl w trakcie.
        return written == 0
          ? .neverStarted("/dev/urandom nie dal ani jednego bajtu")
          : .interrupted(megabytesWritten: written)
      }
      try handle.write(contentsOf: chunk)
      written += 1
    } catch {
      return written == 0
        ? .neverStarted("pierwszy zapis padl od razu: \(error.localizedDescription)")
        : .interrupted(megabytesWritten: written)
    }
  }
  // Nieudany `synchronize` to zapis, ktory nie doszedl na dysk - czyli
  // przerwany, a nie ukonczony.
  guard (try? handle.synchronize()) != nil else {
    return .interrupted(megabytesWritten: written)
  }
  return .completed(megabytesWritten: written)
}
