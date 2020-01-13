//
//  TasksViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol TasksViewProtocol: AnyObject, AlertProtocol, LoadableViewProtocol {
    var presenter: TasksPresenterProtocol! { get set }
    var configurator: TasksConfiguratorProtocol! { get set }
    func reloadActiveTasks()
    func reloadDoneTasks()
    func removeActiveTask(at: Int)
    func removeDoneTask(at: Int)
    func refreshTablesVisibility()
    var loadedCallback: (() -> Void)? { get set }
}

class TasksViewController: UIViewController, TasksViewProtocol {
    var presenter: TasksPresenterProtocol!
    var configurator: TasksConfiguratorProtocol! = TasksConfigurator()
    private var activeTableDelegate: ActiveTasksTableDelegate!
    private var doneTableDelegate: DoneTableDelegate!
    let disposeBag = DisposeBag()

    @IBOutlet var activeTableView: UITableView!
    @IBOutlet var doneTableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var newReminderButton: UIButton!

    private(set) var isLoaded: Bool = false
    var loadedCallback: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        activeTableDelegate = ActiveTasksTableDelegate(with: presenter)
        doneTableDelegate = DoneTableDelegate(with: presenter)
        view.backgroundColor = UIColor.secondaryColor
        activeTableView.backgroundColor = UIColor.secondaryColor
        doneTableView.backgroundColor = UIColor.secondaryColor

        activeTableView.delegate = activeTableDelegate
        activeTableView.dataSource = activeTableDelegate
        activeTableView.register(UINib(nibName: TaskTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TaskTableViewCell.identifier)

        doneTableView.backgroundColor = UIColor.secondaryColor
        doneTableView.delegate = doneTableDelegate
        doneTableView.dataSource = doneTableDelegate
        doneTableView.register(UINib(nibName: TaskTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TaskTableViewCell.identifier)

        segmentControl.tintColor = UIColor.primaryColor
        newReminderButton.backgroundColor = UIColor.primaryColor
        setupBinding()
        isLoaded = true

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTasks()
    }

    func setupBinding() {
        segmentControl.rx.selectedSegmentIndex.bind { [unowned self] _ in
            self.refreshTablesVisibility()
        }.disposed(by: disposeBag)
        newReminderButton.rx.tap.bind { [unowned self] _ in
            self.presenter.createNewTask()
        }.disposed(by: disposeBag)
    }

    func refreshTasks() {
        presenter.refreshTasks()
        reloadActiveTasks()
        reloadDoneTasks()
        loadedCallback?()
    }

    func reloadActiveTasks() {
        activeTableView.reloadData()
    }

    func reloadDoneTasks() {
        doneTableView.reloadData()
    }

    func removeActiveTask(at index: Int) {
        activeTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
    }

    func removeDoneTask(at index: Int) {
        doneTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
    }

    @IBAction func addClicked(_ sender: Any) {
        presenter.createNewTask()
    }

    func refreshTablesVisibility() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            activeTableView?.isHidden = !(presenter?.activeTasks?.count ?? 0 > 0)
            doneTableView?.isHidden = true
        default:
            doneTableView?.isHidden = !(presenter?.doneTasks?.count ?? 0 > 0)
            activeTableView?.isHidden = true
        }
    }

    @objc func willEnterForeground(_ notification: Notification) {
        presenter.refreshTasks()
    }
}

extension TasksViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refreshTasks()
    }
}
