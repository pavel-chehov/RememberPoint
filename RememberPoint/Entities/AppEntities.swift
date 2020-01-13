//
//  Task.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 09/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation

class BaseEntity {
    private(set) var id: String?
    init() {}
    init(from entity: BaseRealmEntity) {
        id = entity.id
    }
}

class Task: BaseEntity {
    var title: String?
    var address: String?
    var isEnabled: Bool = true
    var isDone: Bool = false
    var startDate: Date?
    var endDate: Date?
    var location: GeoPoint?
    var region: CLCircularRegion?
    var notes: String?

    override init() {
        super.init()
    }

    init(from task: RealmTask) {
        super.init(from: task)
        title = task.title
        address = task.address
        isEnabled = task.isEnabled
        isDone = task.isDone
        startDate = task.startDate
        endDate = task.endDate
        notes = task.notes
        if let location = task.location {
            self.location = GeoPoint(from: location)
        }
    }
}

class GeoPoint: BaseEntity {
    var latitude: Double?
    var longitude: Double?

    init(from point: RealmGeoPoint) {
        super.init(from: point)
        latitude = point.latitude
        longitude = point.longitude
    }

    init(latitude: Double, longitude: Double) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
