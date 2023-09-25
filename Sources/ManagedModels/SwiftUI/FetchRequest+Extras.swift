//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//
#if canImport(SwiftUI)

import SwiftUI
import CoreData

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension FetchRequest {
  
  @MainActor
  @inlinable
  init<T>(filter predicate : NSPredicate? = nil,
          sort     keyPath : KeyPath<Result, T>,
          order            : NSSortDescriptor.SortOrder = .forward,
          animation        : Animation? = nil)
  where Result: PersistentModel & NSManagedObject & NSFetchRequestResult
  {
    self.init(
      sortDescriptors: [
        NSSortDescriptor(keyPath: keyPath, ascending: order == .forward)
      ],
      predicate: predicate,
      animation: animation
    )
  }
  
  @MainActor
  @inlinable
  init(filter     predicate : NSPredicate? = nil,
       sort sortDescriptors : [ NSSortDescriptor ],
       animation            : Animation? = nil)
  where Result: PersistentModel & NSManagedObject & NSFetchRequestResult
  {
    self.init(sortDescriptors: sortDescriptors, predicate: predicate,
              animation: animation)
  }
}
#endif // canImport(SwiftUI)
