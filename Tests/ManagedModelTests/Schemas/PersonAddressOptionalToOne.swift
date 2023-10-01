//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  
  enum PersonAddressOptionalToOneSchema: VersionedSchema {
    static var models : [ any PersistentModel.Type ] = [
      Person.self,
      Address.self
    ]
    
    public static let versionIdentifier = Schema.Version(0, 1, 0)

    
    @Model class Person: NSManagedObject {
      var addresses : Set<Address> // [ Address ]
    }
    
    @Model class Address: NSManagedObject {
      @Relationship(deleteRule: .nullify, originalName: "PERSON")
      var person : Person?
    }
  }
}
