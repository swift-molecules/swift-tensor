// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-tensor",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Tensor",
            targets: ["Tensor"]
        ),
        .library(
            name: "Tensor Dynamic",
            targets: ["Tensor Dynamic"]
        ),
        .library(
            name: "Tensor Named",
            targets: ["Tensor Named"]
        ),
        .library(
            name: "Tensor Test Support",
            targets: ["Tensor Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-finite.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-affine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dimension.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-range.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-numeric.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-algebra.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-format.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-sequence.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-vector.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-heap.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Tensor Core",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Finite", package: "swift-finite"),
                .product(name: "Affine", package: "swift-affine"),
                .product(name: "Dimension", package: "swift-dimension"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(
                    name: "Buffer Linear",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Storage", package: "swift-storage"),
                .product(name: "Range", package: "swift-range"),
                .product(name: "Memory", package: "swift-memory"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(
                    name: "Memory Allocator Protocol",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Numeric", package: "swift-numeric"),
                .product(name: "Algebra Ring", package: "swift-algebra"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Format", package: "swift-format"),
                .product(name: "Sequence", package: "swift-sequence"),
                .product(name: "Vector", package: "swift-vector"),
            ]
        ),

        .target(
            name: "Tensor Dynamic",
            dependencies: [
                "Tensor Core",
                .product(name: "Memory Heap", package: "swift-memory-heap"),
            ]
        ),
        .target(
            name: "Tensor Named",
            dependencies: [
                "Tensor Core",
                .product(name: "Memory Heap", package: "swift-memory-heap"),
            ]
        ),

        .target(
            name: "Tensor",
            dependencies: [
                "Tensor Core",
                "Tensor Dynamic",
                "Tensor Named",
            ]
        ),

        .target(
            name: "Tensor Test Support",
            dependencies: [
                "Tensor",
                .product(
                    name: "Buffer Test Support",
                    package: "swift-buffer"
                ),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Tensor Tests",
            dependencies: [
                "Tensor",
                "Tensor Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
