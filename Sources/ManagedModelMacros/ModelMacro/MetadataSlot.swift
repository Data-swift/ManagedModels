//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension ModelMacro {
  
  static func generateMetadataSlot(
    access         : String,
    modelClassName : TokenSyntax,
    properties     : [ ModelProperty ]
  ) -> DeclSyntax
  {
    func generateInfo(for property: ModelProperty) -> ExprSyntax? {
      guard let valueType = property.valueType     else { return nil }
      guard valueType.isKnownAttributePropertyType else { return nil }
      return "CoreData.NSAttributeDescription(name: \(literal: property.name), valueType: \(valueType).self)"
    }

    func attributeInfo(for property: ModelProperty,
                       attribute syntax: AttributeSyntax)
         -> ExprSyntax?
    {
      // Note: We still want empty prop objects, because they still tell the
      //       type of a property!
      let valueType : TypeSyntax = property.valueType?
        .replacingImplicitlyUnwrappedOptionalTypes() ?? "Any"
      var fallback: ExprSyntax {
        "CoreData.NSAttributeDescription(name: \(literal: property.name), valueType: \(valueType).self)"
      }
      guard let arguments = syntax.arguments else { return fallback }
      guard case .argumentList(var labeledExpressions) = arguments else {
        return fallback
      }
      
      // Enrich w/ more data
      labeledExpressions.append(.init(
        label: "name", expression: ExprSyntax("\(literal: property.name)")
      ))
      labeledExpressions.append(.init(
        label: "valueType", expression: ExprSyntax("\(valueType).self")
      ))

      return ExprSyntax(FunctionCallExprSyntax(callee: ExprSyntax("CoreData.NSAttributeDescription")) {
        labeledExpressions
      })
    }
    
    func relationshipInfo(for property: ModelProperty,
                          attribute syntax: AttributeSyntax) -> ExprSyntax?
    {
      // Note: We still want empty prop objects, because they still tell the
      //       type of a property!
      let valueType : TypeSyntax = property.valueType?
        .replacingImplicitlyUnwrappedOptionalTypes() ?? "Any"
      var fallback: ExprSyntax {
        "CoreData.NSRelationshipDescription(name: \(literal: property.name), valueType: \(valueType).self)"
      }
      guard let arguments = syntax.arguments else { return fallback }
      guard case .argumentList(var labeledExpressions) = arguments else {
        return fallback
      }
      
      // Enrich w/ more data
      labeledExpressions.append(.init(
        label: "name", expression: ExprSyntax("\(literal: property.name)")
      ))
      labeledExpressions.append(.init(
        label: "valueType", expression: ExprSyntax("\(valueType).self")
      ))

      return ExprSyntax(FunctionCallExprSyntax(callee: ExprSyntax("CoreData.NSRelationshipDescription")) {
        labeledExpressions
      })
    }

    func metadata(for property: ModelProperty) -> ExprSyntax {
      let metaExpr : ExprSyntax? = switch property.type {
        case .plain: generateInfo(for: property)
        case .attribute   (let attribute, isTransformable: _):
          attributeInfo   (for: property, attribute: attribute)
        case .relationship(let attribute):
          relationshipInfo(for: property, attribute: attribute)
      }
      
      let initExpr = property.initExpression ?? "nil"
      return """
      
      .init(name: \(literal: property.name), keypath: \\\(raw: modelClassName.trimmed).\(raw: property.name),
            defaultValue: \(initExpr),
            metadata: \(metaExpr ?? "nil"))
      """
    }
    
    let fields = ArrayExprSyntax(expressions: properties
      .filter({ !$0.isTransient})
      .map(metadata(for:))
    )
    return
      """
      \(raw: access)static let schemaMetadata : [ CoreData.NSManagedObjectModel.PropertyMetadata ] = \(fields)
      """
  }
}
