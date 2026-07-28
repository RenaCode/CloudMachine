import ArgumentParser
import CloudMachineCore

struct VerifyWatchdog: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "verify-watchdog",
    abstract:
      "Automatyczna, cykliczna weryfikacja sum kontrolnych najnowszego backupu (raz na 7 dni).")

  func run() async throws {
    await VerifyWatchdogService.run()
  }
}

struct ArchiveWatchdog: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "archive-watchdog",
    abstract:
      "Automatycznie kopiuje ukonczone lokalne backupy na Google Drive (co kilka godzin).")

  func run() async throws {
    let (config, key) = await CLIContext.load()
    await ArchiveWatchdogService.run(config: config, machineKey: key)
  }
}
