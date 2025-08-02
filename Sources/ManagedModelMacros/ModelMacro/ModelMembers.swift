//
//  Created by Helge Heß.
//  Copyright © 2023-2025 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/**
 * ```swift
 * @attached(member, names: // Those are the names we add
 *   named(init),           // Initializers.
 *   named(schemaMetadata), // The metadata.
 *   named(_$originalName),
 *   named(_$hashModifier)
 * )
 * ```
 */
extension ModelMacro: MemberMacro { // @attached(member, names:...)
  
  public static func expansion(
    of                   macroNode : AttributeSyntax,
    providingMembersOf declaration : some DeclGroupSyntax,
    conformingTo         protocols : [ TypeSyntax ],
    in                     context : some MacroExpansionContext
  ) throws -> [ DeclSyntax ]
  {
    guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
      context.diagnose(.modelMacroCanOnlyBeAppliedOnNSManagedObjects,
                       on: macroNode)
      return [] // TBD: rather throw?
    }

    let modelClassName = classDecl.name.trimmed
    
    let properties = findModelProperties(in: classDecl,
                                         errorNode: macroNode, context: context)
    let access = classDecl.isPublicOrOpen ? "public " : ""
    
    var newMembers = generateInitializers(
      for: classDecl,
      access: access, modelClassName: modelClassName,
      properties: properties,
      initializers: findInitializers(in: classDecl)
    )

    let metadata = generateMetadataSlot(
      access: access,
      modelClassName: modelClassName,
      properties: properties
    )
    newMembers.append(DeclSyntax(metadata))

    // TODO: Lookup `originalName` parameter in `macroNode`
    newMembers.append(
      """
      \(raw: access)static let _$originalName : String? = nil
      """
    )
    newMembers.append(
      """
      \(raw: access)static let _$hashModifier : String? = nil
      """
    )
    
    return newMembers
  }
}
