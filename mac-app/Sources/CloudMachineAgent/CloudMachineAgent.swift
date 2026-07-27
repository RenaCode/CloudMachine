import ArgumentParser
import CloudMachineCore
import Foundation

@main
struct CloudMachineAgent: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "cloudmachine-agent",
    abstract:
      "CloudMachine - montowanie, watchdogi i instalacja. Wolane przez launchd na harmonogramie, albo recznie z Terminala.",
    subcommands: [
      Mount.self,
      Unmount.self,
      MountWatchdog.self,
      BackupWatchdog.self,
      QuotaWatchdog.self,
      VerifyWatchdog.self,
      VerifyBackup.self,
      InstallLaunchd.self,
      SetupTimeMachine.self,
      ConfigureRemote.self,
      InstallDependencies.self,
      BuildApp.self,
      MakeDmg.self,
      SetupSigningCert.self,
    ]
  )
}

/// Wspolny kontekst (config + klucz tej maszyny) ladowany przez kazda
/// subkomende, ktora tego potrzebuje - jedno miejsce do obslugi
/// "config uszkodzony" zamiast powtarzania tego w kazdym pliku.
enum CLIContext {
  static func load() async -> (config: MachinesConfig, machineKey: String) {
    let (config, corruption) = ConfigStore.loadOrInitialize()
    if let corruption {
      CMLogger.log(
        "BLAD: plik konfiguracyjny jest uszkodzony (\(corruption.localizedDescription)) - uzywam pustej konfiguracji w pamieci, oryginal zachowany na dysku z kopia zapasowa obok."
      )
    }
    let key = await MachineIdentity.currentKey()
    return (config, key)
  }
}
