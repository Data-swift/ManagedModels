//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

extension ClassDeclSyntax {
  
  var isPublicOrOpen : Bool { modifiers.containsPublicOrOpen }
  
  var publicOrOpenModifier : DeclModifierListSyntax.Element? {
    modifiers.publicOrOpenModifier
  }
}

extension ClassDeclSyntax {
  
  var inheritedTypeNames : Set<String> {
    // The protocol types in like (as a workaround for protocols below)
    //   `class Model: Codable, CustomStringConvertible`
    var inheritedTypeNames = Set<String>()
    if let inheritedTypes = inheritanceClause?.inheritedTypes {
      for type : InheritedTypeSyntax in inheritedTypes {
        let typeSyntax : TypeSyntax = type.type
        if let id = typeSyntax.as(IdentifierTypeSyntax.self) {
          inheritedTypeNames.insert(id.name.trimmed.text)
        }
      }
    }
    return inheritedTypeNames
  }
}

extension ClassDeclSyntax {

  func findFunctionWithName(_ name: String, isStaticOrClass: Bool,
                            parameterCount: Int? = nil,
                            numberOfParametersWithoutDefaults: Int? = nil)
       -> FunctionDeclSyntax?
  {
    for member : MemberBlockItemSyntax in memberBlock.members {
      guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
        continue
      }
      let hasStatic = funcDecl.modifiers.containsStaticOrClass
      guard hasStatic == isStaticOrClass else { continue }

      if let parameterCount {
        guard parameterCount == funcDecl.parameterCount else { continue }
      }
      if let numberOfParametersWithoutDefaults {
        guard numberOfParametersWithoutDefaults ==
                funcDecl.numberOfParametersWithoutDefaults else { continue }
      }

      // filter out operators and different names
      guard case .identifier(let idName) = funcDecl.name.tokenKind,
            idName == name else
      {
        continue
      }
      
      // Found it
      return funcDecl
    }
    return nil
  }
}
