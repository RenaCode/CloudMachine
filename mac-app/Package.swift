// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CloudMachineApp",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "CloudMachineCore",
            path: "Sources/CloudMachineCore"
        ),
        .executableTarget(
            name: "CloudMachineApp",
            dependencies: ["CloudMachineCore"],
            path: "Sources/CloudMachineApp"
        ),
        .executableTarget(
            // Target name = name of the compiled binary in SPM - deliberately
            // "cloudmachine-agent" (not "CloudMachineAgent"), so that it matches
            // what CMPaths.agentBinaryPath, build-app.sh and the launchd
            // templates (__CM_AGENT_BIN__) look for.
            name: "cloudmachine-agent",
            dependencies: [
                "CloudMachineCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CloudMachineAgent"
        ),
        .testTarget(
            name: "CloudMachineAppTests",
            dependencies: ["CloudMachineApp", "CloudMachineCore"],
            path: "Tests/CloudMachineAppTests"
        )
    ]
)
