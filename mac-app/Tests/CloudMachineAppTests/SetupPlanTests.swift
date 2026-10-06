import XCTest

@testable import CloudMachineApp

/// The setup card is the first thing someone sees after `brew install`. These
/// pin the order (Google before anything that mounts, because that is where
/// this Mac's Drive folder is chosen) and that unmeasured state never asks
/// for an action.
@MainActor
final class SetupPlanTests: XCTestCase {

  private func inputs() -> SetupPlan.Inputs {
    SetupPlan.Inputs(
      hasRclone: true, hasFuse: true, remoteConfigured: true, hasFullDiskAccess: true,
      agentsInstalled: true, mounted: true, imageExists: true, imageAttached: true,
      timeMachineNotPointingHere: false, connectCommand: "connect",
      setDestinationCommand: "sudo set")
  }

  private func actions(_ input: SetupPlan.Inputs) -> [SetupStep.Action?] {
    SetupPlan.steps(input).map(\.action)
  }

  func testFinishedSetupHasNoSteps() {
    XCTAssertEqual(SetupPlan.steps(inputs()), [])
  }

  func testFreshMacStopsAtGoogleBeforeAnythingThatMounts() {
    var input = inputs()
    input.hasRclone = false
    input.hasFuse = false
    input.remoteConfigured = false
    input.hasFullDiskAccess = false
    input.agentsInstalled = false
    input.mounted = false
    input.imageExists = nil
    input.imageAttached = false
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.map(\.action), [.installRclone, .installFuse, nil])
    XCTAssertEqual(steps.last?.command, "connect")
  }

  func testAfterGoogleTheAgentsComeNext() {
    var input = inputs()
    input.hasFullDiskAccess = false
    input.agentsInstalled = false
    input.mounted = false
    input.imageExists = nil
    input.imageAttached = false
    XCTAssertEqual(actions(input), [.grantFullDiskAccess, .installAgents])
  }

  func testMountedWithoutImageOffersToCreateIt() {
    var input = inputs()
    input.imageExists = false
    input.imageAttached = false
    XCTAssertEqual(actions(input), [.createImage])
  }

  func testExistingImageIsAttachedNotCreated() {
    var input = inputs()
    input.imageAttached = false
    XCTAssertEqual(actions(input), [.attachImage])
  }

  func testUnknownImageStateAsksForNothing() {
    var input = inputs()
    input.imageExists = nil
    input.imageAttached = false
    XCTAssertEqual(SetupPlan.steps(input), [])
  }

  func testNotMountedAsksForNoImageStep() {
    var input = inputs()
    input.mounted = false
    input.imageExists = false
    input.imageAttached = false
    XCTAssertEqual(SetupPlan.steps(input), [])
  }

  func testTimeMachineStepIsACommandToCopy() {
    var input = inputs()
    input.timeMachineNotPointingHere = true
    let steps = SetupPlan.steps(input)
    XCTAssertEqual(steps.map(\.action), [nil])
    XCTAssertEqual(steps.first?.command, "sudo set")
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
