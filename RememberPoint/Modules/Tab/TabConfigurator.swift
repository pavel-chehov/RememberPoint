//
//  MainConfigurator.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import Swinject
import UIKit

protocol TabConfiguratorProtocol: AnyObject {
    func configure(with viewController: TabViewController)
}

class TabConfigurator: TabConfiguratorProtocol {
    func configure(with viewController: TabViewController) {
        let router: TabRouterProtocol = TabRouter(for: viewController)
        let presenter: TabPresenterProtocol = TabPresenter(for: viewController, with: router)
        let interactor: TabInteractorProtocol = TabInteractor(
            locationManager: DIContainer.instance.resolve(),
            reminderService: DIContainer.instance.resolve(),
            notificationService: DIContainer.instance.resolve()
        )
        presenter.configure(with: interactor)
        viewController.presenter = presenter
        viewController.hideNavigationBar()

        let mapVC = UIStoryboard(name: "Map", bundle: nil).instantiateInitialViewController() as! UINavigationController
        prepareTabBarItem(for: mapVC, title: "Map", image: "map", selectedImage: "mapSelected", tag: 0)

        let tasksVC = UIStoryboard(name: "Tasks", bundle: nil).instantiateInitialViewController() as! UINavigationController
        prepareTabBarItem(for: tasksVC, title: "Reminders", image: "reminder", selectedImage: "reminderSelected", tag: 1)

        let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
        prepareTabBarItem(for: settingsVC, title: "Settings", image: "settings", selectedImage: "settingsSelected", tag: 2)

        viewController.tabBar.tintColor = UIColor.primaryColor
        viewController.viewControllers = [mapVC, tasksVC, settingsVC]
    }

    private func prepareTabBarItem(for viewController: UINavigationController, title: String, image: String, selectedImage: String, tag: Int) {
        let tabBarItem = UITabBarItem(title: title, image: UIImage(named: image), tag: tag)
        tabBarItem.selectedImage = UIImage(named: selectedImage)
        viewController.tabBarItem = tabBarItem
        viewController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
