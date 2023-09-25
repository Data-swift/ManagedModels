//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public enum MigrationStage {

  @available(*, unavailable, message: "Not yet implemented")
  case lightweight(fromVersion : VersionedSchema.Type,
                   toVersion   : VersionedSchema.Type)

  // TODO: This takes a context, check how this is supposed to work.
  @available(*, unavailable, message: "Not yet implemented")
  case custom(fromVersion : VersionedSchema.Type,
              toVersion   : VersionedSchema.Type,
              willMigrate : (( NSManagedObjectContext ) throws -> Void)?,
              didMigrate  : (( NSManagedObjectContext ) throws -> Void)?)
}
