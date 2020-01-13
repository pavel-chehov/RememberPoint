//
//  TasksInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol TasksInteractorProtocol: AnyObject {
    init(reminderService: LocationReminderProtocol, dataProvider: RealmDataProvider)
    func getActiveTasks() -> [Task]?
    func getDoneTasks() -> [Task]?
    func doneTask(by id: String)
    func deleteTask(by id: String)
    func setTask(enabled: Bool, by id: String)
}

class TasksInteractor: TasksInteractorProtocol {
    private let dataProvider: RealmDataProvider
    private let reminderService: LocationReminderProtocol

    required init(reminderService: LocationReminderProtocol, dataProvider: RealmDataProvider) {
        self.reminderService = reminderService
        self.dataProvider = dataProvider
    }

    func getActiveTasks() -> [Task]? {
        do {
            let tasks = try (dataProvider.getAll() as [RealmTask])
                .filter { $0.isDone == false }
                .sorted(by: { $0.endDate! < $1.endDate! })
                .map { Task(from: $0) }
            return tasks
        } catch {
            Log.instance.write("\(#function) \(error.localizedDescription)")
            return nil
        }
    }

    func getDoneTasks() -> [Task]? {
        do {
            let tasks = try (dataProvider.getAll() as [RealmTask]).filter { $0.isDone == true }.map { Task(from: $0) }
            return tasks
        } catch {
            Log.instance.write("\(#function) \(error.localizedDescription)")
            return nil
        }
    }

    func doneTask(by id: String) {
        do {
            guard let task: RealmTask = try dataProvider.get(by: id) else { return }
            let proxyTask = Task(from: task)
            proxyTask.isDone = true
            try dataProvider.write(data: RealmTask(from: proxyTask), update: true)
            reminderService.update()
        } catch {
            Log.instance.write("\(#function) \(error.localizedDescription)")
        }
    }

    func deleteTask(by id: String) {
        do {
            guard let task: RealmTask = try dataProvider.get(by: id) else { return }
            try dataProvider.remove(by: task.location?.id, type: RealmGeoPoint.self)
            try dataProvider.remove(by: id, type: RealmTask.self)
            reminderService.update()
        } catch {
            Log.instance.write("\(#function) \(error.localizedDescription)")
        }
    }

    func setTask(enabled: Bool, by id: String) {
        do {
            guard let task: RealmTask = try dataProvider.get(by: id) else { return }
            let proxyTask = Task(from: task)
            proxyTask.isEnabled = enabled
            try dataProvider.write(data: RealmTask(from: proxyTask), update: true)
            reminderService.update()
        } catch {
            Log.instance.write("\(#function) \(error.localizedDescription)")
        }
    }
}
