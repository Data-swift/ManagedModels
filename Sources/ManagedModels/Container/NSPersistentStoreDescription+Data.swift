//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension NSPersistentStoreDescription {

  convenience init(_ modelConfiguration: ModelConfiguration) {
    self.init(url: modelConfiguration.url)
    
    type       = NSSQLiteStoreType
    isReadOnly = !modelConfiguration.allowsSave
    
    // Setting a name produces issues, I think because an NSEntityDescription
    // object is actually bound to a specific configuration.
    // This conflicts w/ our setup?
    #if false
    if !modelConfiguration.name.isEmpty {
      configuration = modelConfiguration.name
    }
    #endif
    
    // TBD: options, timeout, sqlitePragmas
    
    shouldAddStoreAsynchronously = false
    // shouldMigrateStoreAutomatically
    // shouldInferMappingModelAutomatically

    /* TBD. Maybe those are options?
      CoreData (NSPersistentCloudKitContainerOptions/.cloudKitContainerOptions):
        - containerIdentifier: String
     
      SwiftData
        groupAppContainerIdentifier : String? = nil
        cloudKitContainerIdentifier : String? = nil
        groupContainer              = GroupContainer.none
          .automatic
          .none
          .identifier(_ groupName: String) -> Self {
        cloudKitDatabase            = CloudKitDatabase.none
          .automatic = Self(value: .automatic)
          .none      = Self(value: .none)
         .`private`(_ dbName: String) -> Self {
     */
    precondition(modelConfiguration.groupAppContainerIdentifier == .none,
                 "groupAppContainerIdentifier config is not yet supported")
    precondition(modelConfiguration.groupContainer == .none,
                 "groupContainer config is not yet supported")
    precondition(modelConfiguration.cloudKitDatabase == .none,
                 "cloudKitDatabase config is not yet supported")
    if let id = modelConfiguration.cloudKitContainerIdentifier {
      self.cloudKitContainerOptions =
        NSPersistentCloudKitContainerOptions(containerIdentifier: id)
    }
  }
}
