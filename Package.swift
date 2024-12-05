// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SPAsyncVideoView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SPAsyncVideoView",
            targets: ["SPAsyncVideoView"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SPAsyncVideoView",
            dependencies: [],
            path: "SPAsyncVideoView/Classes",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Public"),
                .headerSearchPath("Private"),
                .headerSearchPath("Private/GIF")
            ]
        )
    ]
)
