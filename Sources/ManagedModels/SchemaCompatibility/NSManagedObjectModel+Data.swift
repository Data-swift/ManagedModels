//
//  Created by Helge Heß.
//  Copyright © 2023-2024 ZeeZide GmbH.
//

import CoreData

public extension NSManagedObjectModel {
  // TBD:
  // - schemaEncodingVersion
  // - encodingVersion
  // - version
  
  @inlinable
  convenience init(_ entities: NSEntityDescription...,
                   version: Schema.Version = Version(1, 0, 0))
  {
    self.init()
    self.entities = entities
  }
  
  convenience init(_ types: [ any PersistentModel.Type ],
                   version: Schema.Version = Version(1, 0, 0))
  {
    self.init()
    self.entities = SchemaBuilder().lookupAllEntities(for: types)
  }
  
  @inlinable
  convenience init(versionedSchema: any VersionedSchema.Type) {
    self.init(versionedSchema.models,
              version: versionedSchema.versionIdentifier)
  }
}


// MARK: - Cached ManagedObjectModels

private let lock = NSLock() // TODO: Use new UnfairLock if available
#if swift(>=5.10)
nonisolated(unsafe) 
private var map = [ Set<ObjectIdentifier> : NSManagedObjectModel ]()
nonisolated(unsafe) private let sharedBuilder = SchemaBuilder()
#else // 5.9: nonisolated(unsafe) not available, nonisolated nor working on var
private var map = [ Set<ObjectIdentifier> : NSManagedObjectModel ]()
nonisolated private let sharedBuilder = SchemaBuilder()
#endif

public extension NSManagedObjectModel {
  
  /**
   * This caches a model for the types in the given `VersionedSchema`.
   * I.e. it will return the same `NSManagedObjectModel` when given the same
   * types.
   *
   * - Parameters:
   *   - versionedSchema: The versioned schema to derive the model from.
   * - Returns:           A `NSManagedObjectModel` representing the schema.
   */
  @inlinable
  static func model(for versionedSchema: VersionedSchema.Type)
              -> NSManagedObjectModel
  {
    model(for: versionedSchema.models)
  }

  /**
   * This caches a model for the types passed in.
   * I.e. it will return the same `NSManagedObjectModel` when given the same
   * types.
   *
   * - Parameters:
   *   - types: A set of `PersistentModel` types, e.g. `[Person.self]`.
   * - Returns: A `NSManagedObjectModel` representing the types.
   */
  static func model(for types: [ any PersistentModel.Type ])
              -> NSManagedObjectModel
  {
    // The idea here is that CD is sensitive w/ creating multiple models for the
    // same entities/classes. May be true or not, but prefer this when possible.
    // The entities are cached anyways in the shared generator object.
    var typeIDs = Set<ObjectIdentifier>()
    func addID<M: PersistentModel>(_ type: M.Type) {
      typeIDs.insert(ObjectIdentifier(M.self))
    }
    for anyType in types {
      addID(anyType)
    }
    
    lock.lock()
    let cachedMOM = map[typeIDs]
    let mom : NSManagedObjectModel
    if let cachedMOM { mom = cachedMOM }
    else {
      mom = NSManagedObjectModel()
      mom.entities = sharedBuilder.lookupAllEntities(for: types)
      map[typeIDs] = mom
    }
    lock.unlock()
    return mom
  }
}


// MARK: - Test Helpers

internal extension NSManagedObjectModel {
  
  /// Initializer for testing purposes.
  convenience init(_ types: [ any PersistentModel.Type ],
                   version: Schema.Version = Version(1, 0, 0),
                   schemaCache: SchemaBuilder)
  {
    self.init()
    self.entities = schemaCache.lookupAllEntities(for: types)
  }
  
  /// Initializer for testing purposes.
  convenience init(versionedSchema: any VersionedSchema.Type,
                   schemaCache: SchemaBuilder)
  {
    self.init(versionedSchema.models,
              version: versionedSchema.versionIdentifier,
              schemaCache: schemaCache)
  }
}
