//
//  TransformablePropertiesTests.swift
//  Created by Adam Kopeć on 11/02/2024.
//

import XCTest
import Foundation
import CoreData
@testable import ManagedModels

final class TransformablePropertiesTests: XCTestCase {
    
    private let container = try? ModelContainer(
        for: Fixtures.TransformablePropertiesSchema.managedObjectModel,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    func testEntityName() throws {
        let entityType = Fixtures.TransformablePropertiesSchema.StoredAccess.self
        XCTAssertEqual(entityType.entity().name, "StoredAccess")
    }
    
    func testPropertySetup() throws {
        let valueType = Fixtures.TransformablePropertiesSchema.AccessSIP.self
        let attribute = CoreData.NSAttributeDescription(
            name: "sip",
            options: [.transformable(by: Fixtures.TransformablePropertiesSchema.AccessSIPTransformer.self)],
            valueType: valueType,
            defaultValue: nil
        )
        XCTAssertEqual(attribute.name, "sip")
        XCTAssertEqual(attribute.attributeType, .transformableAttributeType)
        
        let transformerName = try XCTUnwrap(
            ValueTransformer.valueTransformerNames().first(where: {
                $0.rawValue.range(of: "AccessSIPTransformer")
                != nil
            })
        )
        let transformer = try XCTUnwrap(ValueTransformer(forName: transformerName))
        _ = transformer // to clear unused-wraning
        
        XCTAssertTrue(attribute.valueType ==
                      NSObject.self)
        XCTAssertNotNil(attribute.valueTransformerName)
        XCTAssertEqual(attribute.valueTransformerName, transformerName.rawValue)
    }
    
    func testTransformablePropertyEntity() throws {
        let entity = try XCTUnwrap(
            container?.managedObjectModel.entitiesByName["StoredAccess"]
        )
        
        // Creating the entity should have registered the transformer for the
        // CodableBox.
        let transformerName = try XCTUnwrap(
            ValueTransformer.valueTransformerNames().first(where: {
                $0.rawValue.range(of: "AccessSIPTransformer")
                != nil
            })
        )
        let transformer = try XCTUnwrap(ValueTransformer(forName: transformerName))
        _ = transformer // to clear unused-wraning
        
        let attribute = try XCTUnwrap(entity.attributesByName["sip"])
        XCTAssertEqual(attribute.name, "sip")
        XCTAssertTrue(attribute.valueType ==
                      NSObject.self)
        XCTAssertNotNil(attribute.valueTransformerName)
        XCTAssertEqual(attribute.valueTransformerName, transformerName.rawValue)
    }
}
