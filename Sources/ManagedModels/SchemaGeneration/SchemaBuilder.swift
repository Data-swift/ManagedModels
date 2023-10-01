//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import CoreData

/**
 * A shared, thread-safe registry of `NSEntityDescription`'s for the
 * `NSManagedObject` types.
 *
 *
 * ### Registering a declared ManagedObjectModel
 *
 * Always create some `ModelContainer` for a schema before using it (i.e. pass
 * all known model types to something _once_, so that it can register them with
 * this `SchemaBuilder`).
 * Like in SwiftData.
 *
 * Example:
 * ```swift
 * MyView()
 *   .modelContainer(for: [ Contact.self, Address.self ])
 * ```
 * Or just `Contact.self`, if this contains a reference to `Address`.
 */
public final class SchemaBuilder {
  // Notes:
  // - this MUST NOT call `.entity` on the model! might recurse w/ lock, this
  //   object is the authority!
  // - there can be multiple entities that use the same name, this spans the
  //   whole type system. E.g. when versioned schemas are used.
  
  /**
   * A shared SchemaBuilder that caches `NSEntityDescription` values for
   * ``PersistentModel`` `NSManagedObject`'s.
   */
  public static let shared = SchemaBuilder()
  
  private let lock = NSLock() // TODO: use better lock :-)
  
  /// ObjectIdentifier of PersistentModel type to the associated schema.
  private var entitiesByType = [ ObjectIdentifier : NSEntityDescription ]()
  
  /// The identifiers of the types that have been processed and must not be
  /// modified anymore.
  private var frozenTypes    = Set<ObjectIdentifier>()
  
  init() {}
  
  
  // MARK: - Helpers
  
  private func lookupEntity<O>(_ modelType: O.Type) -> NSEntityDescription?
    where O: PersistentModel
  {
    entitiesByType[ObjectIdentifier(O.self)]
  }
  private func isFrozen<O>(_ modelType: O.Type) -> Bool
    where O: PersistentModel
  {
    frozenTypes.contains(ObjectIdentifier(O.self))
  }


  // MARK: - Main Entry
  
  /**
   * Resolve the given types.
   *
   * Thread Safety: This is a thread-safe operation. Do NOT modify the returned
   *                Schema objects.
   */
  func lookupAllEntities(for modelTypes: [ any PersistentModel.Type ])
       -> [ NSEntityDescription ]
  {
    var entities = [ NSEntityDescription ]()

    lock.lock()
    process(modelTypes, entities: &entities)
    lock.unlock()
    
    return entities
  }
  
  /**
   * Resolve the given type. Internal function.
   *
   * It is not recommended to use this method. Instead use the
   * ``Schema/init(_:version:)`` initializers to get a ``Schema`` for a set
   * of ``PersistentModel`` types.
   *
   * Thread Safety: This is a thread-safe operation. Do NOT modify the return
   *                Schema objects.
   */
  public func _entity<M>(for modelType: M.Type) -> NSEntityDescription
    where M: PersistentModel
  {
    var entities = [ NSEntityDescription ]()
    let modelTypes = [ modelType ]
    lock.lock()
    let entity = lookupEntity(modelType) ?? {
      process(modelTypes, entities: &entities)
      guard let entity = lookupEntity(modelType) else {
        fatalError(
          "Could not construct Entity for PersistentModel type: \(modelType)")
      }
      return entity
    }()
    lock.unlock()
    return entity
  }

  
  // MARK: - Things that run in the lock!

  private func process(_ modelTypes: [ any PersistentModel.Type ],
                       entities: inout [ NSEntityDescription ])
  {
    // Note: This is called recursively
    var allFrozen = true
    
    // Create the basic entity and property data
    for modelType in modelTypes {
      if isFrozen(modelType) {
        if let entity = lookupEntity(modelType) {
          entities.append(entity)
          continue
        }
        assertionFailure("Type frozen, but no entity found?")
      }
      allFrozen = false
      if let newEntity = processModel(modelType) {
        entities.append(newEntity)
      }
    }
    if allFrozen { return } // all have been processed already
    
    // TBD: The following does too much work, we might only need the
    //      most of those on the "new models"
    
    // This recurses into `process`, if necessary.
    discoverTargetTypes(in: entities, allEntities: &entities)

    // Collect destination entity names in relships based on the modelType!
    fillDestinationEntityNamesInRelationships(entities)
    
    // Lookup inverse relationships
    fillInverseRelationshipData(entities)
    
    frozenTypes.formUnion(entitiesByType.keys)
  }
  
  /**
   * Walks over all ``Schema/Relationship`` objects and checks whether the
   * model type they point to is already tracked as an entity.
   * Recurses until all relationships have been processed.
   */
  private func discoverTargetTypes(in entities: [ NSEntityDescription ],
                                   allEntities: inout [ NSEntityDescription ])
  {
    var newEntities = [ NSEntityDescription ]()
    for entity in entities {
      for relationship in entity.relationships {
        guard let targetType = relationship.modelType else {
          assertionFailure("Missing type for relationship \(relationship)")
          continue
        }
        // This returns nil if the model is already processed.
        guard let newEntity = processModel(targetType) else { continue }
        
        allEntities.append(newEntity)
        newEntities.append(newEntity)
      }
    }
    
    if !newEntities.isEmpty { // recurse if necessary
      discoverTargetTypes(in: newEntities, allEntities: &allEntities)
    }
  }
  
