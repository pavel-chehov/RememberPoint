//
//  SettingsConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol SettingsConfiguratorProtocol: AnyObject {
    func configure(with viewController: SettingsViewController)
}

class SettingsConfigurator: SettingsConfiguratorProtocol {
    func configure(with viewController: SettingsViewController) {
        let router: SettingsRouterProtocol = SettingsRouter(for: viewController)
        let presenter: SettingsPresenterProtocol = SettingsPresenter(for: viewController, with: router)
        let interactor: SettingsInteractorProtocol = SettingsInteractor(
            locationManager: DIContainer.instance.resolve(),
            reminderService: DIContainer.instance.resolve(),
            notificationService: DIContainer.instance.resolve(),
            settingsProvider: DIContainer.instance.resolve()
        )
        presenter.configure(with: interactor)
        viewController.presenter = presenter
    }
}
