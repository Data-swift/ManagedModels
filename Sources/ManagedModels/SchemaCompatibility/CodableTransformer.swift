//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation
import CoreData

final class CodableTransformer<T: Codable>: ValueTransformer {
  
  #if false
  override class func transformedValueClass() -> AnyClass {
    T.self // doesn't work
  }
  #endif
  override class func allowsReverseTransformation() -> Bool { true }
  
  override func transformedValue(_ value: Any?) -> Any? {
    // value is the box
    guard let value else { return nil }
    guard let typed = value as? T else {
      assertionFailure("Value to be transformed is not the right type? \(value)")
      return nil
    }
    do {
      return try JSONEncoder().encode(typed)
    }
    catch {
      assertionFailure("Could not encode JSON value of property? \(error)")
      return nil
    }
  }

  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let value else { return nil }
    guard let data = value as? Data else {
      assert(value is Data, "Reverse value is not `Data`?")
      return nil
    }
    do {
      return try JSONDecoder().decode(T.self, from: data)
    }
    catch {
      assertionFailure("Could not decode JSON value of property? \(error)")
      return nil
    }
  }
}
