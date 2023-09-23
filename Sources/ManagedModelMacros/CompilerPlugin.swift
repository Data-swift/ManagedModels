//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ModelsPlugin: CompilerPlugin {
  let providingMacros: [ Macro.Type ] = [
    TransientMacro.self,
    AttributeMacro.self,
    RelationshipMacro.self,
    ModelMacro.self
  ]
}
