// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftSerial",
    products: [
        .library(
            name: "SwiftSerial",
            targets: ["SwiftSerial"]),
    ],
    targets: [
        .target(name: "SwiftSerial"),
    ]
)
