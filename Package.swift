// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "HIBPKit",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .watchOS(.v3), .tvOS(.v10)
    ],
    products: [
        .library(
            name: "HIBPKit",
            targets: ["HIBPKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HIBPKit",
            dependencies: [],
            path: "HIBPKit"
        ),
        .testTarget(
            name: "HIBPKitTests",
            dependencies: ["HIBPKit"],
            path: "Tests"
        )
    ]
)
