//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftDiagnostics

enum MacroDiagnostic: String, DiagnosticMessage, Swift.Error {
  
  case modelMacroCanOnlyBeAppliedOnNSManagedObjects
  
  case multipleAttributeMacrosAppliedOnProperty
  case multipleRelationshipMacrosAppliedOnProperty
  case attributeAndRelationshipMacrosAppliedOnProperty
  case propertyNameIsForbidden

  case propertyHasNeitherTypeNorInit
  
  case multipleMembersInAttributesMacroCall
  
  case unexpectedTypeForExtension
  
  var message: String {
    switch self {
      case .modelMacroCanOnlyBeAppliedOnNSManagedObjects:
        "The @Model macro can only be applied on classes that inherit from NSManagedObject."
        
      case .propertyNameIsForbidden:
        "This property name cannot be used in NSManagedObject types, " +
        "it is a system property."
        
      case .multipleAttributeMacrosAppliedOnProperty:
        "Multiple @Attribute macros applied on property."
      case .multipleRelationshipMacrosAppliedOnProperty:
        "Multiple @Relationship macros applied on property."
      case .attributeAndRelationshipMacrosAppliedOnProperty:
        "Both @Attribute and @Relationship macros applied on property."
        
      case .propertyHasNeitherTypeNorInit:
        "Property has neither type nor initializer?"
        
      case .multipleMembersInAttributesMacroCall:
        "Compiler issue, multiple members in attributes macro."
      case .unexpectedTypeForExtension:
        "Compiler issue, unexpected type passed into extension."
    }
  }
  
  var diagnosticID: SwiftDiagnostics.MessageID {
    .init(domain: "ModelsMacro", id: rawValue)
  }
  
  var severity: SwiftDiagnostics.DiagnosticSeverity {
    .error
  }
}
