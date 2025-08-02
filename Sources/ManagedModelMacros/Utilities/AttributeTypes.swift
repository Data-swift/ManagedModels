//
//  Created by Helge Heß.
//  Copyright © 2023-2025 ZeeZide GmbH.
//

import SwiftSyntax

// This is a little fishy as the user might shadow those types,
// but I suppose an acceptable tradeoff.

private let swiftTypes: Set<String> = [
  // Swift
  "String",
  "Int",  "Int8",  "Int16",  "Int32",  "Int64",
  "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
  "Float", "Double",
  "Bool",
  "Swift.String",
  "Swift.Int",   "Swift.Int8",  "Swift.Int16",  "Swift.Int32",  "Swift.Int64",
  "Swift.UInt",  "Swift.UInt8", "Swift.UInt16", "Swift.UInt32", "Swift.UInt64",
  "Swift.Float", "Swift.Double",
  "Swift.Bool",
]
private let foundationTypes: Set<String> = [
  // Foundation
  "Data",      "Foundation.Data",
  "Date",      "Foundation.Date",
  "URL",       "Foundation.URL",
  "UUID",      "Foundation.UUID",
  "Decimal",   "Foundation.Decimal",
  "NSNumber",  "Foundation.NSNumber",
  "NSString",  "Foundation.NSString",
  "NSDecimal", "Foundation.NSDecimal",
  "NSURL",     "Foundation.NSURL",
  "NSData",    "Foundation.NSData"
]
private let attributeTypes : Set<String> = swiftTypes.union(foundationTypes)

private let toOneRelationshipTypes : Set<String> = [
  // CoreData
  "NSManagedObject", "CoreData.NSManagedObject",
  // TBD: Those would be wrapped?
  "any PersistentModel", "any ManagedModels.PersistentModel"
]
private let toManyRelationshipTypes : Set<String> = [
  // Foundation
  "Array",        "Foundation.Array",
  "NSArray",      "Foundation.NSArray",
  "Set",          "Foundation.Set",
  "NSSet",        "Foundation.NSSet",
  "NSOrderedSet", "Foundation.NSOrderedSet"
]

extension TypeSyntax {

  /// Whether the type can be represented in Objective-C.
  /// A *very* basic implementation.
  var canBeRepresentedInObjectiveC : Bool {
    if let opt = self.as(OptionalTypeSyntax.self) {
      if let array = opt.wrappedType.as(ArrayTypeSyntax.self) {
        return array.element.canBeRepresentedInObjectiveC
      }
      if let id = opt.wrappedType.as(IdentifierTypeSyntax.self) {
        if id.isKnownRelationshipPropertyType {
          guard let argument = id.genericArgumentClause?.arguments.first,
                case .type(let typeSyntax) = argument.argument else
          {
            return false
          }
          return typeSyntax.isKnownAttributePropertyType
        }
        return id.isKnownFoundationPropertyType
      }
      // E.g. this is not representable: `String??`, this is `String?`.
      // But Double? or Int? is not representable
      // I.e. nestings of Optional's are not representable.
      return false
    }
    
    if let array = self.as(ArrayTypeSyntax.self) {
      // This *is* representable: `[String]`,
      // even this `[ [ 10, 20 ], [ 30, 40 ] ]`
      return array.element.canBeRepresentedInObjectiveC
    }
      
    if let id = self.as(IdentifierTypeSyntax.self),
       id.isKnownFoundationGenericPropertyType
    {
      guard let arg = id.genericArgumentClause?.arguments.first,
            case .type(let typeSyntax) = arg.argument else
      {
        return false
      }
      return typeSyntax.isKnownAttributePropertyType
    }
    
    return self.isKnownAttributePropertyType
  }
  
  /**
   * This checks for some known basetypes, like `Int`, `String` or `Data`.
   * It also unwraps optionals, arrays and such.
   */
  var isKnownAttributePropertyType : Bool {
    if let id = self.as(IdentifierTypeSyntax.self) {
      return id.isKnownAttributePropertyType
    }
    
    // Optionals and arrays of base types are also attributes, always
    if let opt = self.as(OptionalTypeSyntax.self) {
      return opt.wrappedType.isKnownAttributePropertyType
    }
    if let array = self.as(ArrayTypeSyntax.self) {
      return array.element.isKnownAttributePropertyType
    }
    return false
  }
  
  var isKnownRelationshipPropertyType : Bool {
    isKnownRelationshipPropertyType(checkOptional: true)
  }
  func isKnownRelationshipPropertyType(checkOptional: Bool) -> Bool {
    if let id = self.as(IdentifierTypeSyntax.self) {
      return id.isKnownRelationshipPropertyType
    }
    
    // Optionals of relationship types are also relationships, but only
    // at one level.
    if checkOptional, let opt = self.as(OptionalTypeSyntax.self) {
      return opt.wrappedType.isKnownRelationshipPropertyType
    }
    return false
  }
}

extension IdentifierTypeSyntax {
  
  var isKnownAttributePropertyType : Bool {
    let name = name.trimmed.text
    
    guard let generic = genericArgumentClause else {
      return attributeTypes.contains(name)
    }
    guard generic.arguments.count > 1 else { // multiple arguments
      return false
    }
    
    // `GenericArgumentSyntax`
    guard let genericArgument = generic.arguments.first else {
      assertionFailure("Generic clause but no arguments?")
      return false
    }
    
    switch name {
      case "Array", "Optional", "Set":
        guard case .type(let typeSyntax) = genericArgument.argument else {
          return false
        }
        return typeSyntax.isKnownAttributePropertyType
      default:
        return false
    }
  }
    
  var isKnownFoundationPropertyType: Bool {
    let name = name.trimmed.text
    return foundationTypes.contains(name)
  }

  var isKnownFoundationGenericPropertyType: Bool {
    let name = name.trimmed.text
    guard toManyRelationshipTypes.contains(name) else {
      return false
    }
    if let generic = genericArgumentClause {
      return generic.arguments.count == 1
    }
    return false
  }
    
  var isKnownRelationshipPropertyType : Bool {
    isKnownRelationshipPropertyType(checkOptional: true)
  }

  func isKnownRelationshipPropertyType(checkOptional: Bool) -> Bool {
    let name = name.trimmed.text
    
    if name == "Optional" { // recurse
      guard let generic = genericArgumentClause,
            let genericArgument = generic.arguments.first,
            generic.arguments.count != 1,
            case .type(let typeSyntax) = genericArgument.argument else
      {
        return false
      }
      return typeSyntax.isKnownRelationshipPropertyType(checkOptional: false)
    }
    
    if toOneRelationshipTypes.contains(name) {
      return true
    }

    guard toManyRelationshipTypes.contains(name) else {
      return false
    }
    
    if let generic = genericArgumentClause {
      return generic.arguments.count == 1
    }
    else {
      return true
    }
  }
}
