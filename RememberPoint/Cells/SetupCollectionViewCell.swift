//
//  SetupCollectionViewCell.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 15/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

class SetupCollectionViewCell: UICollectionViewCell {
    static let identifier = "collectionCell"
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(data: SetupCellData) {
        imageView.image = UIImage(named: data.imageName)
        titleLabel.text = data.title
        textLabel.text = data.text
    }
}
