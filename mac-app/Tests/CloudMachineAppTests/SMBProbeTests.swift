import Foundation
import XCTest

@testable import CloudMachineCore

/// Whether Samba in the machine answers THIS Mac, over the address Time
/// Machine uses.
///
/// Everything else asks the machine through `limactl shell`, which goes over
/// Lima's own user network - not over vzNAT, which carries SMB. A cut vzNAT or
/// an smbd that no longer answers was invisible: every service `active`, the
/// panel "Ready".
final class SMBProbeTests: XCTestCase {

  // MARK: - The request

  /// An SMB2 NEGOTIATE in a NetBIOS session frame, offering only dialects
  /// that need no negotiate contexts (the machine's minimum is SMB2_10).
  func testNegotiateRequestShape() {
    let request = SMBProbe.negotiateRequest
    XCTAssertEqual(request.count, 4 + 64 + 36 + 2 * 4)
    XCTAssertEqual(Array(request[0..<4]), [0x00, 0x00, 0x00, UInt8(request.count - 4)])
    XCTAssertEqual(Array(request[4..<8]), [0xFE, 0x53, 0x4D, 0x42], "SMB2 protocol id")
    XCTAssertEqual(Array(request[8..<10]), [64, 0], "header structure size")
    XCTAssertEqual(Array(request[16..<18]), [0, 0], "command NEGOTIATE")
    XCTAssertEqual(Array(request[68..<70]), [36, 0], "negotiate structure size")
    XCTAssertEqual(Array(request[70..<72]), [4, 0], "dialect count")
    XCTAssertEqual(
      Array(request[104..<112]), [0x02, 0x02, 0x10, 0x02, 0x00, 0x03, 0x02, 0x03])
  }

  // MARK: - Verdicts

  private let smb2Answer: [UInt8] = [0x00, 0x00, 0x00, 0x41, 0xFE, 0x53, 0x4D, 0x42, 64, 0]

  func testSMB2AnswerAnswers() {
    XCTAssertEqual(SMBProbe.verdict(.received(smb2Answer), timeout: 5), .answers)
  }

  func testRefusedConnectionIsNamed() {
    XCTAssertEqual(
      SMBProbe.verdict(.connectFailed(ECONNREFUSED), timeout: 5),
      .refused(reason: "ECONNREFUSED"))
  }

  /// REVIEW 03.11: "no route" comes back at once both when the route to the
  /// machine is gone AND when macOS Local Network privacy has not allowed
  /// this program (a launchd agent or the app, while the same probe from
  /// Terminal answers). Not knowing which, it is "unknown", not a refusal.
  func testNoRouteIsUnreachableNotRefused() {
    XCTAssertEqual(
      SMBProbe.verdict(.connectFailed(EHOSTUNREACH), timeout: 5),
      .unreachable(reason: "EHOSTUNREACH"))
    XCTAssertEqual(
      SMBProbe.verdict(.connectFailed(ENETUNREACH), timeout: 5),
      .unreachable(reason: "ENETUNREACH"))
    XCTAssertFalse(SMBProbe.Verdict.unreachable(reason: "x").answers)
  }

  // MARK: - Asking less often

  /// The panel refreshes every 10 s; an answering smbd is asked again only
  /// after `interval`, a failing one at every refresh (so the panel turns
  /// green as soon as it answers again).
  func testOnlyAnAnswerIsReusedAndOnlyForTheSameAddress() {
    var cache = SMBProbe.Cache(interval: 60)
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    XCTAssertNil(cache.reusable(address: "a", now: start))
    cache.record(.answers, address: "a", at: start)
    XCTAssertEqual(cache.reusable(address: "a", now: start.addingTimeInterval(59)), .answers)
    XCTAssertNil(cache.reusable(address: "a", now: start.addingTimeInterval(60)))
    XCTAssertNil(cache.reusable(address: "b", now: start.addingTimeInterval(1)))
    XCTAssertNil(cache.reusable(address: nil, now: start.addingTimeInterval(1)))
    cache.record(.noAnswer(seconds: 5), address: "a", at: start)
    XCTAssertNil(cache.reusable(address: "a", now: start.addingTimeInterval(1)))
  }

  func testCachedProbeAsksOnceAWhile() async {
    final class Count: @unchecked Sendable { var n = 0 }
    let count = Count()
    var cache = SMBProbe.Cache(interval: 60)
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    let answer = smb2Answer
    let transport: SMBProbe.Transport = { _, _, _, _ in
      count.n += 1
      return .received(answer)
    }
    for second in [0, 10, 20, 61] as [TimeInterval] {
      let verdict = await cache.probe(
        address: "a", now: start.addingTimeInterval(second), transport: transport)
      XCTAssertEqual(verdict, .answers)
    }
    XCTAssertEqual(count.n, 2)
  }

