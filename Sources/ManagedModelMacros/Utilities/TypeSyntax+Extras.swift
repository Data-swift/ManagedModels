//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax

extension TypeSyntax {
  
  /**
   * Rewrite `Product!` to `Product?`, since the former is not allowed in
   * type references, like `Product!.self` (is forbidden).
   */
  func replacingImplicitlyUnwrappedOptionalTypes() -> TypeSyntax {
    guard let force = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) else {
      return self
    }
    let regularOptional = OptionalTypeSyntax(wrappedType: force.wrappedType)
    return TypeSyntax(regularOptional)
  }
}
