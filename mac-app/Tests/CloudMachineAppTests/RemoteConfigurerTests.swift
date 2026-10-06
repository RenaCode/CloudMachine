import XCTest

@testable import CloudMachineCore

final class RemoteConfigurerTests: XCTestCase {
  func testExtractToken_validOutput() {
    let output =
      "Paste the following into the remote machine --->\n{\"access_token\":\"abc123\"}\n<---End paste"
    XCTAssertEqual(
      RemoteConfigurer.extractToken(from: output),
      "{\"access_token\":\"abc123\"}"
    )
  }

  func testExtractToken_missingMarkers() {
    XCTAssertNil(RemoteConfigurer.extractToken(from: "something went wrong, no markers"))
  }

  func testExtractToken_onlyStartMarker() {
    XCTAssertNil(RemoteConfigurer.extractToken(from: "text ---> rest without an end"))
  }
}
