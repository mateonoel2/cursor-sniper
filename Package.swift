// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "cursor-sniper",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "cursor-sniper",
            targets: ["cursor-sniper"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "cursor-sniper",
            dependencies: []
        )
    ]
) 