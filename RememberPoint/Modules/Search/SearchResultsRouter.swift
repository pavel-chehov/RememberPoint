//
//  SearchRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol SearchResultsRouterProtocol: AnyObject {
    var mapView: MapViewProtocol! { get set }
    func showTaskCreationViewController(data: GeocodingResult)
}

class SearchResultsRouter: SearchResultsRouterProtocol {
    private weak var viewController: UIViewController!

    weak var mapView: MapViewProtocol!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func showTaskCreationViewController(data: GeocodingResult) {
        if let createTaskNavVC = UIStoryboard(name: "CreateTask", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            viewController.present(createTaskNavVC, animated: true, completion: nil)
            if let createTaskVC = createTaskNavVC.viewControllers[0] as? CreateTaskViewController {
                createTaskVC.configurator = CreateTaskConfigurator(with: data)
            }
        }
    }
}
