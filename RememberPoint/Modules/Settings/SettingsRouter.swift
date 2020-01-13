//
//  SettingsRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsRouterProtocol: AnyObject {}

class SettingsRouter: SettingsRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }
}
