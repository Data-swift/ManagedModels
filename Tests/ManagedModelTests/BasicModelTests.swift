//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
import CoreData
@testable import ManagedModels

final class BasicModelTests: XCTestCase {

  let container = try? ModelContainer(
    for: Fixtures.PersonAddressSchema.managedObjectModel,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
  )
  
  func testEntityName() throws {
    let addressType = Fixtures.PersonAddressSchema.Address.self
    XCTAssertEqual(addressType._$entity.name, "Address")
    XCTAssertEqual(addressType.entity().name, "Address")
  }

  func testPersonTemporaryPersistentIdentifier() throws {
    let newAddress = Fixtures.PersonAddressSchema.Person()

    let id : NSManagedObjectID = newAddress.persistentModelID
    XCTAssertEqual(id.entityName, "Person")
    XCTAssertNil(id.storeIdentifier) // isTemporary!

    // Note: "t" prefix for `isTemporary`, "p" is primary key, e.g. p73
    // - also registered as the primary key
    // "x-coredata:///Person/t4DA54E01-0940-45F4-9E16-956E3C7993B52"
    let url = id.uriRepresentation()
    XCTAssertEqual(url.scheme, "x-coredata")
    XCTAssertNil(url.host) // not store assigned
    XCTAssertTrue(url.path.hasPrefix("/Person/t")) // <= "t" is temporary!
  }

  func testAddressTemporaryPersistentIdentifier() throws {
    // Failed to call designated initializer on NSManagedObject class
    // '_TtCOO17ManagedModelTests8Fixtures19PersonAddressSchema7Address'
    let newAddress = Fixtures.PersonAddressSchema.Address()

    let id : NSManagedObjectID = newAddress.persistentModelID
    XCTAssertEqual(id.entityName, "Address")
    XCTAssertNil(id.storeIdentifier) // isTemporary!

    // Note: "t" prefix for `isTemporary`, "p" is primary key, e.g. p73
    // - also registered as the primary key
    // "x-coredata:///Address/t4DA54E01-0940-45F4-9E16-956E3C7993B52"
    let url = id.uriRepresentation()
    XCTAssertEqual(url.scheme, "x-coredata")
    XCTAssertNil(url.host) // not store assigned
    XCTAssertTrue(url.path.hasPrefix("/Address/t")) // <= "t" is temporary!
  }
}
