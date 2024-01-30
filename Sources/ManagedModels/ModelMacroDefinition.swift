//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

/**
 * Tag an `NSManagedObject` class property as an "Attribute"
 * (`NSAttributeDescription`, vs a `NSRelationshipDescription`).
 *
 * - Parameters:
 *   - options:      A set of attribute `Option`s, e.g. `.unique`, or none.
 *   - originalName: The peer to CoreData's `renamingIdentifier`.
 *   - hashModifier: The peer to CoreData's `versionHashModifier`.
 *   - defaultValue: The default value for the property.
 */
@available(swift 5.9)
@attached(peer)
public macro Attribute(
  _ options: CoreData.NSAttributeDescription.Option...,
  originalName: String? = nil,
  hashModifier: String? = nil,
  defaultValue: Any?    = nil
) = #externalMacro(module: "ManagedModelMacros", type: "AttributeMacro")


/**
 * Tag an `NSManagedObject` class property as a "Relationship"
 * (`NSRelationshipDescription` vs a `NSAttributeDescription`).
 *
 * - Parameters:
 *   - options:      A set of relationship `Option`s.
 *   - originalName: The peer to CoreData's `renamingIdentifier`.
 *   - hashModifier: The peer to CoreData's `versionHashModifier`.
 */
@available(swift 5.9)
@attached(peer)
public macro Relationship(
  _ options: CoreData.NSRelationshipDescription.Option...,
  deleteRule: CoreData.NSRelationshipDescription.DeleteRule = .nullify,
  minimumModelCount: Int? = 0, maximumModelCount: Int? = 0,
  originalName: String? = nil,
  inverse: AnyKeyPath? = nil,
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

/**
 * An internal helper macro. Don't use this.
 */
@available(swift 5.9)
@attached(accessor/*, names: named(init)*/)
public macro _PersistedProperty() =
  #externalMacro(module: "ManagedModelMacros", type: "PersistedPropertyMacro")


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
