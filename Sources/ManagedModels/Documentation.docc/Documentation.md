# ``ManagedModels``

SwiftData like declarative schemas for CoreData.

@Metadata {
  @DisplayName("ManagedModels for CoreData")
}

## Overview

[ManagedModels](https://github.com/Data-swift/ManagedModels/) is a package
that provides a
[Swift 5.9](https://www.swift.org/blog/swift-5.9-released/) 
macro similar to the SwiftData
[@Model](https://developer.apple.com/documentation/SwiftData/Model()).
It can generate CoreData
[ManagedObjectModel](https://developer.apple.com/library/archive/documentation/DataManagement/Devpedia-CoreData/managedObjectModel.html)'s
declaratively from Swift classes, 
w/o having to use the Xcode "CoreData Modeler".

Unlike SwiftData it doesn't require iOS 17+ and works directly w/
[CoreData](https://developer.apple.com/documentation/coredata).
It is **not** a direct API replacement, but a look-a-like.
Example model class:
```swift
@Model
class ToDo: NSManagedObject {
    var title: String
    var isDone: Bool
    var attachments: [ Attachment ]
}
```
Setting up a store in SwiftUI:
```swift
ContentView()
    .modelContainer(for: ToDo.self)
```
Performing a query:
```swift
struct ToDoListView: View {
    @FetchRequest(sort: \.isDone)
    private var toDos: FetchedResults<ToDo>

    var body: some View {
        ForEach(toDos) { todo in
            Text("\(todo.title)")
                .foregroundColor(todo.isDone ? .green : .red)
        }
    }
}
```

- Swift package: [https://github.com/Data-swift/ManagedModels.git](https://github.com/Data-swift/ManagedModels/)
- Example ToDo list app: [https://github.com/Data-swift/ManagedToDosApp.git](https://github.com/Data-swift/ManagedToDosApp/)



## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:DifferencesToSwiftData>

### Support

- <doc:FAQ>
- <doc:Links>
- <doc:Who>
