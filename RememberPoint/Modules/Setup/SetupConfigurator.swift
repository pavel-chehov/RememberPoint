//
//  SetupConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol SetupConfiguratorProtocol: AnyObject {
    func configure(with viewController: SetupViewController)
}

class SetupConfigurator: SetupConfiguratorProtocol {
    func configure(with viewController: SetupViewController) {
        let router: SetupRouterProtocol = SetupRouter(for: viewController)
        let presenter: SetupPresenterProtocol = SetupPresenter(for: viewController, with: router)
        let interactor: SetupInteractorProtocol = SetupInteractor(
            locationManager: DIContainer.instance.resolve(),
            reminderService: DIContainer.instance.resolve(),
            notificationService: DIContainer.instance.resolve(),
            settingsProvider: DIContainer.instance.resolve()
        )
        presenter.configure(with: interactor)
        viewController.presenter = presenter
        viewController.hideNavigationBar()
    }
}
