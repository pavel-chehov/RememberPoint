//
//  DialogService.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 20/12/2018.
//  Copyright © 2018 Pavel Chehov. All rights reserved.
//

import UIKit

extension UIViewController: AlertProtocol {
    func showConfirmAlert(
        title: String?,
        message: String?,
        confirmStyle: UIAlertAction.Style?,
        cancelStyle: UIAlertAction.Style?,
        confirmText: String?,
        confirmCallback: ((UIAlertAction) -> Void)?,
        cancelText: String?,
        cancelCallback: ((UIAlertAction) -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: confirmText, style: confirmStyle ?? .default, handler: confirmCallback)
            let cancelAction = UIAlertAction(title: cancelText, style: cancelStyle ?? .cancel, handler: cancelCallback)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlert(title: String?, message: String?, okText: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: okText, style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showActionSheet(title: String?, text: String?, actions: [UIAlertAction]) {
        let optionMenu = UIAlertController(title: title, message: text, preferredStyle: .actionSheet)
        for action in actions {
            optionMenu.addAction(action)
        }
        present(optionMenu, animated: true, completion: nil)
    }

    func hideNavigationBar() {
        guard let navigationVC = navigationController else {
            return
        }
        navigationVC.isNavigationBarHidden = true
    }

    func showNavigationBar() {
        guard let navigationVC = navigationController else {
            return
        }
        navigationVC.isNavigationBarHidden = false
    }
}
