//
//  MapConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol MapConfiguratorProtocol: AnyObject {
    func configure(with viewController: MapViewController)
}

class MapConfigurator: MapConfiguratorProtocol {
    func configure(with viewController: MapViewController) {
        let router: MapRouterProtocol = MapRouter(for: viewController)
        let presenter: MapPresenterProtocol = MapPresenter(for: viewController, with: router)
        let interactor: MapInteractorProtocol = MapInteractor(
            geocodeProvider: DIContainer.instance.resolve(),
            settingsProvider: DIContainer.instance.resolve(),
            locationManager: DIContainer.instance.resolve(), dataProvider: RealmDataProvider()
        )
        presenter.configure(with: interactor)
        viewController.presenter = presenter
    }
}
