import XCTest

@testable import CloudMachineCore

final class NetworkShareServiceTests: XCTestCase {
  func testIsFileSharingEnabled_explicitlyEnabled() {
    let output = "disabled services = {\n\t\"com.apple.smbd\" => enabled\n}"
    XCTAssertTrue(NetworkShareService.isFileSharingEnabled(printDisabledOutput: output))
  }

  func testIsFileSharingEnabled_explicitlyDisabled() {
    let output = "disabled services = {\n\t\"com.apple.smbd\" => disabled\n}"
    XCTAssertFalse(NetworkShareService.isFileSharingEnabled(printDisabledOutput: output))
  }

  func testIsFileSharingEnabled_noEntry_defaultsToEnabled() {
    let output = "disabled services = {\n\t\"com.apple.someotherd\" => disabled\n}"
    XCTAssertTrue(NetworkShareService.isFileSharingEnabled(printDisabledOutput: output))
  }
}
