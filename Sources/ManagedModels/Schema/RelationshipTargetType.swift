//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

/**
 * Reflects and categorizes the various property types, given a target type.
 */
enum RelationshipTargetType {
  
  case attribute(Any.Type)
  
  case toOne (modelType: any PersistentModel.Type, optional: Bool)
  
  case toMany(collectionType: any RelationshipCollection.Type,
              modelType: any PersistentModel.Type)
  
  case toOrderedSet(optional: Bool)

  init(_ type: Any.Type) {
    if let relType = type as? any RelationshipCollection.Type {
      func modelType<P: RelationshipCollection>(in collection: P.Type)
           -> any PersistentModel.Type
      {
        return collection.PersistentElement.self
      }
      
      self = .toMany(collectionType: relType,
                     modelType: modelType(in: relType))
    }
    else if let modelType = type as? any PersistentModel.Type {
      self = .toOne(modelType: modelType, optional: false)
    }
    else if let anyType = type as? any AnyOptional.Type,
            let modelType = anyType.wrappedType as? any PersistentModel.Type
    {
      self = .toOne(modelType: modelType, optional: true)
    }
    else if type is NSOrderedSet.Type {
      self = .toOrderedSet(optional: false)
    }
    else if type is Optional<NSOrderedSet>.Type {
      self = .toOrderedSet(optional: true)
    }
    else {
      self = .attribute(type)
    }
  }
}
