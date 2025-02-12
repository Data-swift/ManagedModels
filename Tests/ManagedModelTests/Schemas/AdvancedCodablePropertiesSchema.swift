//
//  AdvancedCodablePropertiesSchema.swift
//  ManagedModels
//
//  Created by Adam Kopeć on 04/02/2025.
//

import ManagedModels

extension Fixtures {
    // https://github.com/Data-swift/ManagedModels/issues/36
    
    enum AdvancedCodablePropertiesSchema: VersionedSchema {
        static var models : [ any PersistentModel.Type ] = [
            AdvancedStoredAccess.self
        ]
        
        public static let versionIdentifier = Schema.Version(0, 1, 0)
        
        @Model
        final class AdvancedStoredAccess: NSManagedObject {
            var token   : String
            var expires : Date
            var integer : Int
            var distance: Int?
            var avgSpeed: Double?
            var sip     : AccessSIP
            var numArray: [Int]
            var array   : [String]
            var array2  : Array<String>
            var optionalNumArray : [Int]?
            var optionalNumArray2: Array<Int>?
            var optionalArray    : [String]?
            var optionalArray2   : Array<String>?
            var optionalSip      : AccessSIP?
            var codableSet       : Set<AccessSIP>
            var objcSet          : Set<String>
            var objcNumSet       : Set<Int>
            var codableArray     : [AccessSIP]
            var optCodableSet    : Set<AccessSIP>?
            var optCodableArray  : [AccessSIP]?
        }
        
        struct AccessSIP: Codable, Hashable {
            var username : String
            var password : String
            var realm    : String
        }
    }
}
