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
}

extension Collection where Element == ModelInitializer {

  var hasNoArgumentInitializer: Bool {
    // TBD: should also check for default arguments!!
    guard !self.isEmpty else { return false }
    return self.contains(where: { $0.parameterKeywords.isEmpty })
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
      
      var keywords = [ String ]()
      for parameter : FunctionParameterSyntax
            in initDecl.signature.parameterClause.parameters
      {
        if parameter.firstName.tokenKind == .wildcard { keywords.append("") }
        else { keywords.append(parameter.firstName.trimmedDescription) }
      }
      
      initializers.append(ModelInitializer(
        isConvenience: initDecl.isConvenience,
        parameterKeywords: keywords
      ))
    }
    return initializers
  }
}
