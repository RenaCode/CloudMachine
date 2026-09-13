import CloudMachineCore
import Foundation

/// Wspolne czesci harnessow pomiarowych.
///
/// Same harnessy mierza zachowanie `hdiutil` i FUSE-T, a nie nasz kod. Nie sa
/// czescia dzialajacego systemu - dlatego siedza w OSOBNEJ binarce
/// `cloudmachine-poc`, ktorej `build-app` nie wklada do bundla. Uruchamia sie
/// je recznie, gdy trzeba cos zmierzyc albo potwierdzic regresje.
enum POC {

  struct Failure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
  }

  // MARK: - Procesy

  /// Odpowiednik `set -e`: nieudany proces przerywa harness.
  @discardableResult
  static func run(
    _ executable: String, _ args: [String], timeout: TimeInterval? = 600
  ) async throws -> ProcessResult {
    let result = try await ProcessRunner.run(executable, args, timeout: timeout)
    guard result.succeeded else {
      throw Failure(
        message: """
          Nie powiodlo sie: \(executable) \(args.joined(separator: " "))
          \(result.stderr.isEmpty ? result.stdout : result.stderr)
          """)
    }
    return result
  }

  /// Odpowiednik `... || true` - wolane tam, gdzie porazka jest spodziewana
  /// (sprzatanie po czyms, co moze nie istniec).
  static func runIgnoringFailure(
    _ executable: String, _ args: [String], timeout: TimeInterval? = 300
  ) async {
    _ = try? await ProcessRunner.run(executable, args, timeout: timeout)
  }

  static func detachQuietly(_ path: String, force: Bool = false) async {
    var args = ["detach", path, "-quiet"]
    if force { args.append("-force") }
    await runIgnoringFailure("/usr/bin/hdiutil", args)
  }

  /// Po wymuszonym odpieciu urzadzenie potrafi zostac w systemie jako zombie.
  /// Podpiecie zwraca wtedy martwy uchwyt, na ktorym `fsck_apfs` melduje
  /// "failed to read container superblock" z UUID z samych zer - wyglada to
  /// jak skasowany backup, a jest tylko nieczytelnym urzadzeniem.
  ///
  /// Logika parsowania `hdiutil info` mieszka w `CloudMachineCore` i jest
  /// pokryta testami - harness jej nie powiela.
  static func purgeStaleDevices(forImage image: URL) async {
    await BackupImageService.purgeStaleDevices(image)
  }

  // MARK: - Obrazy

  static func bandSectors(bandMB: Int) -> Int {
    bandMB * 1024 * 1024 / 512
  }

  static func createSparseImage(at path: URL, sizeGB: Int, volumeName: String) async throws {
    try await run(
      "/usr/bin/hdiutil",
      [
        "create", "-type", "SPARSE", "-size", "\(sizeGB)g", "-fs", "APFS",
        "-volname", volumeName, path.path,
      ])
  }

  static func createSparsebundle(
    at path: URL, sizeGB: Int, volumeName: String, bandMB: Int
  ) async throws {
    try await run(
      "/usr/bin/hdiutil",
      [
        "create", "-type", "SPARSEBUNDLE", "-size", "\(sizeGB)g",
        "-fs", "Case-sensitive APFS", "-volname", volumeName,
        "-imagekey", "sparse-band-size=\(bandSectors(bandMB: bandMB))",
        path.path,
      ])
  }

  static func attach(_ image: URL, mountpoint: URL) async throws {
    try await run(
      "/usr/bin/hdiutil",
      ["attach", image.path, "-nobrowse", "-mountpoint", mountpoint.path])
  }

  // MARK: - Pliki

  static func recreateDirectory(_ url: URL) throws {
    try? FileManager.default.removeItem(at: url)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  }

  static func randomData(kilobytes: Int) -> Data {
    var data = Data(count: kilobytes * 1024)
    data.withUnsafeMutableBytes { raw in
      guard let base = raw.baseAddress else { return }
      arc4random_buf(base, raw.count)
    }
    return data
  }

  /// Nadpisuje plik W MIEJSCU - odpowiednik `dd conv=notrunc`.
  ///
  /// To nie jest drobiazg: zapis przez `Data.write(to:)` tworzy nowy plik i
  /// podmienia go, przez co dane ladowalyby w innych miejscach obrazu i
  /// pomiar brudzonych pasm mierzylby cos innego niz realna zmiana w miejscu.
  static func overwriteInPlace(_ url: URL, with data: Data) throws {
    guard let handle = FileHandle(forWritingAtPath: url.path) else {
      throw Failure(message: "Nie mozna otworzyc do zapisu: \(url.path)")
    }
    defer { try? handle.close() }
    try handle.seek(toOffset: 0)
    try handle.write(contentsOf: data)
    try handle.synchronize()
  }

  static func createFile(_ url: URL, kilobytes: Int) throws {
    try randomData(kilobytes: kilobytes).write(to: url)
  }

  static func fileCount(in directory: URL) -> Int {
    (try? FileManager.default.contentsOfDirectory(atPath: directory.path).count) ?? 0
  }

  /// Ile pasm zmienilo sie po znaczniku - odpowiednik `find -newer`.
  static func filesModified(after mark: Date, in directory: URL) -> Int {
    guard
      let entries = try? FileManager.default.contentsOfDirectory(
        at: directory, includingPropertiesForKeys: [.contentModificationDateKey])
    else { return 0 }
    return entries.filter { url in
      guard
        let modified = try? url.resourceValues(forKeys: [.contentModificationDateKey])
          .contentModificationDate
      else { return false }
      return modified > mark
    }.count
  }

  /// Zajetosc na dysku w MB - odpowiednik `du -sk`, czyli miejsce FAKTYCZNIE
  /// zajete, nie suma rozmiarow logicznych.
  static func allocatedMegabytes(of directory: URL) -> Int {
    guard
      let walker = FileManager.default.enumerator(
        at: directory, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey])
    else { return 0 }
    var total = 0
    for case let url as URL in walker {
      let values = try? url.resourceValues(forKeys: [
        .totalFileAllocatedSizeKey, .isRegularFileKey,
      ])
      guard values?.isRegularFile == true, let size = values?.totalFileAllocatedSize else {
        continue
      }
      total += size
    }
    return total / 1024 / 1024
  }

  static func sync() async {
    await runIgnoringFailure("/bin/sync", [])
  }
}
