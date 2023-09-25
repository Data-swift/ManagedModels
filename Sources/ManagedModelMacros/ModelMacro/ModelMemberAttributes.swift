//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/**
 * Attaches attributes (`@NSManaged` etc) to members.
 *
 * This is attached to tracked properties:
 * - `@NSManaged`
 */
extension ModelMacro: MemberAttributeMacro { // @attached(memberAttribute)
  
  public static func expansion(
    of                   macroNode : AttributeSyntax,
    attachedTo         declaration : some DeclGroupSyntax,
    providingAttributesFor  member : some DeclSyntaxProtocol,
    in                     context : some MacroExpansionContext
  ) throws -> [ AttributeSyntax ]
  {
    guard declaration.is(ClassDeclSyntax.self) else {
      context.diagnose(.modelMacroCanOnlyBeAppliedOnNSManagedObjects,
                       on: macroNode)
      return [] // TBD: rather throw?
    }

    var properties = [ ModelProperty ]()
    addModelProperties(in: member, to: &properties, context: context)

    guard let property = properties.first else { return [] } // other member
    
    if properties.count > 1 {
      context.diagnose(.multipleMembersInAttributesMacroCall, on: macroNode)
      return []
    }
    
    guard !property.isTransient else { return [] }

    return [ "@NSManaged" ]
  }
}
