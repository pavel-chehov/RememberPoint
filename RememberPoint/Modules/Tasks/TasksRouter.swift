//
//  TasksRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol TasksRouterProtocol: AnyObject {
    func navigateToMap()
    func navigateToTask(_ task: Task)
}

class TasksRouter: TasksRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func navigateToMap() {
        let tabBarVC = (viewController.parent as? UINavigationController)?.parent as? UITabBarController
        tabBarVC?.selectedIndex = 0
    }

    func navigateToTask(_ task: Task) {
        if let createTaskNavVC = UIStoryboard(name: "CreateTask", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            viewController.present(createTaskNavVC, animated: true, completion: nil)
            if let createTaskVC = createTaskNavVC.viewControllers[0] as? CreateTaskViewController {
                createTaskVC.configurator = CreateTaskConfigurator(with: task)
                createTaskNavVC.presentationController?.delegate = viewController as? UIAdaptivePresentationControllerDelegate
            }
        }
    }
}
