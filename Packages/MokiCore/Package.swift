// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MokiCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MokiCore",
            targets: ["MokiCore"]
        ),
        .library(
            name: "MokiPersistence",
            targets: ["MokiPersistence"]
        )
    ],
    targets: [
        .target(
            name: "MokiCore"
        ),
        .target(
            name: "MokiPersistence",
            dependencies: ["MokiCore"]
        ),
        .testTarget(
            name: "MokiCoreTests",
            dependencies: ["MokiCore"]
        ),
        .testTarget(
            name: "MokiPersistenceTests",
            dependencies: ["MokiCore", "MokiPersistence"]
        )
    ]
)
