//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public protocol VersionedSchema {

  static var models            : [ any PersistentModel.Type ] { get }
  static var versionIdentifier : NSManagedObjectModel.Version { get }
}

public extension VersionedSchema {
  
  /**
   * Returns a cached managed object model for the given schema.
   */
  static var managedObjectModel : NSManagedObjectModel { .model(for: models) }
}
