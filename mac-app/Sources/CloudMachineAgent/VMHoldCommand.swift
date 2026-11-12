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
    // that arrives during it is remembered and ends the wait at once.
    let signals = TerminationSignals()
    let code = await VMHold.run(
      steps: VMHold.live, awaitTermination: { await signals.wait() },
      terminated: { signals.hasArrived })
    if code != 0 { throw ExitCode(code) }
  }
}

/// SIGTERM is what launchd sends; SIGINT and SIGHUP cover a terminal.
private final class TerminationSignals: @unchecked Sendable {
  private let lock = NSLock()
  private var arrived = false
  private var waiter: CheckedContinuation<Void, Never>?
  private var sources: [DispatchSourceSignal] = []

  init() {
    for sig in [SIGTERM, SIGINT, SIGHUP] {
      signal(sig, SIG_IGN)
      let source = DispatchSource.makeSignalSource(signal: sig, queue: .global())
      source.setEventHandler { [weak self] in self?.fire() }
      source.resume()
      sources.append(source)
    }
  }

  private func fire() {
    lock.lock()
    arrived = true
    let w = waiter
    waiter = nil
    lock.unlock()
    w?.resume()
  }

  var hasArrived: Bool {
    lock.lock()
    defer { lock.unlock() }
    return arrived
  }

  func wait() async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      lock.lock()
      if arrived {
        lock.unlock()
        continuation.resume()
      } else {
        waiter = continuation
        lock.unlock()
      }
    }
  }
}
