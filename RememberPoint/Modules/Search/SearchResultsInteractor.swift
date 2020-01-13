//
//  SearchInteractor.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 03/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Firebase
import Foundation
import Moya
import RxCocoa
import RxSwift

protocol SearchResultsInteractorProtocol: AnyObject {
    var searchedAddresses: [GeocodingResult]! { get }
    init(provider: GeocodingProviderProtocol)
    func searchAddresses(for query: String) -> PublishRelay<[GeocodingResult]>
}

class SearchResultsInteractor: SearchResultsInteractorProtocol {
    private let geocodeProvider: GeocodingProviderProtocol!
    var searchedAddresses: [GeocodingResult]!

    required init(provider: GeocodingProviderProtocol) {
        geocodeProvider = provider
    }

    func searchAddresses(for query: String) -> PublishRelay<[GeocodingResult]> {
        let relay = PublishRelay<[GeocodingResult]>()
        geocodeProvider.autocompleteAddresses(for: query) { [unowned self] result in
            relay.accept(result)
            self.searchedAddresses = result
            Analytics.logEvent(Events.addressFound.rawValue, parameters: [Constants.type: AddressFoundType.fromSearch.rawValue])
        }
        return relay
    }
}
