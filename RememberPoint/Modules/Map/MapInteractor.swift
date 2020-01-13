//
//  MapInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation
import RxCocoa

protocol MapInteractorProtocol: AnyObject {
    var currentLocation: GeoPoint? { get }
    var longTapSuggestShown: Bool { get set }
    init(geocodeProvider: GeocodingProviderProtocol, settingsProvider: SettingsProviderProtocol, locationManager: LocationManagerProtocol, dataProvider: RealmDataProvider)
    func searchAddresses(by point: GeoPoint) -> PublishRelay<GeocodingResult>
    func getActiveTasks() -> [Task]?
    func startUpdateLocation()
    func stopUpdateLocation()
}

class MapInteractor: MapInteractorProtocol {
    private let geocodeProvider: GeocodingProviderProtocol!
    private let dataProvider: RealmDataProvider
    private var settingsProvider: SettingsProviderProtocol
    private let locationManager: LocationManagerProtocol

    var currentLocation: GeoPoint? {
        return settingsProvider.currentLocation
    }

    var longTapSuggestShown: Bool {
        get {
            return settingsProvider.longTapSuggestShown
        }
        set {
            settingsProvider.longTapSuggestShown = true
        }
    }

    required init(geocodeProvider: GeocodingProviderProtocol, settingsProvider: SettingsProviderProtocol, locationManager: LocationManagerProtocol, dataProvider: RealmDataProvider) {
        self.geocodeProvider = geocodeProvider
        self.dataProvider = dataProvider
        self.settingsProvider = settingsProvider
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }

    func searchAddresses(by point: GeoPoint) -> PublishRelay<GeocodingResult> {
        let relay = PublishRelay<GeocodingResult>()
        geocodeProvider.searchAddresses(by: point) { result in
            guard result.addressFound else { return }
            relay.accept(result)
        }
        return relay
    }

    func getActiveTasks() -> [Task]? {
        do {
            let tasks = try (dataProvider.getAll() as [RealmTask]).filter { !$0.isDone && $0.isEnabled }.map { Task(from: $0) }
            return tasks
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }

    func startUpdateLocation() {
        locationManager.startUpdates()
    }

    func stopUpdateLocation() {
        locationManager.stopUpdates()
    }
}

extension MapInteractor: LocationManagerDelegateProtocol {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus) {}

    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation) {
        settingsProvider.currentLocation = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: LocationManagerProtocol, didExitRegion region: CLRegion) {}

    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion region: CLRegion) {}
}
