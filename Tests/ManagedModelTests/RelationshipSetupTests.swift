//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
import CoreData
import SwiftUI
@testable import ManagedModels

final class RelationshipSetupTests: SwiftUITestCase {
  
  typealias TestSchema = Fixtures.PersonAddressSchema
  typealias Person     = TestSchema.Person
  typealias Address    = TestSchema.Address

  private let context : ModelContext? = { () -> ModelContext? in
    guard let container = try? ModelContainer(
      for: TestSchema.managedObjectModel,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) else { return nil }
    // let context = ModelContext(concurrencyType: .mainQueueConcurrencyType)
    let context = container.mainContext
    XCTAssertFalse(context.autosaveEnabled) // still seems to be on?
    return context
  }()
  
  func testToManyFill() throws {
    let donald : Person
    do {
      let person = Person(context: context)
      person.firstname = "Donald"
      person.lastname  = "Duck"
      person.addresses = []
      donald = person
    }

    do {
      let address = Address(context: context)
      address.appartment = "404"
      address.street     = "Am Geldspeicher 1"
      address.person     = donald
    }
    do {
      let address = Address(context: context)
      address.appartment = "409"
      address.street     = "Dusseldorfer Straße 10"
      address.person     = donald
    }
    do {
      let address = Address(context: context)
      address.appartment = "204"
      address.street     = "No Content 4"
      address.person     = donald
    }

    XCTAssertEqual(donald.addresses.count, 3)
  }
  
  func testToOneFill() throws {
    let person = Person(context: context)
    person.firstname = "Donald"
    person.lastname  = "Duck"

    let address = Address(context: context)
    address.appartment = "404"
    address.street     = "Am Geldspeicher 1"
    person.addresses   = [ address ]

    XCTAssertEqual(person.addresses.count, 1)
  }
}
