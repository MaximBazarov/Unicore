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
    ],
    targets: [
        .target(
            name: "Unicore",
            dependencies: [
            ]),
        .testTarget(
            name: "UnicoreTests",
            dependencies: ["Unicore"]),
    ]
)