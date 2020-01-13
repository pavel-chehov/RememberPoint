//
//  DataBaseProtocol.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 09/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDataProvider {
    private lazy var realm: Realm = {
        try! Realm()
    }()

    func write<T: BaseRealmEntity>(data: T, update: Bool = false) throws {
        try realm.write {
            realm.add(data, update: .all)
        }
    }

    func getAll<T: BaseRealmEntity>() throws -> [T] {
        let objects = [T](realm.objects(T.self))
        return objects
    }

    func get<T: BaseRealmEntity>(by id: String) throws -> T? {
        let object: T? = realm.objects(T.self).first { $0.id == id }
        return object
    }

    func remove<T: BaseRealmEntity>(by id: String?, type: T.Type) throws {
        guard let id = id else { return }
        let object = realm.objects(T.self).first { $0.id == id }
        if let object = object {
            try realm.write {
                realm.delete(object)
            }
        }
    }
}
