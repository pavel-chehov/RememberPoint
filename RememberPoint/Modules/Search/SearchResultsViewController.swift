//
//  SearchViewController.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol SearchResultsViewProtocol: AnyObject {
    var presenter: SearchResultsPresenterProtocol! { get set }
    var configurator: SearchResultsConfiguratorProtocol! { get set }
    var searchBar: UISearchBar? { get set }
}

class SearchResultsViewController: UITableViewController, SearchResultsViewProtocol {
    var presenter: SearchResultsPresenterProtocol!
    var configurator: SearchResultsConfiguratorProtocol! = SearchResultsConfigurator()
    var searchBar: UISearchBar?
    var searchResults: Observable<[GeocodingResult]>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        setupBinding()
    }

    func setupBinding() {
        searchResults = searchBar?.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { [unowned self] query -> Observable<[GeocodingResult]> in
                if query.isEmpty {
                    return .just([])
                }
                return self.presenter.searchAddresses(for: query).asObservable()
            }.observeOn(MainScheduler.instance)

        searchResults?.bind(to: tableView.rx.items(cellIdentifier: SearchResultTableViewCell.identifier)) {
            _, element, cell in
            guard let fullStreetAddress = element.fullStreetAddress else { return }
            let cell = cell as! SearchResultTableViewCell
            cell.addressLabel.text = fullStreetAddress
            cell.descriptionLabel.text = element.description
            cell.addressCentered = element.description == nil
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.bind { [unowned self] indexPath in
            self.presenter.createTask(for: indexPath.row)
            self.searchBar?.text = ""
        }.disposed(by: disposeBag)
    }
}
