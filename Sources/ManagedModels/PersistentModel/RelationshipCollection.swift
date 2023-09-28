//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

/**
 * An optional or non-optional relationship collection.
 */
public protocol RelationshipCollection {

  associatedtype PersistentElement: PersistentModel
  
  init(coreDataAnySet: Set<AnyHashable>?)
  var coreDataAnySet : Set<AnyHashable>? { get }
}

#if false // see Utilities, doesn't fly yet.
extension OrderedSet: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
}
#endif

extension Set: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
  
  @inlinable
  public init(coreDataAnySet: Set<AnyHashable>?) {
    assert(coreDataAnySet == nil || coreDataAnySet is Self, "Type mismatch.")
    self = coreDataAnySet as? Self ?? Set()
  }
  @inlinable
  public var coreDataAnySet : Set<AnyHashable>? { self }
}

extension Array: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
  
  @inlinable
  public init(coreDataAnySet: Set<AnyHashable>?) {
    assert(coreDataAnySet == nil || coreDataAnySet is Set<PersistentElement>,
           "Type mismatch.")
    self.init(coreDataAnySet as! Set<PersistentElement>)
  }
  @inlinable
  public var coreDataAnySet : Set<AnyHashable>? { Set(self) }
}

// Note: This is not any optional, it is an optional collection! (toMany)
extension Optional: RelationshipCollection
  where Wrapped: Sequence & RelationshipCollection, Wrapped.Element: PersistentModel
{
  public typealias PersistentElement = Wrapped.Element
  
  @inlinable
  public init(coreDataAnySet: Set<AnyHashable>?) {
    if let coreDataAnySet {
      self = .some(.init(coreDataAnySet: coreDataAnySet))
    }
    else {
      self = .none
    }
  }
  @inlinable
  public var coreDataAnySet : Set<AnyHashable>? {
    switch self {
      case .none: return nil
      case .some(let value): return value.coreDataAnySet
    }
  }
}
