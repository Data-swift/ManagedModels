//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension ModelMacro: ExtensionMacro { // @attached(extension, conformances:..)

  /*
   @attached(extension, conformances: // the protocols we add automagically
     PersistentModel
   )
   */
  public static func expansion(
    of               macroNode : AttributeSyntax,
    attachedTo     declaration : some DeclGroupSyntax,    // the class
    providingExtensionsOf type : some TypeSyntaxProtocol, // the classtype
    conformingTo conformancesToAdd : [ TypeSyntax ],
    in                 context : some MacroExpansionContext
  ) throws -> [ ExtensionDeclSyntax ]
  {
    guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
      context.diagnose(.modelMacroCanOnlyBeAppliedOnNSManagedObjects,
                       on: macroNode)
      return [] // TBD: rather throw?
    }

    // The protocol types in like (as a workaround for protocols below)
    //   `class Model: Codable, CustomStringConvertible`
    let inheritedTypeNames = classDecl.inheritedTypeNames

    guard inheritedTypeNames.contains("NSManagedObject") ||
          inheritedTypeNames.contains("CoreData.NSManagedObject") else
    {
      context.diagnose(.modelMacroCanOnlyBeAppliedOnNSManagedObjects,
                       on: macroNode)
      return [] // TBD: rather throw?
    }

    // Already contains the protocol conformance.
    guard !inheritedTypeNames.contains("PersistentModel") &&
          !inheritedTypeNames.contains("ManagedModels.PersistentModel") else
    {
      return []
    }

    // Those are supposed to be the protocols that need to be processed.
    // If they are missing, they are supposed to be applied already?
    // But this doesn't always work, i.e. sometimes they are empty but still
    // missing! (e.g. in tests?)
    // So this is for the situation in which the protocols _are_ passed in,
    // we still need add in the empty scenario.
    if !conformancesToAdd.isEmpty { // this isn't always filled?
      var stillNeeded = false
      for conformance in conformancesToAdd {
        guard let id = conformance.as(IdentifierTypeSyntax.self) else {
          assertionFailure("Unexpected conformance? \(conformance)")
          continue
        }
        let name = id.name.trimmed.text
        if name == "PersistentModel" || 
           name == "ManagedModels.PersistentModel"
        {
          stillNeeded = true
        }
        else {
          assertionFailure("Unexpected conformance: \(name)")
        }
      }
      guard stillNeeded else { return [] }
    }
    return [
      try ExtensionDeclSyntax(
        "extension \(type): ManagedModels.PersistentModel"
      ) {}
    ]
  }
}
