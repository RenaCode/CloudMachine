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
  }

  static let script =
    VMLayout.services.map { "echo SVC \($0) $(systemctl is-active \($0))" }.joined(separator: "; ")
    + "; pid=$(systemctl show -p MainPID --value punchfs); "
    + "if [ \"${pid:-0}\" -gt 0 ]; then echo FD $(ls /proc/$pid/fd | wc -l) "
    + "$(awk '/Max open files/{print $4}' /proc/$pid/limits); fi; "
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
      }
    }
    report.reading = VMLayout.reading(scriptOutput: scriptOutput)
    return report
  }

  /// Whether Time Machine's destinations include this machine; `nil` = unknown
  /// (no address, or `tmutil` did not answer).
  public static func timeMachineTargetsMachine() async -> Bool? {
    guard let address = await VMLayout.currentAddress(),
      let info = try? await ProcessRunner.run(
        "/usr/bin/tmutil", ["destinationinfo"], timeout: TimeMachineStatus.commandTimeout),
      info.succeeded || info.stdout.contains("No destinations")
    else { return nil }
    return targets(urls: destinationURLs(destinationInfo: info.stdout), address: address)
  }

  /// `smb://tm@<address>/...` among the destinations. The `@` and `/` keep
  /// 192.168.64.1 from matching 192.168.64.10.
  static func targets(urls: [String], address: String) -> Bool {
    urls.contains { $0.contains("@\(address)/") }
  }

  /// `URL : smb://...` lines of `tmutil destinationinfo`.
  static func destinationURLs(destinationInfo: String) -> [String] {
    destinationInfo.split(separator: "\n").compactMap { raw in
      let line = raw.trimmingCharacters(in: .whitespaces)
      guard line.hasPrefix("URL") else { return nil }
      let parts = line.split(separator: ":", maxSplits: 1)
      return parts.count == 2 ? parts[1].trimmingCharacters(in: .whitespaces) : nil
    }
  }

  /// Above this share of the limit the status warns about descriptors.
  static let fileWarningRatio = 0.8

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

    let result = try? await VMLayout.rootShell(script, timeout: 60)
    let report = report(scriptOutput: result?.stdout ?? "")
    for service in VMLayout.services {
      let state = report.services[service] ?? L10n.tr("unknown")
      out.append(
        L10n.tr("Service %@: %@", service.padding(toLength: 14, withPad: " ", startingAt: 0), state)
      )
      // tm-bands-bind is legitimately inactive until vm-prepare-bundle.
      if state != "active" && service != "tm-bands-bind" { healthy = false }
    }
    if let reading = report.reading {
      out.append(
        L10n.tr(
          "Upload buffer:    %@ GiB, queued %@, uploading %@",
          "\(reading.buffer.bytesUsed / VMGuard.gib)", "\(reading.buffer.uploadsQueued)",
          "\(reading.buffer.uploadsInProgress)"))
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

    let destination = try? await ProcessRunner.run(
      "/usr/bin/tmutil", ["destinationinfo"], timeout: TimeMachineStatus.commandTimeout)
    if let destination, destination.succeeded || destination.stdout.contains("No destinations") {
      let urls = destinationURLs(destinationInfo: destination.stdout)
      let ours = urls.first { url in address.map { url.contains("\($0)/") } ?? false }
      if let ours {
        out.append(L10n.tr("Time Machine:     %@", ours))
      } else {
        out.append(
          L10n.tr(
            "Time Machine:     NOT pointing at the machine (%@)",
            urls.isEmpty ? L10n.tr("no SMB destination") : urls.joined(separator: ", ")))
        healthy = false
      }
    } else {
      out.append(L10n.tr("Time Machine:     tmutil did not answer"))
      healthy = false
    }
    return (out, healthy)
  }
}
