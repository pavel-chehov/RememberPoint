//
//  AppDelegate.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Firebase
import GoogleMaps
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Theme.initAppearance()
        FirebaseApp.configure()
        GMSServices.provideAPIKey(Constants.GoogleApiKey)
        RealmMigrationService.instance.migrateIfNeeded()

        LocationReminderService.instance.configure(
            locationManager: DIContainer.instance.resolve(),
            notificationService: DIContainer.instance.resolve(),
            settingsProvider: DIContainer.instance.resolve(),
            dataProvider: RealmDataProvider(),
            router: DIContainer.instance.resolve()
        )
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            LocationReminderService.instance.update()
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = UINavigationController()
        window?.rootViewController = rootVC
        if UserDefaults.standard.isInitialised {
            rootVC.setViewControllers([UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!], animated: false)
        } else {
            rootVC.setViewControllers([UIStoryboard(name: "Setup", bundle: nil).instantiateInitialViewController()!], animated: false)
        }
        window?.makeKeyAndVisible()
        return true
    }
}
