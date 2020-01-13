//
//  GeolocationEntity.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 06/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import CoreLocation
import Foundation

struct GeocodingResponse: Decodable {
    let response: JsonResponse?
}

struct JsonResponse: Decodable {
    let geoObjectCollection: GeoObjectCollection?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        geoObjectCollection = try? values.decode(GeoObjectCollection.self, forKey: .geoObjectCollection)
    }

    private enum CodingKeys: String, CodingKey {
        case geoObjectCollection = "GeoObjectCollection"
    }
}

struct GeoObjectCollection: Decodable {
    let metaDataProperty: MetaDataProperty?
    let featureMember: [FeatureMember]?
}

struct MetaDataProperty: Decodable {
    let geocoderResponseMetaData: GeocoderResponseMetaData?
    let geocoderMetaData: GeocoderMetaData?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        geocoderResponseMetaData = try? values.decode(GeocoderResponseMetaData.self, forKey: .geocoderResponseMetaData)
        geocoderMetaData = try? values.decode(GeocoderMetaData.self, forKey: .geocoderMetaData)
    }

    private enum CodingKeys: String, CodingKey {
        case geocoderResponseMetaData = "GeocoderResponseMetaData"
        case geocoderMetaData = "GeocoderMetaData"
    }
}

struct GeocoderResponseMetaData: Decodable {
    let request: String?
    let suggest: String?
    let found: String?
    let results: String?
    let boundedBy: Bounded?
    let point: Point?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request = try? values.decode(String.self, forKey: .request)
        suggest = try? values.decode(String.self, forKey: .suggest)
        found = try? values.decode(String.self, forKey: .found)
        results = try? values.decode(String.self, forKey: .results)
        boundedBy = try? values.decode(Bounded.self, forKey: .boundedBy)
        point = try? values.decode(Point.self, forKey: .point)
    }

    private enum CodingKeys: String, CodingKey {
        case request, suggest, found, results, boundedBy
        case point = "Point"
    }
}

struct Bounded: Decodable {
    let envelope: Envelope?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        envelope = try? values.decode(Envelope.self, forKey: .envelope)
    }

    private enum CodingKeys: String, CodingKey {
        case envelope = "Envelope"
    }
}

struct Envelope: Decodable {
    let lowerCorner: String?
    let upperCorner: String?
}

struct FeatureMember: Decodable {
    let geoObject: GeoObject?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        geoObject = try? values.decode(GeoObject.self, forKey: .geoObject)
    }

    private enum CodingKeys: String, CodingKey {
        case geoObject = "GeoObject"
    }
}

struct GeoObject: Decodable {
    let metaDataProperty: MetaDataProperty?
    let description: String?
    let name: String?
    let boundedBy: Bounded?
    let point: Point?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        metaDataProperty = try? values.decode(MetaDataProperty.self, forKey: .metaDataProperty)
        description = try? values.decode(String.self, forKey: .description)
        name = try? values.decode(String.self, forKey: .name)
        boundedBy = try? values.decode(Bounded.self, forKey: .boundedBy)
        point = try? values.decode(Point.self, forKey: .point)
    }

    private enum CodingKeys: String, CodingKey {
        case metaDataProperty, description, name, boundedBy
        case point = "Point"
    }
}

struct GeocoderMetaData: Decodable {
    let kind: String?
    let text: String?
    let precision: String?
    let address: Address?
    let addressDetails: AddressDetails?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        kind = try? values.decode(String.self, forKey: .kind)
        text = try? values.decode(String.self, forKey: .text)
        precision = try? values.decode(String.self, forKey: .precision)
        address = try? values.decode(Address.self, forKey: .address)
        addressDetails = try? values.decode(AddressDetails.self, forKey: .addressDetails)
    }

    private enum CodingKeys: String, CodingKey {
        case kind, text, precision
        case address = "Address"
        case addressDetails = "AddressDetails"
    }
}

struct Address: Decodable {
    let countryCode: String?
    let formatted: String?
    let components: [Component]?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countryCode = try? values.decode(String.self, forKey: .countryCode)
        formatted = try? values.decode(String.self, forKey: .formatted)
        components = try? values.decode([Component].self, forKey: .components)
    }

    private enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case formatted
        case components = "Components"
    }
}

