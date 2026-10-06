import ArgumentParser

/// Measurement harnesses - a SEPARATE binary, deliberately outside `CloudMachine.app`.
///
/// They measure the behaviour of `hdiutil` and FUSE-T, not our code, and they
/// are not part of the running system: nothing calls them from launchd or from
/// the app. `build-app` does not copy this binary into the bundle, so it never
/// reaches users' machines - and yet it is built and checked by CI together
/// with the rest.
///
/// They are run by hand when something needs measuring or a regression needs
/// confirming:
///
///     swift run cloudmachine-poc amplification --band-mb 32 --workload append
///     swift run cloudmachine-poc pullplug --band-mb 32 --rounds 3
@main
struct CloudMachinePOC: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "cloudmachine-poc",
    abstract: "Measurement harnesses for the backup architecture (not part of the running system).",
    subcommands: [AmplificationCommand.self, PullPlugCommand.self])
}
