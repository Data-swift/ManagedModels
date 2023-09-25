//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

extension VariableDeclSyntax {
  
  var isStaticOrClass : Bool {
    modifiers.contains {
      switch $0.name.tokenKind {
        case .keyword(.static) : return true
        case .keyword(.class)  : return true
        default: return false
      }
    }
  }
  
  var isPublicOrOpen : Bool { modifiers.containsPublicOrOpen }
}

extension InitializerDeclSyntax {
  var isConvenience : Bool { modifiers.convenienceModifier != nil }
}

extension FunctionDeclSyntax {
  
  var parameterCount : Int {
    signature.parameterClause.parameters.count
  }
}

extension ClassDeclSyntax {
  
  var isPublicOrOpen : Bool { modifiers.containsPublicOrOpen }
  var publicOrOpenModifier : DeclModifierListSyntax.Element? {
    modifiers.publicOrOpenModifier
  }
  
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
  
  func findFunctionWithName(_ name: String, isStatic: Bool)
       -> FunctionDeclSyntax?
  {
    for member : MemberBlockItemSyntax in memberBlock.members {
      guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
        continue
      }
      let hasStatic = funcDecl.modifiers.contains(.static)
      guard hasStatic == isStatic else { continue }

      switch funcDecl.name.tokenKind {
        case .identifier(_):
          return funcDecl
        default: // operator
          return nil
      }
    }
    return nil
  }
}

extension DeclModifierListSyntax {
  
  var modifiers : Set<Keyword> {
    var modifiers = Set<Keyword>()
    for modifier in self {
      guard case .keyword(let keyword) = modifier.name.tokenKind else {
        continue
      }
      modifiers.insert(keyword)
    }
    return modifiers
  }
  
  func contains(_ keyword: Keyword) -> Bool {
    for modifier in self {
      guard case .keyword(let keywordMember) = modifier.name.tokenKind else {
        continue
      }
      if keyword == keywordMember { return true }
    }
    return false
  }
  
  var publicOrOpenModifier : Element? {
    self.first {
      switch $0.name.tokenKind {
        case .keyword(.public) : return true
        case .keyword(.open)   : return true
        default: return false
      }
    }
  }

  var convenienceModifier : Element? {
    self.first { $0.name.tokenKind == .keyword(.convenience) }
  }

  var containsPublicOrOpen : Bool { publicOrOpenModifier != nil }
}
