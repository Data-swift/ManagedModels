//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(ManagedModelMacros)
@testable import ManagedModelMacros
#endif

// for inline parsing
import SwiftParser
import SwiftParserDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion

// Macro implementations build for the host, so the corresponding module is not
// available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end
// tests.

final class ModelMacroTests: XCTestCase {
  
  #if canImport(ManagedModelMacros)
  let macros : [ String: Macro.Type] = [
    "Model"              : ModelMacro            .self,
    "Attribute"          : AttributeMacro        .self,
    "Relationship"       : RelationshipMacro     .self,
    "Transient"          : TransientMacro        .self,
    "_PersistedProperty" : PersistedPropertyMacro.self
  ]
  #endif

  func testPersonAddressModels() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Person: NSManagedObject {
      var firstname : String
      var lastname  : String
      var addresses : [ Address ]
    }
    
    @Model
    final class Address /*test*/ : NSManagedObject {      
      var street     : String
      var appartment : String?
      var person     : Person
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)

    let explodedSource = explodedFile.description
    XCTAssertTrue (explodedSource.contains(
      "extension Person: ManagedModels.PersistentModel"))
    XCTAssertFalse(explodedSource.contains("static let x = 10"))
    XCTAssertFalse(explodedSource.contains("convenience"))
    XCTAssertFalse(explodedSource.contains("@NSManaged"))
    XCTAssertTrue (explodedSource.contains("static let schemaMetadata"))
    XCTAssertTrue (explodedSource.contains(
      """
      metadata: CoreData.NSAttributeDescription(name: "firstname", valueType: String.self))
      """
    ))
    XCTAssertFalse(explodedSource.contains(
      """
      metadata: CoreData.NSAttributeDescription(.external, originalName: "First", name: "firstname", valueType: Swift.String.self, defaultValue: nil))
      """
    ))
    
    #if false
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  func testPersonModelWithExtras() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    enum MySchema {
      @Model
      final class Person: NSManagedObject {
      
        static let x = 10
        static var y = 20
        
        @Attribute(.external, originalName: "First")
        var firstname = "Jason"
        var lastname  : String
        var addresses : [ Address ] = []
      
        @Transient var transient = false
        
        init(firstname: String, lastname: String, addresses: [ Address ]) {
          self.firstname = firstname
          self.lastname  = lastname
          self.addresses = addresses
        }
      }
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)

    let explodedSource = explodedFile.description
    XCTAssertTrue(explodedSource.contains(
      "extension Person: ManagedModels.PersistentModel"))
    XCTAssertTrue (explodedSource.contains("static let x = 10"))
    XCTAssertFalse(explodedSource.contains("@NSManaged"))
    XCTAssertTrue (explodedSource.contains("static let schemaMetadata"))
    XCTAssertTrue (explodedSource.contains(
      """
      metadata: CoreData.NSAttributeDescription(.external, originalName: "First", name: "firstname", valueType: Swift.String.self))
      """
    ))
    
    #if false
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }
  
  func testOwnInit() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Person: NSManagedObject {
      var firstname : String
      var lastname  : String
      var addresses : [ Address ]
    
      init(firstname x: String = "", _ lastname: String = "", addresses: [ Address ] = []) {
        self.init()
        self.firstname = x
        self.lastname  = lastname
        self.addresses = addresses
      }
      convenience init(fullname: String) {
        self.init() // do something
      }
      deinit {}
      func regularFunction() {}
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)
    if !diags.isEmpty {
      print("DIAGS:", diags)
    }

    let explodedSource = explodedFile.description
    XCTAssertFalse(explodedSource.contains("init() {"))
    XCTAssertFalse(explodedSource.contains("convenience init(context:"))
    XCTAssertTrue (explodedSource.contains(
      """
      init(context: CoreData.NSManagedObjectContext?)
      """
    ))
    XCTAssertTrue(explodedSource.contains(
      """
      override init(entity: CoreData.NSEntityDescription,
      """
    ))

    #if false
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  
  func testNoInit() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Person: NSManagedObject {
      var firstname : String
      var lastname  : String
      var addresses : [ Address ]
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)
    if !diags.isEmpty {
      print("DIAGS:", diags)
    }

    let explodedSource = explodedFile.description
    XCTAssertTrue (explodedSource.contains("init() {"))
    XCTAssertFalse(explodedSource.contains("convenience init(context:"))
    XCTAssertTrue (explodedSource.contains(
      """
      init(context: CoreData.NSManagedObjectContext?)
      """
    ))
    XCTAssertTrue(explodedSource.contains(
      """
      override init(entity: CoreData.NSEntityDescription,
      """
    ))

    #if false
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  func testComputedProperty() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Person: NSManagedObject {
      var firstname : String
      var lastname  : String
      var fullname  : String { firstname + " " + lastname }
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)
    if !diags.isEmpty {
      print("DIAGS:", diags)
    }

    let explodedSource = explodedFile.description
    XCTAssertTrue (explodedSource.contains("init() {"))
    XCTAssertFalse(explodedSource.contains("convenience init(context:"))
    XCTAssertTrue (explodedSource.contains(
      """
      var firstname : String
      """
    ))
    XCTAssertFalse(explodedSource.contains(
      """
      @NSManaged
        var fullname  : String { firstname + " " + lastname }
      """
    ))
    XCTAssertTrue (explodedSource.contains(
      """
      var fullname  : String { firstname + " " + lastname }
      """
    ))

    #if true
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  func testForceUnwrapType() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Address: NSManagedObject {
      @Relationship(originalName: "ProductID")
      var person: Person!
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)
    if !diags.isEmpty {
      print("DIAGS:", diags)
    }

    let explodedSource = explodedFile.description
    XCTAssertTrue (explodedSource.contains(
      "name: \"person\", valueType: Person?.self"
    ))
    XCTAssertFalse(explodedSource.contains(
      "name: \"person\", valueType: Person!.self"
    ))

    #if false
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  func testCommentInType() throws {
    #if !canImport(ManagedModelMacros)
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #else
    let explodedFile = parseAndExplode(
    """
    @Model
    final class Address: NSManagedObject {
      @Attribute(.unique, originalName: "CustomerTypeID")
      public var typeID: String  // pkey in original
    }
    """
    )
    
    // Hm, this doesn't seem to work?
    let diags = ParseDiagnosticsGenerator.diagnostics(for: explodedFile)
    XCTAssertTrue(diags.isEmpty)
    if !diags.isEmpty {
      print("DIAGS:", diags)
    }

    let explodedSource = explodedFile.description
    XCTAssertTrue (explodedSource.contains(
      """
      originalName: "CustomerTypeID", name: "typeID", valueType: String
      """
    ))
    XCTAssertFalse(explodedSource.contains(
      """
      originalName: "CustomerTypeID", name: "typeID", valueType: String  // pkey in original.self
      """
    ))

    #if true
    print("Exploded:---\n")
    print(explodedSource)
    print("\n-----")
    #endif
    #endif // canImport(ManagedModelMacros)
  }

  
  // MARK: - Helper
  
  func parseAndExplode(_ source: String) -> Syntax {
    // Parse the original source file.
    let sourceFile : SourceFileSyntax = Parser.parse(source: source)

    // Expand all macros in the source.
    let context = BasicMacroExpansionContext(
      sourceFiles: [
        sourceFile: .init(
          moduleName: "TestModule",
          fullFilePath: "TestModule.swift"
        )
      ]
    )

    let explodedFile : Syntax = sourceFile.expand(
      macros: macros,
      in: context,
      indentationWidth: .spaces(2) // what else!
    )

    return explodedFile
  }
}
