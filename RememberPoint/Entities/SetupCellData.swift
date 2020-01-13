//
//  SetupCellData.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 15/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

struct SetupCellData {
    var title: String
    var text: String
    var buttonText: String
    var action: () -> Void
    var imageName: String

    init(title: String, text: String, buttonText: String, imageName: String, action: @escaping () -> Void) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.action = action
        self.imageName = imageName
    }
}
