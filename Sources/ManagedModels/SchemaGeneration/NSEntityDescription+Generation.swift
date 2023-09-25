//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension NSEntityDescription {
  
  /**
   * Create a new ``Schema/Entity`` given a ``PersistentModel`` type.
   *
   * This only fills the data that is local to the model, i.e. it doesn't
   * traverse into destination types for relationships and such.
   *
   * This is not a general purpose builder, use ``SchemaBuilder`` instead.
   */
  convenience init<M>(_ type: M.Type) 
    where M: NSManagedObject & PersistentModel
  {
    self.init()
    self.name              = _typeName(M.self, qualified: false)
    managedObjectClassName = NSStringFromClass(type)

    if let s = M._$originalName { renamingIdentifier  = s }
    if let s = M._$hashModifier { versionHashModifier = s }

    for propMeta in M.schemaMetadata {
      let property = processProperty(propMeta)
      
      assert(attributesByName   [property.name] == nil &&
             relationshipsByName[property.name] == nil)
      properties.append(property)
      
      if property.isUnique && !self.isPropertyUnique(property) {
        uniquenessConstraints.append([ property ])
      }
    }
  }
  
  // MARK: - Properties
  
  private typealias PropertyMetadata = NSManagedObjectModel.PropertyMetadata

  private func processProperty(_ meta: PropertyMetadata)
               -> NSPropertyDescription
  {
    // Check whether a pre-filled property has been set.
    if let templateProperty = meta.metadata {
      return processProperty(meta, template: templateProperty)
    }
    else {
      return createProperty(meta)
    }
  }

  private func processProperty<P>(_ propMeta: PropertyMetadata, template: P)
               -> NSPropertyDescription
    where P: NSPropertyDescription
  {
    let targetType = type(of: propMeta.keypath).valueType

    // Note that we make a copy of the objects, they might be used in
    // different setups/configs.
    
    if let template = template as? NSAttributeDescription {
      let attribute = template.internalCopy()
      fixup(attribute, targetType: targetType, meta: propMeta)
      return attribute
    }
    
    if let template = template as? Schema.Relationship /*NSRelationshipDescription*/ {
      let relationship = template.internalCopy()
      switch RelationshipTargetType(targetType) {
        case .attribute(_):
          // TBD: Rather throw?
          assertionFailure("Relationship target type is not an object?")
          fixup(relationship, targetType: targetType, isToOne: true,
                meta: propMeta)
          return relationship

        case .toOne(modelType: _, optional: _):
          fixup(relationship, targetType: targetType, isToOne: true,
                meta: propMeta)
          return relationship

        case .toMany(collectionType: _, modelType: _):
          fixup(relationship, targetType: targetType, isToOne: false,
                meta: propMeta)
          return relationship
      }
    }

    // TBD: Rather throw?
    assertionFailure("Unexpected property metadata object: \(template)")
    print("Unexpected property metadata object:", template)
    return createProperty(propMeta)
  }
  
  private func createProperty(_ propMeta: PropertyMetadata)
               -> NSPropertyDescription
  {
    let valueType = type(of: propMeta.keypath).valueType

    // Need to reflect to decide what the keypath is pointing too.
    switch RelationshipTargetType(valueType) {
        
      case .attribute(_):
        let attribute = CoreData.NSAttributeDescription(
          name: propMeta.name,
          valueType: valueType,
          defaultValue: propMeta.defaultValue
        )
        fixup(attribute, targetType: valueType, meta: propMeta)
        return attribute
        
      case .toOne(modelType: _, optional: _):
        let relationship = Schema.Relationship()
        relationship.valueType = valueType
        fixup(relationship, targetType: valueType, isToOne: true,
              meta: propMeta)
        return relationship
        
      case .toMany(collectionType: _, modelType: _):
        let relationship = Schema.Relationship()
        relationship.valueType = valueType
        fixup(relationship, targetType: valueType, isToOne: false,
              meta: propMeta)
        return relationship
    }
  }
  
  
  // MARK: - Fixups
  // Those `fixup` functions take potentially half-filled objects and add
  // in the extra values from the metadata.

  private func fixup(_ attribute: NSAttributeDescription, targetType: Any.Type,
                     meta: PropertyMetadata)
  {
    if attribute.name.isEmpty { attribute.name = meta.name }
    if attribute.valueType == Any.self {
      attribute.valueType  = targetType
      attribute.isOptional = targetType is any AnyOptional
    }
    if attribute.defaultValue == nil, let metaDefault = meta.defaultValue {
      attribute.defaultValue = metaDefault
    }
  }
  
  private func fixup(_ relationship: NSRelationshipDescription,
                     targetType: Any.Type,
                     isToOne: Bool,
                     meta: PropertyMetadata)
  {
    
    // TBD: Rather throw?
    assert(meta.defaultValue == nil, "Relationship w/ default value?")
    if relationship.name.isEmpty { relationship.name = meta.name }
    
    if !isToOne {
      // Note: In SwiftData arrays are not ordered.
      relationship.isOrdered = targetType is NSOrderedSet.Type
    }

    if let relationship = relationship as? Schema.Relationship {
      if relationship.keypath == nil { relationship.keypath = meta.keypath }
      if relationship.valueType == Any.self {
        relationship.valueType = targetType
      }
    }
  }
}
