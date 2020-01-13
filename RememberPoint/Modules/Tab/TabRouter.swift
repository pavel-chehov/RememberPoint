//
//  MainRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol TabRouterProtocol: AnyObject {
    func showSettingsBadge(text: String?)
}

class TabRouter: TabRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func showSettingsBadge(text: String?) {
        DispatchQueue.main.async { [unowned self] in
            if let tabBarVC = self.viewController as? UITabBarController {
                if let settingItem = tabBarVC.tabBar.items?[2] {
                    settingItem.badgeValue = text
                }
            }
        }
    }
}
