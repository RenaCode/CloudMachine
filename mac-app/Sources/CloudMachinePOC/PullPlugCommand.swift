import ArgumentParser
import CloudMachineCore
import Foundation

/// Simulates the death of the cloud layer in the middle of a write.
///
/// The most dangerous scenario of this architecture: Time Machine writes to
/// the attached image, and underneath it the rclone mount disappears - because
/// the process died, because FUSE-T crashed, because the system put the disk
/// to sleep. The image loses its bands in the middle of a write.
///
/// The test detaches the outer image (the stand-in for the rclone mount) while
/// writing to the inner one, then attaches everything back and runs
/// `fsck_apfs`.
///
/// What interests us is not whether the write survives - it will not - but
/// whether the image can be repaired afterwards or has to be thrown away. The
/// difference between "backup interrupted, it will resume" and "backup lost,
/// we start from zero".
struct PullPlugCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "pullplug",
    abstract: "Pulls the cloud layer out mid-write and checks whether the image survived.")

  @Option(name: .long, help: "Band size in MB.")
  var bandMB: Int = 64

  @Option(name: .long, help: "How many times to repeat pulling the floor out.")
  var rounds: Int = 3

  @Option(name: .long, help: "Working directory.")
  var root: String = "/tmp/cm-plug"

  @Flag(name: .long, help: "Only clean up after the previous run and exit.")
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
      print("Cleaned up.")
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

    print("Preparation")
    try await POC.createSparseImage(at: outerImage, sizeGB: 20, volumeName: "PlugStandIn")
    try await POC.attach(outerImage, mountpoint: mountPoint)
    try await POC.createSparsebundle(
      at: image, sizeGB: 10, volumeName: "PlugPOC", bandMB: bandMB)

    var failed = 0
    // Rounds that MEASURED NOTHING: the write did not start, finished before
    // the floor was pulled out, or the image could not be checked. Without
    // this counter a run without a single measurement ended with the sentence
    // "The image survived every floor pull".
    var unmeasured = 0
    var executed = 0
    for round in 1...rounds {
      executed += 1
      print("")
      print("--- round \(round) ---")
      try await POC.attach(image, mountpoint: target)

      // A background write, so the floor can be pulled out from under it. This
      // write IS MEANT to fail - interrupting it halfway is the whole point of
      // the test.
      let writer = Task.detached { [target] in
        writeUntilItBreaks(
          to: target.appendingPathComponent("load-\(round).bin"), megabytes: 1500)
      }
      try await Task.sleep(nanoseconds: 3_000_000_000)

      print("Pulling the floor out (detaching the mount stand-in)")
      await POC.detachQuietly(mountPoint.path, force: true)
      // "I never started writing" is NOT "write interrupted". The former means
      // the round had nothing to interrupt, i.e. it measured nothing.
      switch await writer.value {
      case .neverStarted(let reason):
        print("  THE WRITE NEVER STARTED: \(reason)")
        print("  round MEASURES NOTHING - there was nothing to interrupt")
        unmeasured += 1
      case .interrupted(let megabytes):
        print("  write interrupted after \(megabytes) MB, as expected")
      case .completed(let megabytes):
        print("  WARNING: the \(megabytes) MB write finished BEFORE the floor was pulled out")
        print("  round MEASURES NOTHING - the floor disappeared only after the write")
        unmeasured += 1
      }
      await POC.detachQuietly(target.path, force: true)

      print("Restoring the layer and checking the image")
      // We do not check the image in place. After a forced detach a device can
      // linger in the system as a zombie; attaching then returns a dead handle,
      // and fsck_apfs reports "failed to read container superblock" with an
      // all-zero UUID. It looks like irreversible damage, but it is only an
      // unreadable device - an earlier version of this test, on that basis,
      // declared three times in a row the loss of a backup that was intact.
      //
      // A copy under a fresh path is immune to this artefact: new file, new
      // device, no old handle has anything to do with it.
      await POC.detachQuietly(target.path, force: true)
      await POC.purgeStaleDevices(forImage: image)
      try await Task.sleep(nanoseconds: 2_000_000_000)
      try await POC.attach(outerImage, mountpoint: mountPoint)
      try await Task.sleep(nanoseconds: 1_000_000_000)

      let copy = runRoot.appendingPathComponent("check-\(round).sparsebundle")
      try? FileManager.default.removeItem(at: copy)
      try FileManager.default.copyItem(at: image, to: copy)

      guard let device = try await attachWithoutMounting(copy) else {
        print("  RESULT: the image cannot even be attached - lost")
        failed += 1
        break
      }

      let log = runRoot.appendingPathComponent("fsck-\(round).log")
      switch await checkImage(device: device, writingTo: log, repair: false) {
      case .consistent:
        print("  RESULT: consistent")
      case .notChecked(let reason):
        // NOT "lost": we do not have a single result. A backup gets rebuilt from
        // zero on the strength of that sentence, so a guess has no right to say it.
        print("  RESULT: COULD NOT CHECK (\(reason))")
        print("  image consistency REMAINS UNCHECKED - the round measures nothing")
        unmeasured += 1
      case .inconsistent:
        print("  RESULT: inconsistent - trying to repair")
        switch await checkImage(device: device, writingTo: log, repair: true, append: true) {
        case .consistent:
          print("  repair succeeded - the backup can be saved")
        case .inconsistent:
          print("  repair failed - backup lost (log: \(log.path))")
          failed += 1
        case .notChecked(let reason):
          print("  the repair COULD NOT be started (\(reason))")
          print("  unknown whether the backup can be saved (log: \(log.path))")
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

  /// Attaches the copy without mounting and returns the device with the APFS
  /// container. `41504653` is the Apple_APFS partition type in the output of
  /// `hdiutil attach -nomount`.
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

  /// `fsck_apfs` on a damaged image can run for hours - hence `timeout: nil`.
  /// A killed fsck reports a failure that cannot be told apart from a real
  /// inconsistency, and that is the whole quantity measured here.
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

  /// "Could not check" is NOT the same as "inconsistent".
  ///
  /// The same pattern as in `BackupImageService.verifyLocked()`: a `fsck_apfs`
  /// that never ran (missing binary, killed process, pulled device) gave
  /// `false` exactly like a `fsck_apfs` that found damage - the harness then
  /// reported "backup lost" and counted an irreversible loss without having a
  /// single result. A false alarm about losing the whole backup is more
  /// dangerous here than no answer, because the backup gets rebuilt from zero
  /// on the strength of it.
  static func classify(fsck result: ProcessResult?) -> ImageCheck {
    guard let result else {
      return .notChecked("fsck_apfs could not be started or returned no result")
    }
    return result.succeeded ? .consistent : .inconsistent
  }

  /// The last sentence of the run - the only one anybody will remember.
  ///
  /// Pure and extracted, because this is where the bug was: as long as only
  /// losses counted, a run WITHOUT A SINGLE measurement ended with the
  /// sentence "The image survived every floor pull". The harness has no right
  /// to declare that something survived if it does not know whether it even
  /// tried to kill it.
  static func summary(requestedRounds: Int, executedRounds: Int, lost: Int, unmeasured: Int)
    -> [String]
  {
    var lines = [
      "Rounds: \(requestedRounds) requested, \(executedRounds) executed   "
        + "irreversible losses: \(lost)   rounds without a measurement: \(unmeasured)"
    ]
    if executedRounds == 0 {
      lines.append("THE RUN MEASURED NOTHING: not a single round was executed.")
      return lines
    }
    if lost > 0 {
      lines.append("WARNING: the architecture loses the backup when the cloud layer is lost.")
      return lines
    }
    if unmeasured > 0 {
      lines.append(
        "THE RUN PROVES NOTHING: \(unmeasured) of \(executedRounds) rounds measured nothing")
      lines.append(
        "(the write did not start, finished before the floor was pulled out, or the image "
          + "could not be checked).")
      return lines
    }
    lines.append("The image survived every floor pull.")
    return lines
  }
}

/// The result of checking the image with `fsck_apfs`. Three states, because
/// "could not check" and "inconsistent" are two different answers - see
/// `classify`.
enum ImageCheck: Equatable {
  case consistent
  case inconsistent
  case notChecked(String)
}

/// What happened to the test write.
///
/// Three states, not two. `writeUntilItBreaks` used to return `Bool`, and
/// `false` meant both "the write was interrupted halfway" (the whole point of
/// the test) and "the write could not start at all" - `createFile` or
/// `FileHandle` failed immediately, for example because the path does not
/// exist. The harness then printed "write interrupted, as expected" and ended
/// with "The image survived every floor pull", without having written a single
/// byte.
///
/// `completed` is separate too and is NOT a test success either: a write that
/// finished before the floor was pulled out measured nothing (exactly the trap
/// the comment about `arc4random_buf` on the function warns about).
enum WriteProbe: Equatable {
  /// We did NOT START the write - the round measures nothing.
  case neverStarted(String)
  /// The write was running and got interrupted - the expected case.
  case interrupted(megabytesWritten: Int)
  /// The write reached the end, i.e. the floor disappeared too late or not at all.
  case completed(megabytesWritten: Int)
}

/// Pours random data until the floor disappears.
///
/// Internal (not `private`), so that a test can check that "I never started
/// writing" and "write interrupted" are two different answers.
///
/// Writes in chunks through `FileHandle`, not with a single `Data.write`, so
/// that the write really takes time and can be interrupted halfway.
///
/// The data source is `/dev/urandom` - exactly like `dd if=/dev/urandom` in
/// the shell version. This is not excessive fidelity but a condition for the
/// test to work: urandom sets the pace of the write. The version generating
/// data with `arc4random_buf` pushed 1500 MB in under three seconds, so the
/// write finished BEFORE the floor was pulled out - the harness reported "the
/// image survived" without having checked what it exists for. Measured: with
/// urandom the write is still running when the mount disappears.
func writeUntilItBreaks(to url: URL, megabytes: Int) -> WriteProbe {
  guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
    return .neverStarted("could not create \(url.path)")
  }
  guard let handle = FileHandle(forWritingAtPath: url.path) else {
    return .neverStarted("could not open for writing \(url.path)")
  }
  guard let entropy = FileHandle(forReadingAtPath: "/dev/urandom") else {
    try? handle.close()
    return .neverStarted("could not open /dev/urandom")
  }
  defer {
    try? handle.close()
    try? entropy.close()
  }
  var written = 0
  for _ in 0..<megabytes {
    do {
      guard let chunk = try entropy.read(upToCount: 1024 * 1024), !chunk.isEmpty else {
        // Zero bytes from urandom on the FIRST chunk means the write never
        // started - and on the hundredth, that it failed midway.
        return written == 0
          ? .neverStarted("/dev/urandom did not yield a single byte")
          : .interrupted(megabytesWritten: written)
      }
      try handle.write(contentsOf: chunk)
      written += 1
    } catch {
      return written == 0
        ? .neverStarted("the first write failed immediately: \(error.localizedDescription)")
        : .interrupted(megabytesWritten: written)
    }
  }
  // A failed `synchronize` is a write that did not reach the disk - so it is
  // interrupted, not completed.
  guard (try? handle.synchronize()) != nil else {
    return .interrupted(megabytesWritten: written)
  }
  return .completed(megabytesWritten: written)
}
