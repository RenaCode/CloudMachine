import ArgumentParser

/// Harnessy pomiarowe - OSOBNA binarka, celowo poza `CloudMachine.app`.
///
/// Mierza zachowanie `hdiutil` i FUSE-T, a nie nasz kod, i nie sa czescia
/// dzialajacego systemu: nic ich nie wola z launchd ani z aplikacji.
/// `build-app` nie kopiuje tej binarki do bundla, wiec nie trafia na maszyny
/// uzytkownikow - a mimo to jest budowana i sprawdzana przez CI razem z reszta.
///
/// Uruchamia sie je recznie, gdy trzeba cos zmierzyc albo potwierdzic
/// regresje:
///
///     swift run cloudmachine-poc amplification --band-mb 32 --workload append
///     swift run cloudmachine-poc pullplug --band-mb 32 --rounds 3
@main
struct CloudMachinePOC: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "cloudmachine-poc",
    abstract: "Harnessy pomiarowe architektury backupu (nie czesc dzialajacego systemu).",
    subcommands: [AmplificationCommand.self, PullPlugCommand.self])
}
