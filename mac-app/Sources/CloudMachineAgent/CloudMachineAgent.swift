import ArgumentParser
import CloudMachineCore
import Foundation

@main
struct CloudMachineAgent: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "cloudmachine-agent",
    abstract:
      "CloudMachine - weryfikacja, konfiguracja Google Drive i instalacja. Wolane przez launchd na harmonogramie, albo recznie z Terminala.",
    subcommands: [
      InstallLaunchd.self,
      ConfigureRemote.self,
      InstallDependencies.self,
      BuildApp.self,
      MakeDmg.self,
      SetupSigningCert.self,
      // Warstwa Google Drive - zastapila skrypty z gdrive/.
      InstallRclone.self,
      InstallFuse.self,
      MountDrive.self,
      CreateImage.self,
      AttachImage.self,
      Version.self,
      DetachImage.self,
      VerifyImage.self,
      BufferGuard.self,
      BackupHealthCommand.self,
      PrepareShutdown.self,
      DriveStatus.self,
    ]
  )
}

/// Wspolny kontekst (config + klucz tej maszyny) ladowany przez kazda
/// subkomende, ktora tego potrzebuje - jedno miejsce do obslugi
/// "config uszkodzony" zamiast powtarzania tego w kazdym pliku.
enum CLIContext {
  static func load() async -> (config: MachinesConfig, machineKey: String) {
    let outcome = ConfigStore.loadOrInitialize()
    // PRZERYWAMY, nie ostrzegamy. Wczesniej ten sam komunikat - "oryginal
    // zachowany na dysku z kopia zapasowa obok" - szedl takze wtedy, gdy
    // `backupCorruptFile()` zwrocilo `nil`, czyli gdy zadnej kopii nie bylo.
    // Praca na pustej konfiguracji konczy sie nadpisaniem jedynego egzemplarza
    // przy pierwszym zapisie, a tego juz nie da sie cofnac.
    guard let config = outcome.config else {
      CMLogger.log(
        """
        PRZERWANO: plik konfiguracyjny \(CMPaths.configPath.path) jest uszkodzony \
        (\(outcome.corruption?.localizedDescription ?? "nieznany blad")) i NIE UDALO SIE \
        odlozyc jego kopii. Z pusta konfiguracja w pamieci pierwszy zapis nadpisalby \
        jedyny egzemplarz. Skopiuj ten plik gdzie indziej, napraw go albo usun - \
        i uruchom polecenie ponownie.
        """)
      exit(1)
    }
    if case .corruptButBackedUp(_, let backup, let error) = outcome {
      CMLogger.log(
        "BLAD: plik konfiguracyjny jest uszkodzony (\(error.localizedDescription)) - uzywam pustej konfiguracji w pamieci, oryginal skopiowany do \(backup.path)."
      )
    }
    let key = await MachineIdentity.currentKey()
    return (config, key)
  }
}
