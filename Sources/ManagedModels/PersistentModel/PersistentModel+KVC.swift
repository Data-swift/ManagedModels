//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

// Note: This needs to match up the `valueType` in NSAttributeDescription+Data.

// MARK: - Primitives
public extension PersistentModel {

  @inlinable
  func setValue<T>(forKey key: String, to value: T)
    where T: Codable & CoreDataPrimitiveValue
  {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(value, forKey: key)
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: Codable & CoreDataPrimitiveValue
  {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    return primitiveValue(forKey: key) as! T
  }

  @inlinable
  func setValue<T>(forKey key: String, to value: T)
    where T: Codable & CoreDataPrimitiveValue & AnyOptional
  {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    
    // While `nil` is properly bridged to `NSNull`, this is still necessary
    // because `T` is the Optional structure, NOT the value type. I think :-)
    if value.isSome {
      setPrimitiveValue(value.value, forKey: key)
    }
    else {
      setPrimitiveValue(nil, forKey: key)
    }
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: Codable & CoreDataPrimitiveValue & AnyOptional
  {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    return primitiveValue(forKey: key) as! T
  }
}

// MARK: - Transformable
public extension PersistentModel {
  
  @inlinable
  func setTransformableValue(forKey key: String, to value: Any) {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(value, forKey: key)
  }
  
  @inlinable
  func getTransformableValue<T>(forKey key: String) -> T {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    return primitiveValue(forKey: key) as! T
  }
  
  @inlinable
  func setTransformableValue(forKey key: String, to value: Any?) {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(value, forKey: key)
  }
  
  @inlinable
  func getTransformableValue<T>(forKey key: String) -> T
         where T: AnyOptional
  {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    guard let value = primitiveValue(forKey: key) else {
      return .noneValue
    }
    return (value as? T) ?? .noneValue
  }
}


// MARK: - ToOne Relationships
public extension PersistentModel {

  @inlinable
  func setValue<T>(forKey key: String, to model: T) where T: PersistentModel {
    _setOptionalToOneValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T where T: PersistentModel {
    guard let value : T = _getOptionalToOneValue(forKey: key) else {
      fatalError("Non-optional toOne relationship contains nil value?!")
    }
    return value
  }
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T?) where T: PersistentModel {
    _setOptionalToOneValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T? where T: PersistentModel {
    _getOptionalToOneValue(forKey: key)
  }
  
  // Codable disambiguation
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T) 
    where T: PersistentModel & Encodable
  {
    _setOptionalToOneValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: PersistentModel & Encodable
  {
    guard let value : T = _getOptionalToOneValue(forKey: key) else {
      fatalError("Non-optional toOne relationship contains nil value?!")
    }
    return value
  }
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T?) 
    where T: PersistentModel & Encodable
  {
    _setOptionalToOneValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T? 
    where T: PersistentModel & Encodable
  {
    _getOptionalToOneValue(forKey: key)
  }

  // Primitives

  @inlinable
  func _setOptionalToOneValue<T>(forKey key: String, to model: T?)
    where T: PersistentModel
  {
    if let model {
      if model.modelContext != self.modelContext {
        if let otherCtx = model.modelContext, self.modelContext == nil {
          otherCtx.insert(self)
        }
        else if let ownCtx = self.modelContext, model.modelContext == nil {
          ownCtx.insert(model)
        }
      }
    }
    
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    if let model {
      setPrimitiveValue(model, forKey: key)
    }
    else {
      setPrimitiveValue(nil, forKey: key)
    }
  }
  
  @inlinable
  func _getOptionalToOneValue<T>(forKey key: String) -> T?
    where T: PersistentModel
  {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    guard let model = primitiveValue(forKey: key) else { return nil }
    guard let typed = model as? T else {
      fatalError(
        """
        Stored model doesn't match declared type: \(key)
        
          Expected: \(T.self)
          Provided: \(type(of: model))
        
        """
      )
    }
    return typed
  }
}


// MARK: - ToMany Relationships
public extension PersistentModel {
  
  @inlinable
  func setValue<T>(forKey key: String, to models: T)
    where T: RelationshipCollection
  {
    if let set = models.coreDataAnySet {
      // TBD: should this do a diff?
      willChangeValue(forKey: key, withSetMutation: .set, using: set)
      defer { didChangeValue(forKey: key, withSetMutation: .set, using: set) }
      setPrimitiveValue(set, forKey: key)
    }
    else { // TBD
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }
      setPrimitiveValue(nil, forKey: key)
    }
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: RelationshipCollection
  {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    let set = primitiveValue(forKey: key)
    return T.init(coreDataAnySet: set as? Set<AnyHashable>)
  }
}


// MARK: - RawRepresentable
public extension PersistentModel {
  // TBD. That the wrapping can fail and fatalError may be suboptimal.
  // But it is convenient and more importantly _fast_ for enum's.
  
  @inlinable
  func setValue<T>(forKey key: String, to value: T)
    where T: RawRepresentable, T.RawValue: Codable & CoreDataPrimitiveValue
  {
    setValue(forKey: key, to: value.rawValue)
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: RawRepresentable, T.RawValue: Codable & CoreDataPrimitiveValue
  {
    let rawValue : T.RawValue = getValue(forKey: key)
    guard let wrapped = T.init(rawValue: rawValue) else {
      fatalError("Could not wrap raw value \(rawValue) for \(key)")
    }
    return wrapped
  }
  
  // Overloads for RawRepresentables that are ALSO Codable
  
  @inlinable
  func setValue<T>(forKey key: String, to value: T)
    where T: RawRepresentable & Codable,
          T.RawValue: Codable & CoreDataPrimitiveValue
  {
    setValue(forKey: key, to: value.rawValue)
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: RawRepresentable & Codable,
          T.RawValue: Codable & CoreDataPrimitiveValue
  {
    let rawValue : T.RawValue = getValue(forKey: key)
    guard let wrapped = T.init(rawValue: rawValue) else {
      fatalError("Could not wrap raw value \(rawValue) for \(key)")
    }
    return wrapped
  }
}

// MARK: - Codable
public extension PersistentModel {
  // SwiftData is doing a Codable a little different.
  // TBD: we could also use transformers for this, probably faster?!
  
  func setValue<T>(forKey key: String, to value: T) where T: Codable {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(value, forKey: key)
  }
  
  func setValue<T>(forKey key: String, to value: T)
         where T: Codable & AnyOptional
  {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    if value.isSome { setPrimitiveValue(value, forKey: key) }
    else { setPrimitiveValue(nil, forKey: key) }
  }

  func getValue<T>(forKey key: String) -> T where T: Codable {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    guard let value = primitiveValue(forKey: key) else {
      fatalError("No box found for non-optional Codable value for key \(key)?")
    }
    
    if let value = value as? T {
      return value
    }
    
    if let data = value as? Data {
      assertionFailure("Unexpected Data as primitive!")
      do {
        return try JSONDecoder().decode(T.self, from: data)
      }
      catch {
        fatalError("Could not decode JSON value for key \(key)? \(error)")
      }
    }
    
    fatalError("Codable value type doesn't match? \(value)")
  }
  
  func getValue<T>(forKey key: String) -> T where T: Codable & AnyOptional {
    willAccessValue(forKey: key); defer { didAccessValue(forKey: key) }
    guard let value = primitiveValue(forKey: key) else { return .noneValue }
    if let value = value as? T { return value }
    
    if let data = value as? Data {
      assertionFailure("Unexpected Data as primitive!")
      do {
        return try JSONDecoder().decode(T.self, from: data)
      }
      catch {
        fatalError("Could not decode JSON value for key \(key)? \(error)")
      }
    }
    
    guard let value = value as? T else {
      fatalError("Unexpected value for key \(key)? \(value)")
    }
    assertionFailure("Codable value type doesn't match? \(value)")
    return .noneValue
  }
}
