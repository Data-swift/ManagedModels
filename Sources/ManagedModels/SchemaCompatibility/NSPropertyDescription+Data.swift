//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

private var _propertyIsUniqueAssociatedKey: UInt8 = 42

extension NSPropertyDescription {

  public internal(set) var isUnique: Bool {
    // Note: isUnique is only used during schema construction!
    set {
      if newValue {
        objc_setAssociatedObject(self, &_propertyIsUniqueAssociatedKey,
                                 type(of: self), .OBJC_ASSOCIATION_ASSIGN)
      }
      else {
        objc_setAssociatedObject(self, &_propertyIsUniqueAssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN)
      }
      #if false // do we need this? The entity might not yet be setup?
      guard !entity.isPropertyUnique(self) else { return }
      entity.uniquenessConstraints.append( [ self ])
      #endif
    }
    get {
      objc_getAssociatedObject(self, &_propertyIsUniqueAssociatedKey) != nil
        ? true
        : entity.isPropertyUnique(self)
    }
  }
}
