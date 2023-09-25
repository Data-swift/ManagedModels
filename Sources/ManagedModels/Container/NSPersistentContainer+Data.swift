//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension NSPersistentContainer {

  @inlinable
  public var schema : NSManagedObjectModel { managedObjectModel }

  //@MainActor - TBD :-)
  @inlinable
  public var mainContext : NSManagedObjectContext { viewContext }

  convenience
  public init(for      model : NSManagedObjectModel,
              migrationPlan  : SchemaMigrationPlan.Type? = nil,
              configurations : [ ModelConfiguration ]) throws
  {
    precondition(migrationPlan == nil, "Migration plans not yet supported")
    
    let combinedModel : NSManagedObjectModel = {
      let allModels = [ model ] + configurations.compactMap { $0.schema }
      guard allModels.count > 1 else { return model }
      let merged = NSManagedObjectModel(byMerging: allModels)
      assert(merged != nil, "Could not combine object models: \(allModels)")
      return merged ?? model
    }()
    
    // TBD: Is this correct? It is the container name, not the configuration
    //      name?
    let firstName = configurations.first(where: { !$0.name.isEmpty })?.name
                 ?? "ManagedModels"

    self.init(
      name: firstName,
      managedObjectModel: combinedModel
    )
    persistentStoreDescriptions = configurations.map { .init($0) }

    // This seems to run synchronously unless the storeDescription has
    // `shouldAddStoreAsynchronously`.
    var errors = [ Swift.Error ]()
    loadPersistentStores { (storeDescription, error) in
      if let error {
        if !storeDescription.shouldAddStoreAsynchronously {
          errors.append(error)
        }
        else { // TBD: how to report those errors? Delegate?
          // Well, the modifiers take a closure for that, use it?!
          fatalError("Failed to add store: \(error), \(storeDescription)")
        }
      }      
    }
    if let error = errors.first { // TODO: Combine multiple errors :-)
      throw error
    }
    
    viewContext.automaticallyMergesChangesFromParent = true
  }

}

public extension NSPersistentContainer {
  
  convenience init(for     model  : NSManagedObjectModel,
                   migrationPlan  : SchemaMigrationPlan.Type? = nil,
                   configurations : ModelConfiguration...) throws
  {
    try self.init(for: model, migrationPlan: migrationPlan,
                  configurations: configurations)
  }

  convenience init(for      types : any PersistentModel.Type...,
                   migrationPlan  : SchemaMigrationPlan.Type? = nil,
                   configurations : ModelConfiguration...) throws
  {
    let model = NSManagedObjectModel.model(for: types) // this caches!
    try self.init(for: model, migrationPlan: migrationPlan,
                  configurations: configurations)
  }
}
