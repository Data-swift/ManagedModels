//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension CoreData.NSRelationshipDescription {
  
  public typealias DeleteRule = NSDeleteRule
}

extension CoreData.NSRelationshipDescription: SchemaProperty {}

public extension CoreData.NSRelationshipDescription {

  @inlinable var isToOneRelationship : Bool { !isToMany }

  @inlinable var isAttribute    : Bool { return false }
  @inlinable var isRelationship : Bool { return true  }
  
  @inlinable var options : [ Option ] { isUnique ? [ .unique ] : [] }
  
  var keypath : AnyKeyPath? {
    set { writableRelationshipInfo.keypath = newValue }
    get { relationshipInfo?.keypath }
  }
  
  var inverseKeyPath : AnyKeyPath? {
    set { writableRelationshipInfo.inverseKeyPath = newValue }
    get { relationshipInfo?.inverseKeyPath }
  }
  
  var valueType : Any.Type {
    set {
      if newValue == Any.self && relationshipInfo == nil { return }
      writableRelationshipInfo.valueType = newValue
    }
    get { relationshipInfo?.valueType ?? Any.self }
  }
  
  var inverseName : String? {
    set {
      if let inverseName = newValue {
        writableRelationshipInfo.inverseName = inverseName
      }
      else {
        relationshipInfo?.inverseName = nil
      }
    }
    get {
      relationshipInfo?.inverseName ?? inverseRelationship?.name
    }
  }
  
  var destination : String {
    set {
      if !newValue.isEmpty {
        writableRelationshipInfo.destination = newValue
      }
      else {
        relationshipInfo?.destination = nil
      }
    }
    get {
      relationshipInfo?.destination ?? destinationEntity?.name ?? ""
    }
  }
}

// MARK: - Storage

private var _relationshipInfoAssociatedKey: UInt8 = 72

extension CoreData.NSRelationshipDescription {

  func internalCopy() -> Self {
    guard let copy = self.copy() as? Self else {
      fatalError("Could not copy relationship \(self)")
    }
    assert(copy !== self, "Copy didn't produce a copy?")
    
    // Ensure copy of unique marker
    if isUnique { copy.isUnique = true }
    // Ensure copy of extra info
    if let relationshipInfo {
      copy.relationshipInfo = relationshipInfo.internalCopy()
    }
    return copy
  }
}

extension CoreData.NSRelationshipDescription {
  // Information that will get lost after serialization or regular copying.
  // Which should be fine, we only need it for the active, declared schema,
  // and that will have those things.
  
  final class MacroInfo: NSObject {
    var keypath             : AnyKeyPath?
    var inverseKeyPath      : AnyKeyPath?
    var valueType           : Any.Type?
    var inverseName         : String?
    var destination         : String?
    var isToOneRelationship : Bool?

    override func copy() -> Any { internalCopy() }
    
    func internalCopy() -> MacroInfo {
      let copy = MacroInfo()
      copy.keypath             = keypath
      copy.inverseKeyPath      = inverseKeyPath
      copy.valueType           = valueType
      copy.inverseName         = inverseName
      copy.destination         = destination
      copy.isToOneRelationship = isToOneRelationship
      return copy
    }
  }

  var writableRelationshipInfo : MacroInfo {
    if let info =
        objc_getAssociatedObject(self, &_relationshipInfoAssociatedKey)
        as? MacroInfo
    {
      return info
    }
    
    let info = MacroInfo()
    self.relationshipInfo = info
    return info
  }

  var relationshipInfo: MacroInfo? {
    // Note: isUnique is only used during schema construction!
    set {
      objc_setAssociatedObject(self, &_relationshipInfoAssociatedKey,
                               newValue, .OBJC_ASSOCIATION_RETAIN)
    }
    get {
      objc_getAssociatedObject(self, &_relationshipInfoAssociatedKey)
      as? MacroInfo
    }
  }
}
