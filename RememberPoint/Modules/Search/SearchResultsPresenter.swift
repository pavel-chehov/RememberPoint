//
//  SearchPresenter.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol SearchResultsPresenterProtocol {
    var router: SearchResultsRouterProtocol! { get }
    var interactor: SearchResultsInteractorProtocol! { get }
    var view: SearchResultsViewProtocol! { get }
    init(for viewController: SearchResultsViewProtocol, with router: SearchResultsRouterProtocol)
    func createTask(for index: Int)
    func searchAddresses(for address: String) -> PublishRelay<[GeocodingResult]>
    func configure(with: SearchResultsInteractorProtocol)
}

class SearchResultsPresenter: SearchResultsPresenterProtocol {
    private(set) var router: SearchResultsRouterProtocol!
    private(set) var interactor: SearchResultsInteractorProtocol!
    private(set) weak var view: SearchResultsViewProtocol!

    required init(for viewController: SearchResultsViewProtocol, with router: SearchResultsRouterProtocol) {
        view = viewController
        self.router = router
    }

    func configure(with interactor: SearchResultsInteractorProtocol) {
        self.interactor = interactor
    }

    func searchAddresses(for address: String) -> PublishRelay<[GeocodingResult]> {
        return interactor.searchAddresses(for: address)
    }

    func createTask(for index: Int) {
        router.showTaskCreationViewController(data: interactor.searchedAddresses[index])
    }
}
