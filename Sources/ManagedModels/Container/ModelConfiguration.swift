//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

@preconcurrency import CoreData

public struct ModelConfiguration: Hashable, Sendable {
  // TBD: Some of those are `let` in SwiftData

  public var path                        : String
  public var name                        : String
  public var groupAppContainerIdentifier : String? = nil
  public var cloudKitContainerIdentifier : String? = nil
  public var groupContainer              = GroupContainer.none
  public var cloudKitDatabase            = CloudKitDatabase.none
  public var schema                      : NSManagedObjectModel?
  public var allowsSave                  = true
  
  public var isStoredInMemoryOnly : Bool {
    set {
      if newValue {
        path = "/dev/null"
      }
      else if path == "/dev/null" {
        do    { path = try lookupDefaultPath(for: name) }
        catch { fatalError("Could not lookup path for: \(name) \(error)") }
      }
      // else: preserve existing path
    }
    get { path == "/dev/null" }
  }
  
  public init(path: String? = nil, name: String? = nil,
              schema                      : NSManagedObjectModel? = nil,
              isStoredInMemoryOnly        : Bool                  = false,
              allowsSave                  : Bool                  = true,
              groupAppContainerIdentifier : String?               = nil,
              cloudKitContainerIdentifier : String?               = nil,
              groupContainer              : GroupContainer        = .none,
              cloudKitDatabase            : CloudKitDatabase      = .none)
  {
    let actualPath : String
    
    if let path, !path.isEmpty {
      actualPath = path
    }
    else if isStoredInMemoryOnly {
      actualPath = "/dev/null"
    }
    else {
      do {
        actualPath = try lookupDefaultPath(for: name)
      }
      catch {
        fatalError("Could not lookup path for model \(name ?? "?"): \(error)")
      }
    }
    var defaultName : String {
      if isStoredInMemoryOnly || actualPath == "/dev/null" { return "InMemory" }
      if let idx = actualPath.lastIndex(of: "/") {
        return String(actualPath[idx...].dropFirst())
      }
      return actualPath
    }

    self.path                        = actualPath
    self.name                        = name ?? defaultName
    self.groupAppContainerIdentifier = groupAppContainerIdentifier
    self.cloudKitContainerIdentifier = cloudKitContainerIdentifier
    self.groupContainer              = groupContainer
    self.cloudKitDatabase            = cloudKitDatabase
    self.schema                      = schema
    self.allowsSave                  = allowsSave
  }
}

extension ModelConfiguration: Identifiable {
  
  @inlinable
  public var id : String { path }
}

public extension ModelConfiguration {
  
  struct GroupContainer: Hashable, Sendable {
    enum Value: Hashable {
      case automatic, none
      case identifier(String)
    }
    let value : Value
    
    public static let automatic = Self(value: .automatic)
    public static let none      = Self(value: .none)
    public static func identifier(_ groupName: String) -> Self {
      .init(value: .identifier(groupName))
    }
  }
}

public extension ModelConfiguration {
  
  struct CloudKitDatabase: Hashable, Sendable {
    enum Value: Hashable {
      case automatic, none
      case `private`(String)
    }
    let value : Value
    
    public static let automatic = Self(value: .automatic)
    public static let none      = Self(value: .none)
    public static func `private`(_ dbName: String) -> Self {
      .init(value: .private(dbName))
    }
  }
}

public extension ModelConfiguration {
  
  @inlinable
  var url : URL {
    set { path = newValue.path }
    get { URL(fileURLWithPath: path) }
  }

  @inlinable
  init(_ name: String? = nil, schema: Schema? = nil, url: URL,
       isStoredInMemoryOnly: Bool = false, allowsSave: Bool = true,
       groupAppContainerIdentifier: String? = nil,
       cloudKitContainerIdentifier: String? = nil,
       groupContainer: GroupContainer = .none,
       cloudKitDatabase: CloudKitDatabase = .none)
  {
    self.init(path: url.path, name: name ?? url.lastPathComponent,
              schema: schema, 
              isStoredInMemoryOnly: isStoredInMemoryOnly,
              allowsSave: allowsSave,
              groupAppContainerIdentifier: groupAppContainerIdentifier,
              cloudKitContainerIdentifier: cloudKitContainerIdentifier,
              groupContainer: groupContainer,
              cloudKitDatabase: cloudKitDatabase)
  }
  
  @inlinable
  init(for forTypes: any PersistentModel.Type...,
       isStoredInMemoryOnly: Bool = false)
  {
    let model = NSManagedObjectModel(forTypes)
    self.init(schema: model, isStoredInMemoryOnly: isStoredInMemoryOnly)
  }
}

private func lookupDefaultPath(for name: String?) throws -> String {
  // Synchronous I/O, hm.
  let filename = (name?.isEmpty ?? true) ? "default.sqlite" : (name ?? "")
  
  let fm = FileManager.default
  guard let appSupportURL =
    fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
  else {
    struct MissingAppSupport: Swift.Error {}
    throw MissingAppSupport()
  }
  // Make sure it exists
  try fm.createDirectory(at: appSupportURL,
                         withIntermediateDirectories: true)
  let url = appSupportURL.appendingPathComponent(filename)
  return url.path
}
