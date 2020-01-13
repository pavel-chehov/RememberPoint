//
//  CreateTaskInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation
import RealmSwift

protocol CreateTaskInteractorProtocol: AnyObject {
    var startDate: Date { get set }
    var endDate: Date { get set }
    var title: String? { get set }
    var location: GeoPoint? { get set }
    var address: String? { get set }
    var isEnabled: Bool { get set }
    var isDone: Bool { get set }
    var id: String? { get set }
    var createdFromDoneTask: Bool { get }
    var notes: String? { get set }

    init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol)
    func configure(with: Task)
    func save() throws
}

enum SaveError: Error {
    case dateError(message: String)
}

class CreateTaskInteractor: CreateTaskInteractorProtocol {
    private let dataProvider = RealmDataProvider()
    private let locationManager: LocationManagerProtocol
    private let reminderService: LocationReminderProtocol

    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    var title: String? = ""
    var location: GeoPoint?
    var address: String?
    var id: String?
    var notes: String? = ""
    var isEnabled: Bool = true
    var isDone: Bool = false

    private(set) var createdFromDoneTask: Bool = false

    required init(locationManager: LocationManagerProtocol, reminderService: LocationReminderProtocol) {
        self.locationManager = locationManager
        self.reminderService = reminderService
        if self.locationManager.authorizationStatus != .authorizedAlways {
            self.locationManager.requestAlwaysAuthorization()
        }
    }

    func configure(with task: Task) {
        createdFromDoneTask = task.isDone
        location = task.location
        address = task.address
        title = task.title
        id = task.id
        isEnabled = task.isEnabled
        isDone = task.isDone
        notes = task.notes
        if let startDate = task.startDate {
            self.startDate = startDate
        }
        if let endDate = task.endDate {
            self.endDate = endDate
        }
    }

    func save() throws {
        do {
            guard endDate > Date(), endDate > startDate else {
                throw SaveError.dateError(message: "Last reminder end day must be greater then start day or current date")
            }

            var task = Task()
            if let id = id {
                if let existingTask: RealmTask = try dataProvider.get(by: id) {
                    task = Task(from: existingTask)
                }
            }
            task.title = title
            task.startDate = startDate
            task.endDate = endDate
            task.location = location
            task.address = address
            task.isEnabled = isEnabled
            task.isDone = isDone
            task.notes = notes
            try dataProvider.write(data: RealmTask(from: task), update: task.id != nil)
            reminderService.update()
        } catch {
            throw error
        }
    }
}
