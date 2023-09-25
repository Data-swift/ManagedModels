//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ModelMacro {
  
  static func generateInitializers(
    for  classDecl : ClassDeclSyntax,
    access         : String,
    modelClassName : TokenSyntax,
    properties     : [ ModelProperty    ],
    initializers   : [ ModelInitializer ]
  ) -> [ DeclSyntax ]
  {
    var newInitializers = [ DeclSyntax ]()
    
    if !properties.isEmpty && initializers.isEmpty {
      if let decl = generatePropertyInitializer(
        for: classDecl, access: access, modelClassName: modelClassName,
        properties: properties
      ) {
        newInitializers.append(decl)
      }
    }
    
    /// This is needed to make it available when the user writes an own
    /// designated initializer alongside!
    let designatedInit : DeclSyntax =
      """
      /// Initialize a `\(modelClassName)` object, optionally providing an
      /// `NSManagedObjectContext` it should be inserted into.
      /// - Parameters:
      //    - entity:  An `NSEntityDescription` describing the object.
      //    - context: An `NSManagedObjectContext` the object should be inserted into.
      @available(*, deprecated, renamed: "init(context:)",
                 message: "Use `init(context:)`/`init()` instead.")
      \(raw: access)override init(entity: CoreData.NSEntityDescription,
            insertInto context: NSManagedObjectContext? = nil)
      {
        assert(entity === Self._$entity, "Attempt to initialize PersistentModel w/ different entity?")
        super.init(entity: entity, insertInto: context)
      }
      """
    if initializers.hasDesignatedInitializers {
      newInitializers.append(designatedInit)
    }
    
    // This has to be a convenience init because the user might add an own
    // required init, e.g.:
    //   init(name: String) {
    //     self.init() // he has to call this, but this breaks!
    //     self.name = name
    //   }
    // The problem is that designated initializers cannot delegate to other
    // designated initializers.
    let insertWithContext : DeclSyntax =
      """
      /// Initialize a `\(modelClassName)` object, optionally providing an
      /// `NSManagedObjectContext` it should be inserted into.
      /// - Parameters:
      //    - context: An `NSManagedObjectContext` the object should be inserted into.
      \(raw: access)init(context: CoreData.NSManagedObjectContext?) {
        super.init(entity: Self._$entity, insertInto: context)
      }
      """
    newInitializers.append(insertWithContext)
    
    if !initializers.hasNoArgumentInitializer {
      let noArgumentInitializer : DeclSyntax =
        """
        /// Initialize a `\(modelClassName)` object w/o inserting it into a
        /// context.
        \(raw: access)init() {
          super.init(entity: Self._$entity, insertInto: nil)
        }
        """
      newInitializers.append(noArgumentInitializer)
    }
    
    return newInitializers
  }
  
  private static func generatePropertyInitializer(
    for  classDecl : ClassDeclSyntax,
    access         : String,
    modelClassName : TokenSyntax,
    properties     : [ ModelProperty ]
  ) -> DeclSyntax?
  {
    // This is only called if the user has specified no initializers. Synthesize
    // one for (all!) the stored properties.
    
    #if false // TODO!
    for member : MemberBlockItemSyntax in classDecl.memberBlock.members {
      guard let variables = member.decl.as(VariableDeclSyntax.self),
            !variables.isStaticOrClass else
      {
        continue
      }

      // Each binding is a variable in a declaration list,
      // e.g. `let a = 5, b = 6`, the `a` and `b` would be bindings.
      for binding : PatternBindingSyntax in variables.bindings {
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let type : TypeSyntax = binding.typeAnnotation?.type else 
        {
          continue
        }
        let name = pattern.identifier.trimmed.text
        
        // Type is String or Set<Address> etc.
        // Emit initializer if available? Might use non-public things?
        // TODO: How to build the AST for the signature?
        
        print("Name:", name)
        print("  Type:", type)
        print("  Init:", binding.initializer?.value)
      }
    }
    #endif
    return nil
  }
}
