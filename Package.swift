// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "StatusBarOverlay",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(name: "StatusBarOverlay", targets: ["StatusBarOverlay"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/ashleymills/Reachability.swift.git", 
            from: "5.0.0"
        )
    ],
    targets: [
        .target(name: "StatusBarOverlay", dependencies: ["Reachability"])
    ],
    swiftLanguageVersions: [.v5]
)
