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
}

extension DeclModifierListSyntax {
  
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
