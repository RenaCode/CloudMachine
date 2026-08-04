import Foundation

/// Dysk lokalny (wolumin pod `/Volumes`) nadajacy sie do wybrania jako
/// zrodlo udostepnienia sieciowego w Kreatorze - patrz `NetworkShareService`.
public struct DiskCandidate: Equatable, Identifiable, Sendable {
  public var id: String { mountPoint }
  public var name: String
  public var mountPoint: String
  public var totalGB: Double?
  public var isInternal: Bool

  public init(name: String, mountPoint: String, totalGB: Double?, isInternal: Bool) {
    self.name = name
    self.mountPoint = mountPoint
    self.totalGB = totalGB
    self.isInternal = isInternal
  }
}

/// Udostepnianie lokalnego dysku w sieci lokalnej przez SMB (File Sharing),
/// zeby inny Mac (np. MacBook) mogl uzyc go jako wlasny, niezalezny cel
/// Time Machine przez siec. CloudMachine tworzy TYLKO zwykly udzial SMB
/// (`sharing` - publiczne, udokumentowane narzedzie Apple, patrz `man
/// sharing`); zaznaczenie konkretnego udzialu jako "Share as a Time Machine
/// backup destination" w System Settings -> General -> Sharing jest
/// swiadomie POZOSTAWIONE uzytkownikowi jako ostatni, reczny krok (patrz
/// `CloudMachineController.shareDiskOverNetwork`) - ten mechanizm jest
/// wewnetrzny/nieudokumentowany przez Apple, wiec automatyzowanie go
/// byloby krucha zaleznoscia miedzy wersjami macOS. Z tego samego powodu ta
/// warstwa NIE probuje tez wylistowac juz istniejacych udzialow (`sharing -l
/// -f json`) - jego dokladny format wyjscia nie jest udokumentowany, wiec
/// polegamy zamiast tego na surowym komunikacie samego `sharing` po kazdej
/// probie dodania udzialu (patrz `shareDiskOverNetwork`).
public enum NetworkShareService {
  /// Identyfikator urzadzenia dysku rozruchowego (np. "disk3s5") - dyski
  /// pod `/Volumes` pasujace do tego ID sa wykluczane z `candidateDisks()`.
  /// To jest zabezpieczenie, nie tylko podpowiedz UI: `sharing -a`
  /// udostepnialoby caly dysk systemowy w sieci, gdyby uzytkownik przez
  /// pomylke go wybral.
  static func bootVolumeDeviceIdentifier() async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["info", "-plist", "/"], timeout: 15),
      result.succeeded,
      let data = result.stdout.data(using: .utf8),
      let plist = try? PropertyListSerialization.propertyList(from: data, format: nil)
        as? [String: Any]
    else { return nil }
    return plist["DeviceIdentifier"] as? String
  }

  /// Woluminy zamontowane pod `/Volumes` - dysk rozruchowy jest zawsze
  /// wykluczony (patrz `bootVolumeDeviceIdentifier`).
  public static func candidateDisks() async -> [DiskCandidate] {
    guard
      let entries = try? FileManager.default.contentsOfDirectory(atPath: "/Volumes")
    else { return [] }
    let bootID = await bootVolumeDeviceIdentifier()

    var results: [DiskCandidate] = []
    for name in entries.sorted() {
      let mountPoint = "/Volumes/\(name)"
      guard
        let result = try? await ProcessRunner.run(
          "/usr/sbin/diskutil", ["info", "-plist", mountPoint], timeout: 15),
        result.succeeded,
        let data = result.stdout.data(using: .utf8),
        let plist = try? PropertyListSerialization.propertyList(from: data, format: nil)
          as? [String: Any]
      else { continue }

      let deviceID = plist["DeviceIdentifier"] as? String
      if let bootID, let deviceID, deviceID == bootID { continue }

      let totalBytes = plist["TotalSize"] as? Double
      results.append(
        DiskCandidate(
          name: name,
          mountPoint: mountPoint,
          totalGB: totalBytes.map { $0 / 1_073_741_824 },
          isInternal: (plist["Internal"] as? Bool) ?? true
        ))
    }
    return results
  }

  /// Czy usluga File Sharing (`com.apple.smbd`) jest wlaczona - odpowiednik
  /// glownego przelacznika w System Settings -> General -> Sharing -> File
  /// Sharing. Sprawdzane przez `launchctl print-disabled system`, bo
  /// wlaczenie/wylaczenie tej uslugi to dokladnie `launchctl enable/disable
  /// system/com.apple.smbd` (potwierdzone na zywo na tym Maku).
  public static func isFileSharingEnabled() async -> Bool {
    guard
      let result = try? await ProcessRunner.run(
        "/bin/launchctl", ["print-disabled", "system"], timeout: 15)
    else { return false }
    return isFileSharingEnabled(printDisabledOutput: result.stdout)
  }

  static func isFileSharingEnabled(printDisabledOutput: String) -> Bool {
    for line in printDisabledOutput.split(separator: "\n") where line.contains("com.apple.smbd") {
      return line.contains("=> enabled")
    }
    // Brak wpisu na liscie "print-disabled" oznacza, ze usluga nigdy nie
    // zostala jawnie wylaczona - domyslny stan to wlaczona.
    return true
  }
}
