// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "frontegg_flutter",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "frontegg-flutter", targets: ["frontegg_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/frontegg/frontegg-ios-swift.git", exact: "1.3.2"),
    ],
    targets: [
        .target(
            name: "frontegg_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "FronteggSwift", package: "frontegg-ios-swift"),
            ]
        )
    ]
)
