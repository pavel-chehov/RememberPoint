//
//  SetupInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation

protocol SetupInteractorProtocol: AnyObject {
    var showNext: (() -> Void)? { get set }
    init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol, settingsProvider: SettingsProviderProtocol)
    var setupData: [SetupCellData] { get }
    var currentPage: Int { get }
}

class SetupInteractor: SetupInteractorProtocol {
    private let locationManager: LocationManagerProtocol
    private let reminderService: LocationReminderProtocol
    private let notificationService: NotificationServiceProtocol
    private var settingsProvider: SettingsProviderProtocol
    private(set) var setupData: [SetupCellData]
    private(set) var currentPage = 0
    var showNext: (() -> Void)?

    required init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol, notificationService: NotificationServiceProtocol, settingsProvider: SettingsProviderProtocol) {
        self.locationManager = locationManager
        self.reminderService = reminderService
        self.notificationService = notificationService
        setupData = [SetupCellData]()
        self.settingsProvider = settingsProvider
        self.locationManager.delegate = self
        populateSetup()
    }

    private func populateSetup() {
        let first = SetupCellData(
            title: "Reminder address",
            text: "Select task address to bind the reminder to the required place.",
            buttonText: "Allow geolocation",
            imageName: "page1"
        ) { [unowned self] in
            self.locationManager.requestWhenInUseAuthorization()
        }
        let second = SetupCellData(
            title: "Never miss a task, we keep you notified",
            text: "We will always notify you whenever you’re near a task, so you won’t miss anything.",
            buttonText: "Allow notifications",
            imageName: "page2"
        ) { [unowned self] in
            self.notificationService.askAuthorization { status in
                self.showNextPage()
                Analytics.logEvent(Events.allowNotifications.rawValue, parameters: ["allowed": status == .authorized])
            }
        }
        let third = SetupCellData(
            title: "Final step",
            text: "To ensure correct app work, we need to have constant access to your location.",
            buttonText: "Next",
            imageName: "page3"
        ) { [unowned self] in
            self.settingsProvider.isInitialised = true
            self.showNextPage()
        }
        setupData = [first, second, third]
    }

    private func showNextPage() {
        DispatchQueue.main.async {
            self.currentPage += 1
            self.showNext?()
        }
    }
}

// asks in second
extension SetupInteractor: LocationManagerDelegateProtocol {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus) {
        if status != .notDetermined, status != .authorizedAlways {
            showNextPage()
        }
        Analytics.logEvent(Events.allowWhenInUseLocation.rawValue, parameters: ["allowed": status == .authorizedWhenInUse])
    }

    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation) {}
    func locationManager(_ manager: LocationManagerProtocol, didExitRegion: CLRegion) {}
    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion: CLRegion) {}
}
