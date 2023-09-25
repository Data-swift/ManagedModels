//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import Foundation

// Generic subclasses of '@objc' classes cannot have an explicit '@objc'
// because they are not directly visible from Objective-C.
// W/o @objc the declaration works, but then @NSManaged complains about the
// thing not being available in ObjC.
#if false
@objc public final class OrderedSet<Element>: NSOrderedSet
  where Element: Hashable
{
  // This is to enable the use of NSOrderedSet w/ `RelationshipCollection`.
}
#endif
