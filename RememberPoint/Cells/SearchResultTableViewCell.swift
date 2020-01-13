//
//  SearchResultTableViewCell.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 13/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "resultCell"
    static let height = 44

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet private var addressCenterConstraint: NSLayoutConstraint!

    var addressCentered: Bool = false {
        willSet {
            addressCenterConstraint.isActive = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
