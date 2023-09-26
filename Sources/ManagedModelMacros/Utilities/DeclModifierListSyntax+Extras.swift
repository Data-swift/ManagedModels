//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

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
    
  var containsPublicOrOpen : Bool { publicOrOpenModifier != nil }
  
  var containsStaticOrClass : Bool {
    contains {
      switch $0.name.tokenKind {
        case .keyword(.static) : return true
        case .keyword(.class)  : return true
        default: return false
      }
    }
  }
}
