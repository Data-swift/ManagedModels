# Differences to SwiftData

ManagedObjects tries to provide an API that is very close to SwiftData,
but it is not exactly the same API.

## Differences

The key difference when converting SwiftData projects:
- Import `ManagedModels` instead of `SwiftData`.
- Let the models inherit from the CoreData
  [`NSManagedObject`](https://developer.apple.com/documentation/coredata/nsmanagedobject).
- Use the CoreData
  [`@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest)
  instead of SwiftData's
  [`@Query`](https://developer.apple.com/documentation/swiftdata/query).


### Explicit Superclass

ManagedModels classes must explicitly inherit from the CoreData
[`NSManagedObject`](https://developer.apple.com/documentation/coredata/nsmanagedobject).
Instead of just this in SwiftData:
```swift
@Model class Contact {}
```
the superclass has to be specified w/ ManagedModels:
```swift
@Model class Contact: NSManagedObject {}
```

> That is due to a limitation of
> [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/).
> A macro can add protocol conformances, but it cannot add a superclass to a 
> type.


### CoreData @FetchRequest instead of SwiftData @Query

Instead of using the new SwiftUI
[`@Query`](https://developer.apple.com/documentation/swiftdata/query)
wrapper, the already available
[`@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest)
property wrapper is used.

SwiftData:
```swift
@Query var contacts : [ Contact ]
```
ManagedModels:
```swift
@FetchRequest var contacts: FetchedResults<Contact>
```

### Properties

The properties work quite similar.

Like SwiftData, ManagedModels provides implementations of the
[`@Attribute`](https://developer.apple.com/documentation/swiftdata/attribute(_:originalname:hashmodifier:)),
`@Relationship` and
[`@Transient`](https://developer.apple.com/documentation/swiftdata/transient())
macros.

#### Compound Properties
               
More complex Swift types are always stored as JSON by ManagedModels, e.g.
```swift
@Model class Person: NSManagedObject {
  
  struct Address: Codable {
    var street : String?
    var city   : String?
  }
  
  var privateAddress  : Address
  var businessAddress : Address
}
```

SwiftData decomposes those structures in the database.


#### RawRepresentable Properties

Those end up working the same like in SwiftData, but are implemented 
differently.
If a type is RawRepresentable by a CoreData base type (like `Int` or `String`),
they get mapped to the same base type in the model.

Example:
```swift
enum Color: String {
  case red, green, blue
}

enum Priority: Int {
  case high = 5, medium = 3, low = 1
}
```


### Initializers

A CoreData object has to be initialized through some
[very specific initializer](https://developer.apple.com/documentation/coredata/nsmanagedobject/1506357-init),
while a SwiftData model class _must have_ an explicit `init`,
but is otherwise pretty regular.

The ManagedModels `@Model` macro generates a set of helper inits to deal with
that.
But the general recommendation is to use a `convenience init` like so:
```swift
convenience init(title: String, age: Int = 50) {
    self.init()
    title = title
    age = age
}
```
If the own init prefilles _all_ properties (i.e. can be called w/o arguments),
the default `init` helper is not generated anymore, another one has to be used:
```swift
convenience init(title: String = "", age: Int = 50) {
    self.init(context: nil)
    title = title
    age = age
}
```
The same `init(context:)` can be used to insert into a specific context.
Often necessary when setting up relationships (to make sure that they
live in the same
[`NSManagedObjectContext`](https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext)).


### Migration

Regular CoreData migration mechanisms have to be used.
SwiftData specific migration APIs might be 
[added later](https://github.com/Data-swift/ManagedModels/issues/6).


## Implementation Differences

SwiftData completely wraps CoreData and doesn't expose the CoreData APIs.

SwiftData relies on the
[Observation](https://developer.apple.com/documentation/observation) 
framework (which requires iOS 17+).
ManagedModels uses CoreData, which makes models conform to
[ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
to integrate w/ SwiftUI.
