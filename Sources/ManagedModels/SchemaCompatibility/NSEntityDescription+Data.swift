//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension CoreData.NSEntityDescription {
  // Note: `uniquenessConstraints` is String only in SwiftData
  
  @inlinable
  var storedProperties : [ NSPropertyDescription ] {
    properties.filter { !$0.isTransient }
  }
  @inlinable
  var storedPropertiesByName : [ String : NSPropertyDescription ] {
    propertiesByName.filter { !$0.value.isTransient }
  }
  
  @inlinable
  var attributes : [ NSAttributeDescription ] {
    properties.compactMap { $0 as? NSAttributeDescription }
  }
  @inlinable
  var relationships : [ NSRelationshipDescription ] {
    properties.compactMap { $0 as? NSRelationshipDescription }
  }

  @inlinable
  var superentityName : String? { superentity?.name }
  
  // TBD: Not sure this is how it works (i.e. whether inherited are part of
  //      the props or not).

  @inlinable
  var inheritedProperties : [ NSPropertyDescription ] {
    guard let superentity else { return [] }
    return superentity.inheritedProperties + superentity.properties
  }
  
  @inlinable
  var inheritedPropertiesByName : [ String : NSPropertyDescription ] {
    guard let superentity else { return [:] }
    if superentity.inheritedPropertiesByName.isEmpty {
      return superentity.propertiesByName
    }
    else {
      var copy = superentity.inheritedPropertiesByName
      for ( key, value ) in superentity.propertiesByName {
        copy[key] = value
      }
      return copy
    }
   }

  @inlinable
  var _objectType : (any PersistentModel.Type)? {
    set { managedObjectClassName = newValue.flatMap { NSStringFromClass($0) } }
    get {
      guard let managedObjectClassName,
            let clazz = NSClassFromString(managedObjectClassName),
            let model = clazz as? NSManagedObject.Type else
      {
        return nil
      }
      return model as? any PersistentModel.Type
    }
  }
  
  @inlinable
  var _mangledName : String? {
    set { managedObjectClassName = newValue }
    get { managedObjectClassName }
  }
}


// MARK: - Convenience Initializers

public extension NSEntityDescription {
  
  convenience init(_ name: String) {
    self.init()
    self.name = name
  }
  
  convenience init(_ name: String, subentities: NSEntityDescription...,
                   properties: NSPropertyDescription...)
  {
    self.init(name)
    self.subentities = subentities
    addProperties(properties)
  }
  convenience init(_ name: String, properties: NSPropertyDescription...) {
    self.init(name)
    addProperties(properties)
  }
}


// MARK: - Internal Helpers

extension NSEntityDescription {

  func addProperties(_ newProperties: [ NSPropertyDescription ]) {
    for newProperty in newProperties {
      properties.append(newProperty)
    }
  }
}

extension NSEntityDescription {
  
  func isPropertyUnique(_ property: NSPropertyDescription) -> Bool {
    self.uniquenessConstraints.contains(where: { propSet in
      // one or more NSAttributeDescription or NSString instances
      for prop in propSet {
        if let propName = prop as? String {
          if propName == name { return true }
        }
        else if let propAttr = prop as? NSPropertyDescription {
          return propAttr === self || propAttr.name == name
        }
      }
      return false
    })
  }
}
