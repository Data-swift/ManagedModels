//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  
  static let PersonAddressMOM = PersonAddressSchema.managedObjectModel
  
  enum PersonAddressSchema: VersionedSchema {
    static var models : [ any PersistentModel.Type ] = [
      Person.self,
      Address.self
    ]
    
    public static let versionIdentifier = Schema.Version(0, 1, 0)

    
    @Model
    final class Person: NSManagedObject {
      
      var firstname : String
      var lastname  : String
      var addresses : Set<Address> // [ Address ]
    }
    
    enum AddressType: Int {
        case home, work
    }
    
    @Model
    final class Address /*test*/ : NSManagedObject {
      
      var street     : String
      var appartment : String?
      var type       : AddressType
      var person     : Person
      
      // Either: super.init(entity: Self.entity(), insertInto: nil)
      // Or:     mark this as `convenience`
      convenience init(street: String, appartment: String? = nil, type: AddressType, person: Person) {
        //super.init(entity: Self.entity(), insertInto: nil)
        self.init()
        self.street     = street
        self.appartment = appartment
        self.type       = type
        self.person     = person
      }
    }
  }
}
