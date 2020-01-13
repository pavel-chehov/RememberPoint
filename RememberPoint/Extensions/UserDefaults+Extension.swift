//
//  UserDefaults+Extension.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 10/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation

protocol SettingsProviderProtocol {
    var isInitialised: Bool { get set }
    var remindersEnabled: Bool { get set }
    var currentLocation: GeoPoint? { get set }
    var radius: Int { get set }
    var longTapSuggestShown: Bool { get set }
}

extension UserDefaults: SettingsProviderProtocol {
    var isInitialised: Bool {
        get {
            if object(forKey: #function) != nil {
                return bool(forKey: #function)
            }
            return false
        }
        set {
            set(newValue, forKey: #function)
        }
    }

    var longTapSuggestShown: Bool {
        get {
            if object(forKey: #function) != nil {
                return bool(forKey: #function)
            }
            return false
        }
        set {
            set(newValue, forKey: #function)
        }
    }

    var remindersEnabled: Bool {
        get {
            if object(forKey: #function) != nil {
                return bool(forKey: #function)
            }
            return true
        }
        set {
            set(newValue, forKey: #function)
        }
    }

    var currentLocation: GeoPoint? {
        get {
            if let latitude = self.currentLatitude, let longitude = self.currentLongitude {
                return GeoPoint(latitude: latitude, longitude: longitude)
            }
            return nil
        }
        set {
            currentLatitude = newValue?.latitude
            currentLongitude = newValue?.longitude
        }
    }

    var radius: Int {
        get {
            if object(forKey: #function) != nil {
                return integer(forKey: #function)
            }
            return Constants.radiusValues[0]
        }
        set { set(newValue, forKey: #function) }
    }

    private var currentLatitude: Double? {
        get {
            if object(forKey: #function) != nil {
                return double(forKey: #function)
            }
            return nil
        }
        set { set(newValue, forKey: #function) }
    }

    private var currentLongitude: Double? {
        get {
            if object(forKey: #function) != nil {
                return double(forKey: #function)
            }
            return nil
        }
        set { set(newValue, forKey: #function) }
    }
}
