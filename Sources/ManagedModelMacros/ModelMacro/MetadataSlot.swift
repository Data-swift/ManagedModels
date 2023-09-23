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
      return "ManagedModels.Schema.Attribute(name: \(literal: property.name), valueType: \(valueType).self)"
    }

    func attributeInfo(for property: ModelProperty,
                       attribute syntax: AttributeSyntax)
         -> ExprSyntax?
    {
      // Note: We still want empty prop objects, because they still tell the
      //       type of a property!
      let valueType = property.valueType ?? "Any"
      var fallback: ExprSyntax {
        "ManagedModels.Schema.Attribute(name: \(literal: property.name), valueType: \(valueType).self)"
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
      // TBD: put it in here, or not? Would also need to do it in fallback?
      labeledExpressions.append(.init(
        label: "defaultValue", expression: ExprSyntax("nil")
      ))

      return ExprSyntax(FunctionCallExprSyntax(callee: ExprSyntax("ManagedModels.Schema.Attribute")) {
        labeledExpressions
      })
    }
    
    func relationshipInfo(for property: ModelProperty,
                          attribute syntax: AttributeSyntax) -> ExprSyntax?
    {
      // Note: We still want empty prop objects, because they still tell the
      //       type of a property!
      let valueType = property.valueType ?? "Any"
      var fallback: ExprSyntax {
        "ManagedModels.Schema.Relationship(name: \(literal: property.name), valueType: \(valueType).self)"
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

      return ExprSyntax(FunctionCallExprSyntax(callee: ExprSyntax("ManagedModels.Schema.Relationship")) {
        labeledExpressions
      })
    }

    func metadata(for property: ModelProperty) -> ExprSyntax {
      let metaExpr : ExprSyntax? = switch property.type {
        case .plain: generateInfo(for: property)
        case .attribute   (let attribute): 
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
