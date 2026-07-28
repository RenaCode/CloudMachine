import ArgumentParser
import CloudMachineCore

struct Mount: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "mount",
    abstract: "Montuje wolumin NFS + wirtualny dysk sparsebundle dla tej maszyny.")

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let ok = await MountService.mount(config: config, machineKey: key)
    if !ok { throw ExitCode.failure }
  }
}

struct Unmount: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "unmount", abstract: "Odmontowuje wolumin CloudMachine i sparsebundle.")

  func run() async throws {
    let (config, key) = await CLIContext.load()
    let ok = await UnmountService.unmount(config: config, machineKey: key)
    if !ok { throw ExitCode.failure }
  }
}
