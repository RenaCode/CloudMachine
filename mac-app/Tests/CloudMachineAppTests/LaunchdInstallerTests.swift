import XCTest

@testable import CloudMachineCore

/// Finding 9: the launchd agent installer reported success on a PARTIAL
/// failure.
///
/// One loaded agent was enough for `install()` to return `succeeded: true` and
/// the message "Installed agents: ...", listing only the successful ones. An
/// unreadable template went through `continue`, a failed write through `try?` -
/// and after a failed write `launchctl load` read the OLD `.plist` file and
/// exited with code 0, i.e. it counted as a success.
///
/// The result: `buffer-guard` did not load, the installer reported success, the
/// only protection of the disk was not working and nobody knew. Nobody who does
/// not know the list by heart will notice a name missing from it.
///
/// The tests substitute reading the template, writing and reloading: a REAL
/// installation detaches the backup image and reloads this machine's agents, so
/// it cannot be run in a test without taking the working backup apart.
final class LaunchdInstallerTests: XCTestCase {

  private let agentBin = URL(
    fileURLWithPath: "/Applications/CloudMachine.app/bin/cloudmachine-agent")
  private let logDir = URL(fileURLWithPath: "/Users/someone/Library/Logs/CloudMachine")
  private let destination = URL(fileURLWithPath: "/Users/someone/Library/LaunchAgents")

  private func templates(_ names: [String]) -> [URL] {
    names.map { URL(fileURLWithPath: "/repo/launchd/\($0).plist.template") }
  }

  private struct BadSample: Error {}

  // MARK: - Collecting failures

  /// THAT defect, in full. Three agents, one goes in, two fail in two different
  /// ways (`launchctl` refuses, the template is unreadable) - the result MUST
  /// be a failure listing what is NOT there.
  func testOneSuccessfulAgentIsNotASuccessfulInstallation() async {
    let all = templates([
      "com.renacode.cloudmachine.app",
      "com.renacode.cloudmachine.buffer-guard",
      "com.renacode.cloudmachine.backup-health",
    ])

    let outcome = await LaunchdInstaller.installAgents(
      templates: all, into: destination, agentBin: agentBin, logDir: logDir,
      read: { url in
        // A broken backup-health template: previously `guard ... else {
        // continue }` cut it out of the installation WITHOUT A TRACE.
        if url.lastPathComponent.contains("backup-health") { throw BadSample() }
        return "__CM_AGENT_BIN__ __CM_LOG_DIR__"
      },
      write: { _, _ in },
      // buffer-guard does not load - exactly the agent from the finding.
      reload: { !$0.lastPathComponent.contains("buffer-guard") },
      log: { _ in })

    XCTAssertEqual(outcome.installed, ["com.renacode.cloudmachine.app"])
    XCTAssertEqual(
      outcome.failed.map(\.label).sorted(),
      ["com.renacode.cloudmachine.backup-health", "com.renacode.cloudmachine.buffer-guard"])

    let result = LaunchdInstaller.installVerdict(outcome)
    XCTAssertFalse(
      result.succeeded,
      "an installation without buffer-guard is not successful - got: \(result.message)")
    XCTAssertTrue(
      result.message.contains("buffer-guard"),
      "the message must NAME the missing agent: \(result.message)")
    XCTAssertTrue(
      result.message.contains("backup-health"),
      "and the other one too: \(result.message)")
    XCTAssertTrue(
      result.message.contains("launchctl load refused"),
      "and say WHY it did not go in: \(result.message)")
  }

  /// A failed `.plist` write MUST NOT end with an attempt to reload.
  ///
  /// Previously the write went through `try?`, so after it failed `launchctl
  /// load` ran on the file that still lies in `~/Library/LaunchAgents` from the
  /// OLD installation. `launchctl` then exited with code 0 and the agent landed
  /// on the "installed" list, although launchd was running the previous
  /// version - possibly pointing at a binary that no longer exists.
  func testFailedWriteDoesNotAttemptReload() async {
    let reloads = Counter()

    let outcome = await LaunchdInstaller.installAgents(
      templates: templates(["com.renacode.cloudmachine.buffer-guard"]),
      into: destination, agentBin: agentBin, logDir: logDir,
      read: { _ in "__CM_AGENT_BIN__" },
      write: { _, _ in throw BadSample() },
      reload: { _ in
        reloads.increment()
        // This is how launchctl behaved on the old file: code 0, i.e. "success".
        return true
      },
      log: { _ in })

    XCTAssertEqual(
      reloads.count, 0,
      "after a failed write launchctl load would read the OLD .plist and count as a success")
    XCTAssertTrue(outcome.installed.isEmpty)
    XCTAssertEqual(outcome.failed.count, 1, "a failed write must be RECORDED as a failure")
    XCTAssertTrue(
      outcome.failed.first?.reason.contains("could not write") == true,
      "reason: \(outcome.failed.first?.reason ?? "(none - nobody recorded the failure)")")
    XCTAssertFalse(LaunchdInstaller.installVerdict(outcome).succeeded)
  }

