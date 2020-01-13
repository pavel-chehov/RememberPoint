//
//  TasksConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol TasksConfiguratorProtocol: AnyObject {
    func configure(with viewController: TasksViewController)
}

class TasksConfigurator: TasksConfiguratorProtocol {
    func configure(with viewController: TasksViewController) {
        let router: TasksRouterProtocol = TasksRouter(for: viewController)
        let presenter: TasksPresenterProtocol = TasksPresenter(for: viewController, with: router)
        let interactor: TasksInteractorProtocol = TasksInteractor(reminderService: DIContainer.instance.resolve(), dataProvider: RealmDataProvider())

        presenter.configure(with: interactor)
        viewController.presenter = presenter
    }
}
