import ArgumentParser
import CloudMachineCore

struct MountWatchdog: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "mount-watchdog", abstract: "Sprawdza zdrowie montowania i naprawia je automatycznie, jesli zawieszone.")

    func run() async throws {
        let (config, key) = await CLIContext.load()
        await MountWatchdogService.run(config: config, machineKey: key)
    }
}

struct BackupWatchdog: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "backup-watchdog", abstract: "Wznawia backup Time Machine, jesli jest bezczynny mimo ze CloudMachine powinno byc aktywne.")

    func run() async throws {
        let (config, key) = await CLIContext.load()
        await BackupWatchdogService.run(config: config, machineKey: key)
    }
}

struct QuotaWatchdog: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "quota-watchdog", abstract: "Przycina najstarsze backupy, jesli przekroczony limit miejsca tej maszyny.")

    func run() async throws {
        let (config, key) = await CLIContext.load()
        await QuotaWatchdogService.run(config: config, machineKey: key)
    }
}

struct VerifyWatchdog: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "verify-watchdog", abstract: "Automatyczna, cykliczna weryfikacja sum kontrolnych najnowszego backupu (raz na 7 dni).")

    func run() async throws {
        let (config, key) = await CLIContext.load()
        await VerifyWatchdogService.run(config: config, machineKey: key)
    }
}
