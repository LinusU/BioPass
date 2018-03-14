// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BioPass",
    products: [
        .library(name: "BioPass", targets: ["BioPass"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.0.0"),
        .package(url: "https://github.com/LinusU/Valet", .branch("swiftpm")),
    ],
    targets: [
        .target(name: "BioPass", dependencies: ["PromiseKit", "Valet"]),
        .testTarget(name: "BioPassTests", dependencies: ["BioPass"]),
    ]
)
