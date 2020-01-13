//
//  DoneTasksTableViewDelegate.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 05.09.2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ActiveTasksTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var presenter: TasksPresenterProtocol!
    let disposeBag = DisposeBag()

    init(with presenter: TasksPresenterProtocol) {
        super.init()
        self.presenter = presenter
    }

    // MARK: - TableDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.showActiveTask(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let done = UITableViewRowAction(style: .default, title: "Done") { [unowned self] _, indexPath in
            self.presenter.doneActiveTask(withIdentifier: indexPath.row)
        }
        done.backgroundColor = UIColor.green
        return [done]
    }

    // MARK: - DATA SOURCE

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.activeTasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        if let tasks = presenter.activeTasks {
            cell.setup(with: tasks[indexPath.row])
            cell.switchCnanged = { [unowned self] isOn in
                self.presenter.setActiveTask(enabled: isOn, by: indexPath.row)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.height
    }
}
