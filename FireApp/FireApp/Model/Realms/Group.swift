//
//  Group.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {


    override static func primaryKey() -> String? {
        return "groupId"
    }

    @objc dynamic var groupId = ""
    @objc dynamic var isActive = false
    @objc dynamic var createdByNumber = ""
    @objc dynamic var timestamp: CLong = 0
    @objc dynamic var subscribed = false
    
    var users = List<User>()
    var adminUids = List<String>()

    @objc dynamic var onlyAdminsCanPost = false
    @objc dynamic var currentGroupLink = ""

    public func isAdmin(adminUid: String) -> Bool {
        return adminUids.contains(adminUid)
    }

}
