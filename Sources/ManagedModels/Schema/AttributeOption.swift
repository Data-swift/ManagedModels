//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import class Foundation.ValueTransformer

extension NSAttributeDescription {
  
  public struct Option: Equatable {
    
    let value : Value
    
    public static let unique    = Self(value: .unique)
    public static let ephemeral = Self(value: .ephemeral)
    public static let spotlight = Self(value: .spotlight)

    /// Use a Foundation `ValueTransformer`.
    public static func transformable(by transformerType: ValueTransformer.Type)
                       -> Self
    {
      Self(value: .transformableByType(transformerType))
    }
    public static func transformable(by transformerName: String) -> Self {
      Self(value: .transformableByName(transformerName))
    }
    
    public static let externalStorage = Self(value: .externalStorage)
    
    @available(iOS 15.0, macOS 12.0, *)
    public static let allowsCloudEncryption =
                        Self(value: .allowsCloudEncryption)
    
    public static let preserveValueOnDeletion =
                        Self(value: .preserveValueOnDeletion)
  }
  
}

extension NSAttributeDescription.Option {
  
  enum Value {
    case unique, externalStorage, preserveValueOnDeletion, ephemeral, spotlight
    case transformableByType(ValueTransformer.Type)
    case transformableByName(String)
    
    @available(iOS 15.0, macOS 12.0, *)
    case allowsCloudEncryption
  }
}

extension NSAttributeDescription.Option.Value: Equatable {
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch ( lhs, rhs ) {
      case ( .unique          , .unique          ): return true
      case ( .externalStorage , .externalStorage ): return true
      case ( .ephemeral       , .ephemeral       ): return true
      case ( .spotlight       , .spotlight       ): return true
      case ( .transformableByType(let lhs), .transformableByType(let rhs) ):
        return lhs == rhs
      case ( .transformableByName(let lhs), .transformableByName(let rhs) ):
        return lhs == rhs
      case ( .allowsCloudEncryption , .allowsCloudEncryption ):
        return true
      case ( .preserveValueOnDeletion, .preserveValueOnDeletion ):
        return true
      default: return false
    }
  }
}
