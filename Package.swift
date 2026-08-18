// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "BZMenuKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "BZMenuKit", targets: ["BZMenuKit"])
    ],
    targets: [
        .target(
            name: "BZMenuKit",
            path: "Sources/BZMenuKit",
            publicHeadersPath: "include"
        )
    ]
)
