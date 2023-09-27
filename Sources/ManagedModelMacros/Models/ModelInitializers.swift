//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct ModelInitializer {

  /// Whether the initializer is a convenience initializer.
  let isConvenience     : Bool
  
  /// Just the keyword parts of the selector, empty for wildcard.
  let parameterKeywords : [ String ]
  
  let numberOfParametersWithoutDefaults : Int
}

extension Collection where Element == ModelInitializer {

  /// Either has a plain `init()` or an init that has all parameters w/ a
  /// default (e.g. `init(title: String = "")`) which can be called w/o
  /// specifying parameters.
  var hasNoArgumentInitializer: Bool {
    guard !self.isEmpty else { return false }
    return self.contains(where: { $0.numberOfParametersWithoutDefaults == 0 })
  }

  var hasDesignatedInitializers: Bool {
    guard !self.isEmpty else { return false }
    return self.contains(where: { !$0.isConvenience })
  }
}

extension ModelInitializer: CustomStringConvertible {
  var description: String {
    var ms = "<Init"
    if isConvenience { ms += " convenience" }
    if !parameterKeywords.isEmpty {
      ms += " "
      ms += parameterKeywords.joined(separator: ",")
    }
    ms += ">"
    return ms
  }
}

extension ModelMacro {
    
  static func findInitializers(in classDecl: ClassDeclSyntax)
              -> [ ModelInitializer ]
  {
    var initializers = [ ModelInitializer ]()
    
    for member : MemberBlockItemSyntax in classDecl.memberBlock.members {
      guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
        continue
      }
      
      var numberOfParametersWithoutDefaults = 0
      var keywords = [ String ]()
      for parameter : FunctionParameterSyntax
            in initDecl.signature.parameterClause.parameters
      {
        if parameter.firstName.tokenKind == .wildcard { keywords.append("") }
        else { keywords.append(parameter.firstName.trimmedDescription) }
        
        if parameter.defaultValue == nil {
          numberOfParametersWithoutDefaults += 1
        }
      }
      
      initializers.append(ModelInitializer(
        isConvenience: initDecl.isConvenience,
        parameterKeywords: keywords,
        numberOfParametersWithoutDefaults: numberOfParametersWithoutDefaults
      ))
    }
    return initializers
  }
}
