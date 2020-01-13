//
//  RadiusTableViewCell.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 10/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class RadiusTableViewCell: ExpandableTableViewCell {
    static let identifier = "radiusCell"

    @IBOutlet var radiusLabel: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var disclosureView: UIImageView!
    private var items: Observable<[String]>!
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(with values: [String], radius: String?) {
        radiusLabel.text = radius
        items = Observable.of(values)
        items.bind(to: pickerView.rx.itemTitles) { _, element in
            "\(element) m"
        }.disposed(by: disposeBag)
    }
}
