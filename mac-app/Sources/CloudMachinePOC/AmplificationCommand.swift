import ArgumentParser
import Foundation

/// Measures write amplification: how many megabytes have to be uploaded to
/// Drive to persist one megabyte of actual change.
///
/// This is the number that decides the band size. Large bands save file
/// operations (Drive lets through ~2/s and has a limit of 400,000 files), but
/// every small change forces the whole band to be uploaded again. If the
/// amplification turns out high, 64 MB is a mistake and we have to go lower.
///
/// Run separately for each band size; the result is a table for comparison.
struct AmplificationCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "amplification",
    abstract: "Measures write amplification for a given band size.")

  enum Workload: String, ExpressibleByArgument, CaseIterable {
    /// Rewriting scattered files - the worst realistic case.
    case scatter
    /// Adding new files - this is how Time Machine behaves.
    case append
  }

  @Option(name: .long, help: "Band size in MB.")
  var bandMB: Int = 64

  @Option(name: .long, help: "How many files in the first write.")
  var seedFiles: Int = 3000

  @Option(name: .long, help: "Size of a single file in KB.")
  var fileKB: Int = 64

  @Option(name: .long, help: "How many files to change in the second pass.")
  var touchFiles: Int = 300

  @Option(name: .long, help: "scatter = scattered rewrite, append = new files like TM.")
  var workload: Workload = .scatter

  @Option(name: .long, help: "Working directory.")
  var root: String = "/tmp/cm-amp"

  @Flag(name: .long, help: "Only clean up after the previous run and exit.")
  var clean = false

  private var runRoot: URL { URL(fileURLWithPath: root).appendingPathComponent("b\(bandMB)") }
  private var outerImage: URL { runRoot.appendingPathComponent("stand-in.sparseimage") }
  private var mountPoint: URL { runRoot.appendingPathComponent("drive") }
  private var image: URL { mountPoint.appendingPathComponent("amp.sparsebundle") }
  private var target: URL { URL(fileURLWithPath: "/Volumes/AmpPOC\(bandMB)") }

  private func cleanup() async {
    await POC.detachQuietly(target.path)
    await POC.detachQuietly(mountPoint.path)
  }

  func run() async throws {
    guard !clean else {
      await cleanup()
      try? FileManager.default.removeItem(at: URL(fileURLWithPath: root))
      print("Cleaned up.")
      return
    }

    // `trap cleanup EXIT` from the shell version: whatever goes wrong, we do
    // not leave images attached.
    do {
      try await measure()
    } catch {
      await cleanup()
      throw error
    }
    await cleanup()
  }

  private func measure() async throws {
    await cleanup()
    try POC.recreateDirectory(runRoot)
    try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)

    try await POC.createSparseImage(at: outerImage, sizeGB: 40, volumeName: "AmpStandIn")
    try await POC.attach(outerImage, mountpoint: mountPoint)
    try await POC.createSparsebundle(
      at: image, sizeGB: 30, volumeName: "AmpPOC\(bandMB)", bandMB: bandMB)
    try await POC.attach(image, mountpoint: target)

    // First write - the equivalent of a full backup.
    let dataDir = target.appendingPathComponent("data")
    try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
    for i in 1...seedFiles {
      try POC.createFile(dataDir.appendingPathComponent("file-\(i).bin"), kilobytes: fileKB)
    }
    await POC.sync()
    await POC.detachQuietly(target.path)

    let bands = image.appendingPathComponent("bands")
    let seedBands = POC.fileCount(in: bands)
    let seedMB = POC.allocatedMegabytes(of: image)

    // The timestamp against which we count the changed bands.
    let mark = Date()
    try await Task.sleep(nanoseconds: 1_000_000_000)

    // Second pass - the equivalent of an incremental backup.
    try await POC.attach(image, mountpoint: target)
    var changedKB = 0
    switch workload {
    case .append:
      // Time Machine does not rewrite existing data in place - every backup
      // adds new files. The writes are then clustered, not scattered.
      let growth = dataDir.appendingPathComponent("growth")
      try FileManager.default.createDirectory(at: growth, withIntermediateDirectories: true)
      for i in 1...touchFiles {
        try POC.createFile(growth.appendingPathComponent("new-\(i).bin"), kilobytes: fileKB)
        changedKB += fileKB
      }
    case .scatter:
      // We change scattered files to hit as many different bands as possible;
      // this is the worst realistic case, not the average one.
      let step = max(1, seedFiles / touchFiles)
      for i in stride(from: 1, through: seedFiles, by: step) {
        try POC.overwriteInPlace(
          dataDir.appendingPathComponent("file-\(i).bin"),
          with: POC.randomData(kilobytes: fileKB))
        changedKB += fileKB
      }
    }
    await POC.sync()
    await POC.detachQuietly(target.path)

    let dirty = POC.filesModified(after: mark, in: bands)
    let uploadMB = dirty * bandMB
    let changedMB = max(1, changedKB / 1024)

    print("---")
    print("band                 : \(bandMB) MB   (workload: \(workload.rawValue))")
    print("after full write     : \(seedBands) bands, \(seedMB) MB")
    print("actually changed     : \(changedMB) MB in \(touchFiles) files")
    print("dirtied bands        : \(dirty)")
    print("to upload            : \(uploadMB) MB")
    print("AMPLIFICATION        : \(uploadMB / changedMB)x")
  }
}
