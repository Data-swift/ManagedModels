//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension NSManagedObjectModel {
  
  /**
   * Metadata for a property of a ``NSManagedObjectModel`` object.
   *
   * All (code defined) properties of the ``NSManagedObjectModel`` are stored
   * in the `schemaMetadata` static property.
   */
  struct PropertyMetadata {
    
    /// The name of the property instance variable, e.g. `street`.
    public let name         : String
    
    /// A Swift keypath that can be used to access the instance variable,
    /// e.g. `\Address.street`.
    public let keypath      : AnyKeyPath
    
    /// The default value associated with the property, e.g. `""`.
    public let defaultValue : Any?
    
    /**
     * Either a ``NSAttributeDescription`` or a ``NSRelationshipDescription``
     * object (or nil if the user didn't specify an `@Attribute` or
     * `@Relationship` macro).
     * Note: This is never modified, it is treated as a template and gets
     *       copied when the `NSEntityDescription` is built.
     */
    public let metadata     : NSPropertyDescription?
    
    /**
     * Create a new ``PropertyMetadata`` value.
     *
     * - Parameters:
     *   - name:         name of the property instance variable, e.g. `street`.
     *   - keypath:      KeyPath to access the related instance variable.
     *   - defaultValue: The properties default value, if available.
     *   - metadata:     Either nothing, or a template Attribute/Relationship.
     */
    public init(name: String, keypath: AnyKeyPath,
                defaultValue: Any? = nil,
                metadata: NSPropertyDescription? = nil)
    {
      self.name         = name
      self.keypath      = keypath
      self.defaultValue = defaultValue
      self.metadata     = metadata
    }
  }
}
