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
        // Pin to a master commit that includes FronteggRuntime.isTesting support,
        // which is required for the embedded WebView to allow navigation to
        // localhost mock servers in E2E tests.  Released versions (≤1.2.79) do
        // not have this and unconditionally block 127.0.0.1 navigation.
        .package(url: "https://github.com/frontegg/frontegg-ios-swift.git", revision: "f6ffe223cd3cafd80104d27e65c71d24c00a6e86"),
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
