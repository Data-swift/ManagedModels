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
}

#if false // see Utilities, doesn't fly yet.
extension OrderedSet: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
}
#endif

extension Set: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
}

extension Array: RelationshipCollection where Element: PersistentModel {
  public typealias PersistentElement = Element
}

// Note: This is not any optional, it is an optional collection! (toMany)
extension Optional: RelationshipCollection
  where Wrapped: Sequence, Wrapped.Element: PersistentModel
{
  public typealias PersistentElement = Wrapped.Element
}
