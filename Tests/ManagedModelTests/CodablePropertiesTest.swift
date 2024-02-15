//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

import XCTest
import Foundation
import CoreData
@testable import ManagedModels

final class CodablePropertiesTests: XCTestCase {

  private lazy var container = try? ModelContainer(
    for: Fixtures.CodablePropertiesSchema.managedObjectModel,
    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
  )
  
  func testEntityName() throws {
    let entityType = Fixtures.CodablePropertiesSchema.StoredAccess.self
    XCTAssertEqual(entityType.entity().name, "StoredAccess")
  }
  
  func testPropertySetup() throws {
    let valueType = Fixtures.CodablePropertiesSchema.AccessSIP.self
    let attribute = CoreData.NSAttributeDescription(
      name: "sip",
      valueType: valueType,
      defaultValue: nil
    )
    XCTAssertEqual(attribute.name, "sip")
    XCTAssertEqual(attribute.attributeType, .transformableAttributeType)

    let transformerName = try XCTUnwrap(
      ValueTransformer.valueTransformerNames().first(where: {
        $0.rawValue.range(of: "CodableTransformerVOO17ManagedModelTests8")
        != nil
      })
    )
    let transformer = try XCTUnwrap(ValueTransformer(forName: transformerName))
    _ = transformer // to clear unused-wraning

    XCTAssertTrue(attribute.valueType == Any.self)
                  // Fixtures.CodablePropertiesSchema.AccessSIP.self
    XCTAssertNotNil(attribute.valueTransformerName)
    XCTAssertEqual(attribute.valueTransformerName, transformerName.rawValue)
  }
  
  func testCodablePropertyEntity() throws {
    let entity = try XCTUnwrap(
      container?.managedObjectModel.entitiesByName["StoredAccess"]
    )

    // Creating the entity should have registered the transformer for the
    // CodableBox.
    let transformerName = try XCTUnwrap(
      ValueTransformer.valueTransformerNames().first(where: {
        $0.rawValue.range(of: "CodableTransformerVOO17ManagedModelTests8")
        != nil
      })
    )
    let transformer = try XCTUnwrap(ValueTransformer(forName: transformerName))
    _ = transformer // to clear unused-wraning

    let attribute = try XCTUnwrap(entity.attributesByName["sip"])
    XCTAssertEqual(attribute.name, "sip")
    XCTAssertTrue(attribute.valueType == Any.self)
                  // Fixtures.CodablePropertiesSchema.AccessSIP.self)
    XCTAssertNotNil(attribute.valueTransformerName)
    XCTAssertEqual(attribute.valueTransformerName, transformerName.rawValue)
  }
}
