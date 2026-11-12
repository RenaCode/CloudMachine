import Foundation

/// "A termination signal has arrived", as a state that can be waited for.
///
/// A state, not an event: SIGTERM can arrive during the (minutes long) start,
/// before anybody waits, and must not be lost. `wait()` ends when `fire()` was
/// called, now or earlier, or when the waiting task is cancelled (so that a
/// waiter that lost a race does not hang its task group).
public final class TerminationLatch: @unchecked Sendable {
  private let lock = NSLock()
  private var arrived = false
  private var waiters: [UUID: CheckedContinuation<Void, Never>] = [:]

  public init() {}

  public func fire() {
    lock.lock()
    arrived = true
    let released = Array(waiters.values)
    waiters.removeAll()
    lock.unlock()
    for waiter in released { waiter.resume() }
  }

  public var hasArrived: Bool {
    lock.lock()
    defer { lock.unlock() }
    return arrived
  }

  public func wait() async {
    let id = UUID()
    await withTaskCancellationHandler {
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        lock.lock()
        if arrived || Task.isCancelled {
          lock.unlock()
          continuation.resume()
        } else {
          waiters[id] = continuation
          lock.unlock()
        }
      }
    } onCancel: {
      lock.lock()
      let waiter = waiters.removeValue(forKey: id)
      lock.unlock()
      waiter?.resume()
    }
  }
}

/// SIGTERM is what launchd sends; SIGINT and SIGHUP cover a terminal.
///
/// A real handler (`sigaction`) that writes one byte to a pipe, not `SIG_IGN`
/// plus a dispatch source. An ignored signal is inherited through exec, so
/// `limactl` and the Lima host agent would have started with SIGTERM ignored
/// and `Process.terminate()` (or launchd's group kill) would not reach them.
/// A caught signal is reset to the default by exec.
///
/// One instance at a time: the handler reaches the pipe through a global.
public final class TerminationSignals: @unchecked Sendable {
  public let latch = TerminationLatch()
  private let signals: [Int32]
  private var previous: [Int32: sigaction] = [:]
  private var pipeFDs: [Int32] = [-1, -1]
  private var source: DispatchSourceRead?

  public init(signals: [Int32] = [SIGTERM, SIGINT, SIGHUP]) {
    self.signals = signals
    var fds: [Int32] = [-1, -1]
    guard pipe(&fds) == 0 else { return }
    pipeFDs = fds
    for fd in fds {
      _ = fcntl(fd, F_SETFD, FD_CLOEXEC)
      _ = fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK)
    }
    terminationPipeWriteFD = fds[1]

    let readFD = fds[0]
    let latch = self.latch
    let source = DispatchSource.makeReadSource(fileDescriptor: readFD, queue: .global())
    source.setEventHandler {
      var buffer = [UInt8](repeating: 0, count: 16)
      _ = read(readFD, &buffer, buffer.count)
      latch.fire()
    }
    // The descriptor is closed only after the source has really let go of it.
    source.setCancelHandler { close(readFD) }
    source.resume()
    self.source = source

    for sig in signals {
      var action = sigaction()
      action.__sigaction_u.__sa_handler = { signalNumber in
        // Only async-signal-safe calls here: one byte into the pipe, and errno
        // put back for the code the signal interrupted.
        let saved = errno
        var byte = UInt8(truncatingIfNeeded: signalNumber)
        _ = write(terminationPipeWriteFD, &byte, 1)
        errno = saved
      }
      sigemptyset(&action.sa_mask)
      action.sa_flags = SA_RESTART
      var old = sigaction()
      sigaction(sig, &action, &old)
      previous[sig] = old
    }
  }

  /// Puts the previous dispositions back (tests; the job simply exits).
  public func uninstall() {
    for (sig, old) in previous {
      var restore = old
      sigaction(sig, &restore, nil)
    }
    previous.removeAll()
    source?.cancel()
    source = nil
    terminationPipeWriteFD = -1
    if pipeFDs[1] >= 0 { close(pipeFDs[1]) }  // the read end closes in the cancel handler
    pipeFDs = [-1, -1]
  }
}

/// Read by the signal handler, which cannot capture anything.
nonisolated(unsafe) private var terminationPipeWriteFD: Int32 = -1
