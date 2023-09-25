//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

public protocol SchemaMigrationPlan {

  static var schemas : [ VersionedSchema.Type ] { get }
  static var stages  : [ MigrationStage       ] { get }
}
