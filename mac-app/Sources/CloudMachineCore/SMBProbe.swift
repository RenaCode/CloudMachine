import Foundation

/// Asks Samba in the machine to negotiate, from THIS Mac, over the address
/// Time Machine uses (vzNAT).
///
/// Every other question to the machine goes through `limactl shell` - ssh
/// over Lima's own user network, not over vzNAT. So a cut vzNAT, or an smbd
/// that is `active` but does not answer, left every check green while Time
/// Machine could not reach its destination.
///
/// A TCP connect alone would not do: the kernel completes the handshake for
/// a listening socket whether or not smbd ever reads from it. The probe sends
/// an SMB2 NEGOTIATE and waits for an SMB2 header back - the first thing
/// Time Machine itself asks for. It never logs in; the share's password is
/// not involved.
///
/// Sockets do not sit in uninterruptible sleep, so the deadline (non-blocking
/// connect, `poll`) really bounds it; it still runs off the caller's thread,
/// because the panel calls it from the main actor.
public enum SMBProbe {

  public enum Verdict: Equatable, Sendable {
    case answers
    /// The connection failed (`reason`: errno name) or smbd hung up unanswered.
    case refused(reason: String)
    /// Something answered on the port, but not SMB2.
    case notSMB
    /// This Mac had no route (EHOSTUNREACH/ENETUNREACH, at once): the route
    /// to the machine is gone, OR macOS Local Network privacy has not allowed
    /// this program - the same probe from Terminal then answers. Not knowing
    /// which, it is "unknown", not a refusal.
    case unreachable(reason: String)
    /// Nothing came back within the limit - unknown, never fine.
    case noAnswer(seconds: Int)
    /// The machine did not say its address, so nobody could try.
    case noAddress

    public var answers: Bool { self == .answers }
  }

  /// What happened on the wire - the input of the pure `verdict`.
  public enum Exchange: Equatable, Sendable {
    case connectFailed(Int32)
    case timedOut
    case closed
    case received([UInt8])
  }

  public typealias Transport =
    @Sendable (_ host: String, _ port: UInt16, _ request: [UInt8], _ timeout: TimeInterval) ->
    Exchange

  /// A healthy smbd answers a negotiate in milliseconds; 5 s leaves room for
  /// a machine busy with a backup without holding up the panel.
  public static let timeoutSeconds: TimeInterval = 5

  /// NetBIOS session frame + SMB2 header + NEGOTIATE with dialects 2.0.2,
  /// 2.1, 3.0, 3.0.2 - none of which needs negotiate contexts (3.1.1 does,
  /// and the machine's minimum is SMB2_10 anyway). Little-endian fields.
  static let negotiateRequest: [UInt8] = {
    var header = [UInt8](repeating: 0, count: 64)
    header[0...3] = [0xFE, 0x53, 0x4D, 0x42]  // protocol id
    header[4] = 64  // structure size
    // command 0 = NEGOTIATE (bytes 12-13), credit request 1 (bytes 14-15)
    header[14] = 1
    var body = [UInt8](repeating: 0, count: 36)
    body[0] = 36  // structure size
    body[2] = 4  // dialect count
    body[4] = 1  // security mode: signing enabled
    // client GUID (bytes 12-27): any fixed value
    for index in 12..<28 { body[index] = UInt8(index) }
    let dialects: [UInt8] = [0x02, 0x02, 0x10, 0x02, 0x00, 0x03, 0x02, 0x03]
    let message = header + body + dialects
    let length = UInt32(message.count)
    return [0, UInt8((length >> 16) & 0xFF), UInt8((length >> 8) & 0xFF), UInt8(length & 0xFF)]
      + message
  }()

  /// Pure, so every outcome has a test.
  static func verdict(_ exchange: Exchange, timeout: Int) -> Verdict {
    switch exchange {
    case .connectFailed(let code) where code == EHOSTUNREACH || code == ENETUNREACH:
      return .unreachable(reason: errnoName(code))
    case .connectFailed(let code): return .refused(reason: errnoName(code))
    case .timedOut: return .noAnswer(seconds: timeout)
    case .closed: return .refused(reason: "closed without an answer")
    case .received(let bytes):
      // After the 4-byte NetBIOS frame: 0xFE 'S' 'M' 'B'.
      guard bytes.count >= 8, Array(bytes[4..<8]) == [0xFE, 0x53, 0x4D, 0x42] else {
        return .notSMB
      }
      return .answers
    }
  }

  static func errnoName(_ code: Int32) -> String {
    switch code {
    case ECONNREFUSED: return "ECONNREFUSED"
    case EHOSTUNREACH: return "EHOSTUNREACH"
    case ENETUNREACH: return "ENETUNREACH"
    case EHOSTDOWN: return "EHOSTDOWN"
    case ECONNRESET: return "ECONNRESET"
    case ETIMEDOUT: return "ETIMEDOUT"
    case EADDRNOTAVAIL: return "EADDRNOTAVAIL"
    case EINVAL: return "EINVAL"
    default: return "errno \(code)"
    }
  }

