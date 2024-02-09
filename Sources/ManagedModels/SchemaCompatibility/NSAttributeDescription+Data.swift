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
    // TBD: we might actually want to hold on to the type in an assoc prop!
    // Though I'm not sure we actually need it. Maybe we should always convert
    // down to the CoreData base type for _this_ particular property.
    // Its primary use is when the entity builder sets the type from the macro
    // during construction.
    get {
      if let baseType = attributeType.swiftBaseType(isOptional: isOptional) {
        return baseType
      }
      guard let attributeValueClassName else { return Any.self }
      return NSClassFromString(attributeValueClassName) ?? Any.self
    }
    set {
      // Note: This needs to match up w/ PersistentModel+KVC.
      
      if let primitiveType = newValue as? CoreDataPrimitiveValue.Type {
        let config = primitiveType.coreDataValue
        self.attributeType           = config.attributeType
        self.isOptional              = config.isOptional
        if let newClassName = config.attributeValueClassName {
          self.attributeValueClassName = newClassName
        }
        return
      }
      
      // This requires iOS 16:
      //   RawRepresentable<CoreDataPrimitiveValue>
      if let rawType = newValue as? any RawRepresentable.Type {
        func setIt<T: RawRepresentable>(for type: T.Type) -> Bool {
          let rawType = type.RawValue.self
          if let primitiveType = rawType as? CoreDataPrimitiveValue.Type {
            let config = primitiveType.coreDataValue
            self.attributeType           = config.attributeType
            self.isOptional              = config.isOptional
            if let newClassName = config.attributeValueClassName {
              self.attributeValueClassName = newClassName
            }
            return true
          }
          else {
            return false
          }
        }
        if setIt(for: rawType) { return }
      }
      
      if let codableType = newValue as? any Codable.Type {
        // TBD: Someone tell me whether this is sensible.
        self.attributeType = .transformableAttributeType
        self.isOptional    = newValue is any AnyOptional.Type
        
        func setValueClassName<T: Codable>(for type: T.Type) {
          self.attributeValueClassName = NSStringFromClass(CodableBox<T>.self)
          
          let name = NSStringFromClass(CodableBox<T>.Transformer.self)
          if !ValueTransformer.valueTransformerNames().contains(.init(name)) {
            // no access to valueTransformerForName?
            let transformer = CodableBox<T>.Transformer()
            ValueTransformer
              .setValueTransformer(transformer, forName: .init(name))
          }
          valueTransformerName = name
        }
        setValueClassName(for: codableType)
        return
      }

      // TBD:
      // undefinedAttributeType = 0
      // transformableAttributeType = 1800
      // objectIDAttributeType = 2000
      // compositeAttributeType = 2100
      assertionFailure("Unsupported Attribute value type \(newValue)")
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
