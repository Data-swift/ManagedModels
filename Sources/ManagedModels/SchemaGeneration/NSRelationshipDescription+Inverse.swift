//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

extension Schema.Relationship {

  func setInverseRelationship(_ newInverseRelationship: 
                                  NSRelationshipDescription)
  {
    if let inverse = newInverseRelationship as? Schema.Relationship {
      self.setInverseRelationship(inverse)
    }
    else {
      _setInverseRelationship(newInverseRelationship)
    }
  }

  private func _setInverseRelationship(_ newInverseRelationship:
                                         NSRelationshipDescription)
  {
    assert(self.inverseRelationship == nil
        || self.inverseRelationship === newInverseRelationship)
    
    // A regular non-Model relationship
    
    if self.inverseRelationship == nil ||
       self.inverseRelationship !== newInverseRelationship
    {
      self.ensureNotFinalized()
      self.inverseRelationship = newInverseRelationship
    }
    // get only in baseclass: inverseRelationship.inverseName
    if inverseName == nil || inverseName != newInverseRelationship.name {
      self.ensureNotFinalized()
      inverseName = newInverseRelationship.name
    }
    if destinationEntity == nil ||
       destinationEntity != newInverseRelationship.entity
    {
      self.ensureNotFinalized()
      destinationEntity = newInverseRelationship.entity
    }
    if newInverseRelationship.destinationEntity == nil ||
        newInverseRelationship.destinationEntity != entity
    {
      newInverseRelationship.ensureNotFinalized()
      newInverseRelationship.destinationEntity = entity
    }

    if newInverseRelationship.inverseRelationship == nil ||
       newInverseRelationship.inverseRelationship !== self
    {
      newInverseRelationship.ensureNotFinalized()
      newInverseRelationship.inverseRelationship = self
    }
  }

  func setInverseRelationship(_ newInverseRelationship: Schema.Relationship) {
    assert(inverseKeyPath == nil
        || inverseKeyPath == newInverseRelationship.keypath)
    assert(inverseName == nil || inverseName == newInverseRelationship.name)

    _setInverseRelationship(newInverseRelationship)

    if inverseKeyPath == nil ||
       inverseKeyPath != newInverseRelationship.keypath
    {
      self.ensureNotFinalized()
      inverseKeyPath = newInverseRelationship.keypath
    }
    if inverseName == nil || inverseName != newInverseRelationship.name {
      self.ensureNotFinalized()
      inverseName = newInverseRelationship.name
    }
    
    if newInverseRelationship.inverseKeyPath == nil ||
       newInverseRelationship.inverseKeyPath != keypath
    {
      newInverseRelationship.ensureNotFinalized()
      newInverseRelationship.inverseKeyPath = keypath
    }
    if newInverseRelationship.inverseName == nil ||
       newInverseRelationship.inverseName != name
    {
      // also fill inverse if not set
      newInverseRelationship.ensureNotFinalized()
      newInverseRelationship.inverseName = name
    }

    assert(keypath        == newInverseRelationship.inverseKeyPath)
    assert(name           == newInverseRelationship.inverseName)
    assert(inverseKeyPath == newInverseRelationship.keypath)
    assert(inverseName    == newInverseRelationship.name)
  }
}
