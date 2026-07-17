// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MosaicScrubberKit",
    platforms: [.macOS(.v26), .iOS(.v26), .macCatalyst(.v26)],
    products: [
        .library(
            name: "MosaicScrubberKit",
            targets: ["MosaicScrubberKit"]
        ),
        .library(
            name: "MosaicScrubberMosaicKit",
            targets: ["MosaicScrubberMosaicKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/fdenis75/MosaicKit.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "MosaicScrubberCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "MosaicScrubberMetal",
            dependencies: [
                "MosaicScrubberCore",
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Shaders")
            ]
        ),
        .target(
            name: "MosaicScrubberKit",
            dependencies: [
                "MosaicScrubberCore",
                "MosaicScrubberMetal",
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "MosaicScrubberMosaicKit",
            dependencies: [
                "MosaicScrubberCore",
                "MosaicScrubberKit",
                .product(name: "MosaicKit", package: "MosaicKit")
            ]
        ),
        .testTarget(
            name: "MosaicScrubberCoreTests",
            dependencies: ["MosaicScrubberCore"]
        ),
        .testTarget(
            name: "MosaicScrubberKitTests",
            dependencies: ["MosaicScrubberKit"]
        )
    ]
)
