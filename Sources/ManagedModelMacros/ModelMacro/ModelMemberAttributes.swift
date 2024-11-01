//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/**
 * Attaches attributes, `@_PersistedProperty`, to members.
 *
 * This is attached to tracked properties:
 * - `@_PersistedProperty`
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

    // This is an array because the `member` declaration can contain multiple
    // bindings, e.g.: `var street, city, country : String`.
    // Those are NOT all the properties of the `declaration` (e.g. the class).
    var properties = [ ModelProperty ]()
    addModelProperties(in: member, to: &properties,
                       context: context)

    guard let property = properties.first else { return [] } // other member
    
    if properties.count > 1 {
      context.diagnose(.multipleMembersInAttributesMacroCall, on: macroNode)
      return []
    }
    
    guard !property.isTransient else { return [] }
    
    /*
     // property.declaredValueType is nil, but we detect some
     var firstname = "Jason"
     // property.declaredValueType is set
     var lastname  : String
     */
    let addAtObjC = property.isKnownRelationshipPropertyType
                 || (property.valueType?.canBeRepresentedInObjectiveC ?? false)

    // We'd like @objc, but we don't know which ones to attach it to?
    // https://github.com/Data-swift/ManagedModels/issues/36
    return addAtObjC
         ? [ "@_PersistedProperty", "@objc" ]
         : [ "@_PersistedProperty" ]
  }
}
