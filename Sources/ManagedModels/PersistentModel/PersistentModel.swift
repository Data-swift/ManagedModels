//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

/**
 * An `NSManagedObject` that can construct its `NSEntityDescription` using the
 * `@Model` macro.
 */
public protocol PersistentModel: NSManagedObject, Hashable, Identifiable {

  /// The `NSManagedObjectContext` the model is inserted into.
  var modelContext : NSManagedObjectContext? { get }

  /**
   * Reflection data for the model.
   */
  static var schemaMetadata : [ NSManagedObjectModel.PropertyMetadata ] { get }
  

  /// The `renamingIdentifier` of the model.
  static var _$originalName : String? { get }
  /// The `versionHashModifier` of the model.
  static var _$hashModifier : String? { get }
}

public extension PersistentModel {
  
  @inlinable
  var modelContext : NSManagedObjectContext? { managedObjectContext }
  
  /// The `NSManagedObjectID` of the model.
  @inlinable
  var persistentModelID : NSManagedObjectID { objectID }
  
  @inlinable
  var id : NSManagedObjectID { persistentModelID }
}

extension PersistentModel {
    
  @inlinable
  public static var schemaMetadata : [ NSManagedObjectModel.PropertyMetadata ] {
    fatalError("Subclass needs to implement `schemaMetadata`")
  }
}

public extension PersistentModel {

  @inlinable
  static func fetchRequest() -> NSFetchRequest<Self> {
    NSFetchRequest<Self>(entityName: _typeName(Self.self, qualified: false))
  }
  
  @inlinable
  static func fetchRequest<T>(filter         : NSPredicate? = nil,
                              sortBy keyPath : KeyPath<Self, T>,
                              order: NSSortDescriptor.SortOrder = .forward,
                              fetchOffset    : Int? = nil,
                              fetchLimit     : Int? = nil)
              -> NSFetchRequest<Self>
  {
    let fetchRequest = Self.fetchRequest()
    fetchRequest.predicate = filter
    if let meta = Self.schemaMetadata.first(where: { $0.keypath == keyPath }) {
      fetchRequest.sortDescriptors = [
        NSSortDescriptor(key: meta.name, ascending: order == .forward)
      ]
    }
    else {
      fetchRequest.sortDescriptors = [
        NSSortDescriptor(keyPath: keyPath, ascending: order == .forward)
      ]
    }
    if let fetchOffset { fetchRequest.fetchOffset = fetchOffset }
    if let fetchLimit  { fetchRequest.fetchLimit  = fetchLimit  }
    return fetchRequest
  }
}
