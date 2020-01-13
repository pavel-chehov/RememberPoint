//
//  CreateTaskRouter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

protocol CreateTaskRouterProtocol: AnyObject {
    func close()
}

class CreateTaskRouter: CreateTaskRouterProtocol {
    private weak var viewController: UIViewController!

    init(for viewController: UIViewController) {
        self.viewController = viewController
    }

    func close() {
        if #available(iOS 13, *) {
            if let presentationController = self.viewController?.parent?.presentationController {
                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
            }
        }
        viewController.dismiss(animated: true)
    }
}
