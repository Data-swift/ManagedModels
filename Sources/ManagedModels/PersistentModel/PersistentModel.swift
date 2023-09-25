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
  
  /**
   * Reflection data for the model.
   *
   * This is considered private, use a Schema to access entities, and NEVER
   * modify the schema objects after they got setup.
   *
   * API DIFF: SwiftData doesn't have that, always builds dynamically.
   */
  static var _$entity : NSEntityDescription { get }
    // Why have that? Cheap cache.

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
}

extension PersistentModel {
    
  @inlinable
  public static var schemaMetadata : [ NSManagedObjectModel.PropertyMetadata ] {
    fatalError("Subclass needs to implement `schemaMetadata`")
  }
  
  @inlinable
  public static var _$entity : NSEntityDescription { self.entity() }
}
