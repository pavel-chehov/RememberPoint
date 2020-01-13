//
//  MainPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol TabPresenterProtocol {
    var router: TabRouterProtocol! { get }
    var interactor: TabInteractorProtocol! { get }
    var view: TabViewProtocol! { get }
    init(for viewController: TabViewProtocol, with router: TabRouterProtocol)
    func showSettingsAlarm()
    func hideSettingsAlarm()
    func checkAndAskPermissions()
    func configure(with: TabInteractorProtocol)
}

class TabPresenter: TabPresenterProtocol {
    private(set) var router: TabRouterProtocol!
    private(set) var interactor: TabInteractorProtocol!
    private(set) weak var view: TabViewProtocol!

    required init(for viewController: TabViewProtocol, with router: TabRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: TabInteractorProtocol) {
        self.interactor = interactor
        self.interactor.showSettingsAlarm = showSettingsAlarm
        self.interactor.hideSettingsAlarm = hideSettingsAlarm
    }

    func showSettingsAlarm() {
        DispatchQueue.main.async {
            self.router.showSettingsBadge(text: "!")
        }
    }

    func hideSettingsAlarm() {
        DispatchQueue.main.async { [unowned self] in
            self.router.showSettingsBadge(text: nil)
        }
    }

    func checkAndAskPermissions() {
        DispatchQueue.main.async { [unowned self] in
            self.interactor.checkAndAskPermissions()
        }
    }
}
