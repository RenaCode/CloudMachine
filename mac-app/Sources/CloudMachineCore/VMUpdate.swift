import Foundation

/// `vm-update`: brings an existing machine onto the template shipped with this
/// app.
///
/// Lima embeds the template's files into `~/.lima/<machine>/lima.yaml` when the
/// machine is created, and boots from that copy. A newer template in a newer
/// release therefore never reaches a machine that already exists - on
/// 27.10.2026 the live `cmsmb` still ran its morning prototype after 1.3.15
/// shipped the template. This replaces the machine's copy and restarts it twice:
/// the first boot rewrites the units (provisioning), the second starts the
/// services from them. The steps were tried on a throwaway machine and then
/// moved `cmsmb` in 1:52 min.
public enum VMUpdate {
  /// The machine's own copy of the template.
  public static var instanceYAML: URL {
    VMLayout.limaHome.appendingPathComponent(VMLayout.instanceName)
      .appendingPathComponent("lima.yaml")
  }

  /// Top-level settings the update must not change: a different disk or VM
  /// type is a new machine, not an update.
  static let fixedKeys = ["vmType", "arch", "cpus", "memory", "disk"]

  /// The top-level `key: value` lines of a Lima YAML.
  static func topLevel(_ yaml: String) -> [String: String] {
    var values: [String: String] = [:]
    for line in yaml.split(separator: "\n") where !line.hasPrefix(" ") && !line.hasPrefix("#") {
      let parts = line.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else { continue }
      let value = parts[1].trimmingCharacters(in: .whitespaces)
      if !value.isEmpty { values[String(parts[0])] = value }
    }
    return values
  }

  /// The fixed keys that differ, as `key: old -> new`. Empty = safe to update.
  static func fixedDifferences(current: String, new: String) -> [String] {
    let old = topLevel(current)
    let fresh = topLevel(new)
    return fixedKeys.compactMap { key in
      old[key] == fresh[key] ? nil : "\(key): \(old[key] ?? "-") -> \(fresh[key] ?? "-")"
    }
  }

  /// This app's template with its files embedded, as Lima stores it.
  static func embeddedTemplate() async -> String? {
    guard let dir = VMLayout.templateDir else { return nil }
    let out = FileManager.default.temporaryDirectory
      .appendingPathComponent("cloudmachine-\(UUID().uuidString).yaml")
    defer { try? FileManager.default.removeItem(at: out) }
    guard
      let copied = try? await VMLayout.limactl(
        ["template", "copy", "--embed", dir.appendingPathComponent("cmsmb.yaml").path, out.path],
        timeout: 120),
      copied.succeeded
    else { return nil }
    return try? String(contentsOf: out, encoding: .utf8)
  }

  /// Whether the machine runs this app's template. `nil` = could not tell
  /// (no machine, no template, limactl did not answer).
  public static func templateCurrent() async -> Bool? {
    guard let current = try? String(contentsOf: instanceYAML, encoding: .utf8),
      let fresh = await embeddedTemplate()
    else { return nil }
    return current == fresh
  }

  public static func run() async -> CMActionResult {
    func fail(_ message: String) -> CMActionResult {
      CMLogger.log("vm-update: \(message.replacingOccurrences(of: "\n", with: " "))")
      return CMActionResult(succeeded: false, message: message)
    }
    func step(_ text: String) { CMLogger.log("vm-update: \(text)") }

    // 1. Never under a running backup: the machine stops twice.
    switch await TimeMachineStatus.runningState() {
    case .none:
      return fail(
        L10n.tr("tmutil did not answer - not restarting the machine while its state is unknown."))
    case .some(true):
      return fail(L10n.tr("Time Machine is backing up - try again when it has finished."))
    case .some(false):
      break
    }

    // 2. The two templates.
    guard let current = try? String(contentsOf: instanceYAML, encoding: .utf8) else {
      return fail(
        L10n.tr(
          "No machine %@ - create it with: cloudmachine-agent vm-setup", VMLayout.instanceName))
    }
    guard let fresh = await embeddedTemplate() else {
      return fail(L10n.tr("Could not read this app's machine template (limactl template copy)."))
    }
    if current == fresh {
      return CMActionResult(
        succeeded: true,
        message: L10n.tr("Machine %@ already runs this app's template.", VMLayout.instanceName))
    }
    let differences = fixedDifferences(current: current, new: fresh)
    guard differences.isEmpty else {
      return fail(
        L10n.tr(
          "The template changes the machine itself (%@) - that needs a new machine, not an update.",
          differences.joined(separator: ", ")))
    }

    // 3. The units read these files; a machine without them was not set up.
    guard
      (try? await VMLayout.rootShell(
        "test -s \(VMLayout.Guest.vmEnv) && test -s /etc/cloudmachine/tm-ids.env", timeout: 60))?
        .succeeded == true
    else {
      return fail(
        L10n.tr(
          "The machine has no %@ - run cloudmachine-agent vm-setup first.", VMLayout.Guest.vmEnv))
    }

    // 4. Replace the copy, keeping the old one next to it.
    step("stopping \(VMLayout.instanceName)")
    guard
      (try? await VMLayout.limactl(["stop", VMLayout.instanceName], timeout: 600))?.succeeded
        == true
    else { return fail(L10n.tr("limactl stop failed - nothing was changed.")) }
    let stamp = DateFormatter()
    stamp.dateFormat = "yyyyMMdd-HHmm"
    let backup = instanceYAML.deletingLastPathComponent()
      .appendingPathComponent("lima.yaml.before-\(stamp.string(from: Date()))")
    do {
      try FileManager.default.copyItem(at: instanceYAML, to: backup)
      try fresh.write(to: instanceYAML, atomically: true, encoding: .utf8)
    } catch {
      _ = await VMLayout.start()
      return fail(
        L10n.tr("Could not replace %@: %@", instanceYAML.path, error.localizedDescription))
    }
    step("template replaced, old copy in \(backup.lastPathComponent)")

    // 5. Boot to provision, boot again to run the new units.
    for pass in 1...2 {
      if pass == 2 {
        _ = try? await VMLayout.limactl(["stop", VMLayout.instanceName], timeout: 600)
      }
      step("start \(pass) of 2")
      let started = await VMLayout.start()
      guard started.succeeded else {
        return fail(
          L10n.tr(
            "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.",
            started.message, backup.path, VMLayout.instanceName))
      }
    }

    // 6. The share must be back on the Drive layers.
    guard let report = await VMStatus.currentReport(),
      VMStatus.servicesHealthy(report.services) == true
    else {
      return fail(
        L10n.tr(
          "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.",
          backup.path))
    }
    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "Machine %@ now runs this app's template; the previous one is in %@.",
        VMLayout.instanceName, backup.path))
  }
}
