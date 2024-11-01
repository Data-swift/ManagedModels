//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

extension ExprSyntax {
  
  func detectExpressionType() -> TypeSyntax? {
    guard let idType = detectExpressionTypeName() else { return nil }
    return TypeSyntax(IdentifierTypeSyntax(name: .identifier(idType)))
  }
  func detectExpressionTypeName() -> String? {
    // TODO: detect base types and such
    // - check function expressions, like:
    //   - `Data()`?
    //   - `Date()`, `Date.now`, etc
    
    switch kind {
      case .stringLiteralExpr  : return "Swift.String"
      case .integerLiteralExpr : return "Swift.Int"
      case .floatLiteralExpr   : return "Swift.Double"
      case .booleanLiteralExpr : return "Swift.Bool"
      default:
        break
    }
    
    return nil
  }
}
