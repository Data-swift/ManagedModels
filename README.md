<h2>ManagedModels for CoreData
  <img src="https://zeezide.com/img/lighter/Lighter256.png"
       align="right" width="64" height="64" />
</h2>

> Instead of wrapping CoreData, directly use it :-)

The key thing **ManagedModels** provides is a `@Model` macro, 
that works similar (but not identical) to the SwiftData
[`@Model`](https://developer.apple.com/documentation/swiftdata/model())
macro.
It generates an
[`NSManagedObjectModel`](https://developer.apple.com/documentation/coredata/nsmanagedobjectmodel)
straight from the code. I.e. no CoreData modeler / data model file is necessary.

Example:
```swift


****TODO****



```

> This is *not* a replacement implementation of
> [SwiftData](https://developer.apple.com/documentation/swiftdata).
> I.e. the API is kept _similar_ to SwiftData, but not exactly the same.
> It doesn't try to hide CoreData, but rather provides utilities to work with
> CoreData in a similar way.


#### Requirements

The macro implementation requires Xcode 15/Swift 5.9 for compilation.
The generated code itself though should backport way back to 
iOS 10 / macOS 10.12 though (when `NSPersistentContainer` was introduced).


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
- Doesn't use the new 
  [Observation](https://developer.apple.com/documentation/observation) 
  framework (which requires iOS 17+), but uses 
  [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
  (which is directly supported by CoreData).


#### TODO

- [ ] Archiving/Unarchiving, required for migration.
- [ ] Figure out whether we can do ordered attributes.
- [ ] Figure out whether we can add support for array toMany properties.
- [ ] Support for "autosave".
- [ ] Generate property initializers if the user didn't specify any inits?
- [ ] Generate `fetchRequest()` class function.
- [ ] Write more tests.
- [ ] Write DocC docs.
- [ ] Support for entity inheritance.
- [ ] Add support for originalName/versionHash in `@Model`.
- [ ] Generate "To Many" accessor function prototypes (`addItemToGroup` etc).
- [ ] Foundation Predicate support (would require iOS 17+)
  - [ ] SwiftUI `@Query` property wrapper/macro?
- [ ] Figure out all the cloud sync options SwiftData has and whether CoreData
      can do them.
- [ ] Figure out whether we can allow initialized properties 
      (`var title = "No Title"`).

Pull requests are very welcome!
Even just DocC documentation or more tests would be welcome contributions.


#### Links

- Apple:
  - [CoreData](https://developer.apple.com/documentation/coredata)
  - [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Lighter.swift](https://github.com/Lighter-swift), typesafe and superfast 
  [SQLite](https://www.sqlite.org) Swift tooling.


#### Disclaimer

SwiftData and SwiftUI are trademarks owned by Apple Inc. Software maintained as 
a part of the this project is not affiliated with Apple Inc.


### Who

Models are brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
