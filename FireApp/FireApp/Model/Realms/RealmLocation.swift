//
//  RealmLocation.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLocation: Object {
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    @objc dynamic var address = ""
    @objc dynamic var name = ""

    convenience init(lat: Double, lng: Double, address: String, name: String) {
        self.init()
        self.lat = lat
        self.lng = lng
        self.address = address
        self.name = name
    }

    func toMap() -> [String: Any] {
        var locationMap: [String: Any] = [:]
        locationMap["lat"] = lat
        locationMap["lng"] = lng
        locationMap["address"] = address
        locationMap["name"] = name
        return locationMap
    }

}



