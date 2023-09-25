//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import CoreData

public extension NSDeleteRule {
  static let noAction = Self.noActionDeleteRule
  static let nullify  = Self.nullifyDeleteRule
  static let cascade  = Self.cascadeDeleteRule
  static let deny     = Self.denyDeleteRule
}
