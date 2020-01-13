//
//  Task.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 08/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Realm
import RealmSwift

class BaseRealmEntity: Object {
    @objc dynamic var id: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class RealmTask: BaseRealmEntity {
    @objc dynamic var title: String?
    @objc dynamic var address: String?
    @objc dynamic var isEnabled: Bool = false
    @objc dynamic var isDone: Bool = false
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var location: RealmGeoPoint?
    @objc dynamic var notes: String?

    init(from task: Task) {
        super.init()
        if let id = task.id {
            self.id = id
        }
        title = task.title
        address = task.address
        isEnabled = task.isEnabled
        isDone = task.isDone
        startDate = task.startDate
        endDate = task.endDate
        notes = task.notes
        if let location = task.location {
            self.location = RealmGeoPoint(from: location)
        }
    }

    required init() {
        super.init()
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}

final class RealmGeoPoint: BaseRealmEntity {
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0

    init(from point: GeoPoint) {
        super.init()
        if let id = point.id {
            self.id = id
        }
        if let latitude = point.latitude {
            self.latitude = latitude
        }
        if let longitude = point.longitude {
            self.longitude = longitude
        }
    }

    required init() {
        super.init()
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}
