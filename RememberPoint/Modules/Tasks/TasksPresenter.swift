//
//  TasksPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Firebase
import Foundation

protocol TasksPresenterProtocol: AnyObject {
    var router: TasksRouterProtocol! { get }
    var interactor: TasksInteractorProtocol! { get }
    var view: TasksViewProtocol! { get }
    var activeTasks: [Task]? { get }
    var doneTasks: [Task]? { get }
    init(for viewController: TasksViewProtocol, with router: TasksRouterProtocol)
    func configure(with interactor: TasksInteractorProtocol)
    func doneActiveTask(withIdentifier: Int)
    func deleteDoneTask(withIdentifier: Int)
    func refreshTasks()
    func createNewTask()
    func setActiveTask(enabled: Bool, by index: Int)
    func showActiveTask(for: Int)
    func showDoneTask(for: Int)
    func askDoneTask(withIdentifier: String)
}

class TasksPresenter: TasksPresenterProtocol {
    private(set) var router: TasksRouterProtocol!
    private(set) var interactor: TasksInteractorProtocol!
    private(set) weak var view: TasksViewProtocol!
    private(set) var activeTasks: [Task]?
    private(set) var doneTasks: [Task]?

    required init(for viewController: TasksViewProtocol, with router: TasksRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: TasksInteractorProtocol) {
        self.interactor = interactor
        refreshTasks()
    }

    func doneActiveTask(withIdentifier index: Int) {
        if let task = activeTasks?[index], let id = task.id {
            interactor.doneTask(by: id)
            refreshTasks()
            view.removeActiveTask(at: index)
            view.reloadDoneTasks()
            Analytics.logEvent(Events.doneTask.rawValue, parameters: [Constants.type: DoneTaskType.manually.rawValue])
        }
    }

    func deleteDoneTask(withIdentifier index: Int) {
        guard let id = doneTasks?[index].id else { return }
        interactor.deleteTask(by: id)
        refreshTasks()
        view.removeDoneTask(at: index)
        Analytics.logEvent(Events.deleteTask.rawValue, parameters: nil)
    }

    func refreshTasks() {
        activeTasks = interactor.getActiveTasks()
        doneTasks = interactor.getDoneTasks()
        view.refreshTablesVisibility()
    }

    func createNewTask() {
        router.navigateToMap()
        Analytics.logEvent(Events.newTask.rawValue, parameters: [Constants.type: NewTaskType.fromTasks.rawValue])
    }

    func setActiveTask(enabled: Bool, by index: Int) {
        guard let id = activeTasks?[index].id else { return }
        interactor.setTask(enabled: enabled, by: id)
        refreshTasks()
        Analytics.logEvent(Events.taskEnableChanged.rawValue, parameters: ["enabled": enabled.description])
    }

    func showActiveTask(for index: Int) {
        if let task = activeTasks?[index] {
            router.navigateToTask(task)
        }
    }

    func showDoneTask(for index: Int) {
        if let task = doneTasks?[index] {
            router.navigateToTask(task)
        }
    }

    func askDoneTask(withIdentifier identifier: String) {
        view.showConfirmAlert(
            title: "Done task?",
            message: "Dou you want to done this task?",
            confirmStyle: .default, cancelStyle: .cancel,
            confirmText: "Done",
            confirmCallback: { [unowned self] _ in
                guard let index = self.activeTasks?.firstIndex(where: { $0.id == identifier }) else { return }
                self.interactor.doneTask(by: identifier)
                self.refreshTasks()
                self.view.removeActiveTask(at: index)
                self.view.reloadDoneTasks()
            },
            cancelText: "Cancel",
            cancelCallback: { _ in }
        )
    }
}
