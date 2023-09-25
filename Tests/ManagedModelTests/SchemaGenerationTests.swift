//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
import CoreData
@testable import ManagedModels

final class SchemaGenerationTests: XCTestCase {
  
  typealias TestSchemaExpanded = Fixtures.ExpandedPersonAddressSchema
  typealias TestSchemaNoInverseToOne = Fixtures.PersonAddressSchemaNoInverse
  
  func testEntityGeneration() throws {
    let personModelType = try XCTUnwrap(TestSchemaExpanded.models.first)
    XCTAssertTrue(personModelType == TestSchemaExpanded.Person.self)
    
    let person = NSEntityDescription(personModelType)
    XCTAssertEqual(person.attributes.count, 2)
    XCTAssertEqual(person.relationships.count, 1)
    
    let firstname   = try XCTUnwrap(person.attributesByName["firstname"])
    let lastname    = try XCTUnwrap(person.attributesByName["lastname"])
    let toAddresses = try XCTUnwrap(person.relationshipsByName["addresses"])
    XCTAssertFalse(firstname.isTransient)
    XCTAssertFalse(lastname.isRelationship)
    XCTAssertTrue (toAddresses.isRelationship)
    XCTAssertFalse(toAddresses.isToOneRelationship)
    
    // Those can't be setup yet.
    XCTAssertTrue(toAddresses.destination.isEmpty)
    XCTAssertNil(toAddresses.inverseName)
    XCTAssertNil(toAddresses.inverseKeyPath) // could be provided by macro
  }
  
  func testSchemaGeneration() throws {
    let cache  = SchemaBuilder()
    let schema = NSManagedObjectModel(versionedSchema: TestSchemaExpanded.self,
                                      schemaCache: cache)
    
    XCTAssertEqual(schema.entities.count, 2)
    XCTAssertEqual(schema.entitiesByName.count, 2)
    
    let person  = try XCTUnwrap(schema.entitiesByName["Person"])
    let address = try XCTUnwrap(schema.entitiesByName["Address"])
    
    XCTAssertEqual(person.attributes.count, 2)
    XCTAssertEqual(person.relationships.count, 1)
    let firstname   = try XCTUnwrap(person.attributesByName["firstname"])
    let lastname    = try XCTUnwrap(person.attributesByName["lastname"])
    let toAddresses = try XCTUnwrap(person.relationshipsByName["addresses"])
    XCTAssertFalse (firstname.isTransient)
    XCTAssertFalse (lastname.isRelationship)
    XCTAssertTrue  (toAddresses.isRelationship)
    XCTAssertFalse (toAddresses.isToOneRelationship)
    XCTAssertEqual (toAddresses.destination, "Address")
    XCTAssertNotNil(toAddresses.destinationEntity)

    XCTAssertEqual(address.attributes.count, 2)
    XCTAssertEqual(address.relationships.count, 1)
    let toPerson = try XCTUnwrap(address.relationshipsByName["person"])
    XCTAssertTrue (toPerson.isRelationship)
    XCTAssertTrue (toPerson.isToOneRelationship)
    XCTAssertEqual(toPerson.destination, "Person")

    XCTAssertTrue(toAddresses.destinationEntity === address)
    XCTAssertTrue(toPerson   .destinationEntity === person)

    XCTAssertEqual(toPerson   .inverseName, "addresses")
    XCTAssertEqual(toAddresses.inverseName, "person")
    XCTAssertTrue (toAddresses.keypath        == toPerson.inverseKeyPath)
    XCTAssertTrue (toAddresses.inverseKeyPath == toPerson.keypath)
  }
  
  func testMissingInverse() throws {
    let cache = SchemaBuilder()
    
    // First the address
    let address = try XCTUnwrap(
      cache._entity(for: TestSchemaNoInverseToOne.Address.self))

    // Then the person
    let person = try XCTUnwrap(
      cache._entity(for: TestSchemaNoInverseToOne.Person.self))
    
    let toAddresses = try XCTUnwrap(person.relationshipsByName["addresses"])
    XCTAssertTrue  (toAddresses.isRelationship)
    XCTAssertFalse (toAddresses.isToOneRelationship)
    XCTAssertEqual (toAddresses.destination, "Address")
    XCTAssertNotNil(toAddresses.destinationEntity) // still nil

    XCTAssertEqual(address.attributes.count, 2)
    XCTAssertTrue (address.relationships.isEmpty)
    XCTAssertNil  (address.relationshipsByName["person"])
    
    XCTAssertTrue (toAddresses.destinationEntity === address)
  }
  
  func testUnique() throws {
    let personModelType = Fixtures.UniquePerson.self
    
    let person = Schema.Entity(personModelType)
    XCTAssertEqual(person.attributes.count, 2)
    
    let firstname = try XCTUnwrap(person.attributesByName["firstname"])
    let lastname  = try XCTUnwrap(person.attributesByName["lastname"])
    
    XCTAssertTrue (firstname.isUnique)
    XCTAssertFalse(firstname.isTransient)
    XCTAssertFalse(firstname.isOptional)

    XCTAssertFalse(lastname.isUnique)
    XCTAssertFalse(lastname.isTransient)
    XCTAssertFalse(lastname.isRelationship)
  }
  
  func testMOM() throws {
    let mom = Fixtures.PersonAddressMOM
    XCTAssertEqual(mom.entities.count, 2)
    XCTAssertNotNil(mom.entitiesByName["Person"])
    XCTAssertNotNil(mom.entitiesByName["Address"])
  }
}
