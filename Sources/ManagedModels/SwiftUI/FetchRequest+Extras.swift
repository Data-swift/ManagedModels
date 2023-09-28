//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//
#if canImport(SwiftUI)

import SwiftUI
import CoreData

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension FetchRequest {
  
  struct SortDescriptor {
    public let keyPath : PartialKeyPath<Result>
    public let order   : NSSortDescriptor.SortOrder

    @inlinable
    public init<T>(_ keyPath: KeyPath<Result, T>,
                   order: NSSortDescriptor.SortOrder = .forward)
    {
      self.keyPath = keyPath
      self.order   = order
    }
  }
  
  @MainActor
  @inlinable
  init<T>(filter predicate : NSPredicate? = nil,
          sort     keyPath : KeyPath<Result, T>,
          order            : NSSortDescriptor.SortOrder = .forward,
          animation        : Animation? = nil)
    where Result: PersistentModel & NSManagedObject & NSFetchRequestResult
  {
    guard let meta = Result
      .schemaMetadata.first(where: { $0.keypath == keyPath }) else
    {
      fatalError("Could not map keypath to persisted property?")
    }
    self.init(
      sortDescriptors: [
        NSSortDescriptor(key: meta.name, ascending: order == .forward)
      ],
      predicate: predicate,
      animation: animation
    )
  }
  
  @MainActor
  init(filter     predicate : NSPredicate? = nil,
       sort sortDescriptors : [ SortDescriptor ],
       animation            : Animation? = nil)
  where Result: PersistentModel & NSManagedObject & NSFetchRequestResult
  {
    self.init(
      sortDescriptors: sortDescriptors.map { sd in
        guard let meta = Result
          .schemaMetadata.first(where: { $0.keypath == sd.keyPath }) else
        {
          fatalError("Could not map keypath to persisted property?")
        }
        return NSSortDescriptor(key: meta.name, ascending: sd.order == .forward)
      },
      predicate: predicate,
      animation: animation
    )
  }
  
  @MainActor
  init(filter     predicate : NSPredicate? = nil,
       sort sortDescriptors : [ NSSortDescriptor ],
       animation            : Animation? = nil)
  where Result: PersistentModel & NSManagedObject & NSFetchRequestResult
  {
    self.init(
      sortDescriptors: sortDescriptors,
      predicate: predicate,
      animation: animation
    )
  }
}
#endif // canImport(SwiftUI)
