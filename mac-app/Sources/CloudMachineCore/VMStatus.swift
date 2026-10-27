import Foundation

/// `vm-status`: one look at the machine - address, services, upload buffer,
/// free space, punchfs descriptors and where Time Machine points.
public enum VMStatus {
  public struct Report: Equatable, Sendable {
    public var services: [String: String] = [:]
    /// Open descriptors of punchfs and its limit. passthrough_ll keeps one
    /// per inode it has seen, so a full backup climbs towards the number of
    /// bands; at the limit every new band fails with EMFILE (27.10.2026: 910
    /// of 1024, the first copy stopped).
    public var punchfsOpenFiles: Int?
    public var punchfsFileLimit: Int?
    public var reading: VMLayout.Reading?
    /// `vm-prepare-bundle` has run (`bundle.env` exists); `nil` = not read.
    public var bundlePrepared: Bool?
    /// How many images Time Machine has created in the machine; `nil` = not read.
    public var imageCount: Int?

    public init() {}
  }

  static let script =
    VMLayout.services.map { "echo SVC \($0) $(systemctl is-active \($0))" }.joined(separator: "; ")
    + "; pid=$(systemctl show -p MainPID --value punchfs); "
    + "if [ \"${pid:-0}\" -gt 0 ]; then echo FD $(ls /proc/$pid/fd | wc -l) "
    + "$(awk '/Max open files/{print $4}' /proc/$pid/limits); fi; "
    + "echo BUNDLEENV $([ -s \(VMLayout.Guest.bundleEnv) ] && echo 1 || echo 0); "
    + "echo IMAGES $(ls -d \(VMLayout.Guest.localRoot)/*.sparsebundle 2>/dev/null | wc -l); "
    + VMLayout.readingScript

  static func report(scriptOutput: String) -> Report {
    var report = Report()
    for line in scriptOutput.split(separator: "\n") {
      let fields = line.split(separator: " ").map(String.init)
      if fields.first == "SVC", fields.count >= 3 {
        report.services[fields[1]] = fields[2]
      } else if fields.first == "FD", fields.count >= 2 {
        report.punchfsOpenFiles = Int(fields[1])
        if fields.count >= 3 { report.punchfsFileLimit = Int(fields[2]) }
      } else if fields.first == "BUNDLEENV", fields.count >= 2 {
        report.bundlePrepared = fields[1] == "1"
      } else if fields.first == "IMAGES", fields.count >= 2 {
        report.imageCount = Int(fields[1])
      }
    }
    report.reading = VMLayout.reading(scriptOutput: scriptOutput)
    return report
  }

  /// The machine's services, as a verdict: every one `active`, except
  /// `tm-bands-bind`, which is legitimately `inactive` until
  /// `vm-prepare-bundle` (its condition skips it). `failed` is never fine: a
  /// bind that failed after the image was prepared sends the bands to the
  /// machine's local disk instead of Drive. `nil` = no answer for some unit.
  public static func servicesHealthy(_ services: [String: String]) -> Bool? {
    var unknown = false
    for service in VMLayout.services {
      guard let state = services[service] else {
        unknown = true
        continue
      }
      if state == "active" { continue }
      if service == "tm-bands-bind" && state == "inactive" { continue }
      return false
    }
    return unknown ? nil : true
  }

  /// One run of the status script in the machine. `nil` = no answer (machine
  /// down, limactl stuck); a report whose `reading` is `nil` means rclone in
  /// the machine did not answer.
  public static func currentReport() async -> Report? {
    guard let result = try? await VMLayout.rootShell(script, timeout: 60), result.succeeded
    else { return nil }
    return report(scriptOutput: result.stdout)
  }

  /// Whether a destination is this machine's share: `smb://tm@<address>/CloudMachine`.
  /// Without an address (the machine did not answer) any `tm@.../CloudMachine`
  /// share counts - the question is then "does Time Machine point at a
  /// CloudMachine at all". The `@` and `/` keep 192.168.64.1 from matching
  /// 192.168.64.10.
  public static func isMachineShare(_ url: String, address: String?) -> Bool {
    guard url.hasPrefix("smb://"), url.hasSuffix("/\(VMLayout.shareName)"),
      url.contains("\(VMLayout.smbUser)@") || url.contains("\(VMLayout.smbUser):")
    else { return false }
    guard let address else { return true }
    return url.contains("@\(address)/")
  }

  /// This machine's destination among Time Machine's; `nil` when none is.
  public static func machineDestination(
    in destinations: [TimeMachineStatus.Destination], address: String?
  ) -> TimeMachineStatus.Destination? {
    destinations.first { $0.url.map { isMachineShare($0, address: address) } ?? false }
  }

  /// Whether Time Machine points at the machine; `nil` = `tmutil` did not answer.
  public static func timeMachineTargetsMachine(address: String?) async -> Bool? {
    guard let destinations = await TimeMachineStatus.destinationsReading() else { return nil }
    return machineDestination(in: destinations, address: address) != nil
  }

