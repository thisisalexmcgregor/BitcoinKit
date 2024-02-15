// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BitcoinKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "BitcoinKit", targets: ["BitcoinKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.5.1")),
        .package(url: "https://github.com/Boilertalk/secp256k1.swift", .upToNextMinor(from: "0.1.7"))
    ],
    targets: [
        .target(
            name: "BitcoinKit",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "secp256k1", package: "secp256k1.swift")
            ],
            path: "Sources/BitcoinKit"
        ),
        .testTarget(
            name: "BitcoinKitTests",
            dependencies: [
                .target(name: "BitcoinKit")
            ],
            resources: [
                .copy("Resources/block1.raw"),
                .copy("Resources/block413567.raw")
            ]
        )
    ]
)
