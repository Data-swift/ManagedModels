//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension CoreData.NSAttributeDescription {
  
  func internalCopy() -> Self {
    guard let copy = self.copy() as? Self else {
      fatalError("Could not copy attribute \(self)")
    }
    assert(copy !== self, "Copy didn't produce a copy?")
    
    // Ensure copy of unique marker
    if isUnique { copy.isUnique = true }
    return copy
  }
}

@available(iOS 11.0, *) // could backport further
extension CoreData.NSAttributeDescription: SchemaProperty {

  public var valueType: Any.Type {
    get {
      var attributeValueType: Any.Type? {
        guard let attributeValueClassName else { return nil }
        return NSClassFromString(attributeValueClassName)
      }

      switch attributeType { // FIXME: return Int for 32bit
        case .integer16AttributeType  :
          if isOptional { return Int16?  .self } else { return Int16 .self }
        case .integer32AttributeType  :
          if isOptional { return Int32?  .self } else { return Int32 .self }
        case .integer64AttributeType  :
          if isOptional { return Int?    .self } else { return Int   .self }
        case .decimalAttributeType    :
          if isOptional { return Decimal?.self } else { return Decimal.self }
        case .doubleAttributeType     :
          if isOptional { return Double? .self } else { return Double.self }
        case .floatAttributeType      :
          if isOptional { return Float?  .self } else { return Float .self }
        case .stringAttributeType     :
          if isOptional { return String? .self } else { return String.self }
        case .booleanAttributeType    :
          if isOptional { return Bool?   .self } else { return Bool  .self }
        case .dateAttributeType       :
          if isOptional { return Date?   .self } else { return Date  .self }
        case .binaryDataAttributeType :
          if isOptional { return Data?   .self } else { return Data  .self }
        case .UUIDAttributeType       :
          if isOptional { return UUID?   .self } else { return UUID  .self }
        case .URIAttributeType        :
          if isOptional { return URL?.self } else { return URL.self }
        case .undefinedAttributeType, .transformableAttributeType,
             .objectIDAttributeType:
          return attributeValueType ?? Any.self
        default: // for composite
          return attributeValueType ?? Any.self
      }
    }
    set {
      if newValue == Int.self {
        self.attributeType           = .integer64AttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Int?.self {
        self.attributeType           = .integer64AttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == String.self {
        self.attributeType           = .stringAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSString"
      }
      else if newValue == String?.self {
        self.attributeType           = .stringAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSString"
      }
      else if newValue == Bool.self {
        self.attributeType           = .booleanAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Bool?.self {
        self.attributeType           = .booleanAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Double.self {
        self.attributeType           = .doubleAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Double?.self {
        self.attributeType           = .doubleAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Date.self {
        self.attributeType           = .dateAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSDate"
      }
      else if newValue == Date?.self {
        self.attributeType           = .dateAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSDate"
      }
      else if newValue == Data.self {
        self.attributeType           = .binaryDataAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSDate"
      }
      else if newValue == Data?.self {
        self.attributeType           = .binaryDataAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSDate"
      }
      else if newValue == Float.self {
        self.attributeType           = .floatAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Float?.self {
        self.attributeType           = .floatAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Decimal.self {
        self.attributeType           = .decimalAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSDecimalNumber"
      }
      else if newValue == Decimal?.self {
        self.attributeType           = .decimalAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSDecimalNumber"
      }
      else if newValue == UUID.self {
        self.attributeType           = .UUIDAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSUUID"
      }
      else if newValue == UUID?.self {
        self.attributeType           = .UUIDAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSUUID"
      }
      else if newValue == URL.self {
        self.attributeType           = .URIAttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSURL"
      }
      else if newValue == URL?.self {
        self.attributeType           = .URIAttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSURL"
      }
      else if newValue == Int16.self {
        self.attributeType           = .integer16AttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Int16?.self {
        self.attributeType           = .integer16AttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Int32.self {
        self.attributeType           = .integer32AttributeType
        self.isOptional              = false
        self.attributeValueClassName = "NSNumber"
      }
      else if newValue == Int32?.self {
        self.attributeType           = .integer32AttributeType
        self.isOptional              = true
        self.attributeValueClassName = "NSNumber"
      }
      else {
        // TBD:
        // undefinedAttributeType = 0
        // transformableAttributeType = 1800
        // objectIDAttributeType = 2000
        // compositeAttributeType = 2100
      }
    }
  }

  @inlinable public var isAttribute    : Bool { return true  }
  @inlinable public var isRelationship : Bool { return false }

  public var options : [ Option ] {
    // TBD:
    // - ephemeral (stored in entity?!)
    var options = [ Option ]()
    if preservesValueInHistoryOnDeletion {
      options.append(.preserveValueOnDeletion)
    }
    if allowsExternalBinaryDataStorage { options.append(.externalStorage) }
    if isIndexedBySpotlight            { options.append(.spotlight)       }
    if isUnique                        { options.append(.unique)          }
    if isTransient                     { options.append(.ephemeral)       }
    
    if let valueTransformerName, !valueTransformerName.isEmpty {
      options.append(.transformable(by: valueTransformerName))
    }

    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
      if allowsCloudEncryption { options.append(.allowsCloudEncryption) }
    }
    return options
  }
}


// MARK: - Initializers

public extension NSAttributeDescription {

  // SwiftData has this to match the `@Attribute` macro. We can pass in some
  // more data.
  convenience init(_ options: Option..., originalName: String? = nil,
                   hashModifier: String? = nil)
  {
    self.init()
    if let originalName { renamingIdentifier  = originalName }
    if let hashModifier { versionHashModifier = hashModifier }
    setOptions(options)
  }
  
  // The ManagedModels version to match the `@Attribute` macro that can receive
  // a few more datapoints.
  convenience init(_ options: Option..., originalName: String? = nil,
                   hashModifier: String? = nil,
                   defaultValue: Any? = nil,
                   name: String, valueType: Any.Type)
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
    if !name.isEmpty { self.name = name }
    if let originalName { renamingIdentifier  = originalName }
    if let hashModifier { versionHashModifier = hashModifier }
    if let defaultValue { self.defaultValue   = defaultValue }
    isOptional = valueType is any AnyOptional.Type
    if valueType != Any.self { self.valueType = valueType }
    setOptions(options)
  }
}

private extension NSAttributeDescription {
  
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
