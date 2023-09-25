//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
import CoreData
import SwiftUI
@testable import ManagedModels

final class FetchRequestTests: SwiftUITestCase {
  
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

    do {
      try context.save()
    }
    catch {
      print("Error:", error) // throws nilError
      XCTAssert(false, "Error thrown")
    }
    return context
  }()
  
  func testFetchRequest() throws {
    let context = try XCTUnwrap(context)

    let fetchRequest = Address.fetchRequest()
    let models       = try context.fetch(fetchRequest)
    XCTAssertEqual(models.count, 3)
  }

  func testFetchCount() throws {
    let context = try XCTUnwrap(context)
    
    class TestResults {
      var fetchedCount = 0
    }
    
    struct TestView: View {
      let results     : TestResults
      let expectation : XCTestExpectation
      
      @FetchRequest(
        sortDescriptors: [
          NSSortDescriptor(keyPath: \Address.appartment, ascending: true)
        ],
        animation: .none
      )
      private var values: FetchedResults<Address>

      var body: Text { // This must NOT be an `EmptyView`!
        results.fetchedCount = values.count
        expectation.fulfill()
        return Text(verbatim: "Dummy")
      }
    }
    
    let expectation = XCTestExpectation(description: "Test Query Count")
    let results = TestResults()
    let view = TestView(results: results, expectation: expectation)
      .modelContext(context)
    
    try constructView(view, waitingFor: expectation)
    
    XCTAssertEqual(results.fetchedCount, 3)
  }
}
