# Getting Started

Setting up ManagedModels.

## Introduction

This article shows how to setup a small SwiftUI Xcode project to work with
ManagedModels.
It is a conversion of the Xcode template project for CoreData.


## Creating the Xcode Project and Adding ManagedModels

1. Create a new SwiftUI project in Xcode, e.g. a Multiplatform/App project or an
   iOS/App project. (it does work for UIKit as well!)
2. Choose "None" as the "Storage" (instead of "SwiftData" or "Core Data")
3. Select "Add Package Dependencies" in Xcode's "File" menu to add the
   ManagedModels macro.
4. In the **search field** (yes!) of the packages panel,
   paste in the URL of the ManagedModels package:
   `https://github.com/Data-swift/ManagedModels.git`,
   and press "Add Package" twice.

> At some point Xcode will stop compilation and ask you to confirm that you
> want to use the `@Model` macro provided by ManagedModels.
> Confirm to continue, or review the source code of the macro first.


## Create a Model

Create a new file for the model, say `Item.swift` (or just paste the code in
any other Swift file of the project).
It could look like this:
```swift
import ManagedModels

@Model class Item: NSManagedObject {
    var timestamp : Date
}
```

## Configure the App to use the Container

Use the `View/modelContainer` modifier provided by ManagedModels to setup
the whole CoreData stack for the `Item` model:
```swift
import SwiftUI
import ManagedModels

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self, inMemory: true)
    }
}
```

This is using `inMemory: true` during testing, i.e. a new in-memory database
will be create on each restart of the app.
Once the app is in better shape, this can be set to `false` (or the whole
argument removed).


## Write a SwiftUI View that works w/ the Model

Replace the default SwiftUI ContentView with this setup.
The details are addressed below.

```swift
import SwiftUI
import ManagedModels

struct ContentView: View {

    @Environment(\.modelContext) 
    private var viewContext
    
    @FetchRequest(sort: \.timestamp, animation: .default)
    private var items: FetchedResults<Item>

    private func addItem() {
        withAnimation {
            let newItem = Item()
            newItem.timestamp = Date()
            viewContext.insert(newItem)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text("\(item.timestamp, format: .dateTime)")
                }
            }
            .toolbar {
                Button(action: addItem) { Label("Add Item", systemImage: "plus") }
            }
        }
    }    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

#### Access the ModelContext aka NSManagedObjectContext

A ``ModelContext`` (``NSManagedObjectContext``) maintains the current state of
the models. It is used to insert and delete models. 
A model object is always assigned to just one context.

The context can be retrieved using the `@Environment` property wrapper:
```swift
@Environment(\.modelContext) private var viewContext
```
And is then used in e.g. the `addItem` function to create a new model object:
```swift
let newItem = Item()
newItem.timestamp = Date()
viewContext.insert(newItem)
```
One could also write a convenience initializer to streamline the process.

#### Use the SwiftUI @FetchRequest to Fetch Models

The
[`@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest)
property wrapper is used to load models from CoreData:
```swift
@FetchRequest(sort: \.timestamp, animation: .default)
private var items: FetchedResults<Item>
```
It can sort and filter and do various other things as documented in the
- [CoreData documentation](https://developer.apple.com/documentation/coredata).

The value of the `items` can be directly used in SwiftUI
[List](https://developer.apple.com/documentation/swiftui/list)'s:
```swift
List {
    ForEach(items) { 
        item in Text("\(item.timestamp)") 
    }
}
```

#### Test the View using SwiftUI Previews

Using the `#Preview` macro the view can be directly tested in Xcode:
```swift
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```
Note how the in-memory store is used again. In a real setup, one might want to
pre-populate an in-memory store for testing.


## Full Example

There is a small SwiftUI todo list example app,
demonstrating the use of 
[ManagedModels](https://github.com/Data-swift/ManagedModels/).
It has two connected entities and shows the general setup:
[Managed ToDos](https://github.com/Data-swift/ManagedToDosApp/).

It should be self-explanatory. Works on macOS 13+ and iOS 16+, due to the use
of the new SwiftUI navigation views. 
Could be backported to earlier versions.
