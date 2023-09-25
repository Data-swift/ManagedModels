//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

public protocol SchemaProperty : NSPropertyDescription, Hashable {

  var name           : String   { get set }
  var originalName   : String   { get set }

  var valueType      : Any.Type { get set }

  var isAttribute    : Bool     { get }
  var isRelationship : Bool     { get }
  var isTransient    : Bool     { get }
  var isOptional     : Bool     { get }
  
  var isUnique       : Bool     { get }
}

public extension SchemaProperty {
  
  @inlinable
  var originalName: String {
    get { renamingIdentifier ?? "" }
    set { renamingIdentifier = newValue }
  }
}
