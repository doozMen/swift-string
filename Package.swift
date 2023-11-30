// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-string",
    platforms: [.macOS(.v13), .iOS(.v13)],
    products: [
        .library(
            name: "SwiftString",
            targets: ["SwiftString"]),
    ],
    dependencies: [
      .package(url: "https://github.com/doozMen/swift-snapshot-testing-cli.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "SwiftString",
            dependencies: []),
        .testTarget(
            name: "SwiftStringTests",
            dependencies: [
              "SwiftString",
              .product(name: "SnapshotTestingCli", package: "swift-snapshot-testing-cli")
            ]
        ),
    ]
)
