// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Unicore",
    products: [
        .library(
            name: "Unicore",
            targets: ["Unicore"]),
    ],
    dependencies: [        
        .package(url: "https://github.com/Unicore/Command.git", from: "1.5.2"),
    ],
    targets: [
        .target(
            name: "Unicore",
            dependencies: [
                "Command",
            ]),
        .testTarget(
            name: "UnicoreTests",
            dependencies: ["Unicore"]),
    ]
)