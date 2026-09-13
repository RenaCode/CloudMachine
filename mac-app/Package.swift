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
        .executableTarget(
            // Harnessy pomiarowe (dawne gdrive/poc-*.sh). Celowo OSOBNA
            // binarka: mierza zachowanie hdiutil i FUSE-T, nie nasz kod, i nie
            // naleza do dzialajacego systemu - `build-app` ich nie kopiuje do
            // bundla. Osobny target, a nie podkomendy agenta, wlasnie po to,
            // zeby nie dalo sie ich przypadkiem uruchomic na produkcji:
            // kazdy z nich tworzy i kasuje obrazy dyskow.
            name: "cloudmachine-poc",
            dependencies: [
                "CloudMachineCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CloudMachinePOC"
        ),
        .testTarget(
            name: "CloudMachineAppTests",
            dependencies: ["CloudMachineApp", "CloudMachineCore"],
            path: "Tests/CloudMachineAppTests"
        )
    ]
)
