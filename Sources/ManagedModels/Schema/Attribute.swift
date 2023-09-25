//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension Schema {
  
  typealias Attribute = CoreData.NSAttributeDescription
}


// MARK: - Initializers

public extension Schema.Attribute {

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
    if !name.isEmpty { self.name = name }
    if let originalName { renamingIdentifier  = originalName }
    if let hashModifier { versionHashModifier = hashModifier }
    if let defaultValue { self.defaultValue   = defaultValue }
    isOptional = valueType is any AnyOptional.Type
    if valueType != Any.self { self.valueType = valueType }
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

