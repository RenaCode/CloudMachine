import XCTest

@testable import CloudMachineApp

/// The setup card is the first thing someone sees after `brew install`. These
/// pin the order (Google before the machine, because that is where this Mac's
/// Drive folder is chosen), that unmeasured state never asks for an action,
/// and that the Time Machine command's password is not what the card shows.
@MainActor
final class SetupPlanTests: XCTestCase {

  private func inputs() -> SetupPlan.Inputs {
    SetupPlan.Inputs(
      hasRclone: true, remoteConfigured: true, hasLima: true, machineExists: true,
      machineRunning: true, hasFullDiskAccess: true, agentsInstalled: true,
      timeMachineNotPointingHere: false, bundleNeedsPreparing: false,
      connectCommand: "connect", setDestinationCommand: "sudo set secret",
      maskedSetDestinationCommand: "sudo set ****")
  }

  private func actions(_ input: SetupPlan.Inputs) -> [SetupStep.Action?] {
    SetupPlan.steps(input).map(\.action)
  }

  func testFinishedSetupHasNoSteps() {
    XCTAssertEqual(SetupPlan.steps(inputs()), [])
  }

  func testFreshMacStopsAtGoogleBeforeTheMachine() {
    var input = inputs()
    input.hasRclone = false
    input.remoteConfigured = false
    input.hasLima = false
    input.machineExists = false
    input.machineRunning = false
    input.hasFullDiskAccess = false
    input.agentsInstalled = false
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.map(\.action), [.installRclone, nil])
    XCTAssertEqual(steps.last?.command, "connect")
  }

  func testLimaIsACommandToCopyBeforeTheMachine() {
    var input = inputs()
    input.hasLima = false
    input.machineExists = nil
    input.machineRunning = false
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.map(\.action), [nil])
    XCTAssertEqual(steps.first?.command, "brew install lima")
  }

  func testMissingMachineIsSetUp() {
    var input = inputs()
    input.machineExists = false
    input.machineRunning = false
    XCTAssertEqual(actions(input), [.setUpMachine])
  }

  func testStoppedMachineIsStartedNotSetUpAgain() {
    var input = inputs()
    input.machineRunning = false
    XCTAssertEqual(actions(input), [.startMachine])
  }

  func testUnknownMachineAsksForNothingMachineRelated() {
    var input = inputs()
    input.machineExists = nil
    input.machineRunning = false
    XCTAssertEqual(SetupPlan.steps(input), [])
  }

  func testAfterTheMachineTheAgentsComeNext() {
    var input = inputs()
    input.hasFullDiskAccess = false
    input.agentsInstalled = false
    input.timeMachineNotPointingHere = true
    XCTAssertEqual(actions(input), [.grantFullDiskAccess, .installAgents])
  }

  func testTimeMachineStepShowsTheMaskedCommandAndCopiesTheRealOne() {
    var input = inputs()
    input.timeMachineNotPointingHere = true
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.map(\.action), [nil])
    XCTAssertEqual(steps.first?.command, "sudo set secret")
    XCTAssertEqual(steps.first?.displayedCommand, "sudo set ****")
  }

  func testWithoutPasswordOrAddressTheMachineIsSetUpAgain() {
    var input = inputs()
    input.timeMachineNotPointingHere = true
    input.setDestinationCommand = nil
    XCTAssertEqual(actions(input), [.setUpMachine])
  }

  func testNewImageIsPreparedOnlyOnceTimeMachinePointsHere() {
    var input = inputs()
    input.bundleNeedsPreparing = true
    XCTAssertEqual(actions(input), [.prepareBundle])
    input.timeMachineNotPointingHere = true
    XCTAssertEqual(actions(input), [nil])
  }

  func testConnectStepIsWhereTheFolderIsChosen() {
    var input = inputs()
    input.remoteConfigured = false
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.last?.choosesFolder, true)
    XCTAssertEqual(steps.filter(\.choosesFolder).count, 1)
  }

  func testConnectCommandCarriesAValidFolderOnly() {
    XCTAssertEqual(
      SetupPlan.connectCommand(agent: "agent", folder: "office-imac"),
      "agent configure-remote --folder office-imac")
    XCTAssertEqual(SetupPlan.connectCommand(agent: "agent", folder: nil), "agent configure-remote")
    // Rejected names never reach the shell: no quoting is needed for what passes.
    XCTAssertEqual(
      SetupPlan.connectCommand(agent: "agent", folder: "My Mac; rm -rf ~"),
      "agent configure-remote")
  }
}
