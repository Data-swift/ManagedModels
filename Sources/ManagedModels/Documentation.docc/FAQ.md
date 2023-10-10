# Frequently Asked Questions

A collection of questions and possible answers.

## Overview

Any question we should add: [info@zeezide.de](mailto:info@zeezide.de),
file a GitHub [Issue](https://github.com/Data-swift/ManagedModels/issues).
or submit a GitHub PR w/ the answer. Thank you!

## General

### Is the API the same like in SwiftData?

The API is very similar, but there are some significant differences:
<doc:DifferencesToSwiftData>.

### Is ManagedObjects a replacement for SwiftData?

It is not exactly the same but can be used as one, yes.
ManagedObjects allows deployment on earlier versions than iOS 17 or macOS 14
while still providing many of the SwiftData benefits.

It might be a sensible migration path towards using SwiftData directly in the
future.

### Which deployment versions does ManagedObjects support?

While it might be possible to backport further, ManagedObjects currently
supports:
- iOS 13+
- macOS 11+
- tvOS 13+
- watchOS 6+

### Does this require SwiftUI or can I use it in UIKit as well?

ManagedObjects works with both, SwiftUI and UIKit.

In a UIKit environment the ``ModelContainer`` (aka ``NSPersistentContainer``) 
needs to be setup manually, e.g. in the `ApplicationDelegate`.

Example:
```swift
import ManagedModels

let schema = Schema([ Item.self ])
let container = try ModelContainer(for: schema, configurations: [])
```

### Are the `ModelContainer`, `Schema` classes subclasses of CoreData classes?

No, most of the SwiftData-like types provided by ManagedObjects are just 
"typealiases" to the corresponding CoreData types, e.g.:
- ``ModelContainer`` == ``NSPersistentContainer``
- ``ModelContext`` == ``NSManagedObjectContext``
- ``Schema`` == ``NSManagedObjectModel``
- `Schema/Entity` == ``NSEntityDescription``

And so on. The CoreData type names can be used instead, but make a future
migration to SwiftData harder.

### Is it possible to use ManagedModels in SwiftUI Previews?

Yes! Attach an in-memory store to the preview-View, like so:
```swift
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

### Something isn't working right, how do I file a Radar?

Please file a GitHub
 [Issue](https://github.com/Data-swift/ManagedModels/issues).
Thank you very much.
