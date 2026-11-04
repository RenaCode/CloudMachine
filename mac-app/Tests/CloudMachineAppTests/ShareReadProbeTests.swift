import Foundation
import XCTest

@testable import CloudMachineCore

/// The read through the share's own path in the machine
/// (smbd -> tm-bands-bind -> punchfs -> rclone).
///
/// Every service in that chain can be `active` while a read through it fails
/// or never returns: a hung FUSE daemon is still a live process, and punchfs
/// keeps the dead mount of an rclone that systemd restarted under it. Until
/// this probe nothing read through the chain, so the panel said "Ready" for up
/// to 3 h - until the age of the last backup crossed the threshold.
final class ShareReadProbeTests: XCTestCase {

  // MARK: - Parsing what the machine printed

  func testReadableByteIsReadable() {
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: "SVC smbd active\nPROBE ok\n"), .readable)
  }

  func testNoImageIsNotAFailure() {
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: "PROBE none"), .noImage)
  }

  /// The 22.09 incident class: the device is gone, the mount table still lists it.
  func testDeviceErrorsAreDead() {
    let cases: [(String, String)] = [
      ("head: error reading '/srv/tm-local/x.sparsebundle/bands/0': Input/output error", "EIO"),
      ("head: cannot open 'f' for reading: Transport endpoint is not connected", "ENOTCONN"),
      ("head: f: Socket is not connected", "ENOTCONN"),
      ("head: cannot open 'f' for reading: No such device or address", "ENXIO"),
      ("head: cannot open 'f' for reading: No such device", "ENODEV"),
      ("head: error reading 'f': Stale file handle", "ESTALE"),
      ("head: f: Stale NFS file handle", "ESTALE"),
    ]
    for (text, name) in cases {
      XCTAssertEqual(
        ShareReadProbe.verdict(scriptOutput: "PROBE error \(text)"), .dead(reason: name), text)
    }
  }

  /// With an image in the machine, its first band missing means the bind is
  /// not there: bands would go to the machine's local disk, not to Drive.
  func testMissingBandIsDead() {
    XCTAssertEqual(
      ShareReadProbe.verdict(
        scriptOutput: "PROBE error head: cannot open 'f' for reading: No such file or directory"),
      .dead(reason: "ENOENT"))
  }

  /// Not a device failure - restarting the stack would not fix it, but it
  /// is not "readable" either.
  func testOtherErrorsFailWithoutBeingDead() {
    XCTAssertEqual(
      ShareReadProbe.verdict(
        scriptOutput: "PROBE error head: cannot open 'f' for reading: Permission denied"),
      .failed(reason: "Permission denied"))
    XCTAssertEqual(
      ShareReadProbe.verdict(scriptOutput: "PROBE error "), .failed(reason: "no message"))
  }

  func testHungReadIsNoAnswerWithItsAge() {
    XCTAssertEqual(
      ShareReadProbe.verdict(scriptOutput: "PROBE hung 734"), .noAnswer(hungSeconds: 734))
  }

  /// "I do not know" must not become "fine": a report without the line is
  /// not a readable share.
  func testMissingLineIsNoAnswer() {
    XCTAssertEqual(
      ShareReadProbe.verdict(scriptOutput: "SVC smbd active\n"), .noAnswer(hungSeconds: nil))
    XCTAssertEqual(
      ShareReadProbe.verdict(scriptOutput: "PROBE garbage"), .noAnswer(hungSeconds: nil))
  }

  func testOnlyReadableAndNoImageAreConfirmed() {
    XCTAssertTrue(ShareReadProbe.Verdict.readable.isConfirmed)
    XCTAssertTrue(ShareReadProbe.Verdict.noImage.isConfirmed)
    XCTAssertFalse(ShareReadProbe.Verdict.dead(reason: "EIO").isConfirmed)
    XCTAssertFalse(ShareReadProbe.Verdict.failed(reason: "x").isConfirmed)
    XCTAssertFalse(ShareReadProbe.Verdict.noAnswer(hungSeconds: 3).isConfirmed)
    XCTAssertFalse(ShareReadProbe.Verdict.noAnswer(hungSeconds: nil).isConfirmed)
  }

  /// The status script carries the probe, so every reader of the machine
  /// (panel, vm-status, backup-health, vm-guard) gets the verdict.
  func testStatusReportCarriesTheVerdict() {
    XCTAssertTrue(VMStatus.script.contains(ShareReadProbe.guestScript))
    let report = VMStatus.report(scriptOutput: "SVC smbd active\nPROBE error x: Input/output error")
    XCTAssertEqual(report.shareRead, .dead(reason: "EIO"))
    XCTAssertEqual(
      VMStatus.report(scriptOutput: "SVC smbd active").shareRead, .noAnswer(hungSeconds: nil))
  }

  /// REVIEW 03.11: the status script's worst case - the probe's wait, both
  /// `curl -m 20` to rclone's rc, the log reads - must fit its time limit,
  /// with room for `limactl shell` itself. Without that a hung rclone made
  /// the whole report "no answer" and killed the probe's own reader.
  func testStatusScriptWorstCaseFitsItsTimeLimit() {
    let curls = VMLayout.readingScript.components(separatedBy: "curl -s -m 20").count - 1
    XCTAssertEqual(curls, 2)
    let worstCase = Double(ShareReadProbe.timeoutSeconds + 1 + curls * 20)
    XCTAssertGreaterThanOrEqual(VMStatus.reportTimeout, worstCase + 30)
  }

  /// The guest script is the tested pieces with the machine's own paths.
  func testGuestScriptIsTheTestedScriptWithTheMachinesPaths() {
    XCTAssertEqual(
      ShareReadProbe.guestScript,
      ShareReadProbe.script(
        locate: ShareReadProbe.locateFirstBand(
          bundleEnv: VMLayout.Guest.bundleEnv, localRoot: VMLayout.Guest.localRoot),
        stateDir: ShareReadProbe.stateDir, timeout: ShareReadProbe.timeoutSeconds))
    XCTAssertTrue(ShareReadProbe.stateDir.hasPrefix("/run/"), "a tmpfs: a reboot clears a lock")
  }

  // MARK: - Canary: which file the machine reads

  /// What `locateFirstBand` sets `f` to, for a scratch bundle.env and share root.
  private func located(env: String?, images: [String: Bool]) throws -> String {
    let dir = try scratch()
    let root = dir.appendingPathComponent("tm-local")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    for (image, hasFirstBand) in images {
      let bands = root.appendingPathComponent(image).appendingPathComponent("bands")
      try FileManager.default.createDirectory(at: bands, withIntermediateDirectories: true)
      if hasFirstBand { try Data([1]).write(to: bands.appendingPathComponent("0")) }
    }
    let envFile = dir.appendingPathComponent("bundle.env")
    if let env { try env.write(to: envFile, atomically: true, encoding: .utf8) }
    let locate = ShareReadProbe.locateFirstBand(bundleEnv: envFile.path, localRoot: root.path)
    let (output, _) = try bash("\(locate); echo \"F=$f\"")
    return output.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: root.path + "/", with: "")
  }

  func testLocatesNothingWithoutAnImage() throws {
    XCTAssertEqual(try located(env: nil, images: [:]), "F=")
  }

  /// A prepared image is named in bundle.env, and its band is read whatever
  /// it looks like from here: after `vm-prepare-bundle` the bands are the
  /// FUSE chain, and a missing band 0 is exactly what the probe must report.
  func testPreparedImageIsReadEvenWithoutItsBand() throws {
    XCTAssertEqual(
      try located(env: "CM_BUNDLE=\"Mac.sparsebundle\"\n", images: ["Mac.sparsebundle": false]),
      "F=Mac.sparsebundle/bands/0")
  }

  /// REVIEW 03.11: Time Machine creating a NEW image writes the directory
  /// first and band 0 a moment later; on the machine's own disk (not
  /// prepared yet) that gap is not a dead share.
  func testUnpreparedImageWithoutItsBandIsNoImageYet() throws {
    XCTAssertEqual(try located(env: nil, images: ["Mac.sparsebundle": false]), "F=")
    XCTAssertEqual(
      try located(env: nil, images: ["Mac.sparsebundle": true]), "F=Mac.sparsebundle/bands/0")
  }

  // MARK: - Canary: the real script, in bash, on a real file system

  /// Runs `script` in bash; returns stdout and how long it took.
  private func bash(_ script: String) throws -> (String, TimeInterval) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", script]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    let started = Date()
    try process.run()
    let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    process.waitUntilExit()
    return (output, Date().timeIntervalSince(started))
  }

  private func probeScript(target: String, state: URL, timeout: Int = 2) -> String {
    ShareReadProbe.script(
      locate: "f=\(VMLayout.shellQuoted(target))", stateDir: state.path, timeout: timeout)
  }

  /// Runs the probe in its OWN process group, the way `sudo` with `use_pty`
  /// runs it in the machine, and returns that group's id with the output.
  private func runInOwnGroup(target: String, state: URL, output: URL) throws -> pid_t {
    var attributes: posix_spawnattr_t?
    posix_spawnattr_init(&attributes)
    defer { posix_spawnattr_destroy(&attributes) }
    posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_SETPGROUP))
    posix_spawnattr_setpgroup(&attributes, 0)
    var actions: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&actions)
    defer { posix_spawn_file_actions_destroy(&actions) }
    posix_spawn_file_actions_addopen(&actions, 1, output.path, O_WRONLY | O_CREAT | O_TRUNC, 0o600)
    posix_spawn_file_actions_addopen(&actions, 2, "/dev/null", O_WRONLY, 0)
    let arguments = ["/bin/bash", "-c", probeScript(target: target, state: state)]
    var argv: [UnsafeMutablePointer<CChar>?] = arguments.map { strdup($0) } + [nil]
    defer {
      for pointer in argv { free(pointer) }
    }
    var pid: pid_t = 0
    let spawned = posix_spawn(&pid, "/bin/bash", &actions, &attributes, &argv, environ)
    XCTAssertEqual(spawned, 0)
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return pid
  }

  /// Waits up to `seconds` for `condition`.
  private func eventually(_ seconds: TimeInterval, _ condition: () -> Bool) -> Bool {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
      if condition() { return true }
      Thread.sleep(forTimeInterval: 0.1)
    }
    return condition()
  }

  /// REVIEW 03.11 (sudo `use_pty`): the script's process group gets SIGHUP
  /// when bash exits or limactl is killed. A reader that dies of it leaves
  /// its lock behind, and every later run says "hung" on a healthy share.
  /// The reader must outlive the hangup and clean up after itself.
  func testCanaryReaderSurvivesTheHangupAndCleansUp() throws {
    let dir = try scratch()
    let fifo = dir.appendingPathComponent("fifo")
    XCTAssertEqual(mkfifo(fifo.path, 0o600), 0)
    let state = dir.appendingPathComponent("state")
    let output = dir.appendingPathComponent("out")
    addTeardownBlock { self.release(fifo) }

    let group = try runInOwnGroup(target: fifo.path, state: state, output: output)
    let first = try String(contentsOf: output, encoding: .utf8)
    guard case .noAnswer(_?) = ShareReadProbe.verdict(scriptOutput: first) else {
      return XCTFail("expected a hung verdict, got: \(first)")
    }
    _ = kill(-group, SIGHUP)
    Thread.sleep(forTimeInterval: 0.3)
    XCTAssertEqual(readers(of: fifo.path), 1, "the hangup must not kill the reader")

    release(fifo)
    let lock = state.appendingPathComponent("lock").path
    XCTAssertTrue(
      eventually(5) { !FileManager.default.fileExists(atPath: lock) },
      "the reader removes its own lock when the read returns")
    let (next, _) = try bash(
      probeScript(target: dir.appendingPathComponent("absent").path, state: state))
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: next), .dead(reason: "ENOENT"), next)
  }

  /// A lock whose reader is gone (killed outright, SIGKILL) is taken over,
  /// not reported as "hung" forever.
  func testCanaryDeadReadersLockIsReclaimed() throws {
    let dir = try scratch()
    let state = dir.appendingPathComponent("state")
    let lock = state.appendingPathComponent("lock")
    try FileManager.default.createDirectory(at: lock, withIntermediateDirectories: true)
    let gone = Process()
    gone.executableURL = URL(fileURLWithPath: "/usr/bin/true")
    try gone.run()
    gone.waitUntilExit()
    try "\(gone.processIdentifier)\n".write(
      to: lock.appendingPathComponent("pid"), atomically: true, encoding: .utf8)
    try "\(Int(Date().timeIntervalSince1970) - 30)\n".write(
      to: lock.appendingPathComponent("start"), atomically: true, encoding: .utf8)
    let file = dir.appendingPathComponent("0")
    try Data([7]).write(to: file)

    let (output, _) = try bash(probeScript(target: file.path, state: state))
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: output), .readable, output)
  }

  /// A lock that never got its reader's pid (the reader died at once) is
  /// taken over once it is clearly older than any read.
  func testCanaryOldLockWithoutAPidIsReclaimed() throws {
    let dir = try scratch()
    let state = dir.appendingPathComponent("state")
    let lock = state.appendingPathComponent("lock")
    try FileManager.default.createDirectory(at: lock, withIntermediateDirectories: true)
    try "\(Int(Date().timeIntervalSince1970) - 600)\n".write(
      to: lock.appendingPathComponent("start"), atomically: true, encoding: .utf8)
    let file = dir.appendingPathComponent("0")
    try Data([7]).write(to: file)

    let (output, _) = try bash(probeScript(target: file.path, state: state))
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: output), .readable, output)
  }

  /// The panel, backup-health and vm-status can ask at the same moment: one
  /// reader between them, and all of them get a verdict.
  func testCanaryParallelRunsShareOneReader() throws {
    let dir = try scratch()
    let fifo = dir.appendingPathComponent("fifo")
    XCTAssertEqual(mkfifo(fifo.path, 0o600), 0)
    let state = dir.appendingPathComponent("state")
    addTeardownBlock { self.release(fifo) }

    let script = probeScript(target: fifo.path, state: state)
    final class Outputs: @unchecked Sendable {
      let lock = NSLock()
      var values: [String] = []
    }
    let outputs = Outputs()
    let group = DispatchGroup()
    for _ in 0..<3 {
      group.enter()
      DispatchQueue.global().async {
        let output = (try? self.bash(script).0) ?? ""
        outputs.lock.lock()
        outputs.values.append(output)
        outputs.lock.unlock()
        group.leave()
      }
    }
    XCTAssertEqual(group.wait(timeout: .now() + 15), .success)
    XCTAssertEqual(outputs.values.count, 3)
    for output in outputs.values {
      guard case .noAnswer(_?) = ShareReadProbe.verdict(scriptOutput: output) else {
        return XCTFail("expected a hung verdict, got: \(output)")
      }
    }
    XCTAssertEqual(readers(of: fifo.path), 1, "one reader for all three")
  }

  /// Opens the FIFO for writing on a thread, which lets a reader stuck in its
  /// `open` go; the teardown must not hang if there is none.
  private func release(_ fifo: URL) {
    let path = fifo.path
    Thread.detachNewThread {
      let fd = open(path, O_WRONLY)
      if fd >= 0 { close(fd) }
    }
    Thread.sleep(forTimeInterval: 0.3)
  }

  /// Runs the probe script with a fixed target in a scratch directory.
  private func run(target: String, state: URL, timeout: Int = 2) throws -> (String, TimeInterval) {
    let script = ShareReadProbe.script(
      locate: "f=\(VMLayout.shellQuoted(target))", stateDir: state.path, timeout: timeout)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", script]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    let started = Date()
    try process.run()
    process.waitUntilExit()
    let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    return (output, Date().timeIntervalSince(started))
  }

  private func scratch() throws -> URL {
    let dir = FileManager.default.temporaryDirectory
      .appendingPathComponent("cm-sonda-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    addTeardownBlock { try? FileManager.default.removeItem(at: dir) }
    return dir
  }

  func testCanaryReadsARealFile() throws {
    let dir = try scratch()
    let file = dir.appendingPathComponent("0")
    try Data([0x42]).write(to: file)
    let (output, _) = try run(target: file.path, state: dir.appendingPathComponent("state"))
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: output), .readable, output)
  }

  func testCanaryMissingFileIsENOENT() throws {
    let dir = try scratch()
    let (output, _) = try run(
      target: dir.appendingPathComponent("nope").path, state: dir.appendingPathComponent("state"))
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: output), .dead(reason: "ENOENT"), output)
  }

  func testCanaryEmptyTargetIsNoImage() throws {
    let dir = try scratch()
    let script = ShareReadProbe.script(
      locate: "f=", stateDir: dir.appendingPathComponent("state").path, timeout: 2)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", script]
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    process.waitUntilExit()
    let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    XCTAssertEqual(ShareReadProbe.verdict(scriptOutput: output), .noImage, output)
  }

  /// A FIFO with no writer blocks `open` the way a hung FUSE mount blocks a
  /// read: the script must come back within its limit, say "hung", and NOT
  /// start a second reader on the next run - one stuck process, not one per
  /// panel refresh.
  func testCanaryHungReadComesBackAndDoesNotPileUp() throws {
    let dir = try scratch()
    let fifo = dir.appendingPathComponent("fifo")
    XCTAssertEqual(mkfifo(fifo.path, 0o600), 0)
    let state = dir.appendingPathComponent("state")
    // Releases the stuck reader whatever the assertions do. A blocking open:
    // the reader is still inside its own `open`, and a non-blocking writer
    // gets ENXIO then. On a thread, so the teardown itself cannot hang.
    addTeardownBlock {
      let path = fifo.path
      Thread.detachNewThread {
        let fd = open(path, O_WRONLY)
        if fd >= 0 { close(fd) }
      }
      Thread.sleep(forTimeInterval: 0.3)
    }

    let (first, firstTook) = try run(target: fifo.path, state: state, timeout: 2)
    guard case .noAnswer(let hung?) = ShareReadProbe.verdict(scriptOutput: first) else {
      return XCTFail("expected a hung verdict, got: \(first)")
    }
    XCTAssertGreaterThanOrEqual(hung, 1)
    XCTAssertLessThan(firstTook, 8, "the probe must not wait on the stuck read")

    // The second run finds the stuck one and reports it at once.
    let (second, secondTook) = try run(target: fifo.path, state: state, timeout: 2)
    guard case .noAnswer(let again?) = ShareReadProbe.verdict(scriptOutput: second) else {
      return XCTFail("expected a hung verdict, got: \(second)")
    }
    XCTAssertGreaterThanOrEqual(again, hung)
    XCTAssertLessThan(secondTook, 2, "an already stuck probe is reported without waiting again")
    XCTAssertEqual(readers(of: fifo.path), 1, "one stuck reader, not one per run")
  }

  /// `head` processes reading `path` (the stuck probes).
  private func readers(of path: String) -> Int {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/ps")
    process.arguments = ["-axo", "command="]
    process.environment = ["LC_ALL": "C"]
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    // Read BEFORE waiting: the process table does not fit in a pipe buffer,
    // and `ps` blocked on a full pipe never exits.
    let text = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    process.waitUntilExit()
    return text.split(separator: "\n").filter { $0.hasPrefix("head -c1 -- \(path)") }.count
  }
}
