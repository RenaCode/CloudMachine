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
        .executableTarget(
            // Measurement harnesses (formerly gdrive/poc-*.sh). Deliberately a
            // SEPARATE binary: they measure the behaviour of hdiutil and FUSE-T,
            // not our code, and they are not part of the running system -
            // `build-app` does not copy them into the bundle. A separate target
            // rather than agent subcommands precisely so that they cannot be
            // run on production by accident: each of them creates and deletes
            // disk images.
            name: "cloudmachine-poc",
            dependencies: [
                "CloudMachineCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CloudMachinePOC"
        ),
        .testTarget(
            name: "CloudMachineAppTests",
            // `cloudmachine-poc` has been here since 2026-09-25, on purpose:
            // the harnesses measure the behaviour of hdiutil and FUSE-T, but
            // the WAY they report on it is ordinary code and it broke
            // silently - `pullplug` reported "The image survived every
            // floor pull" after a run in which writing never started. The
            // tests touch ONLY the pure parts (result classification,
            // summary, attempting to write to a directory that does not
            // exist) - none of them creates a disk image.
            dependencies: ["CloudMachineApp", "CloudMachineCore", "cloudmachine-poc"],
            path: "Tests/CloudMachineAppTests"
        )
    ]
)
