//
//  Broadcast.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift

class Broadcast: Object {
    override static func primaryKey() -> String? {
        return "broadcastId"
    }
    
    @objc dynamic var broadcastId=""
    @objc dynamic var createdByNumber=""
    @objc dynamic var timestamp:CLong = 0
    var users = List<User>()
    

}
