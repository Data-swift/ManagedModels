//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public typealias PersistentIdentifier = NSManagedObjectID

extension NSManagedObjectID: Identifiable {
  
  public typealias ID = NSManagedObjectID
  
  @inlinable
  public var id: Self { self }
}

public extension NSManagedObjectID {
  
  @inlinable
  var entityName : String {
    entity.name ?? {
      assertionFailure(
        """
        Entity has no name: \(entity), called proper designated initializer?
        
        If an own designated initializer is used, it still has to call into
        
          super.init(entity: Self.entity(), insertInto: nil)
        
        Otherwise CoreData won't be able to generate a proper key.
        """
      )
      let oid = ObjectIdentifier(entity)
      return "Entity<\(String(UInt(bitPattern: oid), radix: 16))>"
    }()
  }
  
  @inlinable
  var storeIdentifier : String? {
    isTemporaryID ? nil : uriRepresentation().absoluteString
  }
}
