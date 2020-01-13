//
//  TaskTableViewCell.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 09/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    static let identifier = "TaskTableViewCell"
    static let height: CGFloat = 70

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dayNumberLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var activeSwitch: UISwitch!
    @IBOutlet var cellContentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        monthLabel.textColor = UIColor.primaryColor
        dayNumberLabel.textColor = UIColor.primaryColor
        cellContentView.layer.borderColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        cellContentView.layer.borderWidth = 1
    }

    var switchCnanged: ((Bool) -> Void)?

    func setup(with task: Task) {
        titleLabel.text = task.title
        addressLabel.text = task.address
        activeSwitch.isOn = task.isEnabled
        activeSwitch.isHidden = task.isDone
        if let date = task.endDate {
            setDate(date: date)
        }
    }

    private func setDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        var monthName = formatter.string(from: date)
        monthName = String(monthName[...monthName.index(monthName.startIndex, offsetBy: 2)])
        formatter.dateFormat = "dd"
        let dayNumber = formatter.string(from: date)
        dayNumberLabel.text = dayNumber
        monthLabel.text = monthName
    }

    @IBAction func siwtchChanged(_ sender: Any) {
        switchCnanged?(activeSwitch.isOn)
    }
}