  /// `nil` address = `.noAddress` without touching the network.
  public static func probe(
    address: String?, port: UInt16 = 445, timeout: TimeInterval = timeoutSeconds,
    transport: @escaping Transport = liveExchange
  ) async -> Verdict {
    guard let address, !address.isEmpty else { return .noAddress }
    let request = negotiateRequest
    let exchange = await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .utility).async {
        continuation.resume(returning: transport(address, port, request, timeout))
      }
    }
    return verdict(exchange, timeout: Int(timeout.rounded()))
  }

  /// `poll` that sits out signal interruptions until the deadline.
  private static func pollUntil(
    _ fd: Int32, events: Int32, milliseconds: () -> Int32
  ) -> Int32 {
    while true {
      var pollFD = pollfd(fd: fd, events: Int16(events), revents: 0)
      let ready = poll(&pollFD, 1, milliseconds())
      if ready < 0 && errno == EINTR { continue }
      return ready
    }
  }

  /// One connection: connect, send, read the first 8 bytes - all within `timeout`.
  @Sendable public static func liveExchange(
    host: String, port: UInt16, request: [UInt8], timeout: TimeInterval
  ) -> Exchange {
    let deadline = Date().addingTimeInterval(timeout)
    func remainingMilliseconds() -> Int32 {
      Int32(max(0, min(Double(Int32.max), deadline.timeIntervalSinceNow * 1000)))
    }

    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = port.bigEndian
    guard inet_pton(AF_INET, host, &address.sin_addr) == 1 else {
      return .connectFailed(EINVAL)
    }
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    guard fd >= 0 else { return .connectFailed(errno) }
    defer { close(fd) }
    var one: Int32 = 1
    setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout<Int32>.size))
    _ = fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK)

    let connected = withUnsafePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    if connected != 0 {
      guard errno == EINPROGRESS || errno == EINTR else { return .connectFailed(errno) }
      let ready = pollUntil(fd, events: POLLOUT, milliseconds: remainingMilliseconds)
      if ready == 0 { return .timedOut }
      if ready < 0 { return .connectFailed(errno) }
      var failure: Int32 = 0
      var length = socklen_t(MemoryLayout<Int32>.size)
      getsockopt(fd, SOL_SOCKET, SO_ERROR, &failure, &length)
      if failure != 0 { return .connectFailed(failure) }
    }

    var sent = 0
    while sent < request.count {
      let written = request[sent...].withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
      if written > 0 {
        sent += written
        continue
      }
      guard written < 0, errno == EAGAIN || errno == EINTR else { return .connectFailed(errno) }
      if pollUntil(fd, events: POLLOUT, milliseconds: remainingMilliseconds) <= 0 {
        return .timedOut
      }
    }

    var received: [UInt8] = []
    var buffer = [UInt8](repeating: 0, count: 64)
    while received.count < 8 {
      let ready = pollUntil(fd, events: POLLIN, milliseconds: remainingMilliseconds)
      if ready == 0 { return .timedOut }
      if ready < 0 { return .connectFailed(errno) }
      let count = read(fd, &buffer, buffer.count)
      if count == 0 { return received.isEmpty ? .closed : .received(received) }
      if count < 0 {
        if errno == EAGAIN || errno == EINTR { continue }
        return .connectFailed(errno)
      }
      received += buffer[0..<count]
    }
    return .received(received)
  }

  /// Asks less often: the panel refreshes every 10 s, and every question is a
  /// connection smbd forks a child for. An ANSWER is reused for `interval`
  /// for the same address; anything else is asked again at the next refresh,
  /// so the panel turns green as soon as Samba answers again.
  public struct Cache: Sendable {
    public let interval: TimeInterval
    private var last: (address: String, at: Date)?

    public init(interval: TimeInterval = 60) { self.interval = interval }

    public func reusable(address: String?, now: Date) -> Verdict? {
      guard let address, let last, last.address == address,
        now.timeIntervalSince(last.at) < interval
      else { return nil }
      return .answers
    }

    public mutating func record(_ verdict: Verdict, address: String?, at date: Date) {
      last = verdict == .answers ? address.map { ($0, date) } : nil
    }

    public mutating func probe(
      address: String?, now: Date = Date(), transport: @escaping Transport = liveExchange
    ) async -> Verdict {
      if let reused = reusable(address: address, now: now) { return reused }
      let verdict = await SMBProbe.probe(address: address, transport: transport)
      record(verdict, address: address, at: now)
      return verdict
    }
  }
}