  /// smbd accepted and hung up before answering: it does not serve.
  func testClosedWithoutAnswerIsRefused() {
    XCTAssertEqual(
      SMBProbe.verdict(.closed, timeout: 5), .refused(reason: "closed without an answer"))
  }

  func testSomethingElseOnThePortIsNotSMB() {
    XCTAssertEqual(
      SMBProbe.verdict(.received(Array("HTTP/1.1 400".utf8)), timeout: 5), .notSMB)
  }

  /// The case that must never read as "fine": no answer within the limit.
  func testTimeoutIsNoAnswer() {
    XCTAssertEqual(SMBProbe.verdict(.timedOut, timeout: 5), .noAnswer(seconds: 5))
    XCTAssertFalse(SMBProbe.Verdict.noAnswer(seconds: 5).answers)
    XCTAssertFalse(SMBProbe.Verdict.noAddress.answers)
    XCTAssertTrue(SMBProbe.Verdict.answers.answers)
  }

  func testWithoutAnAddressNobodyTried() async {
    let verdict = await SMBProbe.probe(address: nil) { _, _, _, _ in
      XCTFail("no address - nothing to connect to")
      return .timedOut
    }
    XCTAssertEqual(verdict, .noAddress)
  }

  func testProbeSendsTheRequestToPort445() async {
    final class Seen: @unchecked Sendable {
      var host = ""
      var port: UInt16 = 0
      var bytes = 0
    }
    let seen = Seen()
    let verdict = await SMBProbe.probe(address: "192.168.64.10") { host, port, request, _ in
      seen.host = host
      seen.port = port
      seen.bytes = request.count
      return .received(self.smb2Answer)
    }
    XCTAssertEqual(verdict, .answers)
    XCTAssertEqual(seen.host, "192.168.64.10")
    XCTAssertEqual(seen.port, 445)
    XCTAssertEqual(seen.bytes, SMBProbe.negotiateRequest.count)
  }

  // MARK: - Canary: real sockets on 127.0.0.1

  /// A listener that accepts and then does `behaviour` with the connection.
  private func listener(_ behaviour: @escaping @Sendable (Int32) -> Void) throws -> UInt16 {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    XCTAssertGreaterThanOrEqual(fd, 0)
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = 0
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    let bound = withUnsafePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    guard bound == 0, listen(fd, 4) == 0 else {
      close(fd)
      throw XCTSkip("cannot listen on 127.0.0.1 here (errno \(errno))")
    }
    var length = socklen_t(MemoryLayout<sockaddr_in>.size)
    _ = withUnsafeMutablePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &length) }
    }
    Thread.detachNewThread {
      let client = accept(fd, nil, nil)
      if client >= 0 { behaviour(client) }
      close(fd)
    }
    return UInt16(bigEndian: address.sin_port)
  }

  func testCanaryAnsweringServerAnswers() async throws {
    let answer = smb2Answer
    let port = try listener { client in
      var buffer = [UInt8](repeating: 0, count: 256)
      _ = read(client, &buffer, buffer.count)
      _ = answer.withUnsafeBytes { write(client, $0.baseAddress, answer.count) }
      close(client)
    }
    let verdict = await SMBProbe.probe(address: "127.0.0.1", port: port, timeout: 3)
    XCTAssertEqual(verdict, .answers)
  }

  /// The smbd-hangs case: the kernel accepts, nobody answers.
  func testCanarySilentServerIsNoAnswerWithinTheLimit() async throws {
    let port = try listener { client in
      Thread.sleep(forTimeInterval: 4)
      close(client)
    }
    let started = Date()
    let verdict = await SMBProbe.probe(address: "127.0.0.1", port: port, timeout: 1)
    XCTAssertEqual(verdict, .noAnswer(seconds: 1))
    XCTAssertLessThan(Date().timeIntervalSince(started), 3)
  }

  func testCanaryNothingListeningIsRefused() async throws {
    // Bind a port, then close it: nothing listens there any more.
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    let bound = withUnsafePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    guard bound == 0 else {
      close(fd)
      throw XCTSkip("cannot bind on 127.0.0.1 here")
    }
    var length = socklen_t(MemoryLayout<sockaddr_in>.size)
    _ = withUnsafeMutablePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &length) }
    }
    close(fd)
    let verdict = await SMBProbe.probe(
      address: "127.0.0.1", port: UInt16(bigEndian: address.sin_port), timeout: 2)
    XCTAssertEqual(verdict, .refused(reason: "ECONNREFUSED"))
  }
}
