import Foundation

/// "Stan pozadany" montowania i zarzadzanie `caffeinate` - port odpowiednich
/// fragmentow common.sh. Watchdog nigdy nie montuje niczego z wlasnej
/// inicjatywy, tylko UTRZYMUJE stan, ktory uzytkownik ostatnio jawnie wybral
/// (mount.sh -> "on", unmount.sh -> "off") - inaczej wracalby wbrew woli
/// uzytkownika po recznym odmontowaniu.
public enum RuntimeState {
  public static func setMountDesired(_ desired: Bool) {
    try? (desired ? "on" : "off").write(
      to: CMPaths.mountDesiredStatePath, atomically: true, encoding: .utf8)
  }

  public static var mountDesired: Bool {
    (try? String(contentsOf: CMPaths.mountDesiredStatePath, encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines) == "on"
  }

  /// `caffeinate -s` blokuje sen systemowy (na zasilaniu AC) przez caly czas
  /// trwania "mount_desired=on" - bez tego Mac usypia w przerwach miedzy
  /// probami backupu i budzi sie z polamanym mountem/polaczeniami sieciowymi.
  public static func startCaffeinate() {
    if let pidString = try? String(contentsOf: CMPaths.caffeinatePidFile, encoding: .utf8),
      let pid = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines)),
      ProcessRunner.isProcessRunning(pid: pid)
    {
      return
    }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
    process.arguments = ["-s"]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    guard (try? process.run()) != nil else { return }
    try? "\(process.processIdentifier)".write(
      to: CMPaths.caffeinatePidFile, atomically: true, encoding: .utf8)
  }

  public static func stopCaffeinate() {
    guard let pidString = try? String(contentsOf: CMPaths.caffeinatePidFile, encoding: .utf8),
      let pid = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines))
    else { return }
    kill(pid, SIGTERM)
    try? FileManager.default.removeItem(at: CMPaths.caffeinatePidFile)
  }
}
