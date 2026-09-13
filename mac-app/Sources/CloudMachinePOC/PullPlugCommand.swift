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
    for round in 1...rounds {
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
      if await writer.value == false {
        print("  zapis przerwany, zgodnie z oczekiwaniem")
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
      if await checkImage(device: device, writingTo: log, repair: false) {
        print("  WYNIK: spojny")
      } else {
        print("  WYNIK: niespojny - probuje naprawic")
        if await checkImage(device: device, writingTo: log, repair: true, append: true) {
          print("  naprawa udana - backup do uratowania")
        } else {
          print("  naprawa nieudana - backup stracony (log: \(log.path))")
          failed += 1
        }
      }
      await POC.detachQuietly(device, force: true)
      try? FileManager.default.removeItem(at: copy)
    }

    print("")
    print("===================================")
    print("Rund: \(rounds)   nieodwracalnych strat: \(failed)")
    print(
      failed == 0
        ? "Obraz przezyl kazde wyrwanie podlogi."
        : "UWAGA: architektura gubi backup przy utracie warstwy chmurowej.")
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
  ) async -> Bool {
    let result = try? await ProcessRunner.run(
      Self.fsck, [repair ? "-y" : "-n", device], timeout: nil)
    let text = (result?.stdout ?? "") + (result?.stderr ?? "")
    let previous = append ? ((try? String(contentsOf: log, encoding: .utf8)) ?? "") : ""
    try? (previous + text).write(to: log, atomically: true, encoding: .utf8)
    return result?.succeeded == true
  }
}

/// Leje losowe dane, dopoki podloga nie zniknie. Zwraca `false`, gdy zapis
/// padl - czyli w oczekiwanym przypadku.
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
private func writeUntilItBreaks(to url: URL, megabytes: Int) -> Bool {
  guard FileManager.default.createFile(atPath: url.path, contents: nil),
    let handle = FileHandle(forWritingAtPath: url.path),
    let entropy = FileHandle(forReadingAtPath: "/dev/urandom")
  else { return false }
  defer {
    try? handle.close()
    try? entropy.close()
  }
  for _ in 0..<megabytes {
    do {
      guard let chunk = try entropy.read(upToCount: 1024 * 1024), !chunk.isEmpty else {
        return false
      }
      try handle.write(contentsOf: chunk)
    } catch {
      return false
    }
  }
  return (try? handle.synchronize()) != nil
}
