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
  public static func startCaffeinate() async {
    if let pidString = try? String(contentsOf: CMPaths.caffeinatePidFile, encoding: .utf8),
      let pid = pid_t(pidString.trimmingCharacters(in: .whitespacesAndNewlines)),
      ProcessRunner.isProcessRunning(pid: pid),
      await commandName(ofPid: pid)?.contains("caffeinate") == true
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

  /// `kill(pid, 0) == 0` samo w sobie nie wystarcza do stwierdzenia "to
  /// nadal NASZ caffeinate" - po reboocie liczniki PID zaczynaja od nowa od
  /// niskich wartosci, wiec stary numer z pliku (sprzed restartu) moze trafic
  /// na zupelnie inny, niepowiazany proces systemowy, ktory akurat dostal ten
  /// sam PID. Bez tej dodatkowej weryfikacji nazwy polecenia kod myslalby, ze
  /// caffeinate juz dziala, i nigdy by go nie uruchomil.
  private static func commandName(ofPid pid: pid_t) async -> String? {
    guard let result = try? await ProcessRunner.run("/bin/ps", ["-p", "\(pid)", "-o", "comm="])
    else { return nil }
    return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
