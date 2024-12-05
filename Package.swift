import PackageDescription

let package = Package(
    name: "SPAsyncVideoView",
    platforms: [
        .iOS(.v8)
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
                .headerSearchPath("Public")
            ]
        )
    ]
)
