//
//  DIContainer.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 15/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import Swinject

class DIContainer {
    static let instance = DIContainer()
    private let container: Container

    private init() {
        container = Container()
        container.register(LocationManagerProtocol.self) { _ in LocationManager() }
        container.register(NotificationServiceProtocol.self) { _ in NotificationService() }
        container.register(SettingsProviderProtocol.self) { _ in UserDefaults.standard }
        container.register(GeocodingProviderProtocol.self) { _ in YandexGeocodingProvider() }
        container.register(LocationReminderProtocol.self) { _ in LocationReminderService.instance }
        container.register(LocationReminderRouterProtocol.self) { _ in LocationReminderRouter() }
    }

    func resolve<T>() -> T {
        return container.resolve(T.self)!
    }
}
