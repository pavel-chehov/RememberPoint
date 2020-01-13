//
//  NotificationService.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 13/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import UIKit
import UserNotifications
// You must assign your delegate to the shared UNUserNotificationCenter object before your app or app extension finishes launching.
// Failure to do so may prevent your app from handling notifications correctly.

protocol NotificationServiceDelegateProtocol: AnyObject {
    func handleNotification(action: Actions)
}

protocol NotificationServiceProtocol {
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
    func createNotification(withIdentifier identifier: String, timeInterval: Int, title: String, text: String, repeats: Bool)
    func createLocationNotification(withIdentifier identifier: String, title: String, text: String, region: CLRegion, repeats: Bool)
    func removeNotifications(withIdentifiers identifiers: [String])
    func askAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void)
    var delegate: UNUserNotificationCenterDelegate? { get set }
}

enum Actions: String {
    case done = "Done"
    case disable = "Disable"
}

class NotificationService: NotificationServiceProtocol {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let authorizedOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
    private let presentOptions: UNNotificationPresentationOptions = [.alert, .sound]
    private let userActionsIdentifier = "UserActions"
    var delegate: UNUserNotificationCenterDelegate? {
        get {
            return notificationCenter.delegate
        } set {
            notificationCenter.delegate = newValue
        }
    }

    func askAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.requestAuthorization(options: authorizedOptions) { [unowned self] didAllow, _ in
            if didAllow {
                self.registerUserActionCategories()
                completion(UNAuthorizationStatus.authorized)
            } else {
                Log.instance.write("\(#function): User has declined notifications")
                completion(UNAuthorizationStatus.denied)
            }
        }
    }

    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            let status = settings.authorizationStatus
            completion(status)
        }
    }

    func createNotification(withIdentifier identifier: String, timeInterval: Int, title: String, text: String, repeats: Bool) {
        getAuthorizationStatus { [unowned self] status in
            guard status == .authorized else {
                Log.instance.write("\(#function): unauthorized for notifications")
                return
            }
            let content = self.createContent(title: title, text: text)

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: repeats)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self.notificationCenter.add(request) { error in
                if let error = error {
                    Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    func removeNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func createLocationNotification(withIdentifier identifier: String, title: String, text: String, region: CLRegion, repeats: Bool) {
        getAuthorizationStatus { [unowned self] status in
            guard status == .authorized else {
                Log.instance.write("\(#function): unauthorized for notifications")
                return
            }
            let content = self.createContent(title: title, text: text)

            let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self.notificationCenter.add(request) { error in
                if let error = error {
                    Log.instance.write("\(#file): \(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    func askAuthorization() {
        notificationCenter.requestAuthorization(options: authorizedOptions) { [unowned self] didAllow, _ in
            if !didAllow {
                Log.instance.write("\(#function): User has declined notifications")
            } else {
                self.registerUserActionCategories()
            }
        }
    }

    private func createContent(title: String, text: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userActionsIdentifier
        return content
    }

    private func registerUserActionCategories() {
        let doneAction = UNNotificationAction(identifier: Actions.done.rawValue, title: Actions.done.rawValue, options: [])
        let deleteAction = UNNotificationAction(identifier: Actions.disable.rawValue, title: Actions.disable.rawValue, options: [.destructive])
        let category = UNNotificationCategory(
            identifier: userActionsIdentifier,
            actions: [doneAction, deleteAction],
            intentIdentifiers: [],
            options: []
        )
        notificationCenter.setNotificationCategories([category])
    }
}
