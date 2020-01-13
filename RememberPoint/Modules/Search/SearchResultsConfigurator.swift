//
//  SearchConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol SearchResultsConfiguratorProtocol: AnyObject {
    func configure(with viewController: SearchResultsViewController)
}

class SearchResultsConfigurator: SearchResultsConfiguratorProtocol {
    func configure(with viewController: SearchResultsViewController) {
        let router: SearchResultsRouterProtocol = SearchResultsRouter(for: viewController)
        let presenter: SearchResultsPresenterProtocol = SearchResultsPresenter(for: viewController, with: router)
        let interactor: SearchResultsInteractorProtocol = SearchResultsInteractor(provider: DIContainer.instance.resolve())
        presenter.configure(with: interactor)
        viewController.presenter = presenter
    }
}
