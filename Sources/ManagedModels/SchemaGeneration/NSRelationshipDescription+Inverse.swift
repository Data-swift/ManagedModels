//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension CoreData.NSRelationshipDescription {

  func setInverseRelationship(_ newInverseRelationship:
                                NSRelationshipDescription)
  {
    assert(self.inverseRelationship == nil
        || self.inverseRelationship === newInverseRelationship)
    
    // A regular non-Model relationship
    
    if self.inverseRelationship == nil ||
       self.inverseRelationship !== newInverseRelationship
    {
      self.inverseRelationship = newInverseRelationship
    }
    // get only in baseclass: inverseRelationship.inverseName
    if inverseName == nil || inverseName != newInverseRelationship.name {
      inverseName = newInverseRelationship.name
    }
    if destinationEntity == nil ||
       destinationEntity != newInverseRelationship.entity
    {
      destinationEntity = newInverseRelationship.entity
    }
    if newInverseRelationship.destinationEntity == nil ||
        newInverseRelationship.destinationEntity != entity
    {
      newInverseRelationship.destinationEntity = entity
    }

    if newInverseRelationship.inverseRelationship == nil ||
       newInverseRelationship.inverseRelationship !== self
    {
      newInverseRelationship.inverseRelationship = self
    }
    
    // Extra model stuff
    
    assert(inverseKeyPath == nil
        || inverseKeyPath == newInverseRelationship.keypath)
    assert(inverseName == nil || inverseName == newInverseRelationship.name)

    if inverseKeyPath == nil ||
       inverseKeyPath != newInverseRelationship.keypath
    {
      inverseKeyPath = newInverseRelationship.keypath
    }
    if inverseName == nil || inverseName != newInverseRelationship.name {
      inverseName = newInverseRelationship.name
    }
    
    if newInverseRelationship.inverseKeyPath == nil ||
       newInverseRelationship.inverseKeyPath != keypath
    {
      newInverseRelationship.inverseKeyPath = keypath
    }
    if newInverseRelationship.inverseName == nil ||
       newInverseRelationship.inverseName != name
    {
      // also fill inverse if not set
      newInverseRelationship.inverseName = name
    }

    assert(keypath        == newInverseRelationship.inverseKeyPath)
    assert(name           == newInverseRelationship.inverseName)
    assert(inverseKeyPath == newInverseRelationship.keypath)
    assert(inverseName    == newInverseRelationship.name)
  }
}
