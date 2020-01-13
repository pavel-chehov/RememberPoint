//
// Created by Pavel Chehov on 2019-01-11.
// Copyright (c) 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    init(from point: GeoPoint) {
        self.init()
        latitude = point.latitude ?? 0
        longitude = point.longitude ?? 0
    }
}

extension CLLocation {
    convenience init(from point: GeoPoint) {
        self.init(latitude: point.latitude ?? 0, longitude: point.longitude ?? 0)
    }
}
