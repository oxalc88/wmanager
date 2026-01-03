// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WManager",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "WManager", targets: ["WManager"])
    ],
    targets: [
        .executableTarget(
            name: "WManager",
            path: "Sources/WManager"
        ),
        .testTarget(
            name: "WManagerTests",
            dependencies: ["WManager"],
            path: "Tests/WManagerTests"
        )
    ]
)
