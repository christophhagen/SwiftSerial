// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftSerial",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "SwiftSerial",
            targets: ["SwiftSerial"]),
    ],
    targets: [
        .target(name: "SwiftSerial"),
    ]
)
