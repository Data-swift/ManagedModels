//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

extension NSAttributeType {
  
  func swiftBaseType(isOptional: Bool) -> Any.Type? {
    switch self { // FIXME: return Int for 32bit
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
        return nil
      default: // for composite
        return nil
    }
  }
}
