//
//  Created by Helge Heß.
//  Copyright © 2023-2024 ZeeZide GmbH.
//

import CoreData

public typealias PersistentIdentifier = NSManagedObjectID

#if compiler(>=6)
extension NSManagedObjectID: @retroactive Identifiable, @retroactive Encodable {
}
#else
extension NSManagedObjectID: Identifiable, Encodable {}
#endif

extension NSManagedObjectID {
  public typealias ID = NSManagedObjectID
  
  @inlinable
  public var id: Self { self }
}

extension NSManagedObjectID {
  
  @inlinable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.uriRepresentation())
  }
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
