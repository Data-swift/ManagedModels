//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AttributeMacro: PeerMacro { // @attached(peer) macro
  
  public static func expansion(
    of                 macroNode : AttributeSyntax,
    providingPeersOf declaration : some DeclSyntaxProtocol,
    in                   context : some MacroExpansionContext
  ) throws -> [ DeclSyntax ]
  {
    [] // Annotation macro, doesn't generate anything
  }
}
