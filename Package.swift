// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-resource-provider",
    platforms: [
        // Minimum deployment version currently set by `Logger` release version.
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .visionOS(.v1),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ResourceProvider",
            targets: ["ResourceProvider"]
        )
    ],
    targets: [
        .target(
            name: "ResourceProvider"
        ),
        .testTarget(
            name: "ResourceProviderTests",
            dependencies: ["ResourceProvider"]
        )
    ],
    swiftLanguageModes: [.v5]
)