  /**
   * Checks whether an ``Entity`` was already generated, and generates a basic
   * one if not yet.
   */
  @discardableResult
  private func processModel<M>(_ modelType: M.Type) -> NSEntityDescription?
    where M: PersistentModel
  {
    let modelID = ObjectIdentifier(M.self) // Register the non-existential type.
    if entitiesByType[modelID] != nil { return nil } // already processed
    
    let entity = NSEntityDescription(modelType)
    entitiesByType[modelID] = entity
    return entity
  }
  
  
  // MARK: - Destinations

  private func fillDestinationEntityNamesInRelationships<S>(_ entities: S)
    where S: Sequence, S.Element == NSEntityDescription
  {
    // Collect destination entity names in relships based on the modelType!
    for entity in entities {
      if let modelType = entity._objectType, isFrozen(modelType) {
        continue
      }
      
      for relationship in entity.relationships
        where relationship.destination.isEmpty
           || relationship.destinationEntity == nil
      {
        // TBD: Cache modelType or entity if too slow to calculate each time.
        guard let destinationModelType = relationship.modelType else {
          assertionFailure("Relationship has no model type?! \(relationship)")
          continue
        }
        
        guard let destinationEntity = lookupEntity(destinationModelType) else {
          assertionFailure("Relationship has no model type?! \(relationship)")
          continue
        }
        
        if let destinationName = destinationEntity.name {
          relationship.destination       = destinationName
          relationship.destinationEntity = destinationEntity
        }
      }
    }
  }
  
  
  // MARK: - Inverse Relationships
  
  private func fillInverseRelationshipData<S>(_ entities: S)
    where S: Sequence, S.Element == NSEntityDescription
  {
    for sourceEntity in entities {
      for relationship in sourceEntity.relationships {
        let targetEntity : NSEntityDescription?
        
        if let entity = relationship.destinationEntity {
          targetEntity = entity
        }
        else {
          guard let targetModel = relationship.modelType else {
            // TBD: fatalError?
            print("WARN: Did not find target model for relationship:",
                  sourceEntity.name ?? "???",
                  relationship.name, relationship.destination)
            continue
          }
          targetEntity = lookupEntity(targetModel)
        }
        guard let targetEntity else {
          // TBD: fatalError?
          print("WARN: Did not find target entity for relationship:",
                sourceEntity.name ?? "???",
                relationship.name, relationship.destination)
          continue
        }
        
        fillInverseRelationshipData(for: relationship, in: sourceEntity,
                                    targetEntity: targetEntity)
      }
    }
  }
  
  @discardableResult
  private func fillInverseRelationshipData(
    for relationship : NSRelationshipDescription,
    in  sourceEntity : NSEntityDescription,
    targetEntity     : NSEntityDescription
  ) -> Bool
  {
    // When the inverse is already set.
    if let inverseKeyPath = relationship.inverseKeyPath {
      guard relationship.inverseName == nil else { return true } // all good

      

      // fill name if missing
      guard let inverseRelship = targetEntity.relationships.first(where: {
        $0.relationshipInfo?.keypath == inverseKeyPath
      }) else
      {
        print("Could not find inverse relationship for:", relationship)
        return false
      }
      
      // FIXME
      // set inverse
      relationship.setInverseRelationship(inverseRelship)
      return true
    }
    
    
    // Inverse missing, look whether the target has one pointing back to
    // the keypath of our relationship.
    
    var firstMatchWithoutInverse : NSRelationshipDescription?
    var firstMatchWithInverse    : NSRelationshipDescription?
    var seenMultipleOptions = false

    // All are walked to look for an exact keyPath match.
    for targetRelationship in targetEntity.relationships {
      
      // check for exact match
      if let targetInverseKeyPath = targetRelationship.inverseKeyPath,
         relationship.keypath == targetInverseKeyPath
      { // target relationship has inverse, and it matches our keypath
        relationship.setInverseRelationship(targetRelationship)
        return true // exact keypath match
      }

      // Only consider targets that point back to our entity.
      guard targetRelationship.destination == sourceEntity.name else {
        assert(!targetRelationship.destination.isEmpty)
        continue
      }
      
      if targetRelationship.inverseKeyPath == nil {
        if firstMatchWithoutInverse == nil {
          firstMatchWithoutInverse = targetRelationship
        }
        else if !seenMultipleOptions {
          seenMultipleOptions = true
        }
      }
      else {
        if firstMatchWithInverse == nil {
          firstMatchWithInverse = targetRelationship
        }
      }
    }
    
    if seenMultipleOptions {
      print("WARN: Multiple inverse relationships,",
            "explicitly specify `inverseKeyPath`:",
            sourceEntity.name ?? "???", relationship.name)
    }
    
    if let firstMatchWithoutInverse = firstMatchWithoutInverse {
      relationship.setInverseRelationship(firstMatchWithoutInverse)
      return true
    }
    
    if let firstMatchWithInverse = firstMatchWithInverse {
      // TBD: Good or not? Will also trigger the preconditions
      print("WARN: Using inverse relationship w/ a mismatching keypath:",
            sourceEntity.name ?? "???",
            relationship.name, firstMatchWithInverse.name)
      relationship.setInverseRelationship(firstMatchWithInverse)
      return true
    }
    
    return false
  }
}
