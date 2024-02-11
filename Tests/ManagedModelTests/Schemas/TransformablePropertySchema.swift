//
//  TransformablePropertySchema.swift
//  Created by Adam Kopeć on 11/02/2024.
//

import ManagedModels

extension Fixtures {
    // https://github.com/Data-swift/ManagedModels/issues/4
    
    enum TransformablePropertiesSchema: VersionedSchema {
        static var models : [ any PersistentModel.Type ] = [
            StoredAccess.self
        ]
        
        public static let versionIdentifier = Schema.Version(0, 1, 0)
        
        @Model
        final class StoredAccess: NSManagedObject {
            var token   : String
            var expires : Date
            @Attribute(.transformable(by: AccessSIPTransformer.self))
            var sip     : AccessSIP
        }
        
        class AccessSIP: NSObject {
            var username : String
            var password : String
            
            init(username: String, password: String) {
                self.username = username
                self.password = password
            }
        }
        
        class AccessSIPTransformer: ValueTransformer {
            override class func transformedValueClass() -> AnyClass {
                return AccessSIP.self
            }
            
            override class func allowsReverseTransformation() -> Bool {
                return true
            }
            
            override func transformedValue(_ value: Any?) -> Any? {
                guard let data = value as? Data else { return nil }
                guard let array = try? JSONDecoder().decode([String].self, from: data) else { return nil }
                return AccessSIP(username: array[0], password: array[1])
            }
            
            override func reverseTransformedValue(_ value: Any?) -> Any? {
                guard let sip = value as? AccessSIP else { return nil }
                return try? JSONEncoder().encode([sip.username, sip.password])
            }
        }
    }
}
