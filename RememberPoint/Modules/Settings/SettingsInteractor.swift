//
//  SettingsInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation

protocol SettingsInteractorProtocol: AnyObject {
    var radiusValues: [Int] { get }
    var currentRadius: Int { get }
    var remindersEnabled: Bool { get }
    var notificationAlarm: ((Bool) -> Void)? { get set }
    var locationAlarm: ((Bool) -> Void)? { get set }
    init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol, settingsProvider: SettingsProviderProtocol)
    func setRadius(by index: Int)
    func setReminders(enabled: Bool)
    func checkAndAskPermissions()
}

class SettingsInteractor: SettingsInteractorProtocol {
    let locationManager: LocationManagerProtocol
    let radiusValues: [Int] = Constants.radiusValues
    private let reminderService: LocationReminderProtocol
    private let notificationService: NotificationServiceProtocol
    private var settingsProvider: SettingsProviderProtocol
    var locationAlarm: ((Bool) -> Void)?
    var notificationAlarm: ((Bool) -> Void)?

    var currentRadius: Int {
        return UserDefaults.standard.radius
    }

    var remindersEnabled: Bool {
        return UserDefaults.standard.remindersEnabled
    }

    required init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol, settingsProvider: SettingsProviderProtocol) {
        self.locationManager = locationManager
        self.reminderService = reminderService
        self.notificationService = notificationService
        self.settingsProvider = settingsProvider
        self.locationManager.delegate = self
    }

    func setRadius(by index: Int) {
        settingsProvider.radius = radiusValues[index]
        reminderService.update()
    }

    func setReminders(enabled: Bool) {
        settingsProvider.remindersEnabled = enabled
        reminderService.update()
    }

    func checkAndAskPermissions() {
        if locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }

        notificationService.getAuthorizationStatus { [unowned self] status in
            self.notificationAlarm?(status == .authorized)
        }
    }
}

// MARK: LocationDelegate

extension SettingsInteractor: LocationManagerDelegateProtocol {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .authorizedAlways:
            locationAlarm?(true)
        default:
            locationAlarm?(false)
        }
    }

    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation) {}
    func locationManager(_ manager: LocationManagerProtocol, didExitRegion: CLRegion) {}
    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion: CLRegion) {}
}
