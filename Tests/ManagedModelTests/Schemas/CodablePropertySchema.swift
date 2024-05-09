//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  // https://github.com/Data-swift/ManagedModels/issues/27
  
  enum CodablePropertiesSchema: VersionedSchema {
    static var models : [ any PersistentModel.Type ] = [
      StoredAccess.self
    ]
    
    public static let versionIdentifier = Schema.Version(0, 1, 0)

    @Model
    final class StoredAccess: NSManagedObject {
      var token   : String
      var expires : Date
      var sip     : AccessSIP
      var optionalSip : AccessSIP?
    }
    
    struct AccessSIP: Codable {
      var username : String
      var password : String
      var realm    : String
    }
  }
}
