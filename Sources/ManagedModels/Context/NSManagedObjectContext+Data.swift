//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

// TODO: autosave

public extension NSManagedObjectContext {
  
  @inlinable
  var autosaveEnabled : Bool { false } // TODO
  
  @inlinable
  var insertedModels      : Set<NSManagedObject> { insertedObjects       }
  @inlinable
  var changedModels       : Set<NSManagedObject> { updatedObjects        }
  @inlinable
  var deletedModels       : Set<NSManagedObject> { deletedObjects        }
  @inlinable
  var registeredModels    : Set<NSManagedObject> { registeredObjects     }
  
  @inlinable
  var insertedModelsArray : [NSManagedObject]    { Array(insertedModels) }
  @inlinable
  var changedModelsArray  : [NSManagedObject]    { Array(changedModels)  }
  @inlinable
  var deletedModelsArray  : [NSManagedObject]    { Array(deletedModels)  }
  
  /**
   * Check whether a model with the given ``PersistentIdentifier`` is known to
   * the storage.
   */
  @inlinable
  func registeredModel<T>(for id: NSManagedObjectID) -> T?
    where T: NSManagedObject
  {
    // Note: This needs the type for a call, e.g.
    //   `let x : Address = ctx.registeredModel(for: id)`
    for object in registeredObjects { // Ugh, scan
      if object.objectID == id { return object as? T }
    }
    return nil
  }
}

public extension NSManagedObjectContext {
  
  static let willSave = willSaveObjectsNotification
  static let didSave  = didSaveObjectsNotification
}

public extension NSManagedObjectContext {
  
  @inlinable
  convenience init(_ container: ModelContainer) {
    self.init(concurrencyType: .mainQueueConcurrencyType) // TBD
    persistentStoreCoordinator = container.persistentStoreCoordinator
  }
}
