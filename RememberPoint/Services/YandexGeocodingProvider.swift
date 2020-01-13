//
//  YandexGeocodingProvider.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 04/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Moya

protocol GeocodingProviderProtocol {
    func searchAddresses(for query: String, completion: @escaping ([GeocodingResult]) -> Void)
    func searchAddresses(by point: GeoPoint, completion: @escaping (GeocodingResult) -> Void)
    func autocompleteAddresses(for query: String, completion: @escaping ([GeocodingResult]) -> Void)
}

class YandexGeocodingProvider: GeocodingProviderProtocol {
    private let gecodingService = MoyaProvider<YandexGeocodingService>()

    func searchAddresses(for query: String, completion: @escaping ([GeocodingResult]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.gecodingService.request(.getGeocoding(address: query)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        let geoResponse = try JSONDecoder().decode(GeocodingResponse.self, from: moyaResponse.data)
                        let decodedResponse = self.geocode(for: geoResponse)
                        completion(decodedResponse)
                    } catch {
                        Log.instance.write(error.localizedDescription)
                    }
                case let .failure(error):
                    Log.instance.write("\(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    func autocompleteAddresses(for query: String, completion: @escaping ([GeocodingResult]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.gecodingService.request(.getSuggestions(address: query)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        guard let preparedData = self.prepareAutocompleteData(data: moyaResponse.data) else {
                            return
                        }
                        let suggestResponse = try JSONDecoder().decode(AutocompleteResponse.self, from: preparedData)
                        let decodedResponse = self.geocode(for: suggestResponse)
                        completion(decodedResponse)
                    } catch {
                        Log.instance.write(error.localizedDescription)
                    }
                case let .failure(error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }

    func searchAddresses(by point: GeoPoint, completion: @escaping (GeocodingResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.gecodingService.request(.getReverseGeocoding(point: point)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        let geoResponse = try JSONDecoder().decode(GeocodingResponse.self, from: moyaResponse.data)
                        let decodedResponse: GeocodingResult = self.geocode(for: geoResponse).first ?? GeocodingResult()
                        completion(decodedResponse)
                    } catch {
                        Log.instance.write(error.localizedDescription)
                    }
                case let .failure(error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }

    private func geocode(for response: AutocompleteResponse) -> [GeocodingResult] {
        var geocodingResults = [GeocodingResult]()
        guard let results = response.results else { return geocodingResults }
        for autocompleteResult in results {
            geocodingResults.append(GeocodingResult(from: autocompleteResult))
        }
        return geocodingResults
    }

    private func geocode(for response: GeocodingResponse, language: String? = nil) -> [GeocodingResult] {
        var mostPossibleGeoPoint: CLLocationCoordinate2D?
        if let positionString = response.response?.geoObjectCollection?.metaDataProperty?.geocoderResponseMetaData?.point?.position {
            let parts = positionString.split(separator: " ")
            if parts.count == 2, let lon = Double(parts[0]), let lat = Double(parts[1]) {
                mostPossibleGeoPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        let geocodingResults = response.response?.geoObjectCollection?.featureMember?.map { geoEntity in
            var geocodinResult = GeocodingResult()
            if let mostPossibleGeoPoint = mostPossibleGeoPoint {
                geocodinResult.point = mostPossibleGeoPoint
            } else {
                if let positionString = geoEntity.geoObject?.point?.position {
                    let parts = positionString.split(separator: " ")
                    if parts.count == 2, let lon = Double(parts[0]), let lat = Double(parts[1]) {
                        geocodinResult.point = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
            }

            if let thoroughfare = getThoroughfare(for: geoEntity) {
                geocodinResult.streetName = thoroughfare.thoroughfareName
                geocodinResult.streetNumber = thoroughfare.premise?.premiseNumber
            } else {
                geocodinResult.streetName = geoEntity.geoObject?.name
            }
            geocodinResult.fullStreetAddress = geoEntity.geoObject?.name
            geocodinResult.city = geoEntity.geoObject?.metaDataProperty?.geocoderMetaData?.addressDetails?.country?.administrativeArea?.administrativeAreaName
            geocodinResult.country = geoEntity.geoObject?.metaDataProperty?.geocoderMetaData?.addressDetails?.country?.countryName
            if geocodinResult.description == nil {
                if let city = geocodinResult.city, let country = geocodinResult.country {
                    geocodinResult.description = "\(city), \(country)"
                } else {
                    if let city = geocodinResult.city {
                        geocodinResult.description = city
                    }
                    if let country = geocodinResult.country {
                        geocodinResult.description = country
                    }
                }
            }
            return geocodinResult
        } ?? [GeocodingResult]()
        return geocodingResults
    }

    private func getThoroughfare(for featureMember: FeatureMember) -> Thoroughfare? {
        if let area = featureMember.geoObject?.metaDataProperty?.geocoderMetaData?.addressDetails?.country?.administrativeArea {
            let thoroughfare = getThoroughfare(for: area)
            return thoroughfare
        } else {
            return nil
        }
    }

    private func getThoroughfare(for area: AdministrativeArea) -> Thoroughfare? {
        guard let locality = area.locality else { return nil }
        if let thoroughfare = getThoroughfare(for: locality) {
            return thoroughfare
        } else {
            return nil
        }
    }

    private func getThoroughfare(for locality: Locality) -> Thoroughfare? {
        return locality.thoroughfare
    }

    private func prepareAutocompleteData(data: Data) -> Data? {
        guard var preparedString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        preparedString = preparedString.replacingOccurrences(of: "suggest.apply(", with: "")
        preparedString.remove(at: preparedString.index(preparedString.endIndex, offsetBy: -1))
        let preparedData = Data(preparedString.utf8)
        return preparedData
    }
}
