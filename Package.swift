// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxStarscream",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        .library(
            name: "RxStarscream",
            targets: ["RxStarscream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", .upToNextMajor(from: "4.0.6")),
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "6.6.0"))
    ],
    targets: [
        .target(
            name: "RxStarscream",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Starscream", package: "Starscream")
            ],
            path: "Source"),
        .testTarget(
            name: "RxStarscreamTests",
            dependencies: [
                .byName(name: "RxStarscream"),
                .product(name: "RxTest", package: "RxSwift")
            ],
            path: "RxStarscreamTests"),
        .testTarget(name: "RxStarscream_macOSTests",
                    dependencies: [
                        .byName(name: "RxStarscream"),
                        .product(name: "RxTest", package: "RxSwift")
                    ],
                   path: "RxStarscream-macOSTests")
    ]
)
