// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lametric-swift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "lametric", targets: ["lametric-cli"]),
        .library(name: "Lametric", targets: ["Lametric"]),
        .library(name: "LametricFoundation", targets: ["LametricFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.26.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/SwiftToolkit/swift-pretty-print", from: "0.1.1"),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.7.0")
    ],
    targets: [
        .target(name: "LametricFoundation"),
        .target(
            name: "Lametric",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .target(name: "LametricFoundation")
            ]
        ),
        .executableTarget(
            name: "lametric-cli",
            dependencies: [
                .target(name: "Lametric"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PrettyPrint", package: "swift-pretty-print"),
                .product(name: "ColorizeSwift", package: "colorizeswift")
            ]
        ),
    ]
)
