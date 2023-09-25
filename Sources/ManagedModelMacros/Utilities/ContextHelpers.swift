//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension MacroExpansionContext {
  
  // TBD: rather put this on the "error node"? (the macro)
  func diagnose<N: SyntaxProtocol>(_ message: MacroDiagnostic, on errorNode: N)
  {
    diagnose(Diagnostic(node: Syntax(errorNode), message: message))
  }
}
