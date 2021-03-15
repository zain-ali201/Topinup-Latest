//
//  RealmConfig.swift
//  Topinup
//
//  Created by Zain Ali on 9/18/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import RealmSwift
class RealmConfig {
    private static let schemaVersion: UInt64 = 1
//    private static let fileURL = FileManager.default
//    .containerURL(forSecurityApplicationGroupIdentifier: Config.groupName)!
//    .appendingPathComponent("default.realm")
    static func getConfig(fileURL: URL, objectTypes: [Object.Type]? = nil) -> Realm.Configuration {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            fileURL: fileURL,


            schemaVersion: schemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion == 0) {
                    migration.renameProperty(onType: "FireCall", from: "callType", to: "direction")

                }
               
                
            }
            ,objectTypes: objectTypes

        )
        return config
    }

}
