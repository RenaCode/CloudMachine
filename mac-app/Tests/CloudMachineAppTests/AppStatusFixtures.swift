import CloudMachineCore
import Foundation

@testable import CloudMachineApp

/// A machine in which everything answers and nothing waits to be uploaded.
extension MachineStatus {
  static var healthyForTests: MachineStatus {
    var machine = MachineStatus()
    machine.state = .running
    machine.address = "192.168.64.10"
    machine.services = [
      "rclone-tm": "active", "punchfs": "active", "tm-bands-bind": "active", "smbd": "active",
    ]
    machine.reading = VMLayout.Reading(
      buffer: VMLayout.BufferStats(
        bytesUsed: 60 * VMGuard.gib, uploadsQueued: 0, uploadsInProgress: 0, unsentBytes: 0),
      freeBytes: 120 * VMGuard.gib)
    machine.bundlePrepared = true
    machine.imageCount = 1
    return machine
  }
}

extension AppStatus {
  /// Everything fine: a test changes ONE thing and looks at what that does.
  @MainActor
  static func healthyForTests() -> AppStatus {
    let status = AppStatus()
    status.dependencyState = .ready
    status.remoteConfigured = true
    status.machine = .healthyForTests
    status.timeMachineState = .registered(url: "smb://tm@192.168.64.10/CloudMachine")
    status.backupCycle = BackupCycleStatus(
      known: true, lastSuccess: Date().addingTimeInterval(-1800), problems: [],
      checkedAt: Date())
    return status
  }
}
