import XCTest

@testable import CloudMachineCore

/// `vm-prepare-bundle`: choosing the image, reading what hdiutil says, and
/// the order of the machine-side install.
final class VMBundlePrepTests: XCTestCase {

  func testBandSizeIs32MiB() {
    XCTAssertEqual(VMBundlePrep.bandBytes, 33_554_432)
  }

  // MARK: - Which image

  func testPrefersTheImageNamedAfterTheComputer() {
    XCTAssertEqual(
      try? VMBundlePrep.chooseBundle(
        found: ["Old.sparsebundle", "Studio (2).sparsebundle"], computerName: "Studio (2)",
        override: nil
      ).get(), "Studio (2).sparsebundle")
  }

  func testASingleImageIsTakenEvenUnderAnotherName() {
    XCTAssertEqual(
      try? VMBundlePrep.chooseBundle(
        found: ["Renamed.sparsebundle"], computerName: "Studio", override: nil
      ).get(), "Renamed.sparsebundle")
  }

  func testSeveralImagesWithoutAMatchAreAQuestion() {
    guard
      case .failure(let problem) = VMBundlePrep.chooseBundle(
        found: ["A.sparsebundle", "B.sparsebundle"], computerName: "C", override: nil)
    else { return XCTFail("must not guess between two images") }
    XCTAssertTrue(problem.message.contains("--bundle"), problem.message)
  }

  func testNoImageYet() {
    guard
      case .failure = VMBundlePrep.chooseBundle(found: [], computerName: "C", override: nil)
    else { return XCTFail("nothing to prepare") }
  }

  func testOverrideMustExist() {
    XCTAssertEqual(
      try? VMBundlePrep.chooseBundle(
        found: ["A.sparsebundle", "B.sparsebundle"], computerName: nil, override: "B"
      ).get(), "B.sparsebundle")
    guard
      case .failure = VMBundlePrep.chooseBundle(
        found: ["A.sparsebundle"], computerName: nil, override: "Z.sparsebundle")
    else { return XCTFail("an override that is not there must fail") }
  }

  // MARK: - hdiutil

  func testBandSizeFromInfoPlist() throws {
    let plist: [String: Any] = [
      "band-size": 33_554_432, "bundle-backingstore-version": 2,
      "diskimage-bundle-type": "com.apple.diskimage.sparsebundle",
    ]
    let data = try PropertyListSerialization.data(
      fromPropertyList: plist, format: .xml, options: 0)
    XCTAssertEqual(VMBundlePrep.bandSize(infoPlist: data), 33_554_432)
    XCTAssertNil(VMBundlePrep.bandSize(infoPlist: Data("not a plist".utf8)))
  }

  func testAttachedDevices() throws {
    let plist: [String: Any] = [
      "system-entities": [
        ["content-hint": "GUID_partition_scheme", "dev-entry": "/dev/disk7"],
        ["content-hint": "EFI", "dev-entry": "/dev/disk7s1"],
        ["content-hint": "Apple_APFS", "dev-entry": "/dev/disk7s2"],
        ["dev-entry": "/dev/disk8"],
        ["content-hint": "41504653-0000-11AA-AA11-00306543ECAC", "dev-entry": "/dev/disk8s1"],
      ]
    ]
    let data = try PropertyListSerialization.data(
      fromPropertyList: plist, format: .xml, options: 0)
    let devices = VMBundlePrep.attachedDevices(attachPlist: data)
    XCTAssertEqual(devices.apfs, "/dev/disk7s2")
    XCTAssertEqual(devices.whole, "/dev/disk7")
  }

  // MARK: - The install script

  private func script() -> [String] {
    VMBundlePrep.installScript(
      name: "Some Mac (3).sparsebundle", staging: "/tmp/cm-prepare-x", aside: "/var/lib/x/1",
      envLine: VMLayout.envLine("CM_BUNDLE", "Some Mac (3).sparsebundle")
    ).components(separatedBy: "\n")
  }

  private func index(_ needle: String, in lines: [String]) -> Int? {
    lines.firstIndex { $0.contains(needle) }
  }

  func testInstallStopsAtTheFirstError() {
    XCTAssertEqual(script().first, "set -euo pipefail")
  }

  /// punchfs keeps a handle to the directory it saw before `mkdir`; the bind
  /// made before its restart shows an empty view. Samba comes back last.
  func testInstallOrder() throws {
    let lines = script()
    let check = try XCTUnwrap(index("bands on Drive appeared meanwhile", in: lines))
    let aside = try XCTUnwrap(index("mv \"$B\"", in: lines))
    let copy = try XCTUnwrap(index("cp -r", in: lines))
    let restart = try XCTUnwrap(index("systemctl restart punchfs", in: lines))
    let env = try XCTUnwrap(index("/etc/cloudmachine/bundle.env", in: lines))
    let bind = try XCTUnwrap(index("systemctl restart tm-bands-bind", in: lines))
    let mounted = try XCTUnwrap(index("mountpoint -q", in: lines))
    let samba = try XCTUnwrap(index("systemctl start smbd", in: lines))
    XCTAssertLessThan(check, aside, "nothing is moved before Drive is checked again")
    XCTAssertLessThan(aside, copy)
    XCTAssertLessThan(copy, restart)
    XCTAssertLessThan(restart, bind)
    XCTAssertLessThan(env, bind)
    XCTAssertLessThan(bind, mounted)
    XCTAssertEqual(samba, lines.count - 1, "smbd starts only after everything else passed")
    XCTAssertNotNil(index("._*", in: lines), "AppleDouble files from the Mac are removed")
  }

  func testImageNameIsQuoted() {
    XCTAssertTrue(script().contains("B='/srv/tm-local/Some Mac (3).sparsebundle'"), "\(script())")
  }
}
