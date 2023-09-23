//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/**
 * ```swift
 * @attached(member, names: // Those are the names we add
 *   named(init),           // Initializers
 *   named(schemaMetadata), // the metadata
 *   named(_$entity)        // API diff, we also cache the Entity
 * )
 * ```
 */
extension ModelMacro: MemberMacro { // @attached(member, names:...)
  
  public static func expansion(
    of                   macroNode : AttributeSyntax,
    providingMembersOf declaration : some DeclGroupSyntax,
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
    
    let metadata = generateMetadataSlot(
      access: access,
      modelClassName: modelClassName,
      properties: properties
    )

    let newInitializers = generateInitializers(
      for: classDecl,
      access: access, modelClassName: modelClassName,
      properties: properties,
      initializers: findInitializers(in: classDecl)
    )
    
    let entityFunction : DeclSyntax =
      """
      /// Returns the `NSEntityDescription` associated w/ the `PersistentModel`.
      \(raw: access)override class func entity() -> NSEntityDescription { _$entity }
      """

    // TODO: Lookup `originalName` parameter in `macroNode`
    let originalName : DeclSyntax =
      """
      \(raw: access)static let _$originalName : String? = nil
      """
    let hashModifier : DeclSyntax =
      """
      \(raw: access)static let _$hashModifier : String? = nil
      """

    let entity : DeclSyntax =
      """
      /// The shared `NSEntityDescription` for the `PersistentModel`.
      /// Never modify the referred object!
      \(raw: access)static let _$entity =
        ManagedModels.SchemaBuilder.shared._entity(for: \(modelClassName).self)
      """
    
    return newInitializers + [
      DeclSyntax(metadata),
      entity,
      entityFunction,
      originalName, hashModifier
    ]
  }
}
