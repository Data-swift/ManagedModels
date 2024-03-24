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


extension CoreData.NSRelationshipDescription {
  
  /**
   * Returns the ``PersistentModel`` type targeted by the relationship,
   * based on the ``valueType`` property.
   */
  var modelType: (any PersistentModel.Type)? {
    if relationshipInfo?.valueType == nil {
      if let destinationEntity = destinationEntity {
        if let type = destinationEntity._objectType {
          return type
        }
      }
      assertionFailure(
        "Could not determine model type of relationship: \(self)?")
      return nil
    }
    
    // TBD: If that's too expensive, we could cache it?
    switch RelationshipTargetType(valueType) {
      case .attribute(_):
        assertionFailure("Detected relationship type as an attribute? \(self)")
        return nil
      case .toOne(modelType: let modelType, optional: _):
        return modelType
      case .toMany(collectionType: _, modelType: let modelType):
        return modelType
      case .toOrderedSet(optional: _):
        assertionFailure(
          "Attempt to get the `modelType` of an NSOrderedSet relship. \(self)"
        )
        return nil
    }
  }
}


// MARK: - Initializer

public extension CoreData.NSRelationshipDescription {
  
  // Note: This matches what the `Relationship` macro takes.
  convenience init(_ options: Option..., deleteRule: NSDeleteRule = .nullify,
                   minimumModelCount: Int? = 0, maximumModelCount: Int? = 0,
                   originalName: String? = nil, inverse: AnyKeyPath? = nil,
                   hashModifier: String? = nil, // TBD
                   name: String? = nil, valueType: Any.Type = Any.self)
  {
    // Note The original doesn't take a name, because it is supposed to match
    // the `@Relationship` macro. That's also why we order those last :-)
    precondition(minimumModelCount ?? 0 >= 0)
    precondition(maximumModelCount ?? 0 >= 0)
    self.init()
    
    self.name                = name ?? ""
    self.valueType           = valueType
    self.renamingIdentifier  = originalName ?? ""
    self.versionHashModifier = hashModifier
    self.deleteRule          = deleteRule
    self.inverseKeyPath      = inverse
    
    if options.contains(.unique) { isUnique = true }
    
    if let minimumModelCount { self.minCount = minimumModelCount }
    if let maximumModelCount {
      self.maxCount = maximumModelCount
    }
    else {
      if valueType is any RelationshipCollection.Type {
        self.maxCount = 0
      }
      else if valueType is NSOrderedSet.Type ||
              valueType is Optional<NSOrderedSet>.Type
      {
        self.maxCount = 0
      }
      else {
        self.maxCount = 1 // the toOne marker!
      }
    }
  }
}


// MARK: - Storage

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
  
  private struct AssociatedKeys {
    nonisolated(unsafe) static var relationshipInfoAssociatedKey: Void? = nil
  }
  
  var writableRelationshipInfo : MacroInfo {
    if let info = objc_getAssociatedObject(
         self, &AssociatedKeys.relationshipInfoAssociatedKey) as? MacroInfo
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
      objc_setAssociatedObject(
        self, &AssociatedKeys.relationshipInfoAssociatedKey,
        newValue, .OBJC_ASSOCIATION_RETAIN
      )
    }
    get {
      objc_getAssociatedObject(
        self, &AssociatedKeys.relationshipInfoAssociatedKey
      ) as? MacroInfo
    }
  }
}
