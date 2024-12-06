// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Assemblages",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Assemblages",
            targets: ["Assemblages"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Assemblages"),
        .testTarget(
            name: "AssemblagesTests",
            dependencies: ["Assemblages"]),
    ]
)


/// To do:
///  - make the regular sorted use an index sorted internally
///  - make `inserting` and `removing` based on `insert` and `remove`
///  - update the tests to reuse logic:
///     - array/set tests
///     - array readable/mutable tests
///  - make reference sorted key set.

