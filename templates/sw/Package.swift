// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AocDay",
    products: [
        .executable(name: "AocDay", targets: ["AocDay"]),
    ],
    targets: [
        .executableTarget(name: "AocDay"),
        .testTarget(
            name: "AocDayTests",
            dependencies: ["AocDay"],
            resources: [.process("Fixtures")]
        ),
    ]
)
