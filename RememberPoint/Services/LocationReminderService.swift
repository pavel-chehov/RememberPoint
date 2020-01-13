//
//  LocationReminderService.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 10/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation
import RealmSwift
import UserNotifications

protocol LocationReminderProtocol {
    func configure(
        locationManager: LocationManagerProtocol,
        notificationService: NotificationServiceProtocol,
        settingsProvider: SettingsProviderProtocol,
        dataProvider: RealmDataProvider,
        router: LocationReminderRouterProtocol
    )
    func update()
    func stop()
}

final class LocationReminderService: NSObject, LocationReminderProtocol {
    static let instance = LocationReminderService()
    private var locationManager: LocationManagerProtocol!
    private var dataProvider: RealmDataProvider!
    private var isStarted: Bool = false
    private var settingsProvider: SettingsProviderProtocol!
    private var notificationService: NotificationServiceProtocol!
    private var tasks = [Task]()
    private var router: LocationReminderRouterProtocol!

    private override init() {
        super.init()
    }

    func configure(
        locationManager: LocationManagerProtocol,
        notificationService: NotificationServiceProtocol,
        settingsProvider: SettingsProviderProtocol,
        dataProvider: RealmDataProvider,
        router: LocationReminderRouterProtocol
    ) {
        self.locationManager = locationManager
        self.dataProvider = dataProvider
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.settingsProvider = UserDefaults.standard
        self.notificationService = notificationService
        self.router = router
        self.locationManager.delegate = self
        self.notificationService.delegate = self
    }

    func update() {
        guard locationManager.authorizationStatus == .authorizedAlways else {
            Log.instance.write("\(#file): not permissions for \(#function)")
            return
        }
        Log.instance.write("\(#file): \(#function)")
        stop()
        guard let activeTasks = self.getActiveTasks()?.prefix(Constants.regionsMaximum),
            activeTasks.isEmpty else {
            tasks.removeAll()
            return
        }
        tasks = activeTasks.compactMap { task in
            guard let latitude = task.location?.latitude,
                let longitude = task.location?.longitude,
                let id = task.id else { return nil }
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                radius: Double(settingsProvider.radius), identifier: id
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            task.region = region
            return task
        }
        start()
    }

    func stop() {
        let regions = tasks.compactMap { $0.region }
        locationManager.stopMonitoring(regions: regions)
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    private func start() {
        locationManager.startMonitoringSignificantLocationChanges()
        let regions = tasks.compactMap { $0.region }
        locationManager.startMonitoring(regions: regions)
    }

    private func getActiveTasks() -> [Task]? {
        do {
            let allTasks = try (dataProvider.getAll() as [RealmTask]).map { Task(from: $0) }
            return filterTasks(tasks: allTasks)
        } catch {
            Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
            return nil
        }
    }

    private func filterTasks(tasks: [Task]) -> [Task]? {
        do {
            let tasksToBeDone = tasks.filter { task in
                guard let endDate = task.endDate else { return true }
                return endDate < Date() && !task.isDone
            }
            for donableTask in tasksToBeDone {
                donableTask.isDone = true
                try dataProvider.write(data: RealmTask(from: donableTask), update: true)
                Analytics.logEvent(Events.doneTask.rawValue, parameters: [Constants.type: DoneTaskType.automatically.rawValue])
            }

            let activeTasks = tasks.filter { task in
                guard let endDate = task.endDate else { return false }
                return endDate > Date() && !task.isDone && task.isEnabled
            }.sorted(by: { [unowned self] task1, task2 in
                guard let location1 = task1.location, let location2 = task2.location, let current = self.settingsProvider.currentLocation else { return false }
                let currentLocation = CLLocation(from: current)
                let distance1 = currentLocation.distance(from: CLLocation(from: location1))
                let distance2 = currentLocation.distance(from: CLLocation(from: location2))
                return distance1 < distance2
            })
            return activeTasks
        } catch {
            Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
            return nil
        }
    }

    private func doneActiveTask(with identifier: String) {
        do {
            removeTask(with: identifier)
            if let task: RealmTask = try dataProvider.get(by: identifier) {
                let proxyTask = Task(from: task)
                proxyTask.isDone = true
                try dataProvider.write(data: RealmTask(from: proxyTask), update: true)
            }
        } catch {
            Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
        }
    }

    private func disableActiveTask(with identifier: String) {
        do {
            removeTask(with: identifier)
            if let task: RealmTask = try dataProvider.get(by: identifier) {
                let proxyTask = Task(from: task)
                proxyTask.isEnabled = false
                try dataProvider.write(data: RealmTask(from: proxyTask), update: true)
            }
        } catch {
            Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
        }
    }

    private func removeTask(with identifier: String) {
        let index = tasks.firstIndex(where: { $0.id == identifier })
        if let index = index {
            tasks.remove(at: index)
        }
    }
}

extension LocationReminderService: LocationManagerDelegateProtocol {
    func locationManagerDidUpdateAuthorization(_ manager: LocationManagerProtocol, status: CLAuthorizationStatus) {}

    func locationManagerDidUpdateLocation(_ manager: LocationManagerProtocol, location: CLLocation) {
        Log.instance.write("\(#file): \(#function) \(location.coordinate.latitude) \(location.coordinate.longitude)")
        settingsProvider.currentLocation = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        update()
    }

    func locationManager(_ manager: LocationManagerProtocol, didExitRegion region: CLRegion) {
        let coordinate = (region as! CLCircularRegion).center
        Log.instance.write("\(#file): \(#function) \(coordinate.latitude) \(coordinate.longitude) for item: \(region.identifier)")
        if let task = tasks.first(where: { $0.id == region.identifier }) {
            if let id = task.id {
                notificationService.removeNotifications(withIdentifiers: [id])
            }
        }
    }

    func locationManager(_ manager: LocationManagerProtocol, didEnterRegion region: CLRegion) {
        let coordinate = (region as! CLCircularRegion).center
        Log.instance.write("\(#file): \(#function) \(coordinate.latitude) \(coordinate.longitude) item: \(region.identifier)")
        if let task = tasks.first(where: { $0.id == region.identifier }) {
            if let id = task.id, let title = task.title, let address = task.address {
                let text = "\(address)\n\(task.notes ?? "")"
                notificationService.createNotification(withIdentifier: id, timeInterval: Constants.defaultNotificationInterval, title: title, text: text, repeats: true)
            }
        }
    }
}

extension LocationReminderService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let presentOptions: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(presentOptions)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        switch response.actionIdentifier {
        case Actions.done.rawValue:
            doneActiveTask(with: identifier)
            Analytics.logEvent(Events.doneTask.rawValue, parameters: nil)
        case Actions.disable.rawValue:
            let identifier = response.notification.request.identifier
            disableActiveTask(with: identifier)
            Analytics.logEvent(Events.disableTaskFromNotification.rawValue, parameters: nil)
        default:
            router.navigateToTasks(withIdentifier: identifier)
            Analytics.logEvent(Events.navigateToTasksFromNotification.rawValue, parameters: nil)
        }
        notificationService.removeNotifications(withIdentifiers: [identifier])
        update()
        completionHandler()
    }
}
