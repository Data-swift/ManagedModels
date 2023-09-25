//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension Schema {
  
  /**
   * A subclass of `NSAttributeDescription` that tracks a few more schema
   * properties for ManagedModels.
   */
  final class Attribute: CoreData.NSAttributeDescription {
    
    final override public var isUnique: Bool {
      set { _isUnique = newValue }
      get { _isUnique }
    }
    private var _isUnique = false

    
    // MARK: - Initializers
    
    override init() {
      super.init()
    }
    
    init(_ other: Attribute) {
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

      attributeType           = other.attributeType
      attributeValueClassName = other.attributeValueClassName
      defaultValue            = other.defaultValue
      valueTransformerName    = other.valueTransformerName

      // get-only: dupe.versionHash = self.versionHash
      allowsExternalBinaryDataStorage =
        other.allowsExternalBinaryDataStorage
      preservesValueInHistoryOnDeletion =
        other.preservesValueInHistoryOnDeletion
      
      _isUnique = other.isUnique
      
      if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
        allowsCloudEncryption = other.allowsCloudEncryption
      }
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    @objc(supportsSecureCoding)
    public class var supportsSecureCoding: Bool { true }
    
    // MARK: - Copying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
      // TBD: unclear whether this is good enough? E.g. what about versionHash?
      Attribute(self)
    }
  }
}


// MARK: - Initializers

public extension Schema.Attribute {

  // SwiftData has this to match the `@Attribute` macro. We can pass in some
  // more data.
  convenience init(_ options: Option..., originalName: String? = nil,
                   hashModifier: String? = nil)
  {
    self.init()
    self.name                = ""
    self.originalName        = originalName ?? ""
    self.valueType           = Any.self
    self.isOptional          = false
    self.versionHashModifier = hashModifier
    setOptions(options)
  }
  
  // The ManagedModels version to match the `@Attribute` macro that can receive
  // a few more datapoints.
  convenience init(_ options: Option..., originalName: String? = nil,
                   hashModifier: String? = nil,
                   name: String, valueType: Any.Type,
                   defaultValue: Any? = nil)
  {
    self.init(name: name, originalName: originalName, options: options,
              valueType: valueType, defaultValue: defaultValue,
              hashModifier: hashModifier)
  }

  convenience init(name: String, originalName: String? = nil,
                   options: [ Option ] = [], valueType: Any.Type,
                   defaultValue: Any? = nil, hashModifier: String? = nil)
  {
    self.init()
    self.name                = name
    self.originalName        = originalName ?? name
    self.defaultValue        = defaultValue
    self.versionHashModifier = hashModifier
    self.isOptional          = valueType is any AnyOptional.Type
    self.valueType           = valueType
    setOptions(options)
  }
}

private extension Schema.Attribute {
  
  func setOptions(_ options: [ Option ]) {
    preservesValueInHistoryOnDeletion = false
    allowsExternalBinaryDataStorage   = false
    isIndexedBySpotlight              = false
    isTransient                       = false
    valueTransformerName              = nil
    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
      allowsCloudEncryption = false
    }

    for option in options {
      switch option.value {
        case .unique:
          isUnique = true
          
        case .preserveValueOnDeletion: preservesValueInHistoryOnDeletion = true
        case .externalStorage: allowsExternalBinaryDataStorage = true
        case .spotlight: isIndexedBySpotlight = true
        case .ephemeral: isTransient = true

        case .transformableByName(let name):
          valueTransformerName = name
        case .transformableByType(let type):
          valueTransformerName = NSStringFromClass(type)

        case .allowsCloudEncryption: // FIXME: restrict availability
          if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            allowsCloudEncryption = true
          }
          else {
            fatalError("Cloud encryption not supported!")
          }
      }
    }
  }
}

