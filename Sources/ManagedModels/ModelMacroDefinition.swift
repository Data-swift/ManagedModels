//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

/**
 * Tag an `NSManagedObject` class property as a ``Schema/Attribute``
 * (vs a ``Schema/Relationship``).
 *
 * - Parameters:
 *   - options:      A set of ``Schema/Attribute/Option``s,
 *                   e.g. ``Schema/Attribute/Option/unique``, or none.
 *   - originalName: The peer to CoreData's `renamingIdentifier`.
 *   - hashModifier: The peer to CoreData's `versionHashModifier`.
 */
@available(swift 5.9)
@attached(peer)
public macro Attribute(
  _ options: NSAttributeDescription.Option...,
  originalName: String? = nil,
  hashModifier: String? = nil
) = #externalMacro(module: "ManagedModelMacros", type: "AttributeMacro")


/**
 * Tag an `NSManagedObject` class property as a ``Schema/Relationship``
 * (vs a ``Schema/Attribute``).
 *
 * - Parameters:
 *   - options:      A set of ``Schema/Relationship/Option``s.
 *   - originalName: The peer to CoreData's `renamingIdentifier`.
 *   - hashModifier: The peer to CoreData's `versionHashModifier`.
 */
@available(swift 5.9)
@attached(peer)
public macro Relationship(
  _ options: NSRelationshipDescription.Option...,
  originalName: String? = nil,
  hashModifier: String? = nil
) = #externalMacro(module: "ManagedModelMacros", type: "RelationshipMacro")


/**
 * Tag an `NSManagedObject` class property as "transient".
 *
 * Transient properties are ignored for any persistence or other
 * `NSManagedObject` operations (it does *not* map to non-stored CoreData
 * properties!).
 * They just live as regular instance variables in the class.
 */
@available(swift 5.9)
@attached(peer)
public macro Transient() =
  #externalMacro(module: "ManagedModelMacros", type: "TransientMacro")


// MARK: - Model Macro

// TBD: This needs an API `originalName` for migrations?
/**
 * Tags a class as a ``PersistentModel``, i.e. an `NSManagedObject` that will
 * have an `NSEntityDescriptor` that is generated from the Swift code.
 *
 * This generates all the necessary helper structures to allow the class being
 * used in CoreData.
 */
@available(swift 5.9)
@attached(member, names: // Those are the names we add
  named(init),           // Initializers.
  named(schemaMetadata), // The metadata.
  named(entity),         // Override the `entity()` function.
  named(_$entity),       // The cached the Entity
  named(_$originalName),
  named(_$hashModifier)
)
@attached(memberAttribute) // attaches attributes (@NSManaged) to members
@attached(extension, conformances: // the protocols we add automagically
  PersistentModel
)
public macro Model(
  originalName: String? = nil,
  hashModifier: String? = nil
) = #externalMacro(module: "ManagedModelMacros", type: "ModelMacro")
