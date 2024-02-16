//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

import XCTest
import Foundation
import CoreData
@testable import ManagedModels

final class CodableRawRepresentableTests: XCTestCase {
  // https://github.com/Data-swift/ManagedModels/issues/29
  
  private lazy var container = try? ModelContainer(
    for: Fixtures.ToDoListSchema.managedObjectModel,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
  )
  
  func testEntityName() throws {
    _ = container // required to register the entity type mapping
    let entityType = Fixtures.ToDoListSchema.ToDo.self
    XCTAssertEqual(entityType.entity().name, "ToDo")
  }
  
  func testPropertySetup() throws {
    let valueType = Fixtures.ToDoListSchema.ToDo.Priority.self
    let attribute = CoreData.NSAttributeDescription(
      name: "priority",
      valueType: valueType,
      defaultValue: nil
    )
    XCTAssertEqual(attribute.name, "priority")
    XCTAssertEqual(attribute.attributeType, .integer64AttributeType)

    XCTAssertTrue(attribute.valueType == Int.self)
    XCTAssertNil(attribute.valueTransformerName)
  }
  
  func testModel() throws {
    _ = container // required to register the entity type mapping
    let todo = Fixtures.ToDoListSchema.ToDo()
    todo.priority = .high
  }
}