  /// rclone's remote control in the machine listens on 127.0.0.1:5572 without
  /// a password. Lima forwards the guest's localhost ports to the Mac's unless
  /// the template says otherwise (`portForwards` in `vm/cmsmb.yaml`), and on
  /// the Mac's localhost any web page can send it commands - including
  /// deleting the backup, with no trash. `true` = something answers there.
  public static func remoteControlOpenOnMac() -> Bool {
    tcpPortAnswers(port: 5572)
  }

  /// A plain TCP connect to 127.0.0.1, with a short timeout.
  static func tcpPortAnswers(port: UInt16, timeoutSeconds: Int = 1) -> Bool {
    let socketFD = socket(AF_INET, SOCK_STREAM, 0)
    guard socketFD >= 0 else { return false }
    defer { close(socketFD) }
    var timeout = timeval(tv_sec: timeoutSeconds, tv_usec: 0)
    setsockopt(
      socketFD, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = port.bigEndian
    address.sin_addr.s_addr = inet_addr("127.0.0.1")
    let result = withUnsafePointer(to: &address) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    return result == 0
  }

  /// Above this share of the limit the status warns about descriptors.
  public static let fileWarningRatio = 0.8

  public static func lines() async -> (lines: [String], healthy: Bool) {
    var out: [String] = []
    var healthy = true
    let status: String?
    do {
      status = try await VMLayout.instanceStatus()
    } catch {
      return ([L10n.tr("Machine:          %@", error.localizedDescription)], false)
    }
    guard let status else {
      return (
        [L10n.tr("Machine:          not created - run: cloudmachine-agent vm-setup")], false
      )
    }
    out.append(L10n.tr("Machine:          %@ (%@)", VMLayout.instanceName, status))
    guard status == "Running" else { return (out, false) }

    let address = await VMLayout.currentAddress()
    out.append(L10n.tr("Address:          %@", address ?? L10n.tr("unknown")))
    if address == nil { healthy = false }

    let report = await currentReport() ?? Report()
    for service in VMLayout.services {
      let state = report.services[service] ?? L10n.tr("unknown")
      out.append(
        L10n.tr("Service %@: %@", service.padding(toLength: 14, withPad: " ", startingAt: 0), state)
      )
    }
    if servicesHealthy(report.services) != true { healthy = false }
    if let reading = report.reading {
      out.append(
        L10n.tr(
          "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)",
          reading.buffer.unsentBytes.map { "\($0 / VMGuard.gib)" } ?? "?",
          "\(reading.buffer.uploadsQueued)", "\(reading.buffer.uploadsInProgress)",
          "\(reading.buffer.bytesUsed / VMGuard.gib)"))
      out.append(L10n.tr("Free in machine:  %@ GiB", "\(reading.freeBytes / VMGuard.gib)"))
    } else {
      out.append(
        L10n.tr("Upload buffer:    no answer from rclone (rc %@)", VMLayout.Guest.rcAddress))
      healthy = false
    }
    if let open = report.punchfsOpenFiles {
      let limit = report.punchfsFileLimit.map(String.init) ?? "?"
      out.append(L10n.tr("punchfs files:    %@ open, limit %@", "\(open)", limit))
      if let max = report.punchfsFileLimit, Double(open) > Double(max) * fileWarningRatio {
        out.append(
          L10n.tr("                  WARNING: close to the limit - new bands will fail with EMFILE")
        )
        healthy = false
      }
    }

    if let destinations = await TimeMachineStatus.destinationsReading() {
      let urls = destinations.compactMap(\.url)
      if let ours = address.flatMap({ machineDestination(in: destinations, address: $0)?.url }) {
        out.append(L10n.tr("Time Machine:     %@", redactedPassword(ours)))
      } else {
        out.append(
          L10n.tr(
            "Time Machine:     NOT pointing at the machine (%@)",
            urls.isEmpty
              ? L10n.tr("no SMB destination")
              : urls.map(redactedPassword).joined(separator: ", ")))
        healthy = false
      }
    } else {
      out.append(L10n.tr("Time Machine:     tmutil did not answer"))
      healthy = false
    }
    if remoteControlOpenOnMac() {
      out.append(
        L10n.tr(
          "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)"
        ))
      healthy = false
    }
    return (out, healthy)
  }

  /// `smb://tm:secret@host/...` -> `smb://tm:***@host/...`. tmutil prints
  /// the URL without the password, but a status line must never be the one
  /// place it leaks from.
  static func redactedPassword(_ url: String) -> String {
    guard let scheme = url.range(of: "://"), let at = url.range(of: "@"),
      scheme.upperBound < at.lowerBound
    else { return url }
    let userInfo = url[scheme.upperBound..<at.lowerBound]
    guard let colon = userInfo.firstIndex(of: ":") else { return url }
    return url.replacingCharacters(in: url.index(after: colon)..<at.lowerBound, with: "***")
  }
}
