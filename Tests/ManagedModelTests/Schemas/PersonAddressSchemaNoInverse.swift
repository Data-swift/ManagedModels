//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  
  enum PersonAddressSchemaNoInverse: VersionedSchema {
    static var models : [ any PersistentModel.Type ] = [
      Person.self,
      Address.self
    ]
    
    public static let versionIdentifier = Schema.Version(0, 1, 0)

    
    @Model
    final class Person: NSManagedObject, PersistentModel {
      
      // TBD: Why are the inits required? *** NEED TO FIGURE THIS OUT
      var firstname : String
      var lastname  : String
      var addresses : [ Address ]
      
      // init() is a convenience initializer, it looks up the the entity for the
      // object?
      // Can we generate inits?
      
      init(firstname: String, lastname: String, addresses: [ Address ]) {
        super.init(entity: Self._$entity, insertInto: nil)
        self.firstname = firstname
        self.lastname  = lastname
        self.addresses = addresses
      }
    }
    
    @Model
    final class Address /*test*/ : NSManagedObject, PersistentModel {
      
      var street     : String
      var appartment : String?
      
      convenience init(street: String, appartment: String? = nil) {
        self.init()
        self.street     = street
        self.appartment = appartment
      }
    }
  }
}
