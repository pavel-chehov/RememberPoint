//
//  SettingsPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Firebase
import Foundation

protocol SettingsPresenterProtocol {
    var router: SettingsRouterProtocol! { get }
    var interactor: SettingsInteractorProtocol! { get }
    var view: SettingsViewProtocol! { get }
    var radiusValues: [String]! { get }
    var currentRadius: String { get }
    var remindersEnabled: Bool { get }
    init(for viewController: SettingsViewProtocol, with router: SettingsRouterProtocol)
    func configure(with interactor: SettingsInteractorProtocol)
    func setRadius(by index: Int)
    func setReminders(enabled: Bool)
    func checkAndAskPermissions()
}

class SettingsPresenter: SettingsPresenterProtocol {
    private(set) var router: SettingsRouterProtocol!
    private(set) var interactor: SettingsInteractorProtocol!
    private(set) weak var view: SettingsViewProtocol!
    private(set) var radiusValues: [String]!

    var currentRadius: String {
        return "\(interactor.currentRadius) m"
    }

    var remindersEnabled: Bool {
        return interactor.remindersEnabled
    }

    required init(for viewController: SettingsViewProtocol, with router: SettingsRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: SettingsInteractorProtocol) {
        self.interactor = interactor
        radiusValues = interactor.radiusValues.map { String($0) }
        view.drawCurrentRadius(radius: "\(interactor.currentRadius) m")
        self.interactor.locationAlarm = locationAlarm
        self.interactor.notificationAlarm = notificationAlarm
    }

    func setRadius(by index: Int) {
        interactor.setRadius(by: index)
        view.drawCurrentRadius(radius: "\(interactor.currentRadius) m")
        Analytics.logEvent(Events.radiusChanged.rawValue, parameters: ["radius": radiusValues[index]])
    }

    func setReminders(enabled: Bool) {
        interactor.setReminders(enabled: !enabled)
        Analytics.logEvent(Events.allTasksEnableChanged.rawValue, parameters: ["enabled": enabled.description])
    }

    func checkAndAskPermissions() {
        interactor.checkAndAskPermissions()
    }

    private func notificationAlarm(hide: Bool) {
        view.notificationAlarm(hide: hide)
    }

    private func locationAlarm(hide: Bool) {
        view.locationAlarm(hide: hide)
    }
}
