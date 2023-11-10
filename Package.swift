// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-string",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "SwiftString",
            targets: ["SwiftString"]),
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0"),
    ],
    targets: [
        .target(
            name: "SwiftString",
            dependencies: []),
        .testTarget(
            name: "SwiftStringTests",
            dependencies: [
              "SwiftString",
              .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["__Snapshots__"]
        ),
    ]
)
