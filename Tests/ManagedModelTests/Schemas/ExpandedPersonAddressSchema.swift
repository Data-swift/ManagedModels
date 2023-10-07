//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  
  enum ExpandedPersonAddressSchema: VersionedSchema {
    
    static var models : [ any PersistentModel.Type ] = [
      Person.self,
      Address.self
    ]

    public static let versionIdentifier = Schema.Version(0, 1, 0)

    
    final class Person: NSManagedObject, PersistentModel {
      
      // TBD: Why are the inits required?
      // @NSManaged property cannot have an initial value?!
      @NSManaged var firstname : String
      @NSManaged var lastname  : String
      @NSManaged var addresses : [ Address ]
      
      // init() is a convenience initializer, it looks up the the entity for the
      // object?
      // Can we generate inits?
      
      init(firstname: String, lastname: String, addresses: [ Address ]) {
        // Note: Could do Self.entity!
        super.init(entity: Self.entity(), insertInto: nil)
        self.firstname = firstname
        self.lastname  = lastname
        self.addresses = addresses
      }

      public static let schemaMetadata : [ Schema.PropertyMetadata ] = [
        .init(name: "firstname" , keypath: \Person.firstname),
        .init(name: "lastname"  , keypath: \Person.lastname),
        .init(name: "addresses" , keypath: \Person.addresses)
      ]
      public static let _$originalName : String? = nil
      public static let _$hashModifier : String? = nil
    }
    
    final class Address: NSManagedObject, PersistentModel {
      
      @NSManaged var street     : String
      @NSManaged var appartment : String?
      @NSManaged var person     : Person
      
      init(street: String, appartment: String? = nil, person: Person) {
        super.init(entity: Self.entity(), insertInto: nil)
        self.street     = street
        self.appartment = appartment
        self.person     = person
      }

      public static let schemaMetadata : [ Schema.PropertyMetadata ] = [
        .init(name: "street"     , keypath: \Address.street),
        .init(name: "appartment" , keypath: \Address.appartment),
        .init(name: "person"     , keypath: \Address.person)
      ]
      public static let _$originalName : String? = nil
      public static let _$hashModifier : String? = nil
    }
  }
}
