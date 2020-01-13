//
//  MainInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation

protocol TabInteractorProtocol: AnyObject {
    var showSettingsAlarm: (() -> Void)? { get set }
    var hideSettingsAlarm: (() -> Void)? { get set }
    init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol)
    func checkAndAskPermissions()
}

class TabInteractor: TabInteractorProtocol {
    private let locationManager: LocationManagerProtocol
    private let reminderService: LocationReminderProtocol
    private let notificationService: NotificationServiceProtocol
    private var shouldShowNotificationAlarm = false
    private var shouldShowLocationAlarm = false
    var showSettingsAlarm: (() -> Void)?
    var hideSettingsAlarm: (() -> Void)?

    required init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol) {
        self.locationManager = locationManager
        self.reminderService = reminderService
        self.notificationService = notificationService
        self.locationManager.delegate = self
    }

    // asks in first
    func checkAndAskPermissions() {
        shouldShowLocationAlarm = locationManager.authorizationStatus != .authorizedAlways
        notificationService.getAuthorizationStatus { [unowned self] status in
            self.shouldShowNotificationAlarm = status != .authorized
            if self.shouldShowNotificationAlarm || self.shouldShowLocationAlarm {
                self.showSettingsAlarm?()
            } else {
                self.hideSettingsAlarm?()
            }
        }
        locationManager.requestAlwaysAuthorization()
    }
}

// asks in second
extension TabInteractor: LocationManagerDelegateProtocol {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus) {
        shouldShowLocationAlarm = status != .authorizedAlways
        Analytics.logEvent(Events.allowAlwaysLocation.rawValue, parameters: ["allowed": status == .authorizedAlways])
        switch status {
        case .authorizedAlways:
            reminderService.update()
            if !shouldShowNotificationAlarm {
                hideSettingsAlarm?()
            }
        default:
            showSettingsAlarm?()
        }
    }

    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation) {}
    func locationManager(_ manager: LocationManagerProtocol, didExitRegion: CLRegion) {}
    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion: CLRegion) {}
}
