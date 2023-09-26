<h2>ManagedModels for CoreData
  <img src="https://zeezide.com/img/managedmodels/ManagedModels128.png"
       align="right" width="64" height="64" />
</h2>

> Instead of wrapping CoreData, use it directly :-)

The key thing **ManagedModels** provides is a `@Model` macro, 
that works similar (but not identical) to the SwiftData
[`@Model`](https://developer.apple.com/documentation/swiftdata/model())
macro.
It generates an
[`NSManagedObjectModel`](https://developer.apple.com/documentation/coredata/nsmanagedobjectmodel)
straight from the code. I.e. no CoreData modeler / data model file is necessary.

A small sample model:
```swift
@Model class Item: NSManagedObject {
  var timestamp : Date
  var title     : String?
}
```

<details>
<summary>The full CoreData template application converted to ManagedModels</summary><br/>

```swift
import SwiftUI
import ManagedModels

@Model class Item: NSManagedObject {
  var timestamp : Date
}

struct ContentView: View {

  @Environment(\.modelContext) private var viewContext
  
  @FetchRequest(sort: \.timestamp, animation: .default)
  private var items: FetchedResults<Item>
  
  var body: some View {
    NavigationView {
      List {
        ForEach(items) { item in
          NavigationLink {
            Text("Item at \(item.timestamp!, format: .dateTime)")
          } label: {
            Text("\(item.timestamp!, format: .dateTime)")
          }
        }
        .onDelete(perform: deleteItems)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      Text("Select an item")
    }
  }
  
  private func addItem() {
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()
      try! viewContext.save()
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items[$0] }.forEach(viewContext.delete)
      try! viewContext.save()
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
```

</details>


> This is *not* intended as a replacement implementation of
> [SwiftData](https://developer.apple.com/documentation/swiftdata).
> I.e. the API is kept _similar_ to SwiftData, but not exactly the same.
> It doesn't try to hide CoreData, but rather provides utilities to work *with*
> CoreData in a similar way to SwiftData.


#### Requirements

The macro implementation requires Xcode 15/Swift 5.9 for compilation.
The generated code itself though should backport way back to 
iOS 10 / macOS 10.12 though (when `NSPersistentContainer` was introduced).

Package URL:
```
https://github.com/Data-swift/ManagedModels.git
```

ManagedModels has no other dependencies.


#### Differences to SwiftData

- The model class must explicitly inherit from
  [`NSManagedObject`](https://developer.apple.com/documentation/coredata/nsmanagedobject)
  (superclasses can't be added by macros), 
  e.g. `@Model class Person: NSManagedObject`.
- ToMany relationships must be a `Set<Target>`, a plain `[ Target ]` cannot be
  used (yet?). E.g. `var contacts : Set<Contact>`.
- Properties cannot be initialized in the declaration,
  e.g. this doesn't work: `var uuid = UUID()`. 
  Must be done in an initializers (requirement by `@NSManaged`).
- CoreData doesn't seem to support optional Swift base types like `Int?`.
- Uses the CoreData `@FetchRequest` property wrapper instead `@Query`.
- Doesn't use the new 
  [Observation](https://developer.apple.com/documentation/observation) 
  framework (which requires iOS 17+), but uses 
  [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
  (which is directly supported by CoreData).


#### TODO

- [x] Archiving/Unarchiving, required for migration.
- [ ] Figure out whether we can do ordered attributes: [Issue #1](https://github.com/Data-swift/ManagedModels/issues/1).
- [ ] Figure out whether we can add support for array toMany properties: [Issue #2](https://github.com/Data-swift/ManagedModels/issues/2)
- [ ] Support for "autosave": [Issue #3](https://github.com/Data-swift/ManagedModels/issues/3)
- [ ] Support transformable types, not sure they work right yet: [Issue #4](https://github.com/Data-swift/ManagedModels/issues/4)
- [ ] Generate property initializers if the user didn't specify any inits: [Issue #5](https://github.com/Data-swift/ManagedModels/issues/5)
- [x] Generate `fetchRequest()` class function.
- [ ] Support SchemaMigrationPlan/MigrationStage: [Issue #6](https://github.com/Data-swift/ManagedModels/issues/6)
- [ ] Write more tests.
- [ ] Write DocC docs: [Issue #7](https://github.com/Data-swift/ManagedModels/issues/7), [Issue #8](https://github.com/Data-swift/ManagedModels/issues/8)
- [ ] Support for entity inheritance: [Issue #9](https://github.com/Data-swift/ManagedModels/issues/9)
- [ ] Add support for originalName/versionHash in `@Model`: [Issue 10](https://github.com/Data-swift/ManagedModels/issues/10)
- [ ] Generate "To Many" accessor function prototypes (`addItemToGroup` etc): [Issue 11](https://github.com/Data-swift/ManagedModels/issues/11)
- [x] Foundation Predicate support (would require iOS 17+) - this seems actually supported by CoreData!
  - [ ] SwiftUI `@Query` property wrapper/macro?: [Issue 12](https://github.com/Data-swift/ManagedModels/issues/12)
- [ ] Figure out all the cloud sync options SwiftData has and whether CoreData
      can do them: [Issue 13](https://github.com/Data-swift/ManagedModels/issues/13)
- [ ] Figure out whether we can allow initialized properties 
      (`var title = "No Title"`): [Issue 14](https://github.com/Data-swift/ManagedModels/issues/14)

Pull requests are very welcome!
Even just DocC documentation or more tests would be welcome contributions.


#### Links

- Apple:
  - [CoreData](https://developer.apple.com/documentation/coredata)
  - [SwiftData](https://developer.apple.com/documentation/swiftdata)
    - [Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187)
    - [Build an App with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154)
    - [Model your Schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195)
  - [Enterprise Objects Framework](https://en.wikipedia.org/wiki/Enterprise_Objects_Framework) / aka EOF
    - [Developer Guide](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_4.5/System/Documentation/Developer/EnterpriseObjects/DevGuide/EOFDevGuide.pdf)
- [Lighter.swift](https://github.com/Lighter-swift), typesafe and superfast 
  [SQLite](https://www.sqlite.org) Swift tooling.
- [ZeeQL](http://zeeql.io), prototype of an [EOF](https://en.wikipedia.org/wiki/Enterprise_Objects_Framework) for Swift,
  with many database backends.
  


#### Disclaimer

SwiftData and SwiftUI are trademarks owned by Apple Inc. Software maintained as 
a part of the this project is not affiliated with Apple Inc.


### Who

Models are brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
