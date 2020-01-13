//
//  ffff.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 05.09.2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

class DoneTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var presenter: TasksPresenterProtocol!

    init(with presenter: TasksPresenterProtocol) {
        super.init()
        self.presenter = presenter
    }

    // MARK: - TableDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.showDoneTask(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] _, indexPath in
            self.presenter.deleteDoneTask(withIdentifier: indexPath.row)
        }
        return [delete]
    }

    // MARK: - DATA SOURCE

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.doneTasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        if let tasks = presenter.doneTasks {
            cell.setup(with: tasks[indexPath.row])
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
