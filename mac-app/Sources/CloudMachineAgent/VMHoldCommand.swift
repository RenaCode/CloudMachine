import ArgumentParser
import CloudMachineCore
import Foundation

struct VMHoldCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-hold",
    // Not translated: only the launchd job runs this, nobody reads its help.
    abstract:
      "Starts the machine and stays running; when it is stopped (logout, shutdown) it stops the machine cleanly."
  )

  func run() async throws {
    // The handlers must be in place before the (minutes long) start: a SIGTERM
    // that arrives during it is remembered and cancels the start.
    let signals = TerminationSignals()
    let code = await VMHold.run(steps: VMHold.live, termination: signals.latch)
    if code != 0 { throw ExitCode(code) }
  }
}
