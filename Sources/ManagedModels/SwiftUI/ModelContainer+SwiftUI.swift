//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//
#if canImport(SwiftUI)

import SwiftUI
import CoreData

// TBD: also on Scene!

public extension EnvironmentValues {
  
  @inlinable
  var modelContainer : NSManagedObjectContext {
    set { self.managedObjectContext = newValue }
    get { self.managedObjectContext }
  }
}

public extension View {

  @inlinable
  func modelContainer(_ container: ModelContainer) -> some View {
    self.modelContext(container.viewContext)
  }

  @ViewBuilder
  func modelContainer(
    for    modelTypes : [ any PersistentModel.Type ],
    inMemory          : Bool = false,
    isAutosaveEnabled : Bool = true,
    isUndoEnabled     : Bool = false,
    onSetup: @escaping (Result<NSPersistentContainer, Error>) -> Void = { _ in }
  ) -> some View
  {
    let result = makeModelContainer(
      for: modelTypes, inMemory: inMemory,
      isAutosaveEnabled: isAutosaveEnabled, isUndoEnabled: isUndoEnabled,
      onSetup: onSetup
    )

    switch result {
      case .success(let container):
        self.modelContainer(container)
      case .failure:
        self // TBD. Could also overlay an error or sth
    }
  }
  
  @inlinable
  func modelContainer(
    for     modelType : any PersistentModel.Type,
    inMemory          : Bool = false,
    isAutosaveEnabled : Bool = true,
    isUndoEnabled     : Bool = false,
    onSetup: @escaping (Result<NSPersistentContainer, Error>) -> Void = { _ in }
  ) -> some View
  {
    self.modelContainer(
      for: [ modelType ], inMemory: inMemory,
      isAutosaveEnabled: isAutosaveEnabled, isUndoEnabled: isUndoEnabled,
      onSetup: onSetup
    )
  }
}

@available(iOS 14.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Scene {
  
  @inlinable
  func modelContainer(_ container: ModelContainer) -> some Scene {
    self.modelContext(container.viewContext)
  }
  
  @SceneBuilder
  func modelContainer(
    for    modelTypes : [ any PersistentModel.Type ],
    inMemory          : Bool = false,
    isAutosaveEnabled : Bool = true,
    isUndoEnabled     : Bool = false,
    onSetup: @escaping (Result<NSPersistentContainer, Error>) -> Void = { _ in }
  ) -> some Scene
  {
    let result = makeModelContainer(
      for: modelTypes, inMemory: inMemory,
      isAutosaveEnabled: isAutosaveEnabled, isUndoEnabled: isUndoEnabled,
      onSetup: onSetup
    )

    // So a SceneBuilder doesn't have a conditional. Can only crash on fail?
    self.modelContainer(try! result.get())
  }
  
  @inlinable
  func modelContainer(
    for     modelType : any PersistentModel.Type,
    inMemory          : Bool = false,
    isAutosaveEnabled : Bool = true,
    isUndoEnabled     : Bool = false,
    onSetup: @escaping (Result<NSPersistentContainer, Error>) -> Void = { _ in }
  ) -> some Scene
  {
    self.modelContainer(
      for: [ modelType ], inMemory: inMemory,
      isAutosaveEnabled: isAutosaveEnabled, isUndoEnabled: isUndoEnabled,
      onSetup: onSetup
    )
  }
}


// MARK: - Primitive

// Note: The docs say that a container is only ever created once! So cache it.
nonisolated(unsafe) private var modelToContainer = [ ObjectIdentifier: NSPersistentContainer ]()

private func makeModelContainer(
  for    modelTypes : [ any PersistentModel.Type ],
  inMemory          : Bool = false,
  isAutosaveEnabled : Bool = true,
  isUndoEnabled     : Bool = false,
  onSetup: @escaping (Result<NSPersistentContainer, Error>) -> Void = { _ in }
) -> Result<NSPersistentContainer, Error>
{
  let model = NSManagedObjectModel.model(for: modelTypes) // caches!
  if let container = modelToContainer[ObjectIdentifier(model)] {
    return .success(container)
  }
  
  let result = _makeModelContainer(
    for: model, 
    configuration: ModelConfiguration(isStoredInMemoryOnly: inMemory)
  )
  switch result {
    case .success(let container):
      modelToContainer[ObjectIdentifier(model)] = container // cache
    case .failure(_): break
  }
  
  onSetup(result) // TBD: this could be delayed for async contexts?
  return result
}

/// Return a `Result` for a container with the given configuration.
private func _makeModelContainer(
  for         model : NSManagedObjectModel,
  configuration: ModelConfiguration
) -> Result<NSPersistentContainer, Error>
{
  let result : Result<NSPersistentContainer, Error>
  do {
    let container = try NSPersistentContainer(
      for: model,
      configurations: configuration
      // TBD: maybe pass in onSetup for async containers
    )
    result = .success(container)
  }
  catch {
    result = .failure(error)
  }
  return result
}

#endif // canImport(SwiftUI)
