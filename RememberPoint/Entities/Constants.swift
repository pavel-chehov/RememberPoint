//
//  Constans.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
class Constants {
    static let GoogleApiKey = ""
    static let YandexApiKey = ""
    static let YandexGeocodingBaseUrl = ""
    static let YandexSuggestionsBaseUrl = ""
    static let locale = Locale.preferredLanguages.first ?? "en-US"
    static let defaultNotificationInterval = 60
    static let autocompleteMaximumResults = 20
    static let regionsMaximum = 20
    static let radiusValues = [200, 300, 400, 500, 600, 700, 800, 900, 1000]
    static let type = "type"
}

enum Events: String {
    case save
    case doneTask
    case deleteTask
    case disableTaskFromNotification
    case taskEnableChanged
    case newTask
    case allTasksEnableChanged
    case radiusChanged
    case addressFound
    case doneTaskByNotification
    case navigateToTasksFromNotification
    case allowNotifications
    case allowWhenInUseLocation
    case allowAlwaysLocation
}

enum AddressFoundType: String {
    case fromTap
    case fromSearch
}

enum NewTaskType: String {
    case fromTasks
    case fromMap
}

enum DoneTaskType: String {
    case manually
    case automatically
    case fromNotification
}

enum DisableTaskType: String {
    case fromNotification
    case manually
}
