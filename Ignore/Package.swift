// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "Ignore",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "Ignore", targets: ["Ignore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/qvacua/misc.swift", exact: "0.2.0"),
    .package(url: "https://github.com/Quick/Nimble", from: "13.0.0"),
  ],
  targets: [
    .target(name: "Ignore", dependencies: [.product(name: "WildmatchC", package: "misc.swift")]),
    .testTarget(
      name: "IgnoreTests",
      dependencies: ["Ignore", "Nimble"],
      resources: [.copy("Resources")]
    ),
  ]
)
