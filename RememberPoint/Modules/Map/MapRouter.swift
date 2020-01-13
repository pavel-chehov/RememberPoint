//
//  MapRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol MapRouterProtocol: AnyObject {
    func navigateToCreateNewTask(with data: GeocodingResult)
}

class MapRouter: MapRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func navigateToCreateNewTask(with data: GeocodingResult) {
        if let createTaskNavVC = UIStoryboard(name: "CreateTask", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            viewController.present(createTaskNavVC, animated: true, completion: nil)
            if let createTaskVC = createTaskNavVC.viewControllers[0] as? CreateTaskViewController {
                createTaskVC.configurator = CreateTaskConfigurator(with: data)
                createTaskNavVC.presentationController?.delegate = viewController as? UIAdaptivePresentationControllerDelegate
            }
        }
    }
}
