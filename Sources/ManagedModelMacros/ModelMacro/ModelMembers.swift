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
 *   named(init),           // Initializers.
 *   named(schemaMetadata), // The metadata.
 *   named(entity),         // Override the `entity()` function.
 *   named(fetchRequest),   // The fetchRequest factory
 *   named(_$entity),       // The cached the Entity
 *   named(_$originalName),
 *   named(_$hashModifier)
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
    
    var newMembers = generateInitializers(
      for: classDecl,
      access: access, modelClassName: modelClassName,
      properties: properties,
      initializers: findInitializers(in: classDecl)
    )

    let needsFR : Bool = {
      guard let f = classDecl
        .findFunctionWithName("fetchRequest", isStatic: true) else
      {
        return true
      }
      return f.parameterCount != 0
    }()
    if needsFR {
      let modelClassName = modelClassName.text
      newMembers.append(
        """
        /// Returns an `NSFetchRequest` setup for the `\(raw: modelClassName)`.
        @nonobjc \(raw: access)class func fetchRequest() -> CoreData.NSFetchRequest<\(raw: modelClassName)> {
            let fetchRequest = CoreData.NSFetchRequest<\(raw: modelClassName)>(entityName: "\(raw: modelClassName)")
            fetchRequest.entity = Self._$entity
            return fetchRequest
        }
        """
      )
    }
    
    let metadata = generateMetadataSlot(
      access: access,
      modelClassName: modelClassName,
      properties: properties
    )
    newMembers.append(DeclSyntax(metadata))

    let needsEntity : Bool = {
      guard let f = classDecl.findFunctionWithName("entity", isStatic: true) else {
        return true
      }
      return f.parameterCount != 0
    }()
    if needsEntity {
      newMembers.append(
        """
        /// Returns the `NSEntityDescription` associated w/ the `PersistentModel`.
        \(raw: access)override class func entity() -> NSEntityDescription { _$entity }
        """
      )
    }
    
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

    newMembers.append(
      """
      /// The shared `NSEntityDescription` for the `PersistentModel`.
      /// Never modify the referred object!
      \(raw: access)static let _$entity =
        ManagedModels.SchemaBuilder.shared._entity(for: \(modelClassName).self)
      """
    )
    
    return newMembers
  }
}
