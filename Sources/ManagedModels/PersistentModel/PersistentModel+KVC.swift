//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

// MARK: - Primitives
public extension PersistentModel {

  @inlinable
  func setValue<T>(forKey key: String, to value: T)
    where T: Encodable & CoreDataPrimitiveValue
  {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(value, forKey: key)
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: Decodable & CoreDataPrimitiveValue
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
}


// MARK: - ToOne Relationships
public extension PersistentModel {

  @inlinable
  func setValue<T>(forKey key: String, to model: T) where T: PersistentModel {
    _setValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T where T: PersistentModel {
    guard let value : T = _getValue(forKey: key) else {
      fatalError("Non-optional toOne relationship contains nil value?!")
    }
    return value
  }
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T?) where T: PersistentModel {
    _setValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T? where T: PersistentModel {
    _getValue(forKey: key)
  }
  
  // Codable disambiguation
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T) 
    where T: PersistentModel & Encodable
  {
    _setValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: PersistentModel & Encodable
  {
    guard let value : T = _getValue(forKey: key) else {
      fatalError("Non-optional toOne relationship contains nil value?!")
    }
    return value
  }
  
  @inlinable
  func setValue<T>(forKey key: String, to model: T?) 
    where T: PersistentModel & Encodable
  {
    _setValue(forKey: key, to: model)
  }
  @inlinable
  func getValue<T>(forKey key: String) -> T? 
    where T: PersistentModel & Encodable
  {
    _getValue(forKey: key)
  }

  // Primitives

  @inlinable
  func _setValue<T>(forKey key: String, to model: T?) where T: PersistentModel {
    willChangeValue(forKey: key); defer { didChangeValue(forKey: key) }
    setPrimitiveValue(model, forKey: key)
  }
  
  @inlinable
  func _getValue<T>(forKey key: String) -> T? where T: PersistentModel {
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
    where T: RawRepresentable, T.RawValue: Encodable & CoreDataPrimitiveValue
  {
    setValue(forKey: key, to: value.rawValue)
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T
    where T: RawRepresentable, T.RawValue: Decodable & CoreDataPrimitiveValue
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
  
  @inlinable
  func setValue<T>(forKey key: String, to value: T) where T: Encodable {
    do {
      let data = try JSONEncoder().encode(value)
      setValue(forKey: key, to: data)
    }
    catch {
      fatalError("Could not encode JSON value for key \(key)? \(error)")
    }
  }
  
  @inlinable
  func getValue<T>(forKey key: String) -> T where T: Decodable {
    let data : Data? = getValue(forKey: key)
    do {
      return try JSONDecoder().decode(T.self, from: data ?? Data())
    }
    catch {
      fatalError("Could not decode JSON value for key \(key)? \(error)")
    }
  }
}
