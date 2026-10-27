import Foundation

/// `vm-prepare-bundle`: after Time Machine has created its first, EMPTY image
/// on the machine's local disk, convert it to 32 MB bands and move the bands
/// to Google Drive.
///
/// Why: Time Machine creates bands of 875 MB (band-size 917504000). Every
/// touched band is uploaded whole, and with bands that large a day of
/// ordinary changes passes Google's 750 GB daily upload limit. 32 MB bands
/// were chosen from measurements of this project. The image's small files
/// (Info.plist, token, the Time Machine plists) stay on ext4, because Samba on
/// rclone fails on renames; only `bands/` becomes a bind of the Drive layer.
///
/// The order of steps is the safety: nothing in the machine changes until the
/// converted copy has passed `fsck_apfs -n` and the band-size check on the
/// Mac. A failure before the install restarts Samba with the image untouched;
/// a failure during it leaves Samba STOPPED (Time Machine must not see a half
/// installed image) and says where the original was set aside.
public enum VMBundlePrep {
  /// 32 MiB in 512-byte sectors, as `hdiutil convert -imagekey` wants it.
  public static let bandSectors = 65536
  public static let bandBytes = bandSectors * 512
  /// An empty image is a few hundred MB; anything near this already holds a
  /// backup, and converting that by hand is not what this command is for.
  public static let maxImageBytes: Int64 = 2 << 30

  public struct Outcome: Sendable {
    public var succeeded: Bool
    public var message: String
  }

