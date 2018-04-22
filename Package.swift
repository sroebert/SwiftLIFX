// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftLIFX",
    products: [
        .library(name: "SwiftLIFX", targets: ["SwiftLIFX"]),
    ],
    dependencies: [
        // Event-driven network application framework for high performance protocol servers & clients, non-blocking.
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.1"),
    ],
    targets: [
        .target(name: "SwiftLIFX", dependencies: ["NIO"]),
    ]
)
