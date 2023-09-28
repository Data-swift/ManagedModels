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
 * Create an NSSortDescriptor for a Swift KeyPath targeting a
 * ``PersistentModel``.
 *
 * - Parameters:
 *   - keyPath: The keypath to sort on.
 *   - order:   Does it go forward or backwards?
 * - Returns:   An `NSSortDescriptor` reflecting the parameters.
 */
@inlinable
public func SortDescriptor<M, T>(_ keyPath: KeyPath<M, T>,
                                 order: NSSortDescriptor.SortOrder = .forward)
            -> NSSortDescriptor
  where M: PersistentModel & NSManagedObject
{
  if let meta = M.schemaMetadata.first(where: { $0.keypath == keyPath }) {
    NSSortDescriptor(key: meta.name, ascending: order == .forward)
  }
  else {
    NSSortDescriptor(keyPath: keyPath, ascending: order == .forward)
  }
}
