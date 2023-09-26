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
  
  var parameterCount : Int { signature.parameterClause.parameters.count }
  
  var numberOfParametersWithoutDefaults : Int {
    signature.parameterClause.parameters.numberOfParametersWithoutDefaults
  }
}

extension FunctionDeclSyntax {
  
  var parameterCount : Int { signature.parameterClause.parameters.count }
  
  var numberOfParametersWithoutDefaults : Int {
    signature.parameterClause.parameters.numberOfParametersWithoutDefaults
  }
}

extension FunctionParameterListSyntax {
  
  var numberOfParametersWithoutDefaults : Int {
    var count = 0
    for parameter : FunctionParameterSyntax in self {
      guard parameter.defaultValue == nil else { continue }
      count += 1
    }
    return count
  }
}
