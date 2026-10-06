import CloudMachineCore
import Foundation

/// Shared parts of the measurement harnesses.
///
/// The harnesses themselves measure the behaviour of `hdiutil` and FUSE-T, not
/// our code. They are not part of the running system - which is why they live
/// in a SEPARATE binary, `cloudmachine-poc`, which `build-app` does not put
/// into the bundle. They are run by hand when something needs measuring or a
/// regression needs confirming.
enum POC {

  struct Failure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
  }

  // MARK: - Processes

  /// The equivalent of `set -e`: a failed process aborts the harness.
  @discardableResult
  static func run(
    _ executable: String, _ args: [String], timeout: TimeInterval? = 600
  ) async throws -> ProcessResult {
    let result = try await ProcessRunner.run(executable, args, timeout: timeout)
    guard result.succeeded else {
      throw Failure(
        message: """
          Failed: \(executable) \(args.joined(separator: " "))
          \(result.stderr.isEmpty ? result.stdout : result.stderr)
          """)
    }
    return result
  }

  /// The equivalent of `... || true` - called where failure is expected
  /// (cleaning up after something that may not exist).
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

  /// After a forced detach a device can linger in the system as a zombie.
  /// Attaching then returns a dead handle on which `fsck_apfs` reports
  /// "failed to read container superblock" with an all-zero UUID - it looks
  /// like a deleted backup, but it is only an unreadable device.
  ///
  /// The `hdiutil info` parsing logic lives in `CloudMachineCore` and is
  /// covered by tests - the harness does not duplicate it.
  static func purgeStaleDevices(forImage image: URL) async {
    await BackupImageService.purgeStaleDevices(image)
  }

  // MARK: - Images

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

  // MARK: - Files

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

  /// Overwrites a file IN PLACE - the equivalent of `dd conv=notrunc`.
  ///
  /// This is not a detail: writing through `Data.write(to:)` creates a new
  /// file and swaps it in, so the data would land in other places of the image
  /// and the dirtied-bands measurement would measure something other than a
  /// real in-place change.
  static func overwriteInPlace(_ url: URL, with data: Data) throws {
    guard let handle = FileHandle(forWritingAtPath: url.path) else {
      throw Failure(message: "Cannot open for writing: \(url.path)")
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

  /// How many bands changed after the marker - the equivalent of `find -newer`.
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

  /// Disk usage in MB - the equivalent of `du -sk`, i.e. the space ACTUALLY
  /// allocated, not the sum of logical sizes.
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
