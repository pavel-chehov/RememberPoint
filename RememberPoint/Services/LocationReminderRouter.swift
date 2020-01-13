//
//  LocationReminderRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 17/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol LocationReminderRouterProtocol {
    func navigateToTasks(withIdentifier: String)
}

class LocationReminderRouter: LocationReminderRouterProtocol {
    func navigateToTasks(withIdentifier identifier: String) {
        if let tabBar = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.viewControllers.first as? TabViewController {
            if tabBar.isLoaded {
                // if app was launched
                tabBar.selectedIndex = 1
                if let tasksVC = (tabBar.selectedViewController as? UINavigationController)?.viewControllers.first as? TasksViewProtocol {
                    if tasksVC.isLoaded {
                        tasksVC.presenter?.askDoneTask(withIdentifier: identifier)
                    } else {
                        tasksVC.loadedCallback = {
                            tasksVC.presenter?.askDoneTask(withIdentifier: identifier)
                            tasksVC.loadedCallback = nil
                        }
                    }
                }
            } else {
                // if app was terminated
                tabBar.preferredStartIndex = 1
                tabBar.loadedCallback = {
                    if let tasksVC = (tabBar.selectedViewController as? UINavigationController)?.viewControllers.first as? TasksViewProtocol {
                        tasksVC.loadedCallback = {
                            tasksVC.presenter?.askDoneTask(withIdentifier: identifier)
                            tasksVC.loadedCallback = nil
                        }
                    }
                }
            }
        }
    }
}
