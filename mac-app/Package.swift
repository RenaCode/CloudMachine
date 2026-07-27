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
            // Nazwa targetu = nazwa skompilowanej binarki w SPM - celowo
            // "cloudmachine-agent" (nie "CloudMachineAgent"), zeby zgadzalo
            // sie z tym, czego szuka CMPaths.agentBinaryPath, build-app.sh i
            // szablony launchd (__CM_AGENT_BIN__).
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