struct Component: Decodable {
    let kind: String?
    let name: String?
}

struct AddressDetails: Decodable {
    let country: Country!

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        country = try? values.decode(Country.self, forKey: .country)
    }

    private enum CodingKeys: String, CodingKey {
        case country = "Country"
    }
}

struct Country: Decodable {
    let addressLine: String?
    let countryNameCode: String?
    let countryName: String?
    let administrativeArea: AdministrativeArea?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        addressLine = try? values.decode(String.self, forKey: .addressLine)
        countryNameCode = try? values.decode(String.self, forKey: .countryNameCode)
        countryName = try? values.decode(String.self, forKey: .countryName)
        administrativeArea = try? values.decode(AdministrativeArea.self, forKey: .administrativeArea)
    }

    private enum CodingKeys: String, CodingKey {
        case addressLine = "AddressLine"
        case countryNameCode = "CountryNameCode"
        case countryName = "CountryName"
        case administrativeArea = "AdministrativeArea"
    }
}

struct AdministrativeArea: Decodable {
    let administrativeAreaName: String?
    let locality: Locality?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        administrativeAreaName = try? values.decode(String.self, forKey: .administrativeAreaName)
        locality = try? values.decode(Locality.self, forKey: .locality)
    }

    private enum CodingKeys: String, CodingKey {
        case administrativeAreaName = "AdministrativeAreaName"
        case locality = "Locality"
    }
}

struct Locality: Decodable {
    let localityName: String?
    let thoroughfare: Thoroughfare?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        localityName = try? values.decode(String.self, forKey: .localityName)
        thoroughfare = try? values.decode(Thoroughfare.self, forKey: .thoroughfare)
    }

    private enum CodingKeys: String, CodingKey {
        case localityName = "LocalityName"
        case thoroughfare = "Thoroughfare"
    }
}

struct Thoroughfare: Decodable {
    let thoroughfareName: String?
    let premise: Premise?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        thoroughfareName = try? values.decode(String.self, forKey: .thoroughfareName)
        premise = try? values.decode(Premise.self, forKey: .premise)
    }

    private enum CodingKeys: String, CodingKey {
        case thoroughfareName = "ThoroughfareName"
        case premise = "Premise"
    }
}

struct Premise: Decodable {
    var premiseNumber: String?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        premiseNumber = try? values.decode(String.self, forKey: .premiseNumber)
    }

    private enum CodingKeys: String, CodingKey {
        case premiseNumber = "PremiseNumber"
    }
}

struct Point: Decodable {
    let position: String?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        position = try? values.decode(String.self, forKey: .position)
    }

    private enum CodingKeys: String, CodingKey {
        case position = "pos"
    }
}

struct GeocodingResult {
    var point: CLLocationCoordinate2D?
    var fullStreetAddress: String?
    var streetName: String?
    var streetNumber: String?
    var unit: String?
    var locality: String?
    var city: String?
    var country: String?
    var description: String?
    var type: String?

    init() {}

    init(from autocompleteResult: AutocompleteResult) {
        if let latitude = autocompleteResult.latitude, let longitude = autocompleteResult.longitude {
            point = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        description = autocompleteResult.description
        fullStreetAddress = autocompleteResult.address
        type = autocompleteResult.type
        streetName = autocompleteResult.address
    }

    var addressFound: Bool {
        return point != nil && !(streetName?.isEmpty ?? true)
    }
}

struct AutocompleteResponse: Decodable {
    var request: String?
    var results: [AutocompleteResult]?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request = try? values.decode(String.self, forKey: .request)
        results = try? values.decode([AutocompleteResult].self, forKey: .results)
    }

    private enum CodingKeys: String, CodingKey {
        case request = "part"
        case results
    }
}

struct AutocompleteResult: Decodable {
    var address: String?
    var type: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try? values.decode(String.self, forKey: .address)
        type = try? values.decode(String.self, forKey: .type)
        description = try? values.decode(String.self, forKey: .description)
        latitude = try? values.decode(Double.self, forKey: .latitude)
        longitude = try? values.decode(Double.self, forKey: .longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case address = "name"
        case description = "desc"
        case latitude = "lat"
        case longitude = "lon"
        case type
    }
}
