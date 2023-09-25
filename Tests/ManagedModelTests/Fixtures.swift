//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import ManagedModels

enum Fixtures {
 
  @Model
  final class UniquePerson: NSManagedObject {
    @Attribute(.unique)
    var firstname : String
    var lastname  : String
  }
}
