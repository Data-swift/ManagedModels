//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension CoreData.NSAttributeDescription {
  struct TypeConfiguration {
    let attributeType           : NSAttributeType
    let isOptional              : Bool
    let attributeValueClassName : String
  }
}

/**
 * Implemented by types that can be directly converted to the primitive values
 * CoreData supports.
 */
public protocol CoreDataPrimitiveValue {
  
  static var coreDataValue : NSAttributeDescription.TypeConfiguration { get }
}

extension Optional: CoreDataPrimitiveValue
  where Wrapped: CoreDataPrimitiveValue
{
  public static var coreDataValue : NSAttributeDescription.TypeConfiguration {
    .init(attributeType: Wrapped.coreDataValue.attributeType,
          isOptional: true,
          attributeValueClassName: Wrapped.coreDataValue.attributeValueClassName
    )
  }
}

extension Int: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .integer64AttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}
extension Int16: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .integer16AttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}
extension Int32: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .integer32AttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}
extension Int64: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .integer64AttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}
extension Int8: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .integer16AttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}

extension UInt: CoreDataPrimitiveValue { // edgy
  public static let coreDataValue = Int64.coreDataValue
}
extension UInt64: CoreDataPrimitiveValue { // edgy
  public static let coreDataValue = Int64.coreDataValue
}

extension UInt32: CoreDataPrimitiveValue {
  public static let coreDataValue = Int64.coreDataValue
}
extension UInt16: CoreDataPrimitiveValue {
  public static let coreDataValue = Int32.coreDataValue
}
extension UInt8: CoreDataPrimitiveValue {
  public static let coreDataValue = Int16.coreDataValue
}


extension String: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .stringAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSString"
  )
}

extension Bool: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .booleanAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}

extension Double: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .doubleAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}
extension Float: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .floatAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSNumber"
  )
}

// MARK: - Foundation

extension Date: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .dateAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSDate"
  )
}

extension Data: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .binaryDataAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSDate"
  )
}

extension Decimal: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .decimalAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSDecimalNumber"
  )
}

extension UUID: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .UUIDAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSUUID"
  )
}

extension URL: CoreDataPrimitiveValue {
  public static let coreDataValue = NSAttributeDescription.TypeConfiguration(
    attributeType           : .URIAttributeType,
    isOptional              : false,
    attributeValueClassName : "NSURL"
  )
}
