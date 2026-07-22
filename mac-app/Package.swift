// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CloudMachineApp",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CloudMachineApp",
            path: "Sources/CloudMachineApp"
        )
    ]
)
