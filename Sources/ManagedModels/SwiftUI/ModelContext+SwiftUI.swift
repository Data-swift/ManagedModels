//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//
#if canImport(SwiftUI)
import SwiftUI
import CoreData

public extension EnvironmentValues {
  
  @inlinable
  var modelContext : NSManagedObjectContext {
    set { self.managedObjectContext = newValue }
    get { self.managedObjectContext }
  }
}

public extension View {
  
  @inlinable
  func modelContext(_ context: NSManagedObjectContext) -> some View {
    self
      .environment(\.managedObjectContext, context)
  }
}

@available(iOS 14.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Scene {
  
  @inlinable
  func modelContext(_ context: NSManagedObjectContext) -> some Scene {
    self
      .environment(\.managedObjectContext, context)
  }
}
#endif // canImport(SwiftUI)
