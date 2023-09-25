//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct ModelProperty {
  
  /**
   * Whether the property is an `NSAttributeDescription` or `Relationship`,
   * or whether it is unknown.
   */
  enum PropertyType {
    
    /// The property had no `@Relationship` or `@Attribute` marker macros.
    case plain
    
    /// The property was explicitly tagged as a `Relationship`.
    case relationship(AttributeSyntax)
    
    /// The property was explicitly tagged as an `Attribute`.
    case attribute   (AttributeSyntax)
  }
  
  let binding           : PatternBindingSyntax
  
  // Extracted information
  let type              : PropertyType
  let name              : String

  let declaredValueType : TypeSyntax?

  let isTransient       : Bool
  let initExpression    : ExprSyntax?
}

extension ModelProperty {
  
  /**
   * If the property type was not declared, attempt to derive the type from
   * expression.
   *
   * Example:
   * ```
   * var lastname = "Street"
   * ```
   * => type will be `String`, because it is a String literal initializer.
   */
  var valueType: TypeSyntax? {
    if let declaredValueType { return declaredValueType }
    
    guard let initExpression else { return nil }
    return initExpression.detectExpressionType()
  }
  
  var isKnownAttributePropertyType: Bool {
    switch type {
      case .attribute(_)    : return true
      case .relationship(_) : return false
      case .plain: return valueType?.isKnownAttributePropertyType ?? false
    }
  }
  var isKnownRelationshipPropertyType: Bool {
    switch type {
      case .attribute(_)    : return false
      case .relationship(_) : return true
      case .plain: return valueType?.isKnownRelationshipPropertyType ?? false
    }
  }
}

extension ModelProperty: CustomStringConvertible {
  
  var description: String {
    var ms = "<ModelProp[\(name)]:"
    ms += " \(type)"
    if isTransient { ms += " transient" }
    
    if let valueType      { ms += " type=\(valueType)" }
    if let initExpression { ms += " init=\(initExpression)" }
    ms += ">"
    return ms
  }
}

extension ModelProperty.PropertyType: CustomStringConvertible {
  
  var description: String {
    switch self {
      case .plain           : return "plain"
      case .attribute   (_) : return "Attribute"
      case .relationship(_) : return "Relationship"
    }
  }
}


// MARK: - Builder

extension ModelMacro {
  
  // errorNode is the @Model, which is where we want to attach diagnostics
  static func findModelProperties(in classDecl: ClassDeclSyntax,
                                  errorNode: AttributeSyntax,
                                  context: some MacroExpansionContext)
              -> [ ModelProperty ]
  {
    var properties = [ ModelProperty ]()
    
    for member : MemberBlockItemSyntax in classDecl.memberBlock.members {
      // Note: One "member block" can contain multiple variable declarations.
      // Like in: `let a = 5, b = 6`.
      addModelProperties(in: member.decl, to: &properties,
                         errorNode: errorNode, context: context)
    }

    return properties
  }

  /**
   * This creates a `ModelProperty` object/value for each property in the
   * given `VariableDeclSyntax`.
   *
   * A variable decl is something like this:
   * ```swift
   * @Relationship(inverse: \.blub)
   * var street, city, country : String
   * ```
   * Note that attributes (e.g. `@Relationship` is one) are attached to the
   * whole declaration, but the declaration can have multiple "bindings",
   * i.e. properties.
   *
   * It uses the `propertyType` function below to look for the attributes.
   */
  static func addModelProperties<T>(in member: T,
                                    to properties: inout [ ModelProperty ],
                                    errorNode node: AttributeSyntax,
                                    context: some MacroExpansionContext)
    where T: SyntaxProtocol
  {
    // Note: One "member block" can contain multiple variable declarations.
    // Like in: `let a = 5, b = 6`.
    guard let variables = member.as(VariableDeclSyntax.self) else {
      return
    }
    guard !variables.isStaticOrClass else { return }

    // Those apply to all variables in the declaration!
    let ( propertyType, isTransient ) = propertyType(
      for: variables.attributes, errorNode: node, context: context
    )
    
    // Each binding is a variable in a declaration list,
    // e.g. `let a = 5, b = 6`, the `a` and `b` would be bindings.
    for binding : PatternBindingSyntax in variables.bindings {
      guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else
      {
        continue
      }
      let name = pattern.identifier.trimmed.text
      
      properties.append(ModelProperty(
        binding: binding,
        type: propertyType,
        name: name,
        declaredValueType: binding.typeAnnotation?.type, // w/o the `:`
        isTransient: isTransient,
        initExpression: binding.initializer?.value // w/o the `=`
      ))
    }
  }
  
  private static func propertyType(
    for attributes: AttributeListSyntax,
    errorNode node: AttributeSyntax,
    context: some MacroExpansionContext
  ) -> ( propertyType : ModelProperty.PropertyType, isTransient: Bool )
  {
    // Those apply to all variables in the declaration!
    var propertyType = ModelProperty.PropertyType.plain
    var isTransient  = false
    
    for attribute : AttributeListSyntax.Element in attributes {
      switch attribute {
        case .ifConfigDecl(_):
          continue
          
        case .attribute(let attribute):
          guard let name = attribute
            .attributeName.as(IdentifierTypeSyntax.self)?
            .name.trimmed.text else
          {
            continue
          }
          switch name {
            case "Transient":
              assert(!isTransient, "Transient macro applied twice!")
              isTransient = true
              
            case "Attribute":
              switch propertyType {
                case .plain:
                  propertyType = .attribute(attribute)
                case .attribute(_):
                  context.diagnose(.multipleAttributeMacrosAppliedOnProperty,
                                   on: node)
                case .relationship(_):
                  context.diagnose(
                    .attributeAndRelationshipMacrosAppliedOnProperty,
                    on: node
                  )
              }
              
            case "Relationship":
              switch propertyType {
                case .plain:
                  propertyType = .relationship(attribute)
                case .relationship(_):
                  context.diagnose(
                    .multipleRelationshipMacrosAppliedOnProperty,
                    on: node
                  )
                case .attribute(_):
                  context.diagnose(
                    .attributeAndRelationshipMacrosAppliedOnProperty,
                    on: node
                  )
              }
              
            default:
              break
          }
          
      }
    }

    return ( propertyType, isTransient )
  }
}
