//
//  ViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import UIKit

protocol TabViewProtocol: AnyObject, LoadableViewProtocol {
    var presenter: TabPresenterProtocol! { get set }
    var configurator: TabConfiguratorProtocol! { get set }
}

class TabViewController: UITabBarController, TabViewProtocol {
    var presenter: TabPresenterProtocol!
    var configurator: TabConfiguratorProtocol! = TabConfigurator()
    var preferredStartIndex = 0
    private(set) var isLoaded = false
    var loadedCallback: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        presenter.checkAndAskPermissions()
        // Do any additional setup after loading the view, typically from a nib.
        selectedIndex = preferredStartIndex
        isLoaded = true
        loadedCallback?()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func willEnterForeground(_ notification: Notification) {
        presenter.checkAndAskPermissions()
    }
}
