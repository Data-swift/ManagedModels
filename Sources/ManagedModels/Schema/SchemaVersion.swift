//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

public extension Schema {
  
  struct Version: Codable, Hashable {
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public init(_ major: Int, _ minor: Int, _ patch: Int) {
      self.major = major
      self.minor = minor
      self.patch = patch
    }
  }
}

extension Schema.Version: CustomStringConvertible {
  
  @inlinable
  public var description: String { "\(major).\(minor).\(patch)" }
}

extension Schema.Version: Comparable {
  
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.major != rhs.major { return lhs.major < rhs.major }
    if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
    if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
    return true // TBD
  }
}
