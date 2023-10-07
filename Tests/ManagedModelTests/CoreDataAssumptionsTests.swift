//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
import CoreData
@testable import ManagedModels

final class CoreDataAssumptionsTests: XCTestCase {
  
  func testRelationshipDefaults() throws {
    let relationship = NSRelationshipDescription()
    XCTAssertEqual(relationship.minCount, 0)
    XCTAssertEqual(relationship.maxCount, 0)
    XCTAssertEqual(relationship.deleteRule, .nullifyDeleteRule)
  }
  
  func testToManySetup() throws {
    let relationship = NSRelationshipDescription()
    relationship.name = "addresses"
    //relationship.destinationEntity =
    //  Fixtures.PersonAddressSchema.Address.entity()
    //relationship.inverseRelationship =
    //  Fixtures.PersonAddressSchema.Address.entity().relationshipsByName["person"]
    
    // This just seems to be the default.
    XCTAssertTrue(relationship.isToMany)
  }
  
  func testToOneSetup() throws {
    let relationship = NSRelationshipDescription()
    relationship.name     = "person"
    relationship.maxCount = 1 // toOne marker!
    #if false // old
    relationship.destinationEntity =
      Fixtures.PersonAddressSchema.Person.entity()
    #endif
    XCTAssertFalse(relationship.isToMany)
  }
  
  func testAttributeCopying() throws {
    let attribute = NSAttributeDescription()
    attribute.name = "Hello"
    attribute.attributeValueClassName = "NSNumber"
    attribute.attributeType = .integer32AttributeType
    
    let copiedAttribute =
      try XCTUnwrap(attribute.copy() as? NSAttributeDescription)
    XCTAssertFalse(attribute === copiedAttribute)
    XCTAssertEqual(attribute.name, copiedAttribute.name)
    XCTAssertEqual(attribute.attributeValueClassName,
                   copiedAttribute.attributeValueClassName)
    XCTAssertEqual(attribute.attributeType, copiedAttribute.attributeType)
  }
  
  func testRelationshipCopying() throws {
    let relationship = NSRelationshipDescription()
    relationship.name = "Hello"
    relationship.isOrdered = true
    relationship.maxCount = 10
    
    let copiedRelationship =
      try XCTUnwrap(relationship.copy() as? NSRelationshipDescription)
    XCTAssertFalse(relationship === copiedRelationship)
    XCTAssertEqual(relationship.name, copiedRelationship.name)
    XCTAssertEqual(relationship.isOrdered, copiedRelationship.isOrdered)
    XCTAssertEqual(relationship.maxCount, copiedRelationship.maxCount)
  }
}
