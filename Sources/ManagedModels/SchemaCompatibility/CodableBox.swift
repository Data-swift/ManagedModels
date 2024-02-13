//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import CoreData

/**
 * Helper object to store arbitrary Codable Swift types in a CoreData
 * property.
 */
final class CodableBox<T: Codable>: NSObject, NSCopying {
  // Inspired by @radianttap
  
  var value : T?
  
  init(_ value: T) { self.value = value }
  
  private init(_ value: T?) { self.value = value }

  private init?(data: Data) {
    do {
      value = try JSONDecoder().decode(T.self, from: data)
    }
    catch {
      assertionFailure("Could not decode JSON value of property? \(error)")
      value = nil
    }
  }
  
  func copy(with zone: NSZone? = nil) -> Any { CodableBox<T>(self.value) }
  
  var data : Data? {
    set {
      guard let data = newValue else {
        value = nil
        return
      }
      do {
        value = try JSONDecoder().decode(T.self, from: data)
      }
      catch {
        assertionFailure("Could not decode JSON value of property? \(error)")
        value = nil
      }
    }
    get {
      guard let value else { return nil }
      do {
        return try JSONEncoder().encode(value)
      }
      catch {
        assertionFailure("Could not encode JSON value of property? \(error)")
        return nil
      }
    }
  }
  
  final class Transformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
      CodableBox<T>.self
    }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
      // value is the box
      guard let value else { return nil }
      guard let typed = value as? CodableBox<T> else {
        assertionFailure("Value to be transformed is not the box? \(value)")
        return nil
      }
      return typed.data
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
      guard let value else { return nil }
      guard let data = value as? Data else { return nil }
      return CodableBox<T>(data: data)
    }
  }
}