  public static func run(bundleOverride: String?) async -> Outcome {
    func fail(_ message: String) -> Outcome {
      CMLogger.log("vm-prepare-bundle: \(message.replacingOccurrences(of: "\n", with: " "))")
      return Outcome(succeeded: false, message: message)
    }
    func step(_ text: String) {
      CMLogger.log("vm-prepare-bundle: \(text)")
    }

    // 1. Time Machine must not be writing.
    switch await TimeMachineStatus.runningState() {
    case .none:
      return fail(
        L10n.tr("tmutil did not answer - not touching the image while its state is unknown."))
    case .some(true):
      // A backup to another destination does not write this image (a second
      // machine, or a throwaway one next to `cmsmb`); one that may is stopped.
      let address = await VMLayout.currentAddress()
      guard let address, await VMStatus.timeMachineTargetsMachine(address: address) == false
      else {
        return fail(L10n.tr("Time Machine is backing up - stop it first: tmutil stopbackup"))
      }
      step("Time Machine is backing up, but not to \(VMLayout.instanceName) - going on")
    case .some(false):
      break
    }

    // 2. Which image.
    guard
      let listing = try? await VMLayout.rootShell(
        "cd \(VMLayout.Guest.localRoot) && for d in *.sparsebundle; do [ -d \"$d\" ] && printf '%s\\n' \"$d\"; done; true",
        timeout: 60), listing.succeeded
    else {
      return fail(
        L10n.tr("The machine does not answer - is it running? cloudmachine-agent vm-status"))
    }
    let found = listing.stdout.split(separator: "\n").map(String.init)
    let computerName = await currentComputerName()
    let name: String
    switch chooseBundle(found: found, computerName: computerName, override: bundleOverride) {
    case .success(let chosen): name = chosen
    case .failure(let problem): return fail(problem.message)
    }
    let bundle = "\(VMLayout.Guest.localRoot)/\(name)"
    let qBundle = VMLayout.shellQuoted(bundle)
    step("image \(name)")

    // 3. Already done?
    if (try? await VMLayout.rootShell("test -s \(VMLayout.Guest.bundleEnv)", timeout: 60))?
      .succeeded == true
    {
      return Outcome(
        succeeded: true,
        message: L10n.tr(
          "Already prepared (%@ exists) - nothing to do.", VMLayout.Guest.bundleEnv))
    }

    // 4. Preconditions in the machine: small image, Drive layers up, no bands on Drive yet.
    let checks =
      "set -e; du -s -B1 \(qBundle) | cut -f1; "
      + "systemctl is-active --quiet rclone-tm punchfs && echo LAYERS-UP || echo LAYERS-DOWN; "
      + "if [ -n \"$(ls -A \(VMLayout.Guest.driveRoot)/bands 2>/dev/null)\" ]; then echo BANDS-ON-DRIVE; fi"
    guard let checked = try? await VMLayout.rootShell(checks, timeout: 120), checked.succeeded
    else { return fail(L10n.tr("Could not check the image in the machine.")) }
    let lines = checked.stdout.split(separator: "\n").map(String.init)
    guard let used = lines.first.flatMap({ Int64($0) }) else {
      return fail(L10n.tr("Could not read the image size."))
    }
    if used >= maxImageBytes {
      return fail(
        L10n.tr(
          "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).",
          "\(used >> 20)", "\(maxImageBytes >> 20)"))
    }
    if !lines.contains("LAYERS-UP") {
      return fail(
        L10n.tr(
          "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status."))
    }
    if lines.contains("BANDS-ON-DRIVE") {
      return fail(
        L10n.tr(
          "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.",
          VMLayout.remote))
    }

    // 5. A working directory on the Mac.
    let stamp = Self.stamp()
    let work = VMLayout.hostDir.appendingPathComponent("prepare-\(stamp)")
    let source = work.appendingPathComponent("source")
    let converted = work.appendingPathComponent("converted")
    do {
      try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
      try FileManager.default.createDirectory(at: converted, withIntermediateDirectories: true)
    } catch {
      return fail(L10n.tr("Could not create %@: %@", work.path, error.localizedDescription))
    }
    defer { try? FileManager.default.removeItem(at: work) }
    let staging = "/tmp/cm-prepare-\(stamp)"

    // 6. Samba off, so Time Machine cannot open the image while we copy it.
    step("stopping smbd")
    guard (try? await VMLayout.rootShell("systemctl stop smbd", timeout: 120))?.succeeded == true
    else { return fail(L10n.tr("Could not stop smbd in the machine.")) }
    func failRestoringSamba(_ message: String) async -> Outcome {
      _ = try? await VMLayout.rootShell("rm -rf \(staging); systemctl start smbd", timeout: 120)
      return fail(message + "\n" + L10n.tr("The image was not changed; smbd started again."))
    }

    // 7. Copy to the Mac.
    step("copying the image to the Mac")
    let pack =
      "set -e; install -d -m 700 -o \"$SUDO_USER\" \(staging); "
      + "tar -C \(VMLayout.Guest.localRoot) --sparse -cf \(staging)/source.tar \(VMLayout.shellQuoted(name)); "
      + "chown \"$SUDO_USER\" \(staging)/source.tar"
    let packed = try? await VMLayout.rootShell(pack, timeout: 900)
    guard packed?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr("Packing the image failed: %@", VMLayout.errorTail(packed)))
    }
    let sourceTar = work.appendingPathComponent("source.tar")
    let fetched = try? await VMLayout.limactl(
      ["copy", "\(VMLayout.instanceName):\(staging)/source.tar", sourceTar.path], timeout: 1800)
    guard fetched?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr("Copying the image to the Mac failed: %@", VMLayout.errorTail(fetched)))
    }
    let unpacked = try? await ProcessRunner.run(
      "/usr/bin/tar", ["-C", source.path, "-xf", sourceTar.path], timeout: 900)
    try? FileManager.default.removeItem(at: sourceTar)
    guard unpacked?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr("Unpacking the image failed: %@", VMLayout.errorTail(unpacked)))
    }
    let src = source.appendingPathComponent(name)
    let dst = converted.appendingPathComponent(name)

    // 8. Convert.
    let encrypted = try? await ProcessRunner.run(
      "/usr/bin/hdiutil", ["isencrypted", src.path], timeout: 120)
    if encrypted?.stdout.contains("encrypted: YES") == true {
      return await failRestoringSamba(
        L10n.tr("The image is encrypted - converting encrypted images is not supported."))
    }
    step("hdiutil convert to \(bandSectors)-sector bands")
    let convert = try? await ProcessRunner.run(
      "/usr/bin/hdiutil",
      [
        "convert", src.path, "-format", "UDSB", "-imagekey", "sparse-band-size=\(bandSectors)",
        "-o", dst.path,
      ], timeout: 3600)
    guard convert?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr("hdiutil convert failed: %@", VMLayout.errorTail(convert)))
    }
    do {
      let entries = try FileManager.default.contentsOfDirectory(atPath: src.path)
      for entry in entries where entry.hasPrefix("com.apple.TimeMachine.") {
        let target = dst.appendingPathComponent(entry)
        try? FileManager.default.removeItem(at: target)
        try FileManager.default.copyItem(
          at: src.appendingPathComponent(entry), to: target)
      }
      try FileManager.default.createDirectory(
        at: dst.appendingPathComponent("mapped"), withIntermediateDirectories: true)
    } catch {
      return await failRestoringSamba(
        L10n.tr("Could not carry the Time Machine files over: %@", error.localizedDescription))
    }

    // 9. Verify - read only.
    guard
      let info = try? Data(contentsOf: dst.appendingPathComponent("Info.plist")),
      bandSize(infoPlist: info) == bandBytes
    else {
      return await failRestoringSamba(
        L10n.tr("The converted image does not have %@-byte bands.", "\(bandBytes)"))
    }
    switch await fsckReadOnly(dst) {
    case .success: step("fsck_apfs -n passed")
    case .failure(let problem): return await failRestoringSamba(problem.message)
    }

    // 10. Install.
    step("installing the converted image")
    let convertedTar = work.appendingPathComponent("converted.tar")
    let repacked = try? await ProcessRunner.run(
      "/usr/bin/tar", ["-C", converted.path, "-cf", convertedTar.path, name],
      env: ["COPYFILE_DISABLE": "1"], timeout: 900)
    guard repacked?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr("Packing the converted image failed: %@", VMLayout.errorTail(repacked)))
    }
    let pushed = try? await VMLayout.limactl(
      ["copy", convertedTar.path, "\(VMLayout.instanceName):\(staging)/converted.tar"],
      timeout: 1800)
    guard pushed?.succeeded == true else {
      return await failRestoringSamba(
        L10n.tr(
          "Copying the converted image into the machine failed: %@", VMLayout.errorTail(pushed)))
    }

    let aside = "\(VMLayout.Guest.backupDir)/\(stamp)"
    let install = installScript(
      name: name, staging: staging, aside: aside,
      envLine: VMLayout.envLine("CM_BUNDLE", name))
    let installed = try? await VMLayout.rootShell(install, timeout: 3600)
    guard installed?.succeeded == true else {
      return fail(
        L10n.tr(
          "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.",
          VMLayout.errorTail(installed), aside))
    }
    return Outcome(
      succeeded: true,
      message: L10n.tr(
        "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup",
        name, "\(bandBytes >> 20)", aside))
  }

  /// The machine-side install, one script so it stops at the first error
  /// (`set -e`). Samba is still stopped while it runs.
  static func installScript(name: String, staging: String, aside: String, envLine: String) -> String
  {
    let local = VMLayout.Guest.localRoot
    let bundle = VMLayout.shellQuoted("\(local)/\(name)")
    let drive = "\(VMLayout.Guest.driveRoot)/bands"
    return [
      "set -euo pipefail",
      "B=\(bundle)",
      // Checked again here: between the first check and now someone may have written there.
      "if [ -n \"$(ls -A \(drive) 2>/dev/null)\" ]; then echo 'bands on Drive appeared meanwhile' >&2; exit 3; fi",
      "install -d -m 700 \(VMLayout.Guest.backupDir)",
      "mv \"$B\" \(VMLayout.shellQuoted(aside))",
      "tar -C \(local) -xf \(staging)/converted.tar",
      "find \"$B\" -name '._*' -delete",
      "count=$(find \"$B/bands\" -type f | wc -l)",
      "mkdir -p \(drive)",
      "cp -r \"$B/bands/.\" \(drive)/",
      "test \"$(find \(drive) -type f | wc -l)\" -eq \"$count\"",
      "rm -rf \"$B/bands\" && mkdir \"$B/bands\"",
      "chown -R tm:tm \"$B\"",
      // punchfs keeps a handle to the directory it saw before mkdir; without a
      // restart the bind would show the old, empty view.
      "systemctl restart punchfs",
      "printf '%s\\n' \(VMLayout.shellQuoted(envLine)) > \(VMLayout.Guest.bundleEnv)",
      "systemctl restart tm-bands-bind",
      "mountpoint -q \"$B/bands\"",
      "test \"$(find \"$B/bands/\" -type f | wc -l)\" -eq \"$count\"",
      "rm -rf \(staging)",
      "systemctl start smbd",
    ].joined(separator: "\n")
  }

  // MARK: - Pure parts

  struct Problem: Error, Equatable {
    var message: String
  }

  /// The image Time Machine named after the computer. Another single image
  /// is accepted (a renamed Mac); several, without a match, are a question for
  /// the person (`--bundle`), not a guess.
  static func chooseBundle(found: [String], computerName: String?, override: String?) -> Result<
    String, Problem
  > {
    if let override {
      let wanted = override.hasSuffix(".sparsebundle") ? override : override + ".sparsebundle"
      return found.contains(wanted)
        ? .success(wanted)
        : .failure(Problem(message: L10n.tr("No image %@ in the machine.", wanted)))
    }
    if let computerName, found.contains(computerName + ".sparsebundle") {
      return .success(computerName + ".sparsebundle")
    }
    if found.count == 1 { return .success(found[0]) }
    if found.isEmpty {
      return .failure(
        Problem(
          message: L10n.tr(
            "No image in the machine yet - point Time Machine at the share and let it create one first."
          )))
    }
    return .failure(
      Problem(
        message: L10n.tr(
          "Several images in the machine (%@) - choose one with --bundle.",
          found.joined(separator: ", "))))
  }

  static func bandSize(infoPlist: Data) -> Int? {
    guard
      let plist = try? PropertyListSerialization.propertyList(from: infoPlist, format: nil)
        as? [String: Any]
    else { return nil }
    return (plist["band-size"] as? NSNumber)?.intValue
  }

  /// From `hdiutil attach -plist`: the APFS partition to check and the whole
  /// disk to detach.
  static func attachedDevices(attachPlist: Data) -> (apfs: String?, whole: String?) {
    guard
      let plist = try? PropertyListSerialization.propertyList(from: attachPlist, format: nil)
        as? [String: Any],
      let entities = plist["system-entities"] as? [[String: Any]]
    else { return (nil, nil) }
    var apfs: String?
    var whole: String?
    for entity in entities {
      guard let device = entity["dev-entry"] as? String else { continue }
      let hint = entity["content-hint"] as? String
      if hint == "Apple_APFS", apfs == nil { apfs = device }
      if device.range(of: #"^/dev/disk\d+$"#, options: .regularExpression) != nil, whole == nil {
        whole = device
      }
    }
    return (apfs, whole)
  }

  static func fsckReadOnly(_ image: URL) async -> Result<Void, Problem> {
    let attach = try? await ProcessRunner.run(
      "/usr/bin/hdiutil",
      ["attach", "-nomount", "-readonly", "-noverify", "-noautofsck", "-plist", image.path],
      timeout: 300)
    guard let attach, attach.succeeded else {
      return .failure(
        Problem(
          message: L10n.tr(
            "hdiutil attach of the converted image failed: %@", VMLayout.errorTail(attach))))
    }
    let devices = attachedDevices(attachPlist: Data(attach.stdout.utf8))
    var fsck: ProcessResult?
    if let apfs = devices.apfs {
      fsck = try? await ProcessRunner.run("/sbin/fsck_apfs", ["-n", apfs], timeout: 1800)
    }
    if let whole = devices.whole {
      _ = try? await ProcessRunner.run("/usr/bin/hdiutil", ["detach", whole], timeout: 120)
    }
    guard devices.apfs != nil else {
      return .failure(Problem(message: L10n.tr("The converted image has no APFS partition.")))
    }
    guard fsck?.succeeded == true else {
      return .failure(
        Problem(message: L10n.tr("fsck_apfs -n found problems: %@", VMLayout.errorTail(fsck))))
    }
    return .success(())
  }

  static func currentComputerName() async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/sbin/scutil", ["--get", "ComputerName"], timeout: 30), result.succeeded
    else { return nil }
    let name = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }

  static func stamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd-HHmmss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
  }
}
