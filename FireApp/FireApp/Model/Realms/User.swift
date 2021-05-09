//
//  User.swift
//  Topinup
//
//  Created by Zain Ali on 5/17/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    override static func primaryKey() -> String? {
        return "uid"
    }

    override static func indexedProperties() -> [String] {
        return ["uid"]
    }

    //user id
    @objc dynamic var uid = ""
    //user photo url in server
    @objc dynamic var photo = ""
    //user status
    @objc dynamic var status = ""
    @objc dynamic var phone = ""
    //user photo path in the device
    @objc dynamic var userLocalPhoto = ""

    @objc dynamic var userName = ""
    @objc dynamic var isBlocked = false
    @objc dynamic var appVer = ""
    @objc dynamic var thumbImg = ""
    @objc dynamic var isGroupBool = false
    @objc dynamic var group: Group?
    @objc dynamic var broadcast: Broadcast?
    @objc dynamic var isBroadcastBool = false
    @objc dynamic var isStoredInContacts = false
    @objc dynamic var ver = ""
    
    var properUserName:String{
        return userName.isEmpty ? phone : userName
    }

    override open func isEqual(_ object: Any?) -> Bool {
        if let user = object as? User {
            return self.uid == user.uid
        }
        return false
    }
}

