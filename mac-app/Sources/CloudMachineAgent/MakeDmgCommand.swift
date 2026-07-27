import ArgumentParser
import Foundation

/// Port `scripts/make-dmg.sh` - pakuje zbudowane `CloudMachine.app` (patrz
/// `build-app`) do instalatora `.dmg` z przeciagalnym skrotem do `/Applications`.
struct MakeDmg: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "make-dmg",
    abstract: "Pakuje build/CloudMachine.app do pliku build/CloudMachine-<wersja>.dmg."
  )

  func run() async throws {
    let macAppRoot = BuildPaths.macAppRoot
    let appName = "CloudMachine"
    let buildDir = macAppRoot.appendingPathComponent("build")
    let appBundle = buildDir.appendingPathComponent("\(appName).app")
    let stagingDir = buildDir.appendingPathComponent("dmg-staging")
    let version =
      (try? String(contentsOf: macAppRoot.appendingPathComponent("VERSION"), encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? "1.0.0"
    let dmgPath = buildDir.appendingPathComponent("\(appName)-\(version).dmg")
    let fm = FileManager.default

    guard fm.fileExists(atPath: appBundle.path) else {
      print("BLAD: brak \(appBundle.path) - uruchom najpierw 'cloudmachine-agent build-app'")
      throw ExitCode.failure
    }

    print("==> Przygotowuje folder staging")
    try? fm.removeItem(at: stagingDir)
    try? fm.removeItem(at: dmgPath)
    try fm.createDirectory(at: stagingDir, withIntermediateDirectories: true)
    try fm.copyItem(at: appBundle, to: stagingDir.appendingPathComponent("\(appName).app"))
    try fm.createSymbolicLink(
      at: stagingDir.appendingPathComponent("Applications"),
      withDestinationURL: URL(fileURLWithPath: "/Applications"))

    print("==> Tworze \(dmgPath.path)")
    let status = try await InteractiveProcess.run(
      "/usr/bin/hdiutil",
      [
        "create", "-volname", appName, "-srcfolder", stagingDir.path, "-ov", "-format", "UDZO",
        dmgPath.path,
      ])
    try? fm.removeItem(at: stagingDir)
    guard status == 0 else {
      print("BLAD: hdiutil zakonczyl sie kodem \(status).")
      throw ExitCode.failure
    }

    print("==> Gotowe: \(dmgPath.path)")
    print(
      """

      Przy pierwszym uruchomieniu (appka niepodpisana kontem Apple Developer):
      1. Otworz \(dmgPath.path) i przeciagnij CloudMachine.app do Applications.
      2. W Finderze kliknij CloudMachine.app PRAWYM przyciskiem -> Otworz -> Otworz
         (samo dwuklikniecie pokaze blokade Gatekeepera "niezidentyfikowany deweloper").
      3. Kolejne uruchomienia dzialaja juz normalnie, dwuklikiem.
      """)
  }
}
