//
//  SetupRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol SetupRouterProtocol: AnyObject {
    func navigateToMain()
}

class SetupRouter: SetupRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func navigateToMain() {
        let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        let navigationVC = viewController.parent as! UINavigationController
        navigationVC.pushViewController(tabBarVC, animated: true)
        navigationVC.viewControllers.remove(at: 0)
    }
}
