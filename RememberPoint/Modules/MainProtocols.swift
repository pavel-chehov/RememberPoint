//
//  MainProtocols.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

protocol AlertProtocol {
    func showAlert(title: String?, message: String?, okText: String?)
    func showConfirmAlert(
        title: String?,
        message: String?,
        confirmStyle: UIAlertAction.Style?,
        cancelStyle: UIAlertAction.Style?,
        confirmText: String?,
        confirmCallback: ((UIAlertAction) -> Void)?,
        cancelText: String?,
        cancelCallback: ((UIAlertAction) -> Void)?
    )
    func showActionSheet(title: String?, text: String?, actions: [UIAlertAction])
}

protocol LoadableViewProtocol {
    var isLoaded: Bool { get }
    var loadedCallback: (() -> Void)? { get set }
}
