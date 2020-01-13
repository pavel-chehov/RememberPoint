//
//  ReminderTableViewCell.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 10/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    static let identifier = "reminderCell"

    @IBOutlet var disableSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(with switchState: Bool) {
        disableSwitch.isOn = switchState
    }
}
