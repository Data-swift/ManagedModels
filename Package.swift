// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "ManagedModels",
  
  // For now :-)
  // macOS v13 needed to build the macro on macOS 13! (for iOS)
  platforms: [ .macOS(.v11), .iOS(.v14), .tvOS(.v15), .watchOS(.v8) ],
  products: [
    .library(name: "ManagedModels", targets: [ "ManagedModels" ])
  ],
  dependencies: [
    // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
    .package(url: "https://github.com/apple/swift-syntax.git", 
             from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
  ],
  targets: [
    .target(name: "ManagedModels", dependencies: [ "ManagedModelMacros" ]),
  
    .macro(
      name: "ManagedModelMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    
    // A test target used to develop the macro implementation.
    .testTarget(
      name: "ManagedModelTests",
      dependencies: [ "ManagedModels" ]
    ),
    
    // A test target used to develop the macro implementation.
    .testTarget(
      name: "ManagedModelMacrosTests",
      dependencies: [
        "ManagedModelMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
