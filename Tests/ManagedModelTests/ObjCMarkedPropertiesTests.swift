//
//  ObjCMarkedPropertiesTests.swift
//  ManagedModels
//
//  Created by Adam Kopeć on 12/02/2025.
//
import XCTest
import Foundation
import CoreData
@testable import ManagedModels

final class ObjCMarkedPropertiesTests: XCTestCase {
    func getAllObjCPropertyNames() -> [String] {
        let classType: AnyClass = Fixtures.AdvancedCodablePropertiesSchema.AdvancedStoredAccess.self
        
        var count: UInt32 = 0
        var properties = [String]()
        class_copyPropertyList(classType, &count)?.withMemoryRebound(to: objc_property_t.self, capacity: Int(count), { pointer in
            var ptr = pointer
            for _ in 0..<count {
                properties.append(String(cString: property_getName(ptr.pointee)))
                ptr = ptr.successor()
            }
            pointer.deallocate()
        })
        
        return properties
    }
    
    func getObjCAttributes(propertyName: String) -> String {
        let classType: AnyClass = Fixtures.AdvancedCodablePropertiesSchema.AdvancedStoredAccess.self

        let property = class_getProperty(classType, propertyName)
        XCTAssertNotNil(property, "Property \(propertyName) not found")
        guard let property else { return "" }
        let attributes = property_getAttributes(property)
        let attributesString = String(cString: attributes!)
        
        return attributesString
    }
    
    func testPropertiesMarkedObjC() {
        let tokenAttributes = getObjCAttributes(propertyName: "token")
        XCTAssertTrue(tokenAttributes.contains("T@\"NSString\""), "Property token is not marked as @objc (\(tokenAttributes))")
        
        let expiresAttributes = getObjCAttributes(propertyName: "expires")
        XCTAssertTrue(expiresAttributes.contains("T@\"NSDate\""), "Property expires is not marked as @objc (\(expiresAttributes))")
        
        let integerAttributes = getObjCAttributes(propertyName: "integer")
        XCTAssertTrue(!integerAttributes.isEmpty, "Property integer is not marked as @objc (\(integerAttributes))")
        
        let arrayAttributes = getObjCAttributes(propertyName: "array")
        XCTAssertTrue(arrayAttributes.contains("T@\"NSArray\""), "Property array is not marked as @objc (\(arrayAttributes))")
        
        let array2Attributes = getObjCAttributes(propertyName: "array2")
        XCTAssertTrue(arrayAttributes.contains("T@\"NSArray\""), "Property array2 is not marked as @objc (\(array2Attributes))")
        
        let numArrayAttributes = getObjCAttributes(propertyName: "numArray")
        XCTAssertTrue(numArrayAttributes.contains("T@\"NSArray\""), "Property numArray is not marked as @objc (\(numArrayAttributes))")
        
        let optionalArrayAttributes = getObjCAttributes(propertyName: "optionalArray")
        XCTAssertTrue(optionalArrayAttributes.contains("T@\"NSArray\""), "Property optionalArray is not marked as @objc (\(optionalArrayAttributes))")
        
        let optionalArray2Attributes = getObjCAttributes(propertyName: "optionalArray2")
        XCTAssertTrue(optionalArray2Attributes.contains("T@\"NSArray\""), "Property optionalArray2 is not marked as @objc (\(optionalArray2Attributes))")
        
        let optionalNumArrayAttributes = getObjCAttributes(propertyName: "optionalNumArray")
        XCTAssertTrue(optionalNumArrayAttributes.contains("T@\"NSArray\""), "Property optionalNumArray is not marked as @objc (\(optionalNumArrayAttributes))")
        
        let optionalNumArray2Attributes = getObjCAttributes(propertyName: "optionalNumArray2")
        XCTAssertTrue(optionalNumArray2Attributes.contains("T@\"NSArray\""), "Property optionalNumArray2 is not marked as @objc (\(optionalNumArray2Attributes))")
        
        let objcSetAttributes = getObjCAttributes(propertyName: "objcSet")
        XCTAssertTrue(objcSetAttributes.contains("T@\"NSSet\""), "Property objcSet is not marked as @objc (\(objcSetAttributes))")
    }
}
