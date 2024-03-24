//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension NSRelationshipDescription {
  
  struct Option: Equatable, Sendable {
    
    enum Value: Sendable {
      case unique
    }
    let value : Value
    
    /// Only one record may point to the target of this relationship.
    public static let unique = Self(value: .unique)
  }
}
