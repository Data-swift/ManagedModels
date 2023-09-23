//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension Schema {
  
  /**
   * A subclass of `NSRelationshipDescription` that tracks a few more schema
   * properties for ManagedModels.
   */
  final class Relationship: CoreData.NSRelationshipDescription, SchemaProperty {
    
    public var keypath : AnyKeyPath? {
      willSet {
        guard keypath != newValue else { return }
        ensureNotFinalized()
      }
    }
    public var inverseKeyPath : AnyKeyPath? {
      willSet {
        guard inverseKeyPath != newValue else { return }
        ensureNotFinalized()
      }
    }

    public var valueType: Any.Type = Any.self {
      willSet {
        guard valueType != newValue else { return }
        ensureNotFinalized()
      }
    }

    final override public var inverseName: String? {
      set {
        guard _inverseName != newValue else { return }
        ensureNotFinalized()
        _inverseName = newValue
      }
      get { _inverseName }
    }
    private var _inverseName : String?

    final override public var destination: String {
      set {
        guard _destination != newValue else { return }
        ensureNotFinalized()
        _destination = newValue
      }
      get { _destination }
    }
    private var _destination = ""

    final override public var isUnique: Bool {
      set { _isUnique = newValue }
      get { _isUnique }
    }
    private var _isUnique = false

    override public var isToOneRelationship : Bool {
      _isToOneRelationship ?? !(valueType is any RelationshipCollection.Type)
    }
    var _isToOneRelationship : Bool? {
      willSet {
        guard _isToOneRelationship != newValue else { return }
        assert(_isToOneRelationship == nil)
        ensureNotFinalized()
      }
    }
    
    override public var isToMany: Bool { !isToOneRelationship }

    final override public var isFinalized: Bool {
      set { _isFinalized = newValue }
      get { _isFinalized }
    }
    private var _isFinalized = false
    
    
    // MARK: - Initializers
    
    public override init() {
      super.init()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    @objc(supportsSecureCoding)
    public class var supportsSecureCoding: Bool { true }

    init(_ other: Relationship) {
      super.init()

      name                 = other.name
      isOptional           = other.isOptional
      isTransient          = other.isTransient
      userInfo             = other.userInfo
      versionHashModifier  = other.versionHashModifier
      isIndexedBySpotlight = other.isIndexedBySpotlight
      renamingIdentifier   = other.renamingIdentifier
      
      if !other.validationPredicates.isEmpty ||
         !other.validationWarnings.isEmpty
      {
        setValidationPredicates(
          other.validationPredicates,
          withValidationWarnings:
            other.validationWarnings.compactMap { $0 as? String }
        )
      }

      if let dest = other.destinationEntity   { self.destinationEntity = dest }
      if let inv  = other.inverseRelationship { self.inverseRelationship = inv }
      maxCount             = other.maxCount
      minCount             = other.minCount
      deleteRule           = other.deleteRule
      maxCount             = other.maxCount
      isOrdered            = other.isOrdered
      keypath              = other.keypath
      inverseKeyPath       = other.inverseKeyPath
      valueType            = other.valueType
      _inverseName         = other.inverseName
      _destination         = other.destination
      _isUnique            = other.isUnique
      _isToOneRelationship = other.isToOneRelationship
    }
    
    // MARK: - Copying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
      // TBD: unclear whether this is good enough?
      Relationship(self)
    }
  }
}

extension Schema.Relationship {
  
  /**
   * Returns the ``PersistentModel`` type targeted by the relationship,
   * based on the ``valueType`` property.
   */
  var modelType: (any PersistentModel.Type)? {
    // TBD: If that's too expensive, we could cache it?
    switch RelationshipTargetType(valueType) {
      case .attribute(_):
        return nil
      case .toOne(modelType: let modelType, optional: _):
        return modelType
      case .toMany(collectionType: _, modelType: let modelType):
        return modelType
    }
  }
}

public extension Schema.Relationship {

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

    if options.contains(.unique) { _isUnique = true }

    if let minimumModelCount { self.minCount = minimumModelCount }
    if let maximumModelCount { self.maxCount = maximumModelCount }
  }
}
