import XCTest

@testable import CloudMachineCore

final class MachinesConfigTests: XCTestCase {

  func testAllocatedGB_sumsAllMachines() {
    let config = MachinesConfig(
      driveTotalGB: 5000,
      safetyMarginPercent: 10,
      remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: [
        MachineEntry(key: "mac-1", displayName: "Mac 1", limitGB: 1000),
        MachineEntry(key: "mac-2", displayName: "Mac 2", limitGB: 1500),
      ]
    )
    XCTAssertEqual(config.allocatedGB, 2500)
  }

  func testSafeBudgetGB_subtractsMargin() {
    let config = MachinesConfig(
      driveTotalGB: 5000,
      safetyMarginPercent: 10,
      remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: []
    )
    XCTAssertEqual(config.safeBudgetGB, 4500)
  }

  func testIsOverBudget_trueWhenAllocationExceedsSafeBudget() {
    let config = MachinesConfig(
      driveTotalGB: 2000,
      safetyMarginPercent: 10,
      remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: [MachineEntry(key: "mac-1", displayName: "Mac 1", limitGB: 1900)]
    )
    // safeBudgetGB = 1800, allocatedGB = 1900 -> over budget
    XCTAssertTrue(config.isOverBudget)
  }

  func testIsOverBudget_falseWhenWithinSafeBudget() {
    let config = MachinesConfig(
      driveTotalGB: 2000,
      safetyMarginPercent: 10,
      remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: [MachineEntry(key: "mac-1", displayName: "Mac 1", limitGB: 1000)]
    )
    XCTAssertFalse(config.isOverBudget)
  }

  // MARK: - Codable round-trip
  // machines.json keeps the machines as a DICTIONARY keyed by "key" (not an
  // array), so that hand-edited JSON is readable - encoding/decoding converts
  // it both ways to/from [MachineEntry]. A regression here means silently
  // losing or duplicating machine entries on every config save.

  func testCodable_roundTripPreservesData() throws {
    let original = MachinesConfig(
      driveTotalGB: 5000,
      safetyMarginPercent: 10,
      remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: [
        MachineEntry(key: "zebra-mac", displayName: "Zebra", limitGB: 500),
        MachineEntry(key: "alpha-mac", displayName: "Alpha", limitGB: 300),
      ]
    )

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(MachinesConfig.self, from: data)

    XCTAssertEqual(decoded.driveTotalGB, original.driveTotalGB)
    XCTAssertEqual(decoded.safetyMarginPercent, original.safetyMarginPercent)
    XCTAssertEqual(decoded.remoteName, original.remoteName)
    XCTAssertEqual(decoded.remoteRootFolder, original.remoteRootFolder)
    // Decoding sorts by key (see init(from:)) - a deterministic order in the
    // UI regardless of the key order in the raw JSON.
    XCTAssertEqual(decoded.machines, original.machines.sorted { $0.key < $1.key })
    XCTAssertEqual(decoded.machines.map(\.key), ["alpha-mac", "zebra-mac"])
  }

  func testDecode_usesDictionaryKeyAsMachineKey() throws {
    let json = """
      {
          "drive_total_gb": 5000,
          "safety_margin_percent": 10,
          "remote_name": "gdrive-cloudmachine",
          "remote_root_folder": "CloudMachine",
          "machines": {
              "marcin-mac-studio": { "display_name": "Marcin's Mac Studio", "limit_gb": 3000 }
          }
      }
      """.data(using: .utf8)!

    let config = try JSONDecoder().decode(MachinesConfig.self, from: json)
    XCTAssertEqual(config.machines.count, 1)
    XCTAssertEqual(config.machines.first?.key, "marcin-mac-studio")
    XCTAssertEqual(config.machines.first?.displayName, "Marcin's Mac Studio")
    XCTAssertEqual(config.machines.first?.limitGB, 3000)
  }

  // MARK: - remotePath / limitGB

  func testRemotePath_combinesRemoteNameRootFolderAndKey() {
    let config = MachinesConfig(
      driveTotalGB: 5000, safetyMarginPercent: 10, remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine", machines: [])
    XCTAssertEqual(
      config.remotePath(forMachineKey: "marcin-mac-studio"),
      "gdrive-cloudmachine:CloudMachine/marcin-mac-studio")
  }

  func testLimitGB_returnsLimitForKnownMachine() {
    let config = MachinesConfig(
      driveTotalGB: 5000, safetyMarginPercent: 10, remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine",
      machines: [MachineEntry(key: "mac-1", displayName: "Mac 1", limitGB: 1000)])
    XCTAssertEqual(config.limitGB(forMachineKey: "mac-1"), 1000)
  }

  func testLimitGB_returnsNilForUnknownMachine() {
    let config = MachinesConfig(
      driveTotalGB: 5000, safetyMarginPercent: 10, remoteName: "gdrive-cloudmachine",
      remoteRootFolder: "CloudMachine", machines: [])
    XCTAssertNil(config.limitGB(forMachineKey: "unknown-machine"))
  }

  // MARK: - config/machines.example.json

  /// Decodes the REAL file from the repo (not a fixture in the test) - a
  /// regression here would mean the project's own example config stopped
  /// parsing (e.g. after a schema change without updating the file). It also
  /// checks that the extra, unrecognized `_comment` field is safely ignored by
  /// the custom `init(from:)`.
  func testDecode_realExampleConfigFileParsesCorrectly() throws {
    let exampleConfigPath = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()  // CloudMachineAppTests
      .deletingLastPathComponent()  // Tests
      .deletingLastPathComponent()  // mac-app
      .deletingLastPathComponent()  // CloudMachine (repo root)
      .appendingPathComponent("config/machines.example.json")

    let data = try Data(contentsOf: exampleConfigPath)
    let config = try JSONDecoder().decode(MachinesConfig.self, from: data)

    XCTAssertEqual(config.remoteName, "gdrive-cloudmachine")
    XCTAssertEqual(config.remoteRootFolder, "CloudMachine")
    XCTAssertEqual(config.machines.count, 2)
    XCTAssertEqual(config.machines.map(\.key).sorted(), ["imac-domowy", "macbook-pro-marcin"])
  }
}
