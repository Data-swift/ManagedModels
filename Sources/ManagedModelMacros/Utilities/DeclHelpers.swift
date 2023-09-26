//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

extension VariableDeclSyntax {
  
  var isStaticOrClass : Bool { modifiers.containsStaticOrClass }
  var isPublicOrOpen  : Bool { modifiers.containsPublicOrOpen  }
}

extension InitializerDeclSyntax {

  var isConvenience : Bool {
    modifiers.contains { $0.name.tokenKind == .keyword(.convenience) }
  }
}

extension FunctionDeclSyntax {
  
  var parameterCount : Int { signature.parameterClause.parameters.count }
}
