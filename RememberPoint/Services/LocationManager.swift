//
//  LocationManager.swift
//  Forecast
//
//  Created by Pavel Chehov on 26/12/2018.
//  Copyright © 2018 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation
import Realm

protocol LocationManagerProtocol: AnyObject {
    var delegate: LocationManagerDelegateProtocol? { get set }
    var currentLocation: CLLocation? { get }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var distanceFilter: CLLocationDistance { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var allowsBackgroundLocationUpdates: Bool { get set }
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func startUpdates()
    func stopUpdates()
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    func startMonitoring(for region: CLRegion)
    func stopMonitoring(for region: CLRegion)
    func startMonitoring(regions: [CLRegion])
    func stopMonitoring(regions: [CLRegion])
}

protocol LocationManagerDelegateProtocol: AnyObject {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus)
    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation)
    func locationManager(_ manager: LocationManagerProtocol, didExitRegion region: CLRegion)
    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion region: CLRegion)
}

class LocationManager: NSObject, CLLocationManagerDelegate, LocationManagerProtocol {
    weak var delegate: LocationManagerDelegateProtocol?
    private var cllLocationManager: CLLocationManager
    private let regionsLimit = 20

    var currentLocation: CLLocation? {
        return cllLocationManager.location
    }

    var pausesLocationUpdatesAutomatically: Bool {
        get {
            return cllLocationManager.pausesLocationUpdatesAutomatically
        }
        set {
            cllLocationManager.pausesLocationUpdatesAutomatically = newValue
        }
    }

    var distanceFilter: CLLocationDistance {
        get {
            return cllLocationManager.distanceFilter
        }
        set {
            cllLocationManager.distanceFilter = newValue
        }
    }

    var allowsBackgroundLocationUpdates: Bool {
        get {
            return cllLocationManager.allowsBackgroundLocationUpdates
        }
        set {
            cllLocationManager.allowsBackgroundLocationUpdates = newValue
        }
    }

    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    var canSignificantLocationChanges: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    var canMonitor: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways && CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    }

    var canUpdates: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    override init() {
        cllLocationManager = CLLocationManager()
        super.init()
        cllLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        cllLocationManager.delegate = self
        cllLocationManager.showsBackgroundLocationIndicator = false
    }

    func requestWhenInUseAuthorization() {
        guard authorizationStatus == .notDetermined else { return }
        cllLocationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        guard authorizationStatus == .authorizedWhenInUse else {
            return
        }
        cllLocationManager.requestAlwaysAuthorization()
    }

    func stopUpdates() {
        if canUpdates {
            cllLocationManager.stopUpdatingLocation()
            cllLocationManager.stopUpdatingHeading()
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func startUpdates() {
        if canUpdates {
            cllLocationManager.startUpdatingLocation()
            cllLocationManager.startUpdatingHeading()
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func startMonitoringSignificantLocationChanges() {
        if canSignificantLocationChanges {
            cllLocationManager.startMonitoringSignificantLocationChanges()
            Log.instance.write("\(#file): \(#function)")
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func stopMonitoringSignificantLocationChanges() {
        if canSignificantLocationChanges {
            cllLocationManager.stopMonitoringSignificantLocationChanges()
            Log.instance.write("\(#file): \(#function)")
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func startMonitoring(for region: CLRegion) {
        if canMonitor {
            cllLocationManager.startMonitoring(for: region)
            Log.instance.write("\(#file): \(#function) regionId: \(region.identifier)")
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func stopMonitoring(for region: CLRegion) {
        if canMonitor {
            cllLocationManager.stopMonitoring(for: region)
            Log.instance.write("\(#file): \(#function) regionId: \(region.identifier)")
        } else {
            Log.instance.write("\(#file): can't \(#function)")
        }
    }

    func startMonitoring(regions: [CLRegion]) {
        guard regions.count <= 20 else {
            Log.instance.write("\(#file): can't monitor more then \(regionsLimit) regions")
            return
        }
        for region in regions {
            startMonitoring(for: region)
        }
    }

    func stopMonitoring(regions: [CLRegion]) {
        for region in regions {
            stopMonitoring(for: region)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManagerDidUpdateAuthorization(self, status: status)
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            delegate?.locationManagerDidUpdateLocation(self, location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.locationManager(self, didEnterRegion: region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.locationManager(self, didExitRegion: region)
    }
}