  /// The full set of agents - and only the full set - is a success. Without
  /// this test a "fix" that always returns `succeeded: false` would go
  /// unnoticed, and an installation that never reports success is just as
  /// useless as one that always does.
  func testFullSetOfAgentsIsStillASuccess() async {
    let outcome = await LaunchdInstaller.installAgents(
      templates: templates([
        "com.renacode.cloudmachine.app", "com.renacode.cloudmachine.buffer-guard",
      ]),
      into: destination, agentBin: agentBin, logDir: logDir,
      read: { _ in "__CM_AGENT_BIN__ __CM_LOG_DIR__" },
      write: { _, _ in }, reload: { _ in true }, log: { _ in })

    XCTAssertTrue(outcome.failed.isEmpty)
    let result = LaunchdInstaller.installVerdict(outcome)
    XCTAssertTrue(result.succeeded, result.message)
    XCTAssertEqual(
      result.message,
      "Installed agents: com.renacode.cloudmachine.app, com.renacode.cloudmachine.buffer-guard"
    )
  }

  /// No templates is still a failure - otherwise an installation that did
  /// NOTHING would report success with an empty list.
  func testNoTemplatesIsAFailure() {
    XCTAssertFalse(LaunchdInstaller.installVerdict(LaunchdInstaller.InstallOutcome()).succeeded)
  }

  // MARK: - Path substitution

  /// The template must get the paths it asks for - otherwise the agent would
  /// start with the literal `__CM_AGENT_BIN__` as its program.
  func testPathsEndUpInTheWrittenFile() async {
    let written = Captured()

    _ = await LaunchdInstaller.installAgents(
      templates: templates(["com.renacode.cloudmachine.app"]),
      into: destination, agentBin: agentBin, logDir: logDir,
      read: { _ in "<string>__CM_AGENT_BIN__</string><string>__CM_LOG_DIR__</string>" },
      write: { content, url in written.add(content, url) },
      reload: { _ in true }, log: { _ in })

    XCTAssertEqual(
      written.contents,
      ["<string>\(agentBin.path)</string><string>\(logDir.path)</string>"])
    XCTAssertEqual(
      written.paths,
      [destination.appendingPathComponent("com.renacode.cloudmachine.app.plist").path])
  }

  /// Files that are not templates must not get into the installation - the
  /// `launchd/` directory is sometimes listed in full (README, `.DS_Store`).
  func testNonTemplatesAreSkipped() async {
    let outcome = await LaunchdInstaller.installAgents(
      templates: [
        URL(fileURLWithPath: "/repo/launchd/README.md"),
        URL(fileURLWithPath: "/repo/launchd/com.renacode.cloudmachine.app.plist.template"),
      ],
      into: destination, agentBin: agentBin, logDir: logDir,
      read: { _ in "x" }, write: { _, _ in }, reload: { _ in true }, log: { _ in })

    XCTAssertEqual(outcome.installed, ["com.renacode.cloudmachine.app"])
    XCTAssertTrue(outcome.failed.isEmpty, "a README is not a failed agent")
  }

  // MARK: - Helpers

  /// Classes, because the substituted closures are `@Sendable`.
  private final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    func increment() {
      lock.lock()
      value += 1
      lock.unlock()
    }
    var count: Int {
      lock.lock()
      defer { lock.unlock() }
      return value
    }
  }

  private final class Captured: @unchecked Sendable {
    private let lock = NSLock()
    private var collected: [(String, String)] = []
    func add(_ content: String, _ url: URL) {
      lock.lock()
      collected.append((content, url.path))
      lock.unlock()
    }
    var contents: [String] {
      lock.lock()
      defer { lock.unlock() }
      return collected.map(\.0)
    }
    var paths: [String] {
      lock.lock()
      defer { lock.unlock() }
      return collected.map(\.1)
    }
  }
}
