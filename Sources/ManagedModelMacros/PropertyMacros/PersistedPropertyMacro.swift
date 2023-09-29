import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// @attached(accessor) macro
public struct PersistedPropertyMacro: AccessorMacro {
  
  public static func expansion(
    of                     macroNode : AttributeSyntax,
    providingAccessorsOf declaration : some DeclSyntaxProtocol,
    in                       context : some MacroExpansionContext
  ) throws -> [ AccessorDeclSyntax ]
  {
    assert(declaration.parent == nil, "We do have access to the parent?!")

    var properties = [ ModelProperty ]()
    ModelMacro
      .addModelProperties(in: declaration, to: &properties, context: context)
    guard let property = properties.first else { return [] }
    if properties.count > 1 {
      context.diagnose(.multipleMembersInAttributesMacroCall, on: macroNode)
      return []
    }
    
    return property.isTransformable
    ? [ "set { setTransformableValue(forKey: \(literal: property.name), to: newValue) }",
        "get { getTransformableValue(forKey: \(literal: property.name)) }" ]
    : [ "set { setValue(forKey: \(literal: property.name), to: newValue) }",
        "get { getValue(forKey: \(literal: property.name)) }" ]
  }
}
