// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

#if swift(>=5.10)
let settings = [ SwiftSetting.enableExperimentalFeature("StrictConcurrency") ]
#else
let settings = [ SwiftSetting ]()
#endif

let package = Package(
  name: "ManagedModels",
  
  platforms: [ .macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6) ],
  products: [
    .library(name: "ManagedModels", targets: [ "ManagedModels" ])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
  ],
  targets: [
    .target(
      name: "ManagedModels",
      dependencies: [ "ManagedModelMacros" ],
      swiftSettings: settings
    ),

    .macro(
      name: "ManagedModelMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    
    .testTarget(
      name: "ManagedModelTests",
      dependencies: [ "ManagedModels" ]
    ),
    
    .testTarget(
      name: "ManagedModelMacrosTests",
      dependencies: [
        "ManagedModelMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
