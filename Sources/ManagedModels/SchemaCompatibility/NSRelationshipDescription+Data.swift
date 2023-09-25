//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension CoreData.NSRelationshipDescription {
  
  public typealias DeleteRule = NSDeleteRule
}

extension CoreData.NSRelationshipDescription {}

public extension CoreData.NSRelationshipDescription {

  @inlinable var isAttribute    : Bool { return false }
  @inlinable var isRelationship : Bool { return true  }
  
  @inlinable var options : [ Option ] { isUnique ? [ .unique ] : [] }
}


/// Those are properties that get overridden in the subclass.
@objc public extension NSRelationshipDescription {

  var isToOneRelationship : Bool    { !isToMany                     }
  var inverseName         : String? { inverseRelationship?.name     }
  var destination         : String  { destinationEntity?.name ?? "" }
}
