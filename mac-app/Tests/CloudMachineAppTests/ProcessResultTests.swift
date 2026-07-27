import XCTest

@testable import CloudMachineCore

final class ProcessResultTests: XCTestCase {
  func testIsSudoAuthFailure_missingSudoersRule() {
    let result = ProcessResult(
      stdout: "", stderr: "sudo: a password is required\n", exitCode: 1)
    XCTAssertTrue(result.isSudoAuthFailure)
  }

  func testIsSudoAuthFailure_noTTY() {
    let result = ProcessResult(
      stdout: "", stderr: "sudo: no tty present and no askpass program specified\n", exitCode: 1)
    XCTAssertTrue(result.isSudoAuthFailure)
  }

  func testIsSudoAuthFailure_realTmutilError() {
    let result = ProcessResult(
      stdout: "", stderr: "tmutil: destination not found\n", exitCode: 1)
    XCTAssertFalse(result.isSudoAuthFailure)
  }

  func testIsSudoAuthFailure_success() {
    let result = ProcessResult(stdout: "OK\n", stderr: "", exitCode: 0)
    XCTAssertFalse(result.isSudoAuthFailure)
  }
}
