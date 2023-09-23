//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

/**
 * A helper to implement freezing model objects. To detect unintended late
 * modification.
 */
@objc protocol FinalizableObject: NSObjectProtocol {
  var isFinalized : Bool { get set }
  func markAsFinalized()
}

// This won't grow unbounded, only used for schema objects
private let lock = NSLock()
private var finalizedObjects = Set<ObjectIdentifier>()

@objc extension NSEntityDescription {
  
  var isFinalized : Bool {
    set {
      lock.lock(); defer { lock.unlock() }
      finalizedObjects.insert(ObjectIdentifier(self))
    }
    get {
      lock.lock(); defer { lock.unlock() }
      return finalizedObjects.contains(ObjectIdentifier(self))
    }
  }
}

@objc extension NSPropertyDescription {

  func markAsFinalized() { isFinalized = true }
  
  var isFinalized : Bool {
    set {
      lock.lock(); defer { lock.unlock() }
      finalizedObjects.insert(ObjectIdentifier(self))
    }
    get {
      lock.lock(); defer { lock.unlock() }
      return finalizedObjects.contains(ObjectIdentifier(self))
    }
  }
}

extension FinalizableObject {
  
  func ensureNotFinalized(file: StaticString = #file, line: UInt = #line) {
    precondition(!isFinalized,
                 "Attempt to modify finalized object \(self)",
                 file: file, line: line)

  }
}
