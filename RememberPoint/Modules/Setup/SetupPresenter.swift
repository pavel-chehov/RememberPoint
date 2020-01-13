//
//  SetupPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation

protocol SetupPresenterProtocol {
    var router: SetupRouterProtocol! { get }
    var interactor: SetupInteractorProtocol! { get }
    var view: SetupViewProtocol! { get }
    var setupData: [SetupCellData]! { get }
    init(for viewController: SetupViewProtocol, with router: SetupRouterProtocol)
    func actionButtonClicked()
    func configure(with: SetupInteractorProtocol)
    func setRequiredButtonTitle()
}

class SetupPresenter: SetupPresenterProtocol {
    private(set) var router: SetupRouterProtocol!
    private(set) var interactor: SetupInteractorProtocol!
    private(set) weak var view: SetupViewProtocol!

    private var currentPage: Int {
        return interactor.currentPage
    }

    var setupData: [SetupCellData]! {
        return interactor.setupData
    }

    required init(for viewController: SetupViewProtocol, with router: SetupRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: SetupInteractorProtocol) {
        self.interactor = interactor
        self.interactor.showNext = showNext
    }

    func setRequiredButtonTitle() {
        view.setButtonTitle(title: setupData[currentPage].buttonText)
    }

    func actionButtonClicked() {
        if currentPage < setupData.count {
            setupData[currentPage].action()
        }
    }

    private func showNext() {
        DispatchQueue.main.async {
            if self.currentPage == self.setupData.count {
                self.router?.navigateToMain()
            } else {
                self.view?.setCurrentPage(to: self.currentPage)
                self.view?.setButtonTitle(title: self.setupData[self.currentPage].buttonText)
            }
        }
    }
}
