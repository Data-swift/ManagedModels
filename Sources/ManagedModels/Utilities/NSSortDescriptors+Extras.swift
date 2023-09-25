//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension NSSortDescriptor {
  
  enum SortOrder: Hashable {
    case forward, reverse
  }
}

/**
 * Create an NSSortDescriptor for a Swift KeyPath.
 */
@inlinable
public func SortDescriptor<M, T>(_ keyPath: KeyPath<M, T>,
                                 order: NSSortDescriptor.SortOrder = .forward)
            -> NSSortDescriptor
  where M: PersistentModel & NSManagedObject
{
  NSSortDescriptor(keyPath: keyPath, ascending: order == .forward)
}
