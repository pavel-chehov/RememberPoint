//
//  RealmMigrationService.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 17/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmMigrationProtocol {
    func migrateIfNeeded()
}

final class RealmMigrationService: RealmMigrationProtocol {
    static let instance = RealmMigrationService()
    private init() {}
    func migrateIfNeeded() {
        let newSchemeVersion: UInt64 = 0
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: newSchemeVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < newSchemeVersion {
                    migration.enumerateObjects(ofType: RealmTask.className()) { _, _ in
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
}
