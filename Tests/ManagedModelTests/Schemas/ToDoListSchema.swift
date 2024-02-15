//
//  Created by Helge Heß.
//  Copyright © 2024 ZeeZide GmbH.
//

import ManagedModels

extension Fixtures {
  
  enum ToDoListSchema: VersionedSchema {
    static var models : [ any PersistentModel.Type ] = [
      ToDo.self, ToDoList.self
    ]
    
    public static let versionIdentifier = Schema.Version(0, 1, 0)
    
    @Model
    final class ToDo: NSManagedObject {
      
      var title     : String
      var isDone    : Bool
      var priority  : Priority
      var created   : Date
      var due       : Date?
      var list      : ToDoList
      
      enum Priority: Int, Comparable, CaseIterable, Codable {
        case veryLow  = 1
        case low      = 2
        case medium   = 3
        case high     = 4
        case veryHigh = 5
        
        static func < (lhs: Self, rhs: Self) -> Bool {
          lhs.rawValue < rhs.rawValue
        }
      }
      
      convenience init(list     : ToDoList,
                       title    : String,
                       isDone   : Bool     = false,
                       priority : Priority = .medium,
                       created  : Date     = Date(),
                       due      : Date?    = nil)
      {
        // This is important so that the objects don't end up in different
        // contexts.
        self.init(context: list.modelContext)
        
        self.list     = list
        self.title    = title
        self.isDone   = isDone
        self.priority = priority
        self.created  = created
        self.due      = due
      }
      
      var isOverDue : Bool {
        guard let due else { return false }
        return due < Date()
      }
    }
    
    @Model
    final class ToDoList: NSManagedObject {
      
      var title = ""
      var toDos = [ ToDo ]()
      
      convenience init(title: String) {
        self.init()
        self.title = title
      }
      
      var hasOverdueItems : Bool { toDos.contains { $0.isOverDue && !$0.isDone } }
      
      enum Doneness { case all, none, some }
      
      var doneness : Doneness {
        let hasDone   = toDos.contains {  $0.isDone }
        let hasUndone = toDos.contains { !$0.isDone }
        switch ( hasDone, hasUndone ) {
          case ( true  , true  ) : return .some
          case ( true  , false ) : return .all
          case ( false , true  ) : return .none
          case ( false , false ) : return .all // empty
        }
      }
    }
  }
}
