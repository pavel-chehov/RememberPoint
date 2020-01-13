//
//  CreateTaskConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol CreateTaskConfiguratorProtocol: AnyObject {
    func configure(with viewController: CreateTaskViewController)
    init(with data: GeocodingResult)
    init(with task: Task)
}

class CreateTaskConfigurator: CreateTaskConfiguratorProtocol {
    private let geoData: GeocodingResult?
    private let task: Task?

    required init(with data: GeocodingResult) {
        geoData = data
        task = nil
    }

    required init(with task: Task) {
        self.task = task
        geoData = nil
    }

    func configure(with viewController: CreateTaskViewController) {
        let router: CreateTaskRouterProtocol = CreateTaskRouter(for: viewController)
        let presenter = CreateTaskPresenter(for: viewController, with: router)
        let interactor = CreateTaskInteractor(
            locationManager: DIContainer.instance.resolve(),
            reminderService: DIContainer.instance.resolve()
        )
        if let task = self.task {
            presenter.configure(with: interactor, data: task)
        } else {
            if let geoData = self.geoData {
                presenter.configure(with: interactor, data: geoData)
            }
        }
        viewController.presenter = presenter
    }
}
