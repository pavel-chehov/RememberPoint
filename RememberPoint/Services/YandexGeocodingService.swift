//
//  YandexGeocodingService.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 04/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Moya

enum YandexGeocodingService {
    case getSuggestions(address: String)
    case getGeocoding(address: String)
    case getReverseGeocoding(point: GeoPoint)
}

extension YandexGeocodingService: TargetType {
    var baseURL: URL {
        switch self {
        case .getGeocoding, .getReverseGeocoding:
            return URL(string: Constants.YandexGeocodingBaseUrl)!
        case .getSuggestions:
            return URL(string: Constants.YandexSuggestionsBaseUrl)!
        }
    }

    var path: String {
        switch self {
        case .getGeocoding, .getReverseGeocoding:
            return "/1.x"
        case .getSuggestions:
            return "/suggest-geo"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        switch self {
        case .getSuggestions:
            guard let url = Bundle.main.url(forResource: "suggestions", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                return Data()
            }
            return data
        case .getGeocoding:
            guard let url = Bundle.main.url(forResource: "geocodingByAddress", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                return Data()
            }
            return data
        case .getReverseGeocoding:
            guard let url = Bundle.main.url(forResource: "geocodingByPoint", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                return Data()
            }
            return data
        }
    }

    var task: Moya.Task {
        let settingsProvider: SettingsProviderProtocol = DIContainer.instance.resolve()
        switch self {
        case let .getSuggestions(address):
            var parameters = ["part": address,
                              "lang": "\(Constants.locale)",
                              "format": "json",
                              "results": "\(Constants.autocompleteMaximumResults)",
                              "spn": "0.2,0.2",
                              "search_type": "all",
                              "v": "7"]
            var locationValue: String?
            if let latitude = settingsProvider.currentLocation?.latitude, let longitude = settingsProvider.currentLocation?.longitude {
                locationValue = "\(longitude),\(latitude)"
                parameters["ll"] = locationValue
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getGeocoding(address):
            let parameters = ["geocode": address,
                              "lang": "\(Constants.locale)",
                              "format": "json",
                              "results": "\(Constants.autocompleteMaximumResults)",
                              "spn": "0.2,0.2",
                              "kind": "house"]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getReverseGeocoding(point):
            let parameters = ["apikey": Constants.YandexApiKey,
                              "geocode": "\(point.longitude!),\(point.latitude!)",
                              "lang": "\(Constants.locale)",
                              "format": "json",
                              "results": "\(Constants.autocompleteMaximumResults)",
                              "kind": "house"]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
